# 05: Beat Pulse Intensity end-to-end

**What to build:** Let users control Beat Pulse strength with Off, Low, Normal, and High presets. The feature changes only rhythmic visual emphasis; it does not alter frequency organization or read System Volume.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** resolved

- [x] Off suppresses rhythmic enhancement while preserving the underlying visualization form.
- [x] Low produces less movement than Normal.
- [x] Normal is the default and preserves the current general feel.
- [x] High produces the strongest bounded emphasis.
- [x] Changing intensity applies immediately and persists.
- [x] Beat Pulse Intensity applies to Spectrum Bars, Waveform Line, and Spectrum Area.
- [x] Tests verify relative ordering and the Off state without depending on real music.

## Answer

Implemented with Off / Low / Normal / High pulse scales, immediate intensity changes, Off cleanup for in-progress pulses, and synthetic rendering tests that preserve the underlying visualization form.
