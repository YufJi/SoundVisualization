# 08: Capture state and recovery UX

**What to build:** Make Stopped State, permission problems, and runtime Capture Failure explicit and recoverable. Keep settings available in every non-terminated state and avoid infinite automatic retry.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** ready-for-agent

- [ ] Starting, Running, Stopped, Permission Required, and Capture Failure have distinct menu status text.
- [ ] Stopping Listening shows a static Attenuated Baseline while retaining the menu entry.
- [ ] Settings and Quick Controls remain available in Stopped State.
- [ ] Permission Required exposes an action to open the relevant macOS settings area.
- [ ] Permission Required exposes Retry without automatically repeating authorization prompts.
- [ ] Capture Failure exposes the failure reason and Retry.
- [ ] Capture Failure stops Listening and does not retry indefinitely.
- [ ] Successful Retry returns the menu to Running and resumes visualization.
