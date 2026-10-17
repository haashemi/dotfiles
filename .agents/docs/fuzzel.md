# fuzzel

App launcher; `Mod+D` in niri (`.config/niri/config/key-bindings.kdl`). Config: `.config/fuzzel/fuzzel.ini` (fuzzel ≥ 1.15).
Reference: `man 5 fuzzel.ini`, defaults in `/etc/xdg/fuzzel/fuzzel.ini`. Validate with `fuzzel --check-config`.

## Token mapping (see AGENTS.md)

| fuzzel key        | M3 token                     |
|-------------------|------------------------------|
| background        | surface-container @ 85% (`d9`) |
| text, input       | on-surface                   |
| message           | on-surface-variant           |
| prompt, match     | primary                      |
| placeholder, counter | outline                   |
| selection         | primary-container            |
| selection-text    | on-primary-container         |
| selection-match   | primary                      |
| border            | outline-variant (border width is 0, so unused) |

## Decisions

- Shape: `radius=28` (M3 extra-large), `selection-radius=20` = half of `line-height=40px` → pill.
- Prompt is the Material Symbols `search` glyph (U+E8B6). It's a private-use codepoint, so editors/tools may drop it.
  Re-insert with: `sed -i "s/^prompt=.*/prompt=\"$(printf '\xee\xa2\xb6')  \"/" .config/fuzzel/fuzzel.ini`
- Font `Vazirmatn` (shared UI font, covers Persian app names); `Material Symbols Rounded` is in the fallback list so the prompt glyph renders.
- `image-size-ratio=0`: no large icon when there are few matches; it kept the list shape stable.
- No border: M3 surfaces separate by tone, not outline.

## Open questions

- Blur behind the translucency (niri support / version)?
- Icon theme: `breeze-dark` for now; Papirus or another theme?
- Light scheme or wallpaper-driven (matugen) colors later?
