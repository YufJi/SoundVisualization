# Adaptive Visualization Settings

## Summary

Add a single-instance SwiftUI settings window and complete the adaptive menu-bar visualization experience. The product remains a local-first, polished open-source macOS menu bar tool. Visualization motion is derived from spectral content and Beat Pulses, never from system volume.

## Product principles

- SoundViz is a low-distraction menu bar utility.
- It becomes more active only when audio activity or a Beat Pulse warrants it.
- Changes to Visualization Settings apply immediately and persist automatically.
- The product respects macOS Reduce Motion without hiding the selected visualization form.
- System Audio remains in memory only: no recording, persistence, upload, or playback.
- Visualization does not read or expose system volume.

## Settings model

The first settings release exposes Global Parameters only. Style Override remains a future extension point.

| Setting | Values | Default |
| --- | --- | --- |
| Visualization Style | Spectrum Bars / Waveform Line / Spectrum Area | Remembered Style; first launch uses Spectrum Bars |
| Band Preset | 8 / 12 / 16 / 24 Frequency Bands | 12 |
| Motion Response Preset | Snappy / Balanced / Smooth | Balanced |
| Beat Pulse Intensity | Off / Low / Normal / High | Normal |
| Scene Adaptation Switch | On / Off | On |
| Rendering Cadence | Standard 30 fps / High 60 fps | Standard 30 fps |

All settings apply immediately. The selected Visualization Style is persisted as the Remembered Style. Restore Defaults returns every setting to the values above and resets Visualization Style to Spectrum Bars.

Band Preset is retained when the active Visualization Style is Waveform Line, but the control is disabled there with an explanation that it only affects spectrum-oriented styles. Style Override has no first-release UI.

## Rendering and adaptation

- Standard Rendering Cadence is 30 fps.
- High Cadence is optional 60 fps.
- Low-distraction Baseline and macOS Low Power Mode cap rendering at 15 fps.
- Scene Adaptation automatically moves between Low-distraction Baseline and Active Enhancement using audio activity, Beat Pulses, hysteresis, and timeout. Its thresholds are internal and are not exposed in the first release.
- The Scene Adaptation Switch defaults to On.
- Under macOS Reduce Motion, Beat Pulse and Active Enhancement are suppressed, but the selected spectral or waveform form remains visible.

## Interface

The menu keeps Quick Controls for Visualization Style, Scene Adaptation Switch, start/stop Listening, and quit. Scene Adaptation is presented as **Audio-adaptive motion**.

A separate single-instance settings window contains a single scrolling form with sections for Motion, Frequency, Beat, Rendering, and Scene. Opening it again focuses the existing window. Closing it does not stop Listening.

The interface supports English and Simplified Chinese. Simplified Chinese is used when the system preferred language is Simplified Chinese; otherwise English is used.

## Stopped and failure states

When Listening is stopped, the menu bar shows a static Attenuated Baseline instead of live motion. Settings and Quick Controls remain available; changes are saved and affect the next Listening session.

If audio capture permission is missing or denied, the menu shows permission status with actions to open System Settings and retry. The icon remains in an Attenuated Baseline.

If Capture Failure occurs while running, Listening stops, the menu shows the failure reason and Retry, and the icon returns to an Attenuated Baseline. The app does not retry indefinitely.

## Out of scope

- Style Override UI.
- User-editable Scene Adaptation thresholds or sensitivity.
- Arbitrary Frequency Band counts.
- 60 fps as an always-on default.
- Audio recording, persistence, upload, or playback.
- System volume as a visualization input.
