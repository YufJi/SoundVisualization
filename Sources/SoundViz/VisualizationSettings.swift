import Foundation

enum BandPreset: Int, CaseIterable, Codable {
    case eight = 8
    case twelve = 12
    case sixteen = 16
    case twentyFour = 24
}

enum MotionResponsePreset: String, CaseIterable, Codable {
    case snappy
    case balanced
    case smooth
}

enum BeatPulseIntensity: String, CaseIterable, Codable {
    case off
    case low
    case normal
    case high
}

enum RenderingCadence: String, CaseIterable, Codable {
    case standard
    case high
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
