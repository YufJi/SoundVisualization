import Foundation

protocol VisualizationSettingsStoring {
    func load() -> VisualizationSettings
    func save(_ settings: VisualizationSettings)
    func restoreDefaults() -> VisualizationSettings
}

final class UserDefaultsSettingsStore: VisualizationSettingsStoring {
    static let settingsKey = "visualizationSettings"
    static let legacyStyleKey = "visualizationStyle"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> VisualizationSettings {
        if let data = defaults.data(forKey: Self.settingsKey),
           let settings = try? JSONDecoder().decode(VisualizationSettings.self, from: data) {
            return settings
        }

        if let legacyStyleRawValue = defaults.string(forKey: Self.legacyStyleKey),
           let legacyStyle = VisualizationStyle(rawValue: legacyStyleRawValue) {
            var settings = VisualizationSettings.default
            settings.style = legacyStyle
            save(settings)
            defaults.removeObject(forKey: Self.legacyStyleKey)
            return settings
        }

        return .default
    }

    func save(_ settings: VisualizationSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: Self.settingsKey)
    }

    func restoreDefaults() -> VisualizationSettings {
        let settings = VisualizationSettings.default
        save(settings)
        return settings
    }
}
