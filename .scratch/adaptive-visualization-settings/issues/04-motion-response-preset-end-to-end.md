# 04: Motion Response Preset end-to-end

**What to build:** Make Snappy, Balanced, and Smooth presets control the perceived attack and decay of visualization motion across styles. Users choose a single preset; individual attack and decay values remain internal.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** resolved

- [x] Snappy produces the fastest visible response and shortest decay.
- [x] Balanced produces the default response.
- [x] Smooth produces softer attack and longer decay.
- [x] Changing the preset applies immediately without restarting Listening.
- [x] The preset persists across relaunch.
- [x] Spectrum Bars, Waveform Line, and Spectrum Area all respond to the selected preset.
- [x] Tests verify that the three presets produce distinguishable motion parameters.

## Answer

Implemented with named Motion Response parameters, immediate propagation to analysis and rendering, persisted startup behavior, and distinct-preset coverage.
