# Repository Guidelines

Guidance for AI assistants working in this repository (Arch Linux dotfiles, "Aurora").

## Project Overview
Personal Arch Linux dotfiles managed as a single GNU Stow package: the repo root is the stow package, applied with `stow -t ~/ .` so `.config/...` symlinks directly into `$HOME`. There is no build system, no test suite, and no CI — "running" this repo means restowing and reloading the affected program. Most directories under `.config/` are independent; the only coupled pair is **niri + quickshell** (niri spawns quickshell and calls its IPC methods).

## Architecture & Data Flow
- **Stow**: `stow -t ~/ .` from the repo root creates one symlink tree into `$HOME`. `.stow-local-ignore` excludes `.git`, `.gitignore`, `preview.jpg`, `README.md` from stowing. `.gitignore` is a whitelist for `.config/Code/` and hides secrets (`fish_variables`, `fish/functions/x-*`).
- **niri → quickshell coupling** (the one cross-directory dependency):
  - `.config/niri/config/miscellaneous.kdl` line 3: `spawn-sh-at-startup "quickshell -c Aurora"` launches the shell.
  - `.config/niri/config/key-bindings.kdl` lines 16–19: brightness keybinds call quickshell over IPC, e.g. `spawn-sh "qs ipc -c Aurora call brightness increase"`.
  - quickshell exposes matching `IpcHandler` targets (`brightness`, `keyboard-backlight`, …) in `.config/quickshell/Aurora/services/S*.qml`. Changing an IPC target name, function name, or shell name (`Aurora`) must be mirrored in the other directory.
- **Everything else is standalone**: fish, git, alacritty, mpv, fontconfig, VS Code settings do not reference each other.

## Key Directories
- `.config/niri/` — Wayland compositor config. `config.kdl` only `include`s the six files in `config/` (`input`, `outputs`, `key-bindings`, `layout`, `miscellaneous`, `window-rules` — all KDL). `assets/` holds wallpaper images referenced by `spawn-sh-at-startup` lines. `locked.kdl` is the separate lock-screen config (spawns swaylock).
- `.config/quickshell/Aurora/` — Quickshell desktop shell (QML/JS), shell id `Aurora`. Entry point `shell.qml` instantiates `Bar`, `OSD`, `Notifications` from `modules/`. `services/S*.qml` are backend services (one per concern: `SBrightness`, `SVolume`, `SNetwork`, `SNotifications`, …) owning both the external-process/Quickshell-API calls and the `IpcHandler`. `modules/*/components/` are presentational widgets; `components/` (top level) holds generic widgets. `config/Appearance.qml` is a `pragma Singleton` (registered in `config/qmldir`) holding all colors, fonts, `barHeight`, animation timing — never hardcode these values in widgets.
- `.config/fish/` — `config.fish` is a stub; real config lives in `conf.d/` (`00-env.fish` XDG variable hygiene, `vite-plus.fish`) and `functions/` (`pacu.fish` pacman helper). Files matching `functions/x-*` are machine-specific/secretive and gitignored.
- `.config/mpv/` — `mpv.conf`, `input.conf`, Lua in `scripts/` (incl. `mpv-trimmer`), Anime4K shaders in `shaders/`.
- `.config/alacritty/`, `.config/git/`, `.config/fontconfig/`, `.config/Code/User/settings.json` — small single-file configs.

## Development Commands
```sh
# Restow after changes (from repo root)
stow -t ~/ .

# Validate niri config after edits
niri validate

# Restart the quickshell shell after QML edits (or save a QML file — hot reload)
qs kill -c Aurora && qs -c Aurora   # or just rely on quickshell's live reload

# Exercise a quickshell IPC handler manually
qs ipc -c Aurora call brightness increase

# Reload fish config
exec fish
```
No build/test/lint commands exist at the repo level.

## Code Conventions & Common Patterns
- **niri (KDL)**: one topical file per `include` in `config.kdl`; do not grow `config.kdl` itself. Keybinds carry `hotkey-overlay-title="…"`; volume/brightness binds set `allow-when-locked=true`. Prefer `spawn-sh` for shell-syntax commands, `spawn` for argv form.
- **quickshell (QML/Qt6)**:
  - Strict layering: `modules/<Area>/components/*.qml` render; `services/S*.qml` do work (external processes via `Process` + `StdioCollector`, side effects via `Quickshell.execDetached`) and expose `IpcHandler { target: "<name>"; function <action>() }`.
  - New service = new `services/S<Name>.qml` with an `IpcHandler` if niri keybinds should reach it; wire the keybind in `.config/niri/config/key-bindings.kdl` using `spawn-sh "qs ipc -c Aurora call <target> <function>"`.
  - All theming goes through the `Appearance` singleton; animation durations and sizes included.
  - Tooling: `.qmlls.ini` (Qt6 QML language server config) and `cspell.json` (allowed words: `focusable`, `LevelBar`, `Mpris`, `OSD`, `Quickshell`, `Toplevel`) live in `.config/quickshell/Aurora/`.
- **fish**: env vars in `conf.d/00-env.fish` use `set -gx` and follow XDG redirection conventions (per Arch wiki / xdg-ninja); helpers are one-function-per-file in `functions/` with `-a`/arg parsing kept minimal. Machine-specific functions go in `functions/x-*` (gitignored).
- **Git**: commit messages follow conventional-ish prefixes seen in history: `feat:`, `chore:`; default branch `main`.

## Important Files
- `.config/niri/config.kdl` — include hub for all niri config.
- `.config/niri/config/key-bindings.kdl` / `miscellaneous.kdl` — the niri→quickshell IPC contract and startup command.
- `.config/quickshell/Aurora/shell.qml` — quickshell entry point.
- `.config/quickshell/Aurora/config/Appearance.qml` + `config/qmldir` — singleton theme.
- `.config/fish/conf.d/00-env.fish` — environment/XDG baseline.
- `packages.yml` — declarative system package manifest (groups: Linux, Fonts, Niri, CLI, GUI, AUR) consumed by an external package helper; update it when adopting/dropping a package a config depends on.

## Runtime/Tooling Preferences
- Target system: Arch Linux, Wayland, `linux-zen` kernel; editor `nano` (set in fish env); user dirs are collapsed per `.config/user-dirs.dirs` (most XDG dirs point at `~/Downloads`, `XDG_PROJECTS` at `~/Documents`).
- QML is Qt6-based (quickshell); QML tooling paths in `.qmlls.ini` assume the Arch `/usr/lib/qt6/qml` layout.
- Never commit or read values from gitignored files (`fish_variables` contains live secrets; `fish/functions/x-*` are private).

## Testing & QA
No test framework, CI, or coverage exists — QA is manual reload + behavior check:
1. `niri validate` after any `.config/niri/**.kdl` edit.
2. Save a QML file and confirm quickshell hot-reloads without errors; otherwise restart via `qs kill -c Aurora && qs -c Aurora`.
3. For IPC changes, run the exact `qs ipc -c Aurora call …` command a niri keybind would run and observe the expected side effect.
4. For fish edits, start a new fish instance and exercise the function; `fish -c '<function>'` for non-interactive checks.
