# 01: Visualization settings model and persistence

**What to build:** A unified Visualization Settings model that becomes the single source of truth for style, Frequency Band preset, Motion Response Preset, Beat Pulse Intensity, Scene Adaptation Switch, and Rendering Cadence. Load it on launch, save changes automatically, migrate the existing remembered style, and support Restore Defaults.

**Blocked by:** None (can start immediately).

**Status:** ready-for-human

- [x] Supported Band Presets are 8, 12, 16, and 24, with 12 as the default.
- [x] Motion Response Preset defaults to Balanced.
- [x] Beat Pulse Intensity defaults to Normal.
- [x] Scene Adaptation defaults to enabled.
- [x] Rendering Cadence defaults to Standard 30 fps and supports High 60 fps as a persisted preference.
- [x] First launch uses Spectrum Bars; later launches restore the Remembered Style.
- [x] Changes persist automatically without a save action.
- [x] Restore Defaults returns all Visualization Settings to the agreed baseline and resets style to Spectrum Bars.
- [x] Persistence is covered by tests using an injected backing store rather than real user defaults.
