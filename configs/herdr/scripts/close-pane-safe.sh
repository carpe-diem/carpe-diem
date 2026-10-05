#!/bin/bash
# cmd+w guard: close the focused Herdr pane, but if a live agent session
# (e.g. a Claude instance) is detected in it, warn instead and require
# a second cmd+w within 10 seconds to actually close.
set -euo pipefail

HERDR=/opt/homebrew/bin/herdr
JQ=/usr/bin/jq
CONFIRM_WINDOW_SECS=10
STATE_DIR="${TMPDIR:-/tmp}/herdr-close-guard"
mkdir -p "$STATE_DIR"

pane_json=$("$HERDR" pane current --current)
pane_id=$("$JQ" -r '.result.pane.pane_id // empty' <<<"$pane_json")
agent=$("$JQ" -r '.result.pane.agent // empty' <<<"$pane_json")
status=$("$JQ" -r '.result.pane.agent_status // "none"' <<<"$pane_json")

[ -n "$pane_id" ] || exit 0

if [ -z "$agent" ]; then
  exec "$HERDR" pane close "$pane_id"
fi

stamp="$STATE_DIR/${pane_id//:/_}"
now=$(date +%s)
if [ -f "$stamp" ] && [ $((now - $(cat "$stamp"))) -le "$CONFIRM_WINDOW_SECS" ]; then
  rm -f "$stamp"
  exec "$HERDR" pane close "$pane_id"
fi

echo "$now" > "$stamp"
"$HERDR" notification show "${agent} session (${status}) in this pane" \
  --body "Press cmd+w again within ${CONFIRM_WINDOW_SECS}s to close it anyway" \
  --sound request
