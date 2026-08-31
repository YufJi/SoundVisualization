# Adaptive Visualization Settings

## Problem Statement

SoundViz currently gives users only a small menu for choosing among three Visualization Styles. There is no way to tune how responsive the menu bar feels, how many Frequency Bands are shown, how strongly Beat Pulses appear, or how the visual behaves during quiet periods. Users also cannot tell from the icon whether capture is stopped, blocked by permission, or failed at runtime.

As a result, the same visual motion must serve very different listening material and environments. A quiet podcast, a detailed acoustic track, and a dense modern production can all produce a menu bar that feels either too subtle or too busy. The tool also asks users to infer errors instead of providing a clear recovery path.

## Solution

Add a single-instance SwiftUI settings window with Global Parameters for Visualization Style, Band Preset, Motion Response Preset, Beat Pulse Intensity, Scene Adaptation Switch, and Rendering Cadence. Apply every change immediately and persist it automatically.

Make menu-bar motion scene-aware: remain quiet when there is little meaningful audio, become more active when spectral content or a Beat Pulse warrants it, and reduce prominence and Rendering Cadence during the Low-distraction Baseline or macOS Low Power Mode. Keep the menu bar recognizable in all states.

Make capture states explicit. Stopped, permission-blocked, failed, and running states should have distinct menu status and predictable icon behavior. Permission and runtime failures should offer recovery actions instead of failing silently.

## User Stories

1. As a macOS user, I want a settings window, so that I can tune SoundViz without editing source code or defaults.
2. As a menu bar user, I want settings changes to apply immediately, so that I can see the effect without restarting the app.
3. As a menu bar user, I want settings to persist automatically, so that my visualization looks the same after relaunch.
4. As a returning user, I want my Visualization Style to be remembered, so that SoundViz opens in the form I prefer.
5. As a first-time user, I want Spectrum Bars by default, so that my first experience is recognizable and easy to understand.
6. As a visual precision seeker, I want to choose 8, 12, 16, or 24 Frequency Bands, so that I can trade detail for clarity.
7. As a user who prefers a calm menu bar, I want fewer Frequency Bands, so that the visualization remains readable at a glance.
8. As a user who enjoys detailed music, I want more Frequency Bands, so that spectral changes are more visible.
9. As a Spectrum Bars user, I want the Band Preset to control the number of bars, so that the setting directly matches the visual result.
10. As a Spectrum Area user, I want the Band Preset to control the spectral curve resolution, so that the area feels smoother or more detailed.
11. As a Waveform Line user, I want Band Preset to remain saved but be disabled in the settings window, so that I understand it applies only to spectrum-oriented styles.
12. As a rhythm-focused listener, I want Beat Pulse Intensity presets, so that I can emphasize musical attacks without understanding DSP thresholds.
13. As a user working in a quiet space, I want to turn Beat Pulses off, so that the menu bar does not distract people nearby.
14. As a user listening to bass-heavy music, I want a High Beat Pulse Intensity option, so that rhythmic energy remains visible in dense audio.
15. As a user who dislikes exaggerated motion, I want Motion Response Presets, so that I can choose between snappy, balanced, and smooth behavior.
16. As a user comparing settings, I want motion changes to be visible immediately, so that I can choose the best preset by observation.
17. As a laptop user, I want Standard 30 fps rendering by default, so that SoundViz does not consume unnecessary energy.
18. As a user with a high-refresh display, I want optional 60 fps rendering, so that fast transients look smoother.
19. As a battery-conscious user, I want rendering to cap at 15 fps in Low-distraction Baseline or Low Power Mode, so that visualization remains useful without draining the battery.
20. As a user who selected 60 fps, I want my preference retained during Low Power Mode, so that it returns automatically when power constraints end.
21. As a user in a meeting, I want scene-aware low-distraction behavior, so that SoundViz becomes quieter when audio activity does not justify motion.
22. As a music listener, I want Active Enhancement during rhythmic passages, so that the visual follows the listening experience.
23. As a user who wants stable visuals, I want a Scene Adaptation Switch, so that I can disable automatic intensity changes.
24. As a user who does not want to understand signal processing, I want scene thresholds to be internal, so that I only control the behavior I care about.
25. As a privacy-conscious user, I want visualization to remain independent of system volume, so that changing loudness does not change the meaning of the visual.
26. As a privacy-conscious user, I want audio to stay in memory, so that SoundViz cannot accumulate recordings or upload sound.
27. As a user with a music player open, I want a Stopped State that remains recognizable, so that I can tell SoundViz is present but not listening.
28. As a paused user, I want settings to remain editable while Listening is stopped, so that I can prepare preferences for the next session.
29. As a user troubleshooting capture, I want a visible permission status, so that I know why the visualization is not moving.
30. As a user who accidentally denied permission, I want actions to open System Settings and retry, so that I can recover without relaunching blindly.
31. As a user encountering a Capture Failure, I want the failure reason and a Retry action, so that I can distinguish permission issues from runtime failures.
32. As a user with an unstable audio setup, I want failed capture to stop instead of retrying endlessly, so that SoundViz does not consume resources in the background.
33. As a user who enables macOS Reduce Motion, I want Beat Pulses and Active Enhancement suppressed, so that SoundViz respects my accessibility preference.
34. As a Reduce Motion user, I want the visualization form to remain visible, so that SoundViz does not disappear from the menu bar.
35. As an English-language user, I want localized menus and settings, so that the interface reads naturally.
36. As a Simplified Chinese user, I want localized menus and settings, so that I can use SoundViz without translating terminology.
37. As a user with duplicate settings windows, I want only one settings window to exist, so that I do not edit stale copies of the same preferences.
38. As a user who closes the settings window, I want Listening to continue, so that window management does not interrupt visualization.
39. As a user experimenting with preferences, I want Restore Defaults, so that I can recover a known-good configuration.
40. As a contributor, I want settings behavior tested through stable seams, so that future DSP and UI changes do not regress the user-visible model.

## Implementation Decisions

- Add a Visualization Settings value model containing Visualization Style, Band Preset, Motion Response Preset, Beat Pulse Intensity, Scene Adaptation Switch, and Rendering Cadence.
- Add a settings persistence boundary responsible for automatic loading, saving, and Restore Defaults. All settings apply immediately; there is no separate save action.
- Use Global Parameters for the first release. Reserve Style Override in the domain model, but do not expose it in settings UI.
- Configure the Spectrum Analyzer with the selected Band Preset. Supported presets are 8, 12, 16, and 24 bands; 12 is default.
- Keep Motion Response Presets as Snappy, Balanced, and Smooth. Internally, each preset may use different attack and decay values, but users do not tune those values separately.
- Represent Beat Pulse Intensity as Off, Low, Normal, and High. Normal is the default.
- Add scene-aware rendering states for Low-distraction Baseline, normal listening, and Active Enhancement. Scene Adaptation uses audio activity, Beat Pulses, hysteresis, and timeout; thresholds are internal and not exposed.
- Introduce a render scheduler that supports Standard 30 fps, optional High 60 fps, and a Reduced Cadence Cap of 15 fps. Low-distraction Baseline and macOS Low Power Mode apply the 15 fps cap while retaining the user's cadence preference.
- Honor macOS Reduce Motion by suppressing Beat Pulses and Active Enhancement while continuing to render the selected Visualization Style in a calmer form.
- Keep Band Preset saved when Waveform Line is active, but disable the control and explain that it affects only spectrum-oriented styles.
- Add a single-instance SwiftUI settings window triggered from the existing AppKit menu. Opening it again focuses the existing window; closing it does not stop Listening.
- Keep high-frequency Quick Controls in the menu: Visualization Style submenu, Audio-adaptive motion switch, start/stop Listening, settings entry, and quit.
- Show a static Attenuated Baseline when Listening is stopped. Keep settings and Quick Controls available while stopped.
- Differentiate missing permission, denied permission, and runtime Capture Failure. Permission states expose System Settings and Retry actions; runtime failures expose a failure reason and Retry. Capture Failure stops Listening and returns the icon to Attenuated Baseline.
- Localize user-facing text in English and Simplified Chinese. Simplified Chinese is selected when the system preferred language is Simplified Chinese; otherwise English is used.
- Preserve the existing privacy boundary: visualization uses spectral content rather than system volume, and captured audio stays in memory only.

## Testing Decisions

Test externally observable behavior rather than private drawing internals or Core Audio implementation details.

Use the existing `SpectrumAnalyzer.process` seam to verify that each Band Preset produces the expected Frequency Band count, stable frame shape, finite values, and deterministic behavior for repeated synthetic input.

Use the settings persistence boundary to verify defaults, automatic save/load, Restore Defaults, validation of supported presets, and preservation of Band Preset while Waveform Line is active. Inject the persistence backing store rather than relying on the user's real defaults.

Use the existing `AudioVisualizer.push` and image-update seam to verify style switching, envelope smoothing, Beat Pulse Intensity, Low-distraction attenuation, cadence selection, Low Power capping, and Reduce Motion behavior. Introduce a testable scheduler or clock only if the existing Timer cannot exercise cadence deterministically.

Use a fake conforming to the existing `CaptureControlling` seam to test menu state transitions, Stopped State, permission recovery actions, and Capture Failure recovery without creating real Core Audio taps.

Existing `SoundVizTests` are the prior art: small XCTest cases using synthetic sine input and assertions on externally returned frame shape and values.

Core Audio Tap creation, macOS permission prompts, actual system audio routing, menu bar appearance, Low Power Mode behavior, and Reduce Motion require manual verification on macOS 14.2+.

## Out of Scope

- Style Override settings UI.
- Arbitrary Frequency Band counts outside the four presets.
- User-facing Scene Adaptation thresholds, sensitivity sliders, timeout fields, or hysteresis controls.
- 60 fps as an always-on default.
- Audio recording, waveform display windows, saved sessions, playback, or export.
- Reading, displaying, or visualizing system volume.
- Network functionality, telemetry, accounts, or cloud sync.
- Languages beyond English and Simplified Chinese.
- Launch at Login, global hotkeys, Sparkle updates, notarization, and sandbox configuration.

## Further Notes

This spec implements the settings and adaptation decisions recorded in `CONTEXT.md`, `docs/specs/0001-adaptive-visualization-settings.md`, and ADR-0002 through ADR-0005. It deliberately keeps the privacy boundary visible to future contributors: visual motion comes from spectral content, not loudness, and captured audio never leaves memory.
