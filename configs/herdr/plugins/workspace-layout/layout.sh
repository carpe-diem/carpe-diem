#!/bin/bash
# Builds the standard tab set in a Herdr workspace, all rooted at its cwd:
#   IA (agent picker + reviewr) | Services (2x2 shells) | Git (lazygit) | Code (nvim) | Console
# Linked git worktrees get only IA + Console.
# Only touches a workspace that is still a single pane, so it never clobbers
# a layout you already arranged (or one restored after a server restart).
set -euo pipefail

HERDR="${HERDR_BIN_PATH:-herdr}"
JQ=/usr/bin/jq
command -v "$JQ" >/dev/null || JQ=jq

ctx="${HERDR_PLUGIN_CONTEXT_JSON:-{\}}"
ws="${HERDR_WORKSPACE_ID:-$("$JQ" -r '.workspace_id // empty' <<<"$ctx")}"
[ -n "$ws" ] || { echo "no workspace in context" >&2; exit 0; }

ws_json=$("$HERDR" workspace get "$ws")
pane_count=$("$JQ" -r '.result.workspace.pane_count' <<<"$ws_json")
if [ "$pane_count" != 1 ]; then
  echo "workspace $ws already has $pane_count panes; leaving it alone"
  exit 0
fi

root_tab=$("$JQ" -r '.result.workspace.active_tab_id' <<<"$ws_json")
root_pane=$("$HERDR" pane list --workspace "$ws" | "$JQ" -r '.result.panes[0].pane_id')
cwd=$("$JQ" -r '.workspace_cwd // .focused_pane_cwd // empty' <<<"$ctx")
[ -n "$cwd" ] || cwd=$("$HERDR" pane get "$root_pane" | "$JQ" -r '.result.pane.cwd')

new_tab() { # label -> prints root pane id
  "$HERDR" tab create --workspace "$ws" --cwd "$cwd" --label "$1" --no-focus \
    | "$JQ" -r '.result.root_pane.pane_id'
}
split() { # pane direction -> prints new pane id
  "$HERDR" pane split "$1" --direction "$2" --cwd "$cwd" --no-focus \
    | "$JQ" -r '.result.pane.pane_id'
}

# IA: reuse the workspace's initial tab, with reviewr's diff pane on the right.
# Opened as reviewr's own plugin pane (not `herdr-reviewr` in a plain split) so
# its toggle (cmd+r) recognizes it and the binary resolves inside the plugin dir
"$HERDR" tab rename "$root_tab" IA >/dev/null
# pick-agent.sh asks which agent to start (claude, pi, ...; enter = claude)
picker="$HOME/.config/herdr/scripts/pick-agent.sh"
if [ -x "$picker" ]; then
  "$HERDR" pane run "$root_pane" "$picker" >/dev/null
else
  "$HERDR" pane run "$root_pane" claude >/dev/null
fi
# (reviewr's auto_open is off in its config, but skip if one is there anyway)
if ! "$HERDR" pane list --workspace "$ws" | "$JQ" -e '.result.panes[] | select(.label == "reviewr")' >/dev/null; then
  "$HERDR" plugin pane open --plugin persiyanov.reviewr --entrypoint pane --placement split \
    --target-pane "$root_pane" --direction right --cwd "$cwd" --no-focus >/dev/null \
    || echo "reviewr not available, IA tab has claude only" >&2
fi

# Worktree workspaces are short-lived side branches: just IA + Console
is_worktree=$("$JQ" -r '.result.workspace.worktree.is_linked_worktree // false' <<<"$ws_json")

if [ "$is_worktree" != true ]; then
  # Services: 2x2 grid of shells
  top_left=$(new_tab Services)
  top_right=$(split "$top_left" right)
  split "$top_left" down >/dev/null
  split "$top_right" down >/dev/null

  git_pane=$(new_tab Git)
  "$HERDR" pane run "$git_pane" lazygit >/dev/null

  code_pane=$(new_tab Code)
  "$HERDR" pane run "$code_pane" nvim >/dev/null
fi

new_tab Console >/dev/null

"$HERDR" tab focus "$root_tab" >/dev/null
echo "layout applied to $ws ($cwd)$([ "$is_worktree" = true ] && echo ', worktree')"
