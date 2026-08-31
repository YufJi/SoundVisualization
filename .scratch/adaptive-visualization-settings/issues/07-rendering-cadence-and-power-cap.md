# 07: Rendering cadence and power cap

**What to build:** Add a rendering scheduler that supports Standard 30 fps, optional High 60 fps, and a 15 fps Reduced Cadence Cap during Low-distraction Baseline or macOS Low Power Mode. Preserve the user's cadence preference while the cap is active.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** ready-for-agent

- [ ] Standard cadence renders at 30 fps.
- [ ] High cadence renders at up to 60 fps when enabled.
- [ ] Low-distraction Baseline caps rendering at 15 fps.
- [ ] macOS Low Power Mode caps rendering at 15 fps.
- [ ] The user's Standard or High preference is retained while the cap is active.
- [ ] Changing cadence applies immediately without restarting Listening.
- [ ] Cadence changes do not alter audio capture or analysis policy.
- [ ] Scheduler behavior is covered by deterministic tests or a documented manual verification path.
