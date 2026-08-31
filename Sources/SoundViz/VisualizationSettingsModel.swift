import Combine
import Foundation

final class VisualizationSettingsModel: ObservableObject {
    @Published private(set) var settings: VisualizationSettings

    private let store: VisualizationSettingsStoring
    var onChange: ((VisualizationSettings) -> Void)?

    init(settings: VisualizationSettings, store: VisualizationSettingsStoring) {
        self.settings = settings
        self.store = store
    }

    func update(_ newSettings: VisualizationSettings) {
        settings = newSettings
        store.save(newSettings)
        onChange?(newSettings)
    }

    func restoreDefaults() {
        let settings = store.restoreDefaults()
        self.settings = settings
        onChange?(settings)
    }
}
