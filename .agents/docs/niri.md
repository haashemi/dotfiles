# niri

Compositor. Entry `.config/niri/config.kdl` includes `.config/niri/config/*.kdl`. Validate with `niri validate`.

## Decisions

- Display: eDP-1 stays at 165 Hz with `variable-refresh-rate` always on (not `on-demand`), so the refresh rate drops
  while nothing redraws and saves power that way. Replaced a script that forced 60 Hz on battery, which felt bad to use.
- Chrome (`.config/chrome-flags.conf`) and Spotify (`.config/spotify-launcher.conf`) run native Wayland; Chrome also gets VA-API
  video decode on the iGPU. Check with `chrome://gpu` → Video Decode.
- `environment` (`miscellaneous.kdl`) holds only toolkit backends and Qt styling. `XDG_CURRENT_DESKTOP`/`XDG_SESSION_*`
  are left to `niri-session` (started from `config.fish` on tty1), so apps and portals see the same values.
  `SDL_VIDEODRIVER` is `wayland,x11` so SDL2 games without Wayland support fall back to X11.
- Hybrid GPU: no GPU-selection variables. With `vulkan-radeon` installed, the Vulkan loader lists the iGPU as GPU0
  (`vulkaninfo --summary`) even without `vulkan-mesa-layers`, so the dGPU stays asleep unless an app asks for it. Without `vulkan-radeon`, every Vulkan app (GTK4, mpv) wakes the 3050 Ti.

- `Mod+V` opens the Aurora clipboard history. It used to be `toggle-window-floating`; the owner dropped that bind (`Mod+Shift+V` still switches focus between floating and tiling).

## Open questions

- No idle daemon: screens only turn off with `Mod+Shift+P`.
- `QT_STYLE_OVERRIDE "adwaita"` overrides the style chosen in qt6ct; keep one of the two.
- Always-on VRR: watch for flicker or a choppy cursor on the desktop. If it shows up, switch to `variable-refresh-rate on-demand=true`.
