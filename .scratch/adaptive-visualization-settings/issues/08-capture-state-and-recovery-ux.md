# 08: Capture state and recovery UX

**What to build:** Make Stopped State, permission problems, and runtime Capture Failure explicit and recoverable. Keep settings available in every non-terminated state and avoid infinite automatic retry.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** resolved

- [x] Starting, Running, Stopped, Permission Required, and Capture Failure have distinct menu status text.
- [x] Stopping Listening shows a static Attenuated Baseline while retaining the menu entry.
- [x] Settings and Quick Controls remain available in Stopped State.
- [x] Permission Required exposes an action to open the relevant macOS settings area.
- [x] Permission Required exposes Retry without automatically repeating authorization prompts.
- [x] Capture Failure exposes the failure reason and Retry.
- [x] Capture Failure stops Listening and does not retry indefinitely.
- [x] Successful Retry returns the menu to Running and resumes visualization.

## Answer

Implemented with CaptureFailure classification, distinct menu states, dedicated permission/runtime recovery actions, no automatic retry loop, and an Attenuated Baseline for stopped or failed sessions.
