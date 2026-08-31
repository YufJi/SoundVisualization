# 04: Motion Response Preset end-to-end

**What to build:** Make Snappy, Balanced, and Smooth presets control the perceived attack and decay of visualization motion across styles. Users choose a single preset; individual attack and decay values remain internal.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** ready-for-agent

- [ ] Snappy produces the fastest visible response and shortest decay.
- [ ] Balanced produces the default response.
- [ ] Smooth produces softer attack and longer decay.
- [ ] Changing the preset applies immediately without restarting Listening.
- [ ] The preset persists across relaunch.
- [ ] Spectrum Bars, Waveform Line, and Spectrum Area all respond to the selected preset.
- [ ] Tests verify that the three presets produce distinguishable motion parameters.
