# 09: English and Simplified Chinese localization

**What to build:** Localize every user-facing menu item, settings label, option, status message, recovery action, and accessibility label in English and Simplified Chinese. Select Simplified Chinese when the system preferred language is Simplified Chinese; otherwise use English.

**Blocked by:** 02 — SwiftUI settings window; 03 — Band Preset end-to-end; 04 — Motion Response Preset end-to-end; 05 — Beat Pulse Intensity end-to-end; 06 — Scene adaptation and Reduce Motion; 07 — Rendering cadence and power cap; 08 — Capture state and recovery UX.

**Status:** resolved

- [x] All menu items are localized.
- [x] All settings labels, option labels, section headings, and help text are localized.
- [x] All capture states and recovery actions are localized.
- [x] English is the fallback language.
- [x] Simplified Chinese is selected when the system preferred language is Simplified Chinese.
- [x] Language selection follows system preferences; there is no in-app language switcher.
- [x] Screenshots for English and Simplified Chinese are checked manually.

## Answer

Implemented centralized English and Simplified Chinese text selection, localized menus, settings, states, recovery actions, and error messages. Verified language selection with automated tests and manually checked English/Simplified Chinese settings-window screenshots.
