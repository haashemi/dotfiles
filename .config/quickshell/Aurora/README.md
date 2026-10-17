## Aurora — QuickShell desktop shell

Managed by GNU stow. Run with `quickshell -c Aurora`; Niri spawns it at startup.

## Structure

```
Aurora/
├── shell.qml              # entrypoint: ShellRoot + pragmas; instantiates Bar, OSD, Notifications
├── config/                # design tokens (Appearance singleton: colors, fonts, sizes)
├── components/            # shared primitives (MaterialSymbol, HSlider, M3Switch, MediaCard)
├── services/              # S* singletons over Quickshell/system services (SVolume, SBrightness, ...)
└── modules/               # top-level UI, one folder per feature
    ├── Bar/               # full-width top bar: Clock + Mpris pills with media card (L), AppTitle (C), Wifi/Bluetooth/Brightness/Volume/Mic/Battery (R)
    ├── OSD/               # Android 16-style volume/brightness dialog (right edge, blurred), driven by S*.adjusted
    ├── Notifications/     # Android-style heads-up cards, top-right (server lives in services/SNotifications.qml)
    └── QuickSettings/     # Android 17 shade: sliders, tiles, Wi-Fi/Bluetooth/Battery/Power pages, media (Mod+S)
```

Each module owns its `PanelWindow`s; module-local widgets live in `modules/<mod>/components/`.
Volume/brightness/keyboard-backlight keys call the shell via IPC (`qs ipc -c Aurora call volume increase`, etc.).
Blur needs the niri `layer-rule` for namespaces `^aurora-` with `xray false` (see `.config/niri/config/window-rules.kdl`).

## Required Packages

- AUR: `ttf-material-symbols-variable-git`
- `vazirmatn-fonts` / Vazirmatn (UI font, Persian + Latin)
- `brightnessctl` (screen brightness)
- `upower` (battery, keyboard backlight), `networkmanager` (Wi-Fi), `bluez` (Bluetooth), `pipewire` (audio)
- `asusctl` / asusd (power mode, charge limit; tiles hide without it)