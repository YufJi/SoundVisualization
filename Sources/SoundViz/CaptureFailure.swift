import CoreAudio
import Foundation

enum CaptureFailureKind: Equatable {
    case permissionRequired
    case runtime
}

struct CaptureFailure: Equatable, LocalizedError {
    let kind: CaptureFailureKind
    let status: OSStatus?
    private let action: CaptureAction?
    private let underlyingMessage: String?

    var errorDescription: String? {
        message
    }

    var message: String {
        switch kind {
        case .permissionRequired:
            return AppText.capturePermissionRequired(action ?? .readSystemAudio).localized
        case .runtime:
            if let action, let status {
                return AppText.captureRuntimeFailure(action: action, status: status).localized
            }
            return underlyingMessage ?? AppText.captureRuntimeFailure(
                action: .readSystemAudio,
                status: kAudioHardwareUnspecifiedError
            ).localized
        }
    }

    init(kind: CaptureFailureKind, status: OSStatus? = nil, message: String? = nil) {
        self.kind = kind
        self.status = status
        self.action = nil
        self.underlyingMessage = message
    }

    init(kind: CaptureFailureKind, status: OSStatus?, action: CaptureAction) {
        self.kind = kind
        self.status = status
        self.action = action
        self.underlyingMessage = nil
    }

    init(error: Error) {
        if let captureError = error as? CaptureError {
            self = captureError.failure
        } else {
            self.init(kind: .runtime, message: error.localizedDescription)
        }
    }

    static func classify(status: OSStatus, action: CaptureAction) -> CaptureFailure {
        if status == kAudioDevicePermissionsError {
            return CaptureFailure(
                kind: .permissionRequired,
                status: status,
                action: action
            )
        }

        return CaptureFailure(
            kind: .runtime,
            status: status,
            action: action
        )
    }
}
