# Use Core Audio Process Tap

SoundViz uses a Core Audio Process Tap through a private aggregate device to read system output audio. This avoids the Screen Recording permission and purple screen-capture indicator that would be required by ScreenCaptureKit, while still providing access to system output. The tradeoff is a higher macOS-version requirement and dependence on Core Audio Tap authorization behavior.
