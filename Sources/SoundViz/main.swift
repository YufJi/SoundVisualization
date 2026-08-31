import AppKit

let application = NSApplication.shared
let settingsStore = UserDefaultsSettingsStore()
let settings = settingsStore.load()
let settingsModel = VisualizationSettingsModel(settings: settings, store: settingsStore)
let delegate = AppDelegate(
    visualizer: AudioVisualizer(style: settings.style),
    settingsModel: settingsModel
)
settingsModel.onChange = { [weak delegate] settings in
    delegate?.applyVisualSettings(settings)
}
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
