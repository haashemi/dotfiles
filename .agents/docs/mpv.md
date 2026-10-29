# mpv

Video player. Files: `.config/mpv/mpv.conf`, `scripts/` (thumbfast, trimmer, autoload, osc), `script-opts/`.

## Decisions

- `hwdec=auto-safe`: hardware decoding via VA-API on the AMD iGPU (mpv defaults to software decoding).
  Needs `vulkan-radeon`, or mpv's Vulkan output runs on the NVIDIA dGPU. Check with `mpv -v <file> | grep -i hwdec`.
