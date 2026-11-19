# Apps

## Install

| App | Package | From | Notes |
|---|---|---|---|
| SmartTube | `org.smarttube.stable` | [GitHub releases](https://github.com/yuliskov/SmartTube/releases/latest), the `_stable_` APK for the TV's ABI (`getprop ro.product.cpu.abi`: `armeabi-v7a` on the MOOQ0) | YouTube without ads, SponsorBlock. Check the signer before installing: `apksigner verify --print-certs` must say `CN=Yurii L, O=SmartTube` |
| NordVPN | `com.nordvpn.android` | Google Play (open its page: `am start -a android.intent.action.VIEW -d market://details?id=com.nordvpn.android`) | The person signs in on the TV; never ask for the credentials. Suggest split tunnelling for local streaming |

`adb install -r <apk>` works on Android 10 and 11. On Android 14, push the APK and `pm install -r` it
from the shell (CleanYourTV `PROMPT.md`).

## Remove

User-installed apps that are not wanted, uninstalled with `adb uninstall` (never a system package:
those are disabled):

| App | Package |
|---|---|
| PLAYMAD | `org.madrid.cmtv` |

## Never install

Pirate streaming apps (OnStream and the like): unlicensed content, APKs from unverifiable sources
with a history of adware, and they would sit on the home network. Legal free options: RTVE Play,
Pluto TV, Rakuten TV's free tier, Plex.

## Ideas not done yet

- Moonlight (streaming from a PC with Sunshine/Apollo).
- Photos from the home server: Aerial Views as screensaver (Immich/SMB/WebDAV), or CleanYourTV's
  `photo-screensaver` add-on.
