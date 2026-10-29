# AGENTS.md

Personal Arch Linux dotfiles (Wayland · Niri · QuickShell · Alacritty · Fuzzel · Fish), deployed with GNU stow
(`~/.config/<app>` → `dotfiles/.config/<app>`).

## Design system

Target: **Material You / M3 Expressive, dark scheme**, generated from seed `#7fbbea`
(the `primary` in `.config/quickshell/Aurora/config/Appearance.qml`).
Use the shared tokens below when theming any app; don't invent ad-hoc colors.

| Token                  | Hex       |
|------------------------|-----------|
| primary                | `#9ccbfb` |
| on-primary             | `#003352` |
| primary-container      | `#0f4a73` |
| on-primary-container   | `#cfe5ff` |
| secondary-container    | `#3a4857` |
| on-secondary-container | `#d6e4f7` |
| error                  | `#ffb4ab` |
| surface                | `#101418` |
| surface-container      | `#1d2024` |
| surface-container-high | `#272a2f` |
| on-surface             | `#e0e2e8` |
| on-surface-variant     | `#c2c7cf` |
| outline                | `#8c9199` |
| outline-variant        | `#43474e` |

Shapes: 28px extra-large (sheets/dialogs), full-pill for selected/active items.
Translucent surfaces: `surface-container` at ~85% alpha.
Fonts: UI `Vazirmatn` everywhere (Persian/Arabic + Roboto-derived Latin; use `tnum` for changing numbers), icons `Material Symbols Rounded`, terminal/code `JetBrains Mono`.

## Conventions

- Requirements are vague on purpose: ask the owner before baking in opinions, and propose ideas, never impose them.
- One doc per app in `.agents/docs/<app>.md`: what it is, files, the decisions taken, and open questions. Keep these up to date when you change an app.
- Validate configs with the app's own checker when it has one (e.g. `fuzzel --check-config`).

## App docs

- [fuzzel](.agents/docs/fuzzel.md): replaced by the Aurora launcher, config kept
- [launcher (Aurora)](.agents/docs/launcher.md): Mod+D app launcher, ranking, usage counts
- [mpv](.agents/docs/mpv.md): hardware decoding
- [niri](.agents/docs/niri.md): 165 Hz with VRR
- [quickshell (Aurora)](.agents/docs/quickshell.md): services, OSD/notification/media specs, testing gotchas
