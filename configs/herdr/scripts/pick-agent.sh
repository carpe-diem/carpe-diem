#!/bin/bash
# Asks which coding agent to start in this pane, then execs it.
# The workspace-layout plugin runs it in the IA tab of new workspaces.
# Enter starts the first one (claude); `s` leaves a plain shell.
#
# Agents are the known CLIs found on PATH, plus machine-specific ones from
# ~/.config/herdr/agents.local (not in the repo), one `name=command` per line:
#   pilot=PILOT_ENV=local node ~/work/pilot/bin/pilot.mjs
#
# In the pilot repo (or a worktree of it: bin/pilot.mjs at the git root) it
# also offers "pilot qa" and "pilot prod": `npm ci`, then pilot against that
# gateway here, plus `node bin/pilot.mjs --gateway=<gw> web` in a pane on the
# right, 1/4 of the tab wide.
set -u

HERDR="${HERDR_BIN_PATH:-herdr}"
JQ=/usr/bin/jq
command -v "$JQ" >/dev/null || JQ=jq
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# pick-agent.sh --pilot <gateway>
if [ "${1:-}" = --pilot ]; then
  gw="$2"
  cd "$root" || exit 1
  npm ci || { echo "npm ci failed, not starting pilot"; exit 1; }
  if [ -n "${HERDR_PANE_ID:-}" ]; then
    # ratio = share this pane keeps, so the new one is 1/4 of the tab width
    ratio=$("$HERDR" pane layout --pane "$HERDR_PANE_ID" | "$JQ" -r --arg p "$HERDR_PANE_ID" '
      .result.layout as $l | ($l.panes[] | select(.pane_id == $p).rect.width) as $w
      | [1 - $l.area.width / 4 / $w, 0.3] | max')
    web=$("$HERDR" pane split "$HERDR_PANE_ID" --direction right --ratio "$ratio" --cwd "$root" --no-focus \
      | "$JQ" -r '.result.pane.pane_id')
    "$HERDR" pane rename "$web" "pilot web $gw" >/dev/null
    # give pilot a head start before the web UI
    "$HERDR" pane run "$web" "sleep 3; node bin/pilot.mjs --gateway=$gw web" >/dev/null
  fi
  if command -v pilot >/dev/null; then
    exec pilot --gateway="$gw"
  fi
  exec node bin/pilot.mjs --gateway="$gw"
fi

names=() cmds=()
for a in claude pi codex opencode; do
  command -v "$a" >/dev/null && { names+=("$a"); cmds+=("$a"); }
done

if [ -f "$root/bin/pilot.mjs" ]; then
  for gw in qa prod; do names+=("pilot $gw"); cmds+=("'$0' --pilot $gw"); done
fi

local_agents="$HOME/.config/herdr/agents.local"
if [ -f "$local_agents" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ""|\#*) continue ;; esac
    names+=("${line%%=*}")
    cmds+=("${line#*=}")
  done <"$local_agents"
fi

start() { exec bash -c "${cmds[$1]}"; }

[ ${#names[@]} -eq 0 ] && { echo "no coding agent found"; exit 0; }
[ ${#names[@]} -eq 1 ] && start 0

printf '\n  Start which agent?\n\n'
for i in "${!names[@]}"; do
  printf '   %d) %s%s\n' $((i + 1)) "${names[$i]}" "$([ "$i" = 0 ] && echo '  (enter)')"
done
printf '   s) shell\n\n  > '

while true; do
  IFS= read -rsn1 key
  case "$key" in
    "") start 0 ;;
    s|S) echo; exit 0 ;;
    [1-9])
      if [ "$key" -le ${#names[@]} ]; then
        echo "${names[$((key - 1))]}"
        start $((key - 1))
      fi
      ;;
  esac
done
