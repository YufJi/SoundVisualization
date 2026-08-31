# SoundViz Context

SoundViz turns macOS system output audio into ambient menu-bar visual motion. It favors a privacy-preserving, low-distraction experience that can temporarily become more rhythmic when the audio warrants it.

## Language

### Audio

**System Audio**:
Audio produced by applications and rendered to the selected macOS output device.
_Avoid_: microphone input, system volume

**Listening**:
The active capture and analysis of System Audio for visualization.
_Avoid_: recording, monitoring

**Spectral Frame**:
A short-time frequency snapshot derived from System Audio.
_Avoid_: audio chunk, sample buffer

**Frequency Band**:
A logarithmic range of frequencies used to aggregate spectral content.
_Avoid_: EQ slider, channel

**Adaptive Normalization**:
Per-band adjustment that keeps visual motion comparable over changing audio material without using System Volume.
_Avoid_: gain, loudness matching

### Visualization

**Visualization Style**:
The selected presentation form for menu-bar audio motion.
_Avoid_: theme, skin

**Spectrum Bars**:
A Visualization Style showing discrete Frequency Bands as centered vertical bars.
_Avoid_: EQ view

**Waveform Line**:
A Visualization Style showing a smoothed time-domain curve.
_Avoid_: oscilloscope mode

**Spectrum Area**:
A Visualization Style showing a smooth spectral curve with a filled region.
_Avoid_: mountain chart

**Beat Pulse**:
A transient low-frequency emphasis triggered by a detected musical onset.
_Avoid_: volume boost, bass boost

**Low-distraction Baseline**:
The quiet visual state used when music does not justify stronger motion.
_Avoid_: idle mode, sleep mode

**Active Enhancement**:
A temporary, bounded increase in visual motion when spectral activity or a Beat Pulse warrants it.
_Avoid_: party mode, full-power mode

### Preferences

**Visualization Settings**:
The user-controlled collection that governs visual motion, Frequency Band organization, Beat Pulse strength, and Rendering Cadence.
_Avoid_: preferences panel, config file

**Global Parameter**:
A Visualization Setting that applies across Visualization Styles unless a Style Override changes it.
_Avoid_: master setting, common setting

**Style Override**:
A Visualization Style-specific exception to a Global Parameter.
_Avoid_: custom mode, advanced mode

**Band Preset**:
A named selection of the number of Frequency Bands used by spectrum-oriented styles.
_Avoid_: custom band count, EQ preset

**Beat Pulse Intensity**:
The user-selected strength of Beat Pulses, including the option to turn them off.
_Avoid_: bass level, volume boost

**Motion Smoothing**:
The degree to which visual changes are temporally softened while preserving attack and decay differences.
_Avoid_: latency reduction, FPS smoothing

**Rendering Cadence**:
The target rate at which menu-bar visual state is refreshed.
_Avoid_: FPS setting, audio sample rate

**Scene Adaptation**:
Automatic movement between the Low-distraction Baseline and Active Enhancement based on Listening activity.
_Avoid_: app detection, fullscreen detection

**Remembered Style**:
The persisted Visualization Style restored when SoundViz launches.
_Avoid_: last theme, recent style

**Motion Response Preset**:
A named Motion Smoothing choice: Snappy, Balanced, or Smooth.
_Avoid_: FPS preset, quality preset

**High Cadence**:
The optional 60 fps Rendering Cadence selected by the user.
_Avoid_: performance mode, gaming mode

**Reduced Cadence Cap**:
A temporary 15 fps ceiling applied during Low-distraction Baseline or low-power conditions.
_Avoid_: throttling, slowdown

**Scene Adaptation Switch**:
The user control that enables or disables automatic movement between visual states.
_Avoid_: sensitivity slider, threshold setting

**Inactive Parameter**:
A setting retained for the user's chosen style but temporarily not applicable to the active Visualization Style.
_Avoid_: deleted setting, reset setting

**Restore Defaults**:
The action that returns Visualization Settings to their agreed baseline values.
_Avoid_: reset app, clear listening history

**Default Visualization Settings**:
The agreed baseline parameter values used on first launch and by Restore Defaults.
_Avoid_: factory reset, recommended experiment

**Attenuated Baseline**:
The Low-distraction Baseline presentation that preserves visual identity while reducing motion and prominence.
_Avoid_: hidden state, static placeholder

**Quick Controls**:
High-frequency menu commands that change visualization behavior without opening the settings window.
_Avoid_: advanced settings, diagnostics

**Reduce Motion Compliance**:
Suppression of rhythmic pulses and Active Enhancement when macOS requests reduced motion.
_Avoid_: disabling visualization

**Bilingual Interface**:
User-facing English and Simplified Chinese text selected by the system's preferred language.
_Avoid_: in-app language switcher

**Single-instance Settings Window**:
The one detailed settings window; opening it again focuses the existing window.
_Avoid_: multiple editors, modal sheet

**Stopped State**:
The state after Listening ends where the menu bar shows a calm, recognizable visual without live motion.
_Avoid_: quit state, hidden state

**Permission Recovery**:
The user-initiated path from an audio capture permission problem back to Listening.
_Avoid_: automatic authorization, repeated prompting

**Capture Failure**:
A runtime failure of the audio tap or aggregate device after Listening has started.
_Avoid_: permission problem, app crash

**Language Fallback**:
The rule that selects Simplified Chinese for a Simplified Chinese system and English otherwise.
_Avoid_: region-based language, automatic translation
