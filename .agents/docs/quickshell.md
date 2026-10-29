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

- **Blur**: every surface sets a namespace starting with `aurora-` and requests its own rounded shape with `BackgroundEffect.blurRegion`. The niri `layer-rule` for `^aurora-` sets `xray false`. Without that, niri defaults to xray, which blurs only the wallpaper and looks like a flat tint. Don't add `blur true` to the rule: it would blur the whole layer rectangle, including full-screen transparent windows. Keep surfaces around 60–75% opacity so the blur shows.

- Every service is a `pragma Singleton` (`Singleton {}` root). Modules never instantiate services.
- Colors only come from `Appearance` M3 tokens. In QML, `on-*` tokens are named `textOn*`, because a property named `onX` is parsed as a signal handler.
- Inside a `ClippingRectangle`, children are reparented, so `parent.x` is wrong there. Give the rectangle an `id`.
- QML treats `onX` properties as handlers, and a `Behavior` can't target a `readonly` property.
- **Don't animate with `transform: Translate`** on anything used as a `Region` item (mask or blur). Regions track item geometry, not transforms, so animate `x`/`y` instead.
- Icon-only buttons use `components/IconButton.qml` (40dp circle, hover state layer); the media card keeps its own smaller `TransportButton`.
- All text uses `Appearance.fontUi` (Vazirmatn). Numbers that change in place (clock, battery) set `font.features: { "tnum": 1 }`. Leave `horizontalAlignment` unset so RTL text auto-aligns.

## Performance and memory

Measured on a fresh start (anonymous memory, `RssAnon`): ~125 MB with all modules, of which ~45 MB is the bare QML engine and most of the rest is the first GPU window (Qt scene graph + Mesa). Idle CPU is ~0. Per-module costs are small, so the wins come from not building hidden UI:

- Quick Settings detail pages (Wi-Fi, Bluetooth, Battery, Power, Clipboard) are `Loader`s (`DetailPage` in `QuickSettings.qml`) that exist only while shown, fading out, and the panel is open. First open of the main page went from ~+55 MB to ~+25 MB. Page state (an expanded network, the clipboard selection) resets when the panel closes.
- The launcher window and the bar's per-player media card window sit behind `LazyLoader`s.
- Images get a fixed `sourceSize` so layout changes don't re-decode them.
- Memory freed by unloading isn't returned to the OS (malloc keeps it), so RSS after closing stays near its peak; the gain is a lower peak.
- Tried and rejected: `QT_QUICK_BACKEND=software` (−45 MB, but Quick Settings didn't render and animations cost more CPU); `QSG_RENDER_LOOP=basic` (only −9 MB); panel-sized instead of full-screen click-catcher windows (no measurable difference).
- Delegates bound to a model can see `modelData` go null while their page unloads; guard bindings with `?.` (see `WifiPage.qml`).

## Services

| Service | Source of truth | Notes |
|---|---|---|
| SVolume | Pipewire default sink/source | `adjusted` fires on any volume/mute/mic change, after a 500ms settle following a device (re)bind. IPC `volume increase/decrease/toggleMute` (4% steps). |
| SBrightness | `brightnessctl` + sysfs | Re-reads sysfs before each step, so outside changes aren't overwritten. IPC `brightness`. |
| SKeyboardBacklight | UPower `KbdBacklight` over `gdbus` | The ASUS firmware handles the Fn keys itself; UPower's `BrightnessChangedWithSource` is the only signal for that. 0–3 levels. IPC `keyboard-backlight`. Changes made with `asusctl`/`brightnessctl` are **not** seen. |
| SNotifications | `NotificationServer` | Advertises only what the popup renders (actions, markup, links, image). `dnd` drops non-critical notifications (there's no history); it survives reloads, not restarts. niri's "Screenshot captured" notification is always dropped (the screenshot is in the clipboard history). |
| SAsus | asusd `xyz.ljones.Platform` over busctl/gdbus | `PlatformProfile` (Quiet=2, Balanced=0, Performance=1), `ChargeControlEndThreshold`, `OneShotFullCharge`. |
| SPanels | — | UI open state (`quickSettings`, `quickSettingsPage`, `launcher`) shared by the bar button, the panels and IPC `quicksettings toggle/open/close`, `clipboard toggle`, `launcher toggle/open/close`. `toggleQuickSettings(page)` closes only when that page is already showing. Launcher and Quick Settings close each other. |
| SLauncher | `DesktopEntries` | App list, search ranking and launch counts (`~/.local/share/aurora/launcher/usage.json`, seeded once from fuzzel's cache). `Terminal=true` apps run in `alacritty -e`. See `.agents/docs/launcher.md`. |
| SClipboard | `wl-paste --watch scripts/clipboard.sh store` | Entries are files in `~/.local/share/aurora/clipboard/{history,pinned}`, named `<epoch-ns>-<sha1>.<txt\|png…>`. History keeps 14, pins are unlimited, both survive reboots. Re-copying moves an entry to the top (pinned ones stay put). `CLIPBOARD_STATE=sensitive` copies (password managers) are skipped. Script commands run through one queue, and every command but `copy` prints the new list. |
| SPlayers | Mpris | Exposes a `ScriptModel`, so delegates survive track changes. |
| SNetwork / SBluetooth | Networking / Bluetooth | Sorted `ScriptModel`s for the lists. `scanning` is bound by the Quick Settings detail pages, so scanning and discovery run only while a list is visible. |
| SBattery | UPower + sysfs | Health = `energyCapacity` / sysfs `energy_full_design`; UPower's display device reports no health. |
| SClock | SystemClock | Minute precision. |

## OSD — Android 16/17 expressive volume dialog

Reference: 9to5google "Android 17 QPR1 Beta 3 blur" screenshot, measured at 2.625 px/dp.

| Part | Spec |
|---|---|
| Container | 60dp wide, 10dp padding, `surfaceContainer` @ 60% + compositor blur, 12dp from the right edge, vertically centered. Full pill with buttons; otherwise radius 22 (slider radius 12 + padding), concentric with the slider. |
| Top button (mute) | 40dp circle, `primary` / `textOnPrimary` |
| Slider | 40×250dp; outer corners 12, inner 2; handle 52×4 with 6dp gaps; inactive `textOnPrimary`, active `primary`; 20dp icon 10dp from top, flips color when covered. Discrete mode (`steps`) snaps and draws 4dp stop dots. |
| Bottom button (mic) | 40dp, radius 12; tonal when live, `primary` when muted |
| Motion | slide+fade in 350ms OutCubic, out 200ms InCubic; hides 3s after the last change, stays open while hovered |

Brightness and keyboard backlight show only the slider.

## Notifications — Android heads-up cards

Top-right, 8px under the bar, 400 wide, stacked oldest-first. Card: radius 28, `surfaceContainerHigh` @ 85% + per-card blur.
Layout: 40dp avatar (image > app icon > bell), app name, ✕, summary (2 lines), body (StyledText, 4 lines, links open), tonal action chips.
Click runs the `default` action. Swipe (>30% width) or ✕ calls `dismiss()`. Timeout calls `expire()`: `expireTimeout`, or 4s by default; critical notifications never time out. Hover pauses the timer.
No history or notification center, by owner's decision; expired notifications are gone.

## Quick Settings — Android 17 shade

Opened by `Mod+A` or the bar's status pill (it highlights while open). Esc, a click outside, or the pill again closes it; Esc on a detail page goes back.
It's a full-screen transparent Overlay layer with exclusive keyboard focus. The panel is 400 wide, top-right under the bar, radius 28, with an **opaque** `surfaceContainer` background and no blur (because of the niri bug below). Open/close reveals it by height with M3 emphasized motion: 450ms `[0.05, 0.7, 0.1, 1]` in, 250ms `[0.3, 0, 0.8, 0.15]` out. Page switches animate `fullHeight` (350ms emphasized) and cross-fade over 200ms.
While it's open, the OSD is suppressed and notification popups are hidden with their timers paused (Android: no heads-up over the shade).

- **Main**: header (44px clock, date, battery chip → Battery, power button → Power), brightness / volume / keyboard `HSlider`s, then a 4-column tile grid.
  - Wide tiles: Wi-Fi, Bluetooth, Power mode, Do Not Disturb. The icon container toggles; the body opens details (DND only toggles).
  - Small tiles: mic, airplane (Wi-Fi + Bluetooth off), screenshot (closes the panel, then `niri msg action screenshot`), clipboard (opens Clipboard).
  - Then a `MediaCard` carousel of all players.
- **Wi-Fi**: master switch and the network list. A tap joins saved or open networks; secured new networks expand to a password field (Enter or Connect). A wrong password shows inline. Expand a saved network for Forget / Disconnect.
- **Bluetooth**: master switch, paired devices (tap to connect/disconnect; the chevron reveals Forget) and available devices (tap to trust + pair, then auto-connect).
- **Battery**: level, status, time left, power draw, energy, health, power-mode button group, charge-limit slider (50–100%, 5% steps), "Charge to 100% once".
- **Clipboard** (also `Mod+V`, which opens the panel straight on this page): pinned entries, then the 14 newest copies, text and images. Rows are a fixed 64px: text shows 2 lines, images a cropped thumbnail. Click or Enter copies the entry back and closes the panel (no auto-paste, by owner's decision). Up/Down move the selection (hover moves it too), Delete removes. Each row has pin and remove buttons, and the header's sweep button clears the history but keeps pins. Keys reach the page through `Keys.forwardTo` on the panel.
- **Power**: Log out / Suspend / Restart / Power off. No Lock tile, because no screen locker is installed.

Tile spec: 64 tall. Off = pill; on = rounded square (r20) for every tile. Wide tiles have a 48 icon container (circle when off, primary r16 when on); small tiles fill primary when on. Hover state layer at 8%.

## Launcher

`Mod+D`: centered search + 8-row list, most launched first, blurred, 200ms center zoom (blur follows the real geometry; the surface never fades because blur can't); window behind a `LazyLoader`. Full spec and decisions: [launcher.md](launcher.md).

## Media card (`components/MediaCard.qml`)

Shared by Quick Settings (all players, with paging) and the bar pill popup (one player). Matches the Android 16 player:
- album-art backdrop with a horizontal `surface` scrim
- app icon badge and output-device chip (default sink description; headphone icon for head/buds/pods)
- title/artist with a 64×44 play button (rounded square while playing, pill while paused)
- prev / next, shuffle / repeat
- wavy progress drawn with `Shape` + `PathPolyline`: it flattens when paused and only animates while `active`
- arrows + dots for multiple players

Position is polled at 1Hz while it's active and playing.

## Backlog

- Launcher: typing/clicks verified only via IPC and rendering.

- Clipboard: no section labels between pinned and recent (rows have a fixed height); pinned rows are only marked by a filled pin. Niri screenshots land in the history too, since niri copies them to the clipboard (its notification is muted). Clipboard key and mouse handling verified only through IPC and rendering.

- Swipe-to-dismiss, media-card controls and Quick Settings interactions (password entry, pairing) are verified only by rendering and IPC, not real pointer/keyboard input.
- The DND state resets on shell restart (PersistentProperties only survives reloads).
- **Known niri bug (26.04, non-xray blur):** after rapid open/close toggling of Quick Settings, a strip at the bottom of the panel can end up unblurred. A `WAYLAND_DEBUG=client` trace shows Quickshell sending the correct full-height `set_blur_region` in both cases, so niri drops part of it. Already tried without success: explicit Region geometry, swapping Region objects, a null swap, and a 1px nudge after settling. The owner chose an opaque Quick Settings background instead; if a niri update fixes this, blur could come back (re-add `BackgroundEffect.blurRegion` and lower the opacity).
