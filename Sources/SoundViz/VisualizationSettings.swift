import Foundation

enum BandPreset: Int, CaseIterable, Codable {
    case eight = 8
    case twelve = 12
    case sixteen = 16
    case twentyFour = 24

    var title: String {
        "\(rawValue) 段"
    }

    var bandCount: Int {
        rawValue
    }

}

struct MotionResponseParameters: Equatable {
    let bandAttack: Float
    let bandDecay: Float
    let waveformSmoothing: Float
    let beatDecay: Float
}

enum MotionResponsePreset: String, CaseIterable, Codable {
    case snappy
    case balanced
    case smooth

    var title: String {
        switch self {
        case .snappy:
            return "迅速"
        case .balanced:
            return "平衡"
        case .smooth:
            return "平滑"
        }
    }

    var parameters: MotionResponseParameters {
        switch self {
        case .snappy:
            return MotionResponseParameters(
                bandAttack: 0.85,
                bandDecay: 0.42,
                waveformSmoothing: 0.75,
                beatDecay: 0.70
            )
        case .balanced:
            return MotionResponseParameters(
                bandAttack: 0.65,
                bandDecay: 0.16,
                waveformSmoothing: 0.55,
                beatDecay: 0.82
            )
        case .smooth:
            return MotionResponseParameters(
                bandAttack: 0.38,
                bandDecay: 0.06,
                waveformSmoothing: 0.30,
                beatDecay: 0.92
            )
        }
    }
}

enum BeatPulseIntensity: String, CaseIterable, Codable {
    case off
    case low
    case normal
    case high

    var title: String {
        switch self {
        case .off:
            return "关闭"
        case .low:
            return "低"
        case .normal:
            return "正常"
        case .high:
            return "高"
        }
    }
}

enum RenderingCadence: String, CaseIterable, Codable {
    case standard
    case high

    var title: String {
        switch self {
        case .standard:
            return "标准 30 fps"
        case .high:
            return "高 60 fps"
        }
    }
}

struct VisualizationSettings: Equatable, Codable {
    var style: VisualizationStyle = .bars
    var bandPreset: BandPreset = .twelve
    var motionResponsePreset: MotionResponsePreset = .balanced
    var beatPulseIntensity: BeatPulseIntensity = .normal
    var sceneAdaptationEnabled = true
    var renderingCadence: RenderingCadence = .standard

    static let `default` = VisualizationSettings()
}
