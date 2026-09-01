import Foundation

enum VisualizationStyle: String, CaseIterable, Codable {
    case bars
    case waveform
    case spectrumArea

    var title: String {
        switch self {
        case .bars:
            return AppText.spectrumBars.localized
        case .waveform:
            return AppText.waveformLine.localized
        case .spectrumArea:
            return AppText.spectrumArea.localized
        }
    }
}
