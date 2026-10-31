#!/bin/bash
# Asks which coding agent to start in this pane, then execs it.
# The workspace-layout plugin runs it in the IA tab of new workspaces.
# Enter starts the first one (claude); `s` leaves a plain shell.
set -u

agents=()
for a in claude pi pilot codex opencode; do
  command -v "$a" >/dev/null && agents+=("$a")
done

[ ${#agents[@]} -eq 0 ] && { echo "no coding agent installed"; exit 0; }
[ ${#agents[@]} -eq 1 ] && exec "${agents[0]}"

printf '\n  Start which agent?\n\n'
for i in "${!agents[@]}"; do
  printf '   %d) %s%s\n' $((i + 1)) "${agents[$i]}" "$([ "$i" = 0 ] && echo '  (enter)')"
done
printf '   s) shell\n\n  > '

while true; do
  IFS= read -rsn1 key
  case "$key" in
    "") exec "${agents[0]}" ;;
    s|S) echo; exit 0 ;;
    [1-9])
      if [ "$key" -le ${#agents[@]} ]; then
        echo "${agents[$((key - 1))]}"
        exec "${agents[$((key - 1))]}"
      fi
      ;;
  esac
done
