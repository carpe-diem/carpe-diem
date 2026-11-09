#!/bin/bash
# Opens the agent map overlay in the current tab, or closes it if it's open.
set -euo pipefail

HERDR="${HERDR_BIN_PATH:-herdr}"
JQ=/usr/bin/jq
command -v "$JQ" >/dev/null || JQ=jq

ws="${HERDR_WORKSPACE_ID:-}"
open=$("$HERDR" pane list ${ws:+--workspace "$ws"} \
  | "$JQ" -r '.result.panes[] | select(.label == "agent map") | .pane_id' | head -1)

if [ -n "$open" ]; then
  "$HERDR" plugin pane close "$open" >/dev/null
else
  "$HERDR" plugin pane open --plugin carpe-diem.agent-map --entrypoint map \
    --placement overlay ${ws:+--workspace "$ws"} --focus >/dev/null
fi
