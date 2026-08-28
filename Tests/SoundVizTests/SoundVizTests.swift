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
}
