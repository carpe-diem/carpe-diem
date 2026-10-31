#!/bin/bash
# Asks which coding agent to start in this pane, then execs it.
# The workspace-layout plugin runs it in the IA tab of new workspaces.
# Enter starts the first one (claude); `s` leaves a plain shell.
#
# Agents are the known CLIs found on PATH, plus machine-specific ones from
# ~/.config/herdr/agents.local (not in the repo), one `name=command` per line:
#   pilot=PILOT_ENV=local node ~/work/pilot/bin/pilot.mjs
set -u

names=() cmds=()
for a in claude pi codex opencode; do
  command -v "$a" >/dev/null && { names+=("$a"); cmds+=("$a"); }
done

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
