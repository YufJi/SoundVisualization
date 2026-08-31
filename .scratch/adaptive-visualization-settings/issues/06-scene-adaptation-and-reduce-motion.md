# 06: Scene adaptation and Reduce Motion

**What to build:** Automatically move between Low-distraction Baseline and Active Enhancement based on audio activity, Beat Pulses, hysteresis, and timeout. Let users disable the behavior, and suppress enhancement when macOS requests reduced motion.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** ready-for-agent

- [ ] Scene Adaptation Switch defaults to enabled.
- [ ] Disabling Scene Adaptation prevents automatic movement between visual states.
- [ ] Low-distraction Baseline preserves recognition of the selected Visualization Style while reducing prominence.
- [ ] Active Enhancement is bounded and returns to baseline after audio activity subsides.
- [ ] Hysteresis and timeout prevent rapid visual flicker.
- [ ] Internal thresholds are not exposed in the settings window.
- [ ] macOS Reduce Motion suppresses Beat Pulses and Active Enhancement.
- [ ] Reduce Motion does not hide or blank the visualization.
