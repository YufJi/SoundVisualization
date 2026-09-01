import AppKit

let application = NSApplication.shared
let settingsStore = UserDefaultsSettingsStore()
let settings = settingsStore.load()
let settingsModel = VisualizationSettingsModel(settings: settings, store: settingsStore)
let visualizer = AudioVisualizer(
    style: settings.style,
    bandPreset: settings.bandPreset,
    motionResponsePreset: settings.motionResponsePreset,
    renderingCadence: settings.renderingCadence,
    renderScheduler: TimerRenderScheduler()
)
visualizer.updateBeatPulseIntensity(settings.beatPulseIntensity)
visualizer.updateLowPowerMode(ProcessInfo.processInfo.isLowPowerModeEnabled)
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
