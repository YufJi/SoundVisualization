import AppKit

let application = NSApplication.shared
let settingsStore = UserDefaultsSettingsStore()
let settings = settingsStore.load()
let delegate = AppDelegate(
    visualizer: AudioVisualizer(style: settings.style),
    settings: settings,
    settingsStore: settingsStore
)
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
