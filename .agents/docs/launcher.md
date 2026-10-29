# launcher (Aurora)

App launcher inside the Aurora shell, replacing fuzzel on `Mod+D` (`qs ipc -c Aurora call launcher toggle`; also `open`/`close`).
Files: `.config/quickshell/Aurora/modules/Launcher/Launcher.qml` (UI), `services/SLauncher.qml` (apps, search, usage), open state in `services/SPanels.qml` (`launcher`).

## Behavior

- Centered panel, 560 wide: an M3 search bar (56 tall, pill) over a fixed 8-row list (48px rows, 32px icon + name, `primaryContainer` pill selection that slides between rows). Fixed height, so the shape never changes while typing.
- Up/Down (Tab/Shift+Tab) move, Enter or click launches, hover with real pointer motion selects. Esc or a click outside closes.
- Motion: one 200ms animation, same curve both ways (M3 standard `[0.2, 0, 0, 1]`). The panel zooms from 85% to 100% around the center by real width/height/radius, and only the content (scaled to match) fades. The surface itself never fades, because the compositor blur can't: an earlier fade + slide left the blur at full strength from the first frame (owner: "static, not synced"). The blur region now has the panel's shape every frame (checked at 4s slow motion). Rows fade in and slide when the results reorder.
- Surface: `surfaceContainer` @ 70% + compositor blur (namespace `aurora-launcher`), search bar `surfaceContainerHighest` @ 70%.
- Launcher and Quick Settings close each other (both take exclusive keyboard focus).

## Apps

- Source: `DesktopEntries.applications` — the same XDG `applications` dirs fuzzel scans (`$XDG_DATA_HOME`, `$XDG_DATA_DIRS`, default `/usr/local/share:/usr/share`), with `NoDisplay`/`Hidden` dropped. Verified on 2026-10-29: the same 46 ids fuzzel's rules give (incl. OnlyShowIn/NotShowIn/TryExec), no differences.
- Flatpak/snap: not installed. Their exports only show up if `XDG_DATA_DIRS` includes them in niri's environment; that was true for fuzzel too.
- `DesktopEntries` scans lazily on first access, so `SLauncher.apps` binds it at startup.
- `Terminal=true` apps run as `alacritty -e <command>` (like fuzzel's `terminal=alacritty -e`); others use `DesktopEntry.execute()`.

## Ranking

Tiers, then launch count (desc), then name:
0. a word of the name starts with the query
1. a word of the generic name or keywords starts with it
2. substring of name, generic name, keywords, id or Exec
3. fuzzy (in-order characters) on the name

Empty query = all apps by launch count. Counts: `~/.local/share/aurora/launcher/usage.json` (`{ "<desktop id>": n }`), written on every launch. On first start (file missing) it was seeded once from fuzzel's `~/.cache/fuzzel`, by owner's decision.

## Decisions

- List rather than icon grid; blurred translucent surface; fuzzel config kept as a fallback (owner).
- Lives in the main shell process, not a separate `qs` instance (owner). The window is behind a `LazyLoader`, created only while shown. Measured against an empty shell: eager window +53 MB idle / +115 MB after first open; lazy +15 MB idle / +83 MB after use. Lazy costs ~55 ms extra on the first open only (later opens match eager, ~37 ms including the `qs ipc` round trip).
- No desktop actions (e.g. "New Private Window"), as in fuzzel's `show-actions=no`.

## Open questions / backlog

- Keyboard and pointer input verified only through IPC and rendering (no input injection tool installed); real typing should be checked by hand.
- "Recently used" decay: counts only grow, so a heavy past favorite stays on top.
