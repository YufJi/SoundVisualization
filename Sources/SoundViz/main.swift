import AppKit

let application = NSApplication.shared
let settingsStore = UserDefaultsSettingsStore()
let settings = settingsStore.load()
let settingsModel = VisualizationSettingsModel(settings: settings, store: settingsStore)
let visualizer = AudioVisualizer(
    style: settings.style,
    bandPreset: settings.bandPreset,
    motionResponsePreset: settings.motionResponsePreset
)
visualizer.updateBeatPulseIntensity(settings.beatPulseIntensity)
let delegate = AppDelegate(
    visualizer: visualizer,
    settingsModel: settingsModel
)
settingsModel.onChange = { [weak delegate] settings in
    delegate?.applyVisualSettings(settings)
}
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
