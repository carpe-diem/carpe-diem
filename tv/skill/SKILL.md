---
name: tv-setup
description: Set up, clean up or re-check an Android TV / Google TV at home the way the other TVs are (CleanYourTV debloat and launcher, my theme, SmartTube, my apps), and keep the TV notes in carpe-diem up to date. Use when the user asks to set up, debloat, fix or update a TV, add a TV app, change the TV home screen or remote buttons, or after a TV firmware update.
---

# TV setup

My TV choices and notes live in `__TV_DIR__` (the `tv/` folder of the carpe-diem repo). Treat its
files as my decisions, and CleanYourTV's `PROMPT.md` as the procedure and the safety rules.

1. Read `__TV_DIR__/PROMPT.md` and follow it, with `<TV_DIR>` meaning `__TV_DIR__`.
2. For a smaller job (one app, one button, a check after a firmware update), do only the steps it
   needs, but still read `choices.md`, `LEARNINGS.md` and the model's `devices/` file first.
3. Always finish with step 12 of `PROMPT.md`: propose updates to `__TV_DIR__` from what the session
   showed, show the diff, and commit only with my OK. If `__TV_DIR__` has uncommitted changes or is on
   another branch, say so before editing.

If `__TV_DIR__` does not exist, the repo moved: ask where carpe-diem is, and re-run its `tv/install-skill.sh`.
