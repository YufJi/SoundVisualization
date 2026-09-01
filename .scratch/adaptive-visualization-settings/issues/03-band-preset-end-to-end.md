# 03: Band Preset end-to-end

**What to build:** Connect the selected Band Preset through analysis and rendering so spectrum-oriented Visualization Styles actually display 8, 12, 16, or 24 Frequency Bands. Waveform Line remains sample-based and unaffected.

**Blocked by:** 01 — Visualization settings model and persistence; 02 — SwiftUI settings window.

**Status:** resolved

- [x] Changing Band Preset immediately reconfigures analysis for the next Listening frames.
- [x] If Listening is stopped, the selected preset is used when Listening starts again.
- [x] Spectrum Bars renders exactly the selected number of Frequency Bands.
- [x] Spectrum Area renders exactly the selected number of Frequency Bands.
- [x] Waveform Line remains stable and does not change its point count when Band Preset changes.
- [x] Band Preset values are constrained to 8, 12, 16, and 24.
- [x] Analyzer tests cover every preset and assert stable, finite frame output.

## Answer

Implemented with configurable Band Presets, analyzer updates, dynamic spectrum rendering, persisted preferences, and multi-frame analyzer coverage.
