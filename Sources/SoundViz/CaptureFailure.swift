import CoreAudio
import Foundation

enum CaptureFailureKind: Equatable {
    case permissionRequired
    case runtime
}

struct CaptureFailure: Equatable, LocalizedError {
    let kind: CaptureFailureKind
    let status: OSStatus?
    let message: String

    var errorDescription: String? {
        message
    }

    init(kind: CaptureFailureKind, status: OSStatus? = nil, message: String) {
        self.kind = kind
        self.status = status
        self.message = message
    }

    init(error: Error, action: String = "读取系统音频") {
        if let captureError = error as? CaptureError {
            self = captureError.failure
        } else {
            self.init(kind: .runtime, message: error.localizedDescription)
        }
    }

    static func classify(status: OSStatus, action: String) -> CaptureFailure {
        if status == kAudioDevicePermissionsError {
            return CaptureFailure(
                kind: .permissionRequired,
                status: status,
                message: "\(action)需要音频捕获权限。"
            )
        }

        return CaptureFailure(
            kind: .runtime,
            status: status,
            message: "\(action)失败（\(status)）。"
        )
    }
}
