# 06: Scene adaptation and Reduce Motion

**What to build:** Automatically move between Low-distraction Baseline and Active Enhancement based on audio activity, Beat Pulses, hysteresis, and timeout. Let users disable the behavior, and suppress enhancement when macOS requests reduced motion.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** resolved

- [x] Scene Adaptation Switch defaults to enabled.
- [x] Disabling Scene Adaptation prevents automatic movement between visual states.
- [x] Low-distraction Baseline preserves recognition of the selected Visualization Style while reducing prominence.
- [x] Active Enhancement is bounded and returns to baseline after audio activity subsides.
- [x] Hysteresis and timeout prevent rapid visual flicker.
- [x] Internal thresholds are not exposed in the settings window.
- [x] macOS Reduce Motion suppresses Beat Pulses and Active Enhancement.
- [x] Reduce Motion does not hide or blank the visualization.

## Answer

Implemented with a testable SceneAdapter, bounded prominence scaling, hysteresis and timeout, an Audio-adaptive motion menu switch, and macOS Reduce Motion observation.
