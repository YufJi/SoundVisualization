import XCTest

@testable import SoundViz

final class SoundVizTests: XCTestCase {
    func testVisualizationStyleTitles() {
        XCTAssertEqual(VisualizationStyle.bars.title, "柱状频谱")
        XCTAssertEqual(VisualizationStyle.waveform.title, "波形线")
        XCTAssertEqual(VisualizationStyle.spectrumArea.title, "频谱带")
        XCTAssertEqual(VisualizationStyle.allCases.count, 3)
    }

    func testSpectrumAnalyzerProducesStableFrameShape() throws {
        let analyzer = SpectrumAnalyzer(requestedSampleRate: 48_000, requestedBandCount: 12)
        let samples = (0..<512).map { index in
            sin(2 * Float.pi * Float(index) * 220 / 48_000) * 0.2
        }

        let firstFrame = analyzer.process(samples: samples, timestamp: 0)
        let secondFrame = analyzer.process(samples: samples, timestamp: 0.01)

        XCTAssertEqual(firstFrame.bands.count, 12)
        XCTAssertEqual(secondFrame.bands.count, 12)
        XCTAssertEqual(firstFrame.waveform.count, 32)
        XCTAssertEqual(secondFrame.waveform.count, 32)
        XCTAssertTrue(firstFrame.bands.allSatisfy { $0.isFinite })
        XCTAssertTrue(secondFrame.bands.allSatisfy { $0.isFinite })
        XCTAssertTrue(firstFrame.waveform.allSatisfy { $0.isFinite })
        XCTAssertTrue(secondFrame.waveform.allSatisfy { $0.isFinite })
    }

    func testDefaultVisualizationSettingsUseAgreedBaseline() {
        let settings = VisualizationSettings.default

        XCTAssertEqual(settings.style, .bars)
        XCTAssertEqual(settings.bandPreset, .twelve)
        XCTAssertEqual(settings.motionResponsePreset, .balanced)
        XCTAssertEqual(settings.beatPulseIntensity, .normal)
        XCTAssertTrue(settings.sceneAdaptationEnabled)
        XCTAssertEqual(settings.renderingCadence, .standard)
    }

    func testSettingsStoreRoundTripsSavedSettings() {
        let temporaryDefaults = makeTemporaryDefaults()
        let store = UserDefaultsSettingsStore(defaults: temporaryDefaults)
        var settings = VisualizationSettings.default
        settings.style = .spectrumArea
        settings.bandPreset = .sixteen
        settings.motionResponsePreset = .smooth
        settings.beatPulseIntensity = .off
        settings.sceneAdaptationEnabled = false
        settings.renderingCadence = .high

        store.save(settings)
        let loaded = store.load()

        XCTAssertEqual(loaded, settings)
    }

    func testSettingsStoreMigratesLegacyRememberedStyle() {
        let temporaryDefaults = makeTemporaryDefaults()
        temporaryDefaults.set("spectrumArea", forKey: UserDefaultsSettingsStore.legacyStyleKey)
        let store = UserDefaultsSettingsStore(defaults: temporaryDefaults)

        let settings = store.load()

        XCTAssertEqual(settings.style, .spectrumArea)
        XCTAssertEqual(settings.bandPreset, VisualizationSettings.default.bandPreset)
        XCTAssertEqual(settings.motionResponsePreset, VisualizationSettings.default.motionResponsePreset)
        XCTAssertEqual(settings.beatPulseIntensity, VisualizationSettings.default.beatPulseIntensity)
        XCTAssertEqual(settings.sceneAdaptationEnabled, VisualizationSettings.default.sceneAdaptationEnabled)
        XCTAssertEqual(settings.renderingCadence, VisualizationSettings.default.renderingCadence)
        XCTAssertNotNil(temporaryDefaults.data(forKey: UserDefaultsSettingsStore.settingsKey))
        XCTAssertNil(temporaryDefaults.string(forKey: UserDefaultsSettingsStore.legacyStyleKey))
    }

    func testSettingsStoreRestoreDefaultsReplacesSavedSettings() {
        let temporaryDefaults = makeTemporaryDefaults()
        let store = UserDefaultsSettingsStore(defaults: temporaryDefaults)
        var settings = VisualizationSettings.default
        settings.style = .waveform
        settings.bandPreset = .twentyFour
        settings.renderingCadence = .high
        store.save(settings)

        let restored = store.restoreDefaults()

        XCTAssertEqual(restored, VisualizationSettings.default)
        XCTAssertEqual(store.load(), VisualizationSettings.default)
    }

    func testSettingsModelUpdatePersistsAndNotifies() throws {
        let temporaryDefaults = makeTemporaryDefaults()
        let store = UserDefaultsSettingsStore(defaults: temporaryDefaults)
        let model = VisualizationSettingsModel(settings: .default, store: store)
        var publishedSettings: [VisualizationSettings] = []
        var changedSettings: [VisualizationSettings] = []
        let cancellable = model.$settings.dropFirst().sink { publishedSettings.append($0) }
        model.onChange = { changedSettings.append($0) }
        var settings = VisualizationSettings.default
        settings.bandPreset = .sixteen

        model.update(settings)

        XCTAssertEqual(publishedSettings, [settings])
        XCTAssertEqual(changedSettings, [settings])
        XCTAssertEqual(store.load(), settings)
        cancellable.cancel()
    }

    func testSettingsModelRestoreDefaultsPersistsAndNotifies() {
        let temporaryDefaults = makeTemporaryDefaults()
        let store = UserDefaultsSettingsStore(defaults: temporaryDefaults)
        let model = VisualizationSettingsModel(settings: .default, store: store)
        var changedSettings: [VisualizationSettings] = []
        model.onChange = { changedSettings.append($0) }
        var settings = VisualizationSettings.default
        settings.style = .waveform
        model.update(settings)

        model.restoreDefaults()

        XCTAssertEqual(model.settings, VisualizationSettings.default)
        XCTAssertEqual(changedSettings, [settings, VisualizationSettings.default])
        XCTAssertEqual(store.load(), VisualizationSettings.default)
    }

    private func makeTemporaryDefaults() -> UserDefaults {
        let suiteName = "SoundVizTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
