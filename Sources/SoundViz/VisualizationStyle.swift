import Foundation

enum VisualizationStyle: String, CaseIterable, Codable {
    case bars
    case waveform
    case spectrumArea

    var title: String {
        switch self {
        case .bars:
            return "柱状频谱"
        case .waveform:
            return "波形线"
        case .spectrumArea:
            return "频谱带"
        }
    }
}
