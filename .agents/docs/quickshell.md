# quickshell (Aurora)

Desktop shell: `.config/quickshell/Aurora` (Quickshell 0.3.2, Qt 6.12). Started by niri (`spawn-sh-at-startup "quickshell -c Aurora"`).
Structure and packages: see `.config/quickshell/Aurora/README.md`.

## Testing

```sh
S=<scratch dir>; cp -r .config/quickshell/Aurora $S/t   # trim shell.qml to the module under test
setsid qs -p $S/t/shell.qml > $S/qs.log 2>&1 &
qs ipc -p $S/t/shell.qml call volume increase
niri msg action screenshot-screen --show-pointer false --path $S/shot.png
```

- **Hot reload is unreliable with singletons.** After a reload, IPC targets disappear and singleton bindings can read `undefined` (stuck windows, missing popups). Judge only a fresh start:
  `qs kill -c Aurora; niri msg action spawn -- quickshell -c Aurora`.
- Only one process can own `org.freedesktop.Notifications`, so test notifications on the live shell (`notify-send`; with `-A` it blocks, so run it in the background).
- Test instances keep their own service state; restore volume, brightness and keyboard-backlight values after testing.
- 1 logical px ≈ 1 Android dp on this panel (2560x1440 @ 1.25, 14"), so Android dp specs map 1:1.

## Conventions

- Every service is a `pragma Singleton` (`Singleton {}` root). Modules never instantiate services.
- Colors only come from `Appearance` M3 tokens. In QML, `on-*` tokens are named `textOn*`, because a property named `onX` is parsed as a signal handler.
- **Don't animate with `transform: Translate`** on anything used as a `Region` item (mask or blur). Regions track item geometry, not transforms, so animate `x`/`y` instead.
- All text uses `Appearance.fontUi` (Vazirmatn). Numbers that change in place (clock, battery) set `font.features: { "tnum": 1 }`. Leave `horizontalAlignment` unset so RTL text auto-aligns.

## Services

| Service | Source of truth | Notes |
|---|---|---|
| SVolume | Pipewire default sink/source | `adjusted` fires on any volume/mute/mic change, after a 500ms settle following a device (re)bind. IPC `volume increase/decrease/toggleMute` (4% steps). |
| SBrightness | `brightnessctl` + sysfs | Re-reads sysfs before each step, so outside changes aren't overwritten. IPC `brightness`. |
| SKeyboardBacklight | UPower `KbdBacklight` over `gdbus` | The ASUS firmware handles the Fn keys itself; UPower's `BrightnessChangedWithSource` is the only signal for that. 0–3 levels. IPC `keyboard-backlight`. Changes made with `asusctl`/`brightnessctl` are **not** seen. |
| SNotifications | `NotificationServer` | Advertises only what the popup renders (actions, markup, links, image). |
| SPlayers | Mpris | Exposes a `ScriptModel`, so delegates survive track changes. |
| SBattery / SNetwork / SBluetooth / SClock | UPower / Networking / Bluetooth / SystemClock | `SBattery.present` hides the battery on machines without one. |

## OSD — Android 16/17 expressive volume dialog

Reference: 9to5google "Android 17 QPR1 Beta 3 blur" screenshot, measured at 2.625 px/dp.

| Part | Spec |
|---|---|
| Container | 60dp wide, 10dp padding, `surfaceContainer` @ 60% + compositor blur, 12dp from the right edge, vertically centered. Full pill with buttons; otherwise radius 22 (slider radius 12 + padding), concentric with the slider. |
| Top button (mute) | 40dp circle, `primary` / `textOnPrimary` |
| Slider | 40×250dp; outer corners 12, inner 2; handle 52×4 with 6dp gaps; inactive `textOnPrimary`, active `primary`; 20dp icon 10dp from top, flips color when covered. Discrete mode (`steps`) snaps and draws 4dp stop dots. |
| Bottom button (mic) | 40dp, radius 12; tonal when live, `primary` when muted |
| Motion | slide+fade in 350ms OutCubic, out 200ms InCubic; hides 3s after the last change, stays open while hovered |

Brightness and keyboard backlight show only the slider. Blur needs `BackgroundEffect.blurRegion` plus the niri `layer-rule` for `aurora-osd`.

## Notifications — Android heads-up cards

Top-right, 8px under the bar, 400 wide, stacked oldest-first. Card: radius 28, `surfaceContainerHigh` @ 85% + per-card blur.
Layout: 40dp avatar (image > app icon > bell), app name, ✕, summary (2 lines), body (StyledText, 4 lines, links open), tonal action chips.
Click runs the `default` action. Swipe (>30% width) or ✕ calls `dismiss()`. Timeout calls `expire()`: `expireTimeout`, or 5s by default; critical notifications never time out. Hover pauses the timer.
No history or notification center, by owner's decision; expired notifications are gone.

## Media card

Clicking a bar Mpris pill toggles it. It closes 1s after the pointer leaves (or after opening without a hover). 400×152, radius 28, blurred album art under a 55% `surface` scrim. Play/pause morphs circle ↔ rounded square. Seek bar uses the expressive track and handle. Position is polled at 1Hz while the card is open and playing.

## Backlog

- Swipe-to-dismiss and the media card are untested with real pointer input; verified only by rendering.
