# Set up an Android TV

The procedure the `tv-setup` skill follows. Without the skill, paste everything below the line into
Claude Code (or another agent with a shell) and replace `<TV_DIR>` with this folder's path.

---

Set up the Android TV on my network the way my other TVs are: debloated, CleanYourTV's launcher with
my theme, SmartTube and my apps. My choices are in `<TV_DIR>`: read `choices.md`, `apps.md`,
`theme/config.json`, `LEARNINGS.md` and the matching file in `devices/` before starting.

**CleanYourTV's `PROMPT.md` is the procedure and its safety rules win over anything here.** This
file only adds my defaults and what I learned.

1. **Get CleanYourTV.** Clone https://github.com/Gathin23/cleanyourtv to `~/src/cleanyourtv`, or
   `git pull --ff-only` if it is there. Read its `PROMPT.md` and `AGENTS.md`. Never edit its
   tracked files; my config goes in as a theme. Make the venv if missing
   (`python3 -m venv tools/venv && tools/venv/bin/pip install -r tools/requirements.txt`).
2. **Find and connect.** Look for TVs on the LAN (ARP table; port 5555 open, or Cast on 8008, whose
   `/ssdp/device-desc.xml` gives the friendly name and model). If adb says "No route to host" while
   the port is open, ask me to start the relay from `LEARNINGS.md` in my own terminal, one per TV on
   its own port, and use `TV_ADB_BINARY=$(which adb) TV_HOST=127.0.0.1:<port>`. Tell me when the
   "Allow USB debugging?" prompt is coming, and to tick "Always allow".
3. **Back up** into `~/src/cleanyourtv/backup/<model>-<date>/` (package list, disabled list, third-party
   list, getprop, the three settings namespaces, Home, `wm size`/`wm density`).
4. **Compare.** Match the model and firmware against CleanYourTV's `examples/` and my `devices/`.
   List installed packages against that list plus `choices.md`. If I have done this model before,
   diff the package list against what my `devices/` file says, and show me **only the differences**:
   apps this TV has that the others didn't, and third-party apps I installed. Ask about those, with
   a recommendation each; everything `choices.md` already decides needs no question.
5. **Debloat** with `tools/disable.sh`, in batches of about five, with a screenshot after each
   (`tools/tv.py --screenshot`). Lists go in `~/src/cleanyourtv/work/<model>-<n>/`. Factory-test Home
   claimants go before the launcher. Leave the stock screensavers for step 7.
6. **Launcher.** `INPUT_KEY_SERVICE=1 launcher/build-and-install.sh` (upstream source, unchanged), then
   `tools/theme.sh <TV_DIR>/theme`. If the APK is already built for another TV this session,
   `SKIP_BUILD=1`. Confirm Home with `dumpsys activity activities | grep ResumedActivity`.
7. **Screensaver**: `settings put secure screensaver_components com.gathin.tvhome/.ClockDream`, then
   disable the stock screensavers named in `choices.md`.
8. **Apps** from `apps.md`: install what is missing, uninstall what it says to remove.
9. **Reboot and check**: same disabled list, Home is the launcher, the key helper is still enabled.
10. **The real remote.** Ask me to press each button listed in my `devices/` file for the model (or,
    for a new model: Home/Mi, Input, arrows and OK, mic, app buttons, and holding volume), with
    `getevent -lt` recording when a button misbehaves. Injected keys prove nothing here. Also have
    me seek with Left/Right inside a SmartTube video: some key-helper options break it. To tell the
    helper from the app, switch the helper off for one try (`settings put secure
    enabled_accessibility_services ''`, then put back what it was).
11. **Close ADB** when I say we're done, as CleanYourTV's `PROMPT.md` describes: I revoke the
    authorisations and switch USB debugging off; you check the port with `nc -vz <tv-ip> 5555`
    ("Connection refused" is the only proof) after I power-cycle the TV. Then tell me to stop the relays.
12. **Update `<TV_DIR>`.** Propose the changes the session taught: a new `devices/` file or rows in
    it, new answers in `choices.md`, apps in `apps.md`, keys in `theme/config.json`, fixes in
    `LEARNINGS.md`. Show me the diff and commit only after I say so. The repo is public: no IPs,
    MACs, serials, Wi-Fi or account names, and no backups.
