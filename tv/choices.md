# Choices

The answers to CleanYourTV's checklist, so the agent doesn't ask them again. Only ask about what is
not covered here, then add the answer to this file.

## Always disabled

Everything in the CleanYourTV `examples/` list for the model, except what "Keep" below names. That
list already covers manufacturer telemetry, ad and recommendation services, the stock launcher's
recommendation plumbing, preloaded apps and the factory test app that claims Home.

On top of it:

| Package | Why |
|---|---|
| `com.mitv.tvhome.mitvplus` | Mi TV+ free channels: not used |
| `com.google.android.youtube.tvmusic` | YouTube Music: not used |
| `com.xiaomi.mitv.mediaexplorer`, `com.mitv.videoplayer` | Xiaomi's USB players: not used |
| `com.mitv.milinkservice`, `com.xiaomi.mitv.smartshare` | Mi Cast / SmartShare: Chromecast covers phone casting |
| `com.google.android.videos` | Play Movies & TV: not used |
| `com.xiaomi.mitv.manualhelp`, `com.xiaomi.mitv.handbook` | On-screen manual |
| `com.google.android.backdrop`, `com.mitv.dream` | Stock screensavers. Only **after** the launcher is in: first `settings put secure screensaver_components com.gathin.tvhome/.ClockDream` |

## Keep

| What | Package(s) | Why |
|---|---|---|
| Voice assistant | `com.google.android.katniss`, `com.google.android.tv.assistant` | The mic button is used |
| Chromecast | `com.google.android.apps.mediashell` | "Cast" from phones |
| Miracast | `com.xiaomi.wfdsinkhelperservice` | Windows' wireless projection (Win+K). An HDMI cable needs nothing |
| Firmware updates | `com.xiaomi.mitv.updateservice` | Security patches; run `tools/check.py` after one |
| Netflix, Prime Video | `com.netflix.ninja`, `com.amazon.amazonvideo.livingroom` | Used |
| YouTube (official) | `com.google.android.youtube.tv` | Fallback when SmartTube breaks |
| Play Store and Play Services | | Always |

## Home screen

- CleanYourTV's launcher, built from upstream unchanged, with `INPUT_KEY_SERVICE=1`.
- Config in [`theme/config.json`](./theme/config.json), pushed with `tools/theme.sh`: dock SmartTube,
  Netflix, Disney+, Prime Video; the Mi button (keycode 192) goes Home; Input (130) opens Inputs.
- Clock screensaver (`com.gathin.tvhome/.ClockDream`).
- System language: English (United States).

## Optional extras, ask first

- Ad-blocking Private DNS: skipped so far. NordVPN runs on the TVs, and Private DNS doesn't block
  YouTube ads anyway.
- Channel shortcuts: pinned to SmartTube's sidebar by hand (open a channel, hold OK, "Pin to sidebar").
  Home tiles for channels would need a module-card add-on.
