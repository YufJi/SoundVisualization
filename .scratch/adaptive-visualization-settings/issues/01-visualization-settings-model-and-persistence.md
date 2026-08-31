# 01: Visualization settings model and persistence

**What to build:** A unified Visualization Settings model that becomes the single source of truth for style, Frequency Band preset, Motion Response Preset, Beat Pulse Intensity, Scene Adaptation Switch, and Rendering Cadence. Load it on launch, save changes automatically, migrate the existing remembered style, and support Restore Defaults.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Supported Band Presets are 8, 12, 16, and 24, with 12 as the default.
- [ ] Motion Response Preset defaults to Balanced.
- [ ] Beat Pulse Intensity defaults to Normal.
- [ ] Scene Adaptation defaults to enabled.
- [ ] Rendering Cadence defaults to Standard 30 fps and supports High 60 fps as a persisted preference.
- [ ] First launch uses Spectrum Bars; later launches restore the Remembered Style.
- [ ] Changes persist automatically without a save action.
- [ ] Restore Defaults returns all Visualization Settings to the agreed baseline and resets style to Spectrum Bars.
- [ ] Persistence is covered by tests using an injected backing store rather than real user defaults.
