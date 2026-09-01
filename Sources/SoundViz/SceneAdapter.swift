import Foundation

enum VisualizationMotionState: Equatable {
    case lowDistraction
    case active
}

final class SceneAdapter {
    private(set) var state: VisualizationMotionState = .lowDistraction
    private var lastActiveAt: TimeInterval?

    private let activationBandThreshold: Float = 0.56
    private let activationBeatThreshold: Float = 0.28
    private let deactivationBandThreshold: Float = 0.34
    private let deactivationBeatThreshold: Float = 0.12
    private let activeTimeout: TimeInterval = 1.25

    func update(
        spectrum: SpectrumFrame,
        sceneAdaptationEnabled: Bool,
        reduceMotion: Bool,
        timestamp: TimeInterval
    ) -> VisualizationMotionState {
        if reduceMotion {
            state = .lowDistraction
            lastActiveAt = nil
            return state
        }

        guard sceneAdaptationEnabled else {
            state = .active
            lastActiveAt = nil
            return state
        }

        let bandActivity = spectrum.bands.max() ?? 0
        let isClearlyActive = bandActivity >= activationBandThreshold
            || spectrum.beat >= activationBeatThreshold
        let isQuiet = bandActivity <= deactivationBandThreshold
            && spectrum.beat <= deactivationBeatThreshold

        if isClearlyActive {
            state = .active
            lastActiveAt = timestamp
        } else if state == .active, isQuiet,
                  let lastActiveAt,
                  timestamp - lastActiveAt >= activeTimeout {
            state = .lowDistraction
            self.lastActiveAt = nil
        }

        return state
    }
}
