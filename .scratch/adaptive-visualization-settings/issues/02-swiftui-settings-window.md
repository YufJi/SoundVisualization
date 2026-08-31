# 02: SwiftUI settings window

**What to build:** A single-instance SwiftUI settings window that exposes the Global Parameters from the Visualization Settings model. Every change applies immediately, persists automatically, and is visible in the current visualization. The existing AppKit menu gains a Settings entry.

**Blocked by:** 01 — Visualization settings model and persistence.

**Status:** ready-for-human

- [x] The menu contains a Settings entry that opens the window.
- [x] Opening Settings again focuses the existing window instead of creating a duplicate.
- [x] Closing the window does not stop Listening.
- [x] The window includes controls for Visualization Style, Band Preset, Motion Response Preset, Beat Pulse Intensity, Scene Adaptation Switch, Rendering Cadence, and Restore Defaults.
- [x] Changes apply immediately and remain after relaunch.
- [x] Band Preset is disabled when Waveform Line is active and explains that it affects only spectrum-oriented styles.
- [x] Settings and Quick Controls remain usable when Listening is stopped.
- [x] Restore Defaults resets Visualization Style and all Global Parameters to the agreed defaults.
