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

    func testSpectrumAnalyzerSupportsEveryBandPreset() {
        let samples = (0..<512).map { index in
            sin(2 * Float.pi * Float(index) * 220 / 48_000) * 0.2
        }

        for preset in BandPreset.allCases {
            let analyzer = SpectrumAnalyzer(requestedSampleRate: 48_000, requestedBandCount: preset.rawValue)
            let frame = analyzer.process(samples: samples, timestamp: 0)

            XCTAssertEqual(frame.bands.count, preset.rawValue)
            XCTAssertTrue(frame.bands.allSatisfy { $0.isFinite && $0 >= 0 })
            let secondFrame = analyzer.process(samples: samples, timestamp: 0.01)
            XCTAssertEqual(secondFrame.bands.count, preset.rawValue)
            XCTAssertTrue(secondFrame.bands.allSatisfy { $0.isFinite && $0 >= 0 })
            XCTAssertTrue(frame.waveform.allSatisfy { $0.isFinite })
            XCTAssertTrue(frame.beat.isFinite && frame.beat >= 0)
            XCTAssertTrue(secondFrame.waveform.allSatisfy { $0.isFinite })
            XCTAssertTrue(secondFrame.beat.isFinite && secondFrame.beat >= 0)
        }
    }

    func testBandPresetPersistsWithWaveformStyle() throws {
        let temporaryDefaults = makeTemporaryDefaults()
        let store = UserDefaultsSettingsStore(defaults: temporaryDefaults)
        var settings = VisualizationSettings.default
        settings.style = .waveform
        settings.bandPreset = .twentyFour

        store.save(settings)

        XCTAssertEqual(store.load(), settings)
        XCTAssertEqual(store.load().bandPreset, .twentyFour)
    }

    func testAudioVisualizerAdoptsUpdatedBandCount() {
        let visualizer = AudioVisualizer(style: .bars, bandPreset: .twelve)

        XCTAssertEqual(visualizer.bandCount, 12)
        visualizer.updateBandPreset(.sixteen)

        XCTAssertEqual(visualizer.bandCount, 16)
    }

    func testCaptureControllerStoresBandPresetWhenNoAnalyzerExists() {
        let controller = SystemAudioCaptureController(
            bandPreset: .twelve,
            onSpectrum: { _ in },
            onStateChange: { _ in }
        )

        XCTAssertEqual(controller.bandPreset, .twelve)
        controller.updateBandPreset(.twentyFour)

        XCTAssertEqual(controller.bandPreset, .twentyFour)
    }

    func testBeatPulseIntensitiesHaveExpectedScales() {
        XCTAssertEqual(BeatPulseIntensity.off.pulseScale, 0)
        XCTAssertEqual(BeatPulseIntensity.low.pulseScale, 0.55)
        XCTAssertEqual(BeatPulseIntensity.normal.pulseScale, 1)
        XCTAssertEqual(BeatPulseIntensity.high.pulseScale, 1.6)
    }

    func testAudioVisualizerAdoptsBeatPulseIntensity() {
        let visualizer = AudioVisualizer(style: .bars)

        XCTAssertEqual(visualizer.beatPulseIntensity, .normal)
        visualizer.updateBeatPulseIntensity(.off)

        XCTAssertEqual(visualizer.beatPulseIntensity, .off)
    }

    func testBeatPulseIntensityOrdersRenderedPulseWhilePreservingSpectrumForm() {
        let spectrum = SpectrumFrame(
            bands: [Float](repeating: 0.8, count: 12),
            beat: 1,
            waveform: [Float](repeating: 0.25, count: 32)
        )
        var renderedBeats: [CGFloat] = []

        for intensity in BeatPulseIntensity.allCases {
            let visualizer = AudioVisualizer(style: .bars)
            let originalStyle = visualizer.style
            let originalBandCount = visualizer.bandCount

            visualizer.updateBeatPulseIntensity(intensity)
            XCTAssertEqual(visualizer.beatPulseIntensity, intensity)
            XCTAssertEqual(visualizer.beatPulseScale, intensity.pulseScale)

            visualizer.applySpectrum(spectrum)
            XCTAssertEqual(visualizer.targetBeat, Float(intensity.pulseScale))
            visualizer.render()

            renderedBeats.append(visualizer.currentBeat)
            XCTAssertEqual(visualizer.style, originalStyle)
            XCTAssertEqual(visualizer.bandCount, originalBandCount)
        }

        XCTAssertEqual(renderedBeats[0], 0)
        XCTAssertLessThan(renderedBeats[1], renderedBeats[2])
        XCTAssertLessThan(renderedBeats[2], renderedBeats[3])
    }

    func testSceneAdapterActivatesAndDeactivatesWithHysteresisAndTimeout() {
        let adapter = SceneAdapter()
        let activeSpectrum = SpectrumFrame(
            bands: [Float](repeating: 0.8, count: 12),
            beat: 0,
            waveform: [Float](repeating: 0, count: 32)
        )
        let quietSpectrum = SpectrumFrame(
            bands: [Float](repeating: 0.1, count: 12),
            beat: 0,
            waveform: [Float](repeating: 0, count: 32)
        )
        let moderateSpectrum = SpectrumFrame(
            bands: [Float](repeating: 0.45, count: 12),
            beat: 0,
            waveform: [Float](repeating: 0, count: 32)
        )

        XCTAssertEqual(
            adapter.update(
                spectrum: activeSpectrum,
                sceneAdaptationEnabled: true,
                reduceMotion: false,
                timestamp: 0
            ),
            .active
        )
        XCTAssertEqual(
            adapter.update(
                spectrum: moderateSpectrum,
                sceneAdaptationEnabled: true,
                reduceMotion: false,
                timestamp: 0.5
            ),
            .active
        )
        XCTAssertEqual(
            adapter.update(
                spectrum: quietSpectrum,
                sceneAdaptationEnabled: true,
                reduceMotion: false,
                timestamp: 0.6
            ),
            .active
        )
        XCTAssertEqual(
            adapter.update(
                spectrum: quietSpectrum,
                sceneAdaptationEnabled: true,
                reduceMotion: false,
                timestamp: 1.9
            ),
            .lowDistraction
        )
    }

    func testSceneAdapterDisabledPreventsStateMovement() {
        let adapter = SceneAdapter()
        let activeSpectrum = SpectrumFrame(
            bands: [Float](repeating: 0.8, count: 12),
            beat: 0,
            waveform: [Float](repeating: 0, count: 32)
        )
        let quietSpectrum = SpectrumFrame(
            bands: [Float](repeating: 0.1, count: 12),
            beat: 0,
            waveform: [Float](repeating: 0, count: 32)
        )

        XCTAssertEqual(
            adapter.update(
                spectrum: activeSpectrum,
                sceneAdaptationEnabled: true,
                reduceMotion: false,
                timestamp: 0
            ),
            .active
        )
        XCTAssertEqual(
            adapter.update(
                spectrum: quietSpectrum,
                sceneAdaptationEnabled: false,
                reduceMotion: false,
                timestamp: 10
            ),
            .active
        )
    }

    func testSceneAdapterDisabledRetainsInitialLowDistraction() {
        let adapter = SceneAdapter()
        let quietSpectrum = SpectrumFrame(
            bands: [Float](repeating: 0.1, count: 12),
            beat: 0,
            waveform: [Float](repeating: 0, count: 32)
        )

        let state = adapter.update(
            spectrum: quietSpectrum,
            sceneAdaptationEnabled: false,
            reduceMotion: false,
            timestamp: 10
        )

        XCTAssertEqual(state, .lowDistraction)
    }

    func testSceneAdapterReduceMotionForcesLowDistraction() {
        let adapter = SceneAdapter()
        let activeSpectrum = SpectrumFrame(
            bands: [Float](repeating: 0.9, count: 12),
            beat: 1,
            waveform: [Float](repeating: 0, count: 32)
        )

        let state = adapter.update(
            spectrum: activeSpectrum,
            sceneAdaptationEnabled: true,
            reduceMotion: true,
            timestamp: 10
        )

        XCTAssertEqual(state, .lowDistraction)
    }

    func testReduceMotionSuppressesPulseWhilePreservingVisualization() {
        let visualizer = AudioVisualizer(style: .bars)
        let spectrum = SpectrumFrame(
            bands: [Float](repeating: 0.9, count: 12),
            beat: 1,
            waveform: [Float](repeating: 0.25, count: 32)
        )

        visualizer.updateReduceMotion(true)
        visualizer.applySpectrum(spectrum)
        visualizer.render()

        XCTAssertEqual(visualizer.motionState, .lowDistraction)
        XCTAssertEqual(visualizer.currentBeat, 0)
        XCTAssertEqual(visualizer.style, .bars)
        XCTAssertEqual(visualizer.bandCount, 12)
        XCTAssertLessThan(visualizer.prominenceScale, 1)
    }

    func testMotionResponsePresetsHaveDistinctParameters() {
        let presets = MotionResponsePreset.allCases
        let parameters = presets.map(\.parameters)

        XCTAssertNotEqual(parameters[0], parameters[1])
        XCTAssertNotEqual(parameters[0], parameters[2])
        XCTAssertNotEqual(parameters[1], parameters[2])

        let expectedBandAttack: [Float] = [0.85, 0.65, 0.38]
        let expectedBandDecay: [Float] = [0.42, 0.16, 0.06]
        let expectedWaveformSmoothing: [Float] = [0.75, 0.55, 0.30]
        let expectedBeatDecay: [Float] = [0.70, 0.82, 0.92]

        for index in 0..<presets.count {
            XCTAssertEqual(parameters[index].bandAttack, expectedBandAttack[index])
            XCTAssertEqual(parameters[index].bandDecay, expectedBandDecay[index])
            XCTAssertEqual(parameters[index].waveformSmoothing, expectedWaveformSmoothing[index])
            XCTAssertEqual(parameters[index].beatDecay, expectedBeatDecay[index])
        }
    }

    func testAudioVisualizerAdoptsMotionResponsePreset() {
        let visualizer = AudioVisualizer(style: .bars)

        XCTAssertEqual(visualizer.motionResponsePreset, .balanced)
        visualizer.updateMotionResponse(.snappy)

        XCTAssertEqual(visualizer.motionResponsePreset, .snappy)
    }

    func testCaptureControllerAdoptsMotionResponsePreset() {
        let controller = SystemAudioCaptureController(
            onSpectrum: { _ in },
            onStateChange: { _ in }
        )

        XCTAssertEqual(controller.motionResponsePreset, .balanced)
        controller.updateMotionResponse(.smooth)

        XCTAssertEqual(controller.motionResponsePreset, .smooth)
    }

    func testSpectrumAnalyzerAdoptsMotionResponsePreset() throws {
        let analyzer = SpectrumAnalyzer(
            requestedSampleRate: 48_000,
            requestedBandCount: 12,
            motionResponsePreset: .balanced
        )

        XCTAssertEqual(analyzer.motionResponsePreset, .balanced)
        analyzer.updateMotionResponse(.snappy)

        XCTAssertEqual(analyzer.motionResponsePreset, .snappy)
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
