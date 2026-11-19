# Learnings

Mac-side problems hit while setting up TVs, newest last. Add to it when something new comes up.

## ADB can't reach the TV: "No route to host"

macOS Local Network privacy blocks non-Apple binaries (adb, node, python) started from the agent's
session, while system binaries like `nc` still connect. Granting the terminal app Local Network access
did not help when the agent runs under a background `claude` process.

Fix that worked: a relay the person starts in their own terminal (the agent may not start it itself),
one per TV, on its own local port:

```bash
mkfifo /tmp/adbf; while true; do nc -l 127.0.0.1 6555 </tmp/adbf | nc <tv-ip> 5555 >/tmp/adbf; done
```

Then `adb connect 127.0.0.1:6555`, and point CleanYourTV's tools at that transport with
`TV_ADB_BINARY=$(which adb) TV_HOST=127.0.0.1:6555`. The relay takes one connection at a time: keep a
single adb server and don't probe the port with `nc -z` (it eats the listener).
CleanYourTV's own `tools/relay.py` does the same in Python, if the venv's Python is allowed out.

## Gradle times out downloading itself

`java` had no network at all (every TCP connect timed out) while `curl` worked: **LuLu** was blocking
Homebrew's `openjdk@17`. Allow `java` in LuLu, at least while building. Check quickly with a
four-line Java socket test before blaming Gradle.

## Docker build: "no space left on device"

`tools/docker-build.sh` is the fallback when there is no JDK, but Docker Desktop's disk was full.
`docker system df` shows it; `docker builder prune` frees the build cache. Ask before pruning.

## The TV says "unauthorized" after a reboot

The first authorisation was accepted without "Always allow from this computer". Reconnect
(`adb disconnect`/`connect`) to show the prompt again and tick the box.

## Commands that hang through the relay

A `reboot` + reconnect loop hung past its timeout once while the TV had in fact rebooted. Wrap each
adb call in `timeout`, and check `/proc/uptime` instead of trusting the loop.
