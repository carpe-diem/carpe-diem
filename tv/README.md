# TV

My Android TV setup: no Xiaomi/Google ads or telemetry, an Apple TV-style home, SmartTube instead of
YouTube's ads, the remote's buttons working on the new home. Built on
[CleanYourTV](https://github.com/Gathin23/cleanyourtv), which owns the tools, the launcher and the
per-model debloat lists; this folder only holds **my** choices and what I learned on my TVs.

| File | What it is |
|---|---|
| [`PROMPT.md`](./PROMPT.md) | What the `tv-setup` skill does, step by step. Paste it into an agent that has no skill |
| [`choices.md`](./choices.md) | What stays and what goes on every TV, and why |
| [`apps.md`](./apps.md) | Apps to install (and where from), apps to remove |
| [`theme/config.json`](./theme/config.json) | My launcher config, pushed as a CleanYourTV theme: dock, remote buttons, volume |
| [`devices/`](./devices) | What each TV model needed beyond CleanYourTV's own list |
| [`LEARNINGS.md`](./LEARNINGS.md) | Mac-side problems hit while doing it, and their fixes |
| [`skill/SKILL.md`](./skill/SKILL.md) | The `tv-setup` skill; `../update.sh` installs it for Claude Code and pi |

## Use

In Claude Code (or pi), with the TV on the same network and USB debugging on:

> set up this TV

The skill finds the TV, follows CleanYourTV's procedure with these choices, asks only about what is
not decided here, and at the end proposes updates to this folder (a new model, a new app, a new
fix). Nothing is committed without my OK.

## Never in this folder

This repo is public. No IPs, MAC addresses, serial numbers, Wi-Fi names, account names or backups.
Per-TV backups, screenshots and applied lists stay in the CleanYourTV checkout
(`~/src/cleanyourtv/backup/`, `shots/`, `work/`), which that repo already ignores.

## Undo

Everything is disabled, not uninstalled. From the CleanYourTV checkout, with ADB connected:
`tools/restore.sh <the list applied to that TV>` brings the apps and the stock launcher back, and
`tools/theme.sh --reset` drops the theme.
