# Xiaomi MiTV-MOOQ0 (codename croods)

Two sets done on 2026-11-19, both with CleanYourTV's `examples/xiaomi-mitv-mooq0/debloat.txt`:

| Firmware | Android TV | Notes |
|---|---|---|
| `RTM4.220307.164.8835` | 11 | 1.7 GB RAM, `armeabi-v7a` |
| `QTG3.200305.006.5135` | 10 | Also has `com.duokan.factorytest` (claims Home at priority 0), `leanbacklauncher` (+ recommendations), `bugreportsender` and `floatingframe`, all in the list. Ships with the system in English |

## The remote

| Button | Kernel key | Android keycode | Who answers it | What the theme does |
|---|---|---|---|---|
| Mi (the remote has no separate Home) | `KEY_WWW` | 192 (`KEYCODE_BUTTON_5`) | Global key → `com.xiaomi.android.tvsetup.partnercustomizer` `GlobalKeyReceiver` | `"app_keys": ["192:home"]` |
| Input | `KEY_RECORD` | 130 (`KEYCODE_MEDIA_RECORD`) | The stock launcher only | `"input_key_keycodes": [130]`, `"handle_view_inputs": true` |
| Mic, YouTube, Netflix, Prime | | | Their own receivers | Nothing needed: they keep working |

What `GlobalKeyReceiver` does with 192, read from its dex: Mi TV+ if enabled and in a Mi TV+ region;
else PatchWall if `Settings.Global patchwall_enable` is `"true"` and PatchWall is enabled; else Live
TV (`com.mediatek.wwtv.tvcenter`), by explicit component. So with PatchWall disabled and no key
helper, Mi opens Live TV, and on a set with no tuned channels Back and the arrows do nothing there:
the TV is stuck. The key helper is not optional on this model.

## The key helper and volume

| Firmware | Volume held, helper on | D-pad seek in SmartTube, helper on |
|---|---|---|
| Android 11 (`8835`) | One step per press: the repeat is dropped. Comes back with the helper off | Works (`key_filter` only) |
| Android 10 (`5135`) | Repeats normally | Works (`key_filter` only) |

- **Don't use `consume_volume_keys` on this model.** Tried on the Android 10 set: Left/Right stopped
  seeking in SmartTube's player; dropping the key brought them back.
- Android 11 lives with one volume step per press for now. Untried there: `volume_pauses_filter`
  (made for the MOEU0, a Xiaomi). Test it alone, then check SmartTube seeking before keeping it.
- The trade is worth it: without the helper, Mi traps the TV in Live TV (above).

## Other

- `com.google.android.tungsten.setupwraith` owns the saved Wi-Fi network on both sets: never disable
  it (the TV drops off Wi-Fi and ADB).
- After a reboot the TV asked again for the USB debugging authorisation on the first set: tick
  "Always allow from this computer", or every reboot means another prompt.
