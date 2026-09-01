# 07: Rendering cadence and power cap

**What to build:** Add a rendering scheduler that supports Standard 30 fps, optional High 60 fps, and a 15 fps Reduced Cadence Cap during Low-distraction Baseline or macOS Low Power Mode. Preserve the user's cadence preference while the cap is active.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** resolved

- [x] Standard cadence renders at 30 fps.
- [x] High cadence renders at up to 60 fps when enabled.
- [x] Low-distraction Baseline caps rendering at 15 fps.
- [x] macOS Low Power Mode caps rendering at 15 fps.
- [x] The user's Standard or High preference is retained while the cap is active.
- [x] Changing cadence applies immediately without restarting Listening.
- [x] Cadence changes do not alter audio capture or analysis policy.
- [x] Scheduler behavior is covered by deterministic tests or a documented manual verification path.

## Answer

Implemented with an injectable rendering scheduler, immediate Standard/High cadence changes, system Low Power Mode observation, and a 15 fps cap during Low-distraction Baseline or Low Power Mode.
