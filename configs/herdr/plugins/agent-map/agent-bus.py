#!/usr/bin/env python3
"""Agent bus: logs `herdr agent prompt` calls between agents and shows them live.

  agent-bus.py claude-hook       Claude Code PreToolUse/PostToolUse hook (JSON on stdin)
  agent-bus.py record '<json>'   {"phase": "sent"|"returned", "id", "command", "exit"?} (pi extension)
  agent-bus.py map               live view of agents and the messages between them (q quits)

Messages are appended to ~/.local/state/carpe-diem/agent-bus.jsonl. Hooks never
fail or print: a logging problem must not get in the way of the agent.
"""

import json
import os
import select
import shlex
import shutil
import subprocess
import sys
import termios
import time
import tty

LOG = os.path.expanduser("~/.local/state/carpe-diem/agent-bus.jsonl")
HERDR = os.environ.get("HERDR_BIN_PATH") or shutil.which("herdr") or "herdr"
VALUE_FLAGS = {"--timeout", "--until"}


def herdr(*args):
    try:
        out = subprocess.run([HERDR, *args], capture_output=True, text=True, timeout=5)
        return json.loads(out.stdout).get("result", {}) if out.returncode == 0 else {}
    except Exception:
        return {}


# --- recording ---------------------------------------------------------------


def parse_prompt(command):
    """Find `herdr agent prompt <target> <text> [flags]` in a shell command."""
    if "agent" not in command or "prompt" not in command:
        return None
    try:
        words = shlex.split(command, posix=True)
    except ValueError:
        return None
    for i in range(len(words) - 2):
        if os.path.basename(words[i]) == "herdr" and words[i + 1 : i + 3] == ["agent", "prompt"]:
            args, wait, rest = [], False, iter(words[i + 3 :])
            for w in rest:
                if w in ("&&", "||", ";", "|"):
                    break
                if w == "--wait":
                    wait = True
                elif w in VALUE_FLAGS:
                    next(rest, None)
                elif not w.startswith("--"):
                    args.append(w)
            if args:
                return {"to": args[0], "text": " ".join(args[1:]), "wait": wait}
    return None


def agent_label(target):
    """Name if the agent has one, else `<workspace label>:<pane>`."""
    agent = herdr("agent", "get", target).get("agent", {})
    if not agent:
        return target, target
    pane = agent.get("pane_id", target)
    if agent.get("name"):
        return agent["name"], pane
    ws = herdr("workspace", "get", agent.get("workspace_id", "")).get("workspace", {})
    return f"{ws.get('label', agent.get('workspace_id', '?'))}:{pane.split(':')[-1]}", pane


def append(entry):
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    with open(LOG, "a") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def record(phase, call_id, command, exit_code=None):
    msg = parse_prompt(command or "")
    if not msg:
        return
    entry = {"t": time.time(), "phase": phase, "id": call_id}
    if phase == "sent":
        me = os.environ.get("HERDR_PANE_ID", "")
        entry["from"], entry["from_pane"] = agent_label(me) if me else ("?", "")
        entry["to"], entry["to_pane"] = agent_label(msg["to"])
        entry.update(text=msg["text"], wait=msg["wait"])
    else:
        entry["exit"] = exit_code
    append(entry)


def claude_hook():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    command = (data.get("tool_input") or {}).get("command", "")
    if data.get("hook_event_name") == "PreToolUse":
        record("sent", data.get("tool_use_id"), command)
    else:
        resp = data.get("tool_response") or {}
        failed = data.get("hook_event_name") == "PostToolUseFailure" or resp.get("interrupted")
        record("returned", data.get("tool_use_id"), command, 1 if failed else 0)


# --- live map ----------------------------------------------------------------

DIM, BOLD, RESET = "\033[2m", "\033[1m", "\033[0m"
COLORS = {"working": "\033[33m", "blocked": "\033[31m", "idle": "\033[32m", "done": "\033[32m"}
ICONS = {"working": "●", "blocked": "■", "idle": "○", "done": "✓"}


def ago(seconds):
    s = int(seconds)
    return f"{s}s" if s < 60 else f"{s // 60}m" if s < 3600 else f"{s // 3600}h"


def load_messages(limit=200):
    try:
        with open(LOG) as f:
            lines = f.readlines()[-limit * 2 :]
    except FileNotFoundError:
        return []
    sent, returned = {}, {}
    for line in lines:
        try:
            e = json.loads(line)
        except ValueError:
            continue
        (sent if e.get("phase") == "sent" else returned)[e.get("id")] = e
    msgs = list(sent.values())
    for m in msgs:
        m["returned"] = returned.get(m.get("id"))
    return sorted(msgs, key=lambda m: m["t"], reverse=True)


def fit(text, width):
    text = " ".join(text.split())
    return text if len(text) <= width else text[: max(0, width - 1)] + "…"


def render():
    cols, rows = shutil.get_terminal_size((100, 30))
    agents = herdr("agent", "list").get("agents", [])
    workspaces = {w["workspace_id"]: w.get("label", "") for w in herdr("workspace", "list").get("workspaces", [])}
    status_by_pane = {a["pane_id"]: a.get("agent_status", "unknown") for a in agents}
    out = [f"{BOLD} Agent map{RESET}{DIM}  ·  q to close{RESET}".ljust(cols - 8) + time.strftime("%H:%M:%S"), ""]

    out.append(f"{BOLD} AGENTS{RESET}")
    for a in sorted(agents, key=lambda a: (workspaces.get(a["workspace_id"], ""), a["pane_id"])):
        st = a.get("agent_status", "unknown")
        name = a.get("name") or "-"
        where = f"{workspaces.get(a['workspace_id'], a['workspace_id'])} · {a['pane_id']}"
        line = f" {COLORS.get(st, '')}{ICONS.get(st, '?')}{RESET} {BOLD}{name:<12}{RESET} {a.get('agent', '?'):<8} {COLORS.get(st, '')}{st:<8}{RESET} {DIM}{where}{RESET}"
        out.append(line)
    if not agents:
        out.append(f"{DIM}   no agents running{RESET}")

    out += ["", f"{BOLD} MESSAGES{RESET}{DIM}  (newest first){RESET}"]
    now = time.time()
    msgs = load_messages()
    for m in msgs[: max(0, rows - len(out) - 1)]:
        ret = m.get("returned")
        if ret:
            mark = f"\033[31m✗{RESET}" if ret.get("exit") else f"\033[32m✓{RESET}"
            state = f"{mark} {ago(ret['t'] - m['t'])}"
        elif m.get("wait"):
            state = f"\033[33m⏳{RESET} {ago(now - m['t'])}"
        else:
            st = status_by_pane.get(m.get("to_pane"), "gone")
            state = f"{COLORS.get(st, DIM)}→ {st}{RESET}"
        head = f" {time.strftime('%H:%M', time.localtime(m['t']))}  {m['from']} → {BOLD}{m['to']}{RESET}"
        plain_len = len(f" HH:MM  {m['from']} → {m['to']}") + 12
        out.append(f"{head}  {state}  {DIM}{fit(m.get('text', ''), cols - plain_len - 4)}{RESET}")
    if not msgs:
        out.append(f"{DIM}   nothing yet — agents talk with `herdr agent prompt <name> \"...\"`{RESET}")

    sys.stdout.write("\033[H\033[2J" + "\n".join(out[:rows]))
    sys.stdout.flush()


def live_map():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    sys.stdout.write("\033[?25l")
    try:
        tty.setcbreak(fd)
        while True:
            render()
            ready, _, _ = select.select([sys.stdin], [], [], 1.0)
            if ready and sys.stdin.read(1) in ("q", "Q", "\x1b"):
                break
    except KeyboardInterrupt:
        pass
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        sys.stdout.write("\033[?25h\033[H\033[2J")


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "map"
    if cmd == "map":
        return live_map()
    try:
        if cmd == "claude-hook":
            claude_hook()
        elif cmd == "record":
            d = json.loads(sys.argv[2])
            record(d.get("phase"), d.get("id"), d.get("command"), d.get("exit"))
    except Exception:
        pass  # never get in the agent's way


if __name__ == "__main__":
    main()
