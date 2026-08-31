# 05: Beat Pulse Intensity end-to-end

**What to build:** Let users control Beat Pulse strength with Off, Low, Normal, and High presets. The feature changes only rhythmic visual emphasis; it does not alter frequency organization or read System Volume.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** ready-for-agent

- [ ] Off suppresses rhythmic enhancement while preserving the underlying visualization form.
- [ ] Low produces less movement than Normal.
- [ ] Normal is the default and preserves the current general feel.
- [ ] High produces the strongest bounded emphasis.
- [ ] Changing intensity applies immediately and persists.
- [ ] Beat Pulse Intensity applies to Spectrum Bars, Waveform Line, and Spectrum Area.
- [ ] Tests verify relative ordering and the Off state without depending on real music.
