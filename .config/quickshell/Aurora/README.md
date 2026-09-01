## Aurora — QuickShell desktop shell

Managed by GNU stow. Run with `quickshell -c Aurora`; Niri spawns it at startup.

## Structure

```
Aurora/
├── shell.qml              # entrypoint: ShellRoot + pragmas; instantiates Bar, OSD, Notifications
├── config/                # design tokens (Appearance singleton: colors, fonts, sizes)
├── components/            # shared primitives (MaterialSymbol, Divider, Orientation, LevelBar)
├── services/              # S* wrappers over Quickshell/system services (SVolume, SBrightness, ...)
└── modules/               # top-level UI, one folder per feature
    ├── Bar/               # Pixel-style floating pill status bar: Clock + Mpris (L), AppTitle (C), Wifi/Bluetooth/Brightness/Volume/Mic/Battery (R)
    ├── OSD/               # overlay that pops on volume/brightness/keyboard-backlight change
    └── Notifications/     # notification popup UI (server lives in services/SNotifications.qml)
```

Each module owns its `PanelWindow`s; module-local widgets live in `modules/<mod>/components/`.
The OSD is driven by niri keybindings via IPC (`qs ipc -c Aurora call brightness increase`, etc.).

## Required Packages

- AUR: `ttf-material-symbols-variable-git`
- `ttf-jetbrains-mono` (shell mono font)
- `brightnessctl` (brightness/keyboard-backlight control)