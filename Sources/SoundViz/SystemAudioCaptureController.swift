import CoreAudio
import AudioUnit
import AudioToolbox

protocol CaptureControlling {
    var isRunning: Bool { get }
    func updateBandPreset(_ preset: BandPreset)
    func updateMotionResponse(_ preset: MotionResponsePreset)
    func start()
    func stop()
}

enum CaptureState: Equatable {
    case starting
    case running
    case permissionRequired
    case failed(CaptureFailure)
    case stopped
}

final class SystemAudioCaptureController: CaptureControlling {
    private let onSpectrum: (SpectrumFrame) -> Void
    private let onStateChange: (CaptureState) -> Void
    private let captureQueue = DispatchQueue(label: "SoundViz.capture", qos: .userInteractive)
    private var tapID: AudioObjectID?
    private var aggregateDeviceID: AudioDeviceID?
    private var ioProcID: AudioDeviceIOProcID?
    private var tapFormat: AudioStreamBasicDescription?
    private var spectrumAnalyzer: SpectrumAnalyzer?
    private(set) var isRunning = false
    private(set) var bandPreset: BandPreset
    private(set) var motionResponsePreset: MotionResponsePreset

    init(
        bandPreset: BandPreset = .twelve,
        motionResponsePreset: MotionResponsePreset = .balanced,
        onSpectrum: @escaping (SpectrumFrame) -> Void,
        onStateChange: @escaping (CaptureState) -> Void
    ) {
        self.bandPreset = bandPreset
        self.motionResponsePreset = motionResponsePreset
        self.onSpectrum = onSpectrum
        self.onStateChange = onStateChange
    }

    func updateBandPreset(_ preset: BandPreset) {
        bandPreset = preset
        captureQueue.sync {
            recreateAnalyzer()
        }
    }

    func updateMotionResponse(_ preset: MotionResponsePreset) {
        motionResponsePreset = preset
        captureQueue.sync {
            spectrumAnalyzer?.updateMotionResponse(preset)
        }
    }

    func start() {
        guard !isRunning else { return }
        onStateChange(.starting)

        guard #available(macOS 14.2, *) else {
            onStateChange(
                .failed(
                    CaptureFailure(
                        kind: .runtime,
                        message: "Core Audio Tap 需要 macOS 14.2 或更高版本。"
                    )
                )
            )
            return
        }

        do {
            let aggregateDeviceID = try createTapAggregateDevice()
            self.aggregateDeviceID = aggregateDeviceID
            try startAggregateIO(deviceID: aggregateDeviceID)
            isRunning = true
            onStateChange(.running)
        } catch {
            handleStartFailure(error)
        }
    }

    func handleStartFailure(_ error: Error) {
        if #available(macOS 14.2, *) {
            cleanup()
        }
        let failure = CaptureFailure(error: error)
        onStateChange(
            failure.kind == .permissionRequired
                ? .permissionRequired
                : .failed(failure)
        )
    }

    func stop() {
        guard isRunning || aggregateDeviceID != nil else {
            onStateChange(.stopped)
            return
        }
        if #available(macOS 14.2, *) {
            cleanup()
        }
        onStateChange(.stopped)
    }

    @available(macOS 14.2, *)
    private func createTapAggregateDevice() throws -> AudioDeviceID {
        let description = CATapDescription(stereoGlobalTapButExcludeProcesses: [])
        description.name = "SoundViz System Audio Tap"
        description.uuid = UUID()
        description.isPrivate = true
        description.muteBehavior = .unmuted

        var tapID = AudioObjectID(0)
        let tapStatus = AudioHardwareCreateProcessTap(description, &tapID)
        guard tapStatus == noErr else {
            throw CaptureError.osStatus(tapStatus, "创建系统音频 Tap")
        }
        self.tapID = tapID
        let format = try tapFormat(tapID)
        tapFormat = format
        spectrumAnalyzer = makeAnalyzer(sampleRate: Float(format.mSampleRate))

        let tap: [String: Any] = [
            "uid": description.uuid.uuidString,
            "drift": 1,
            "drift quality": 127
        ]
        let composition: [String: Any] = [
            "uid": UUID().uuidString,
            "name": "SoundViz Private Aggregate",
            "private": 1,
            "taps": [tap],
            "tapautostart": 1
        ]
        var aggregateDeviceID = AudioDeviceID(0)
        let aggregateStatus = AudioHardwareCreateAggregateDevice(
            composition as CFDictionary,
            &aggregateDeviceID
        )
        guard aggregateStatus == noErr else {
            throw CaptureError.osStatus(aggregateStatus, "创建私有聚合设备")
        }
        return aggregateDeviceID
    }

    @available(macOS 14.2, *)
    private func startAggregateIO(deviceID: AudioDeviceID) throws {
        var createdProcID: AudioDeviceIOProcID?
        let createStatus = AudioDeviceCreateIOProcIDWithBlock(
            &createdProcID,
            deviceID,
            captureQueue
        ) { [weak self] inNow, inputData, _, _, _ in
            self?.process(inputData: inputData, timestamp: Date().timeIntervalSince1970)
        }
        guard createStatus == noErr, let ioProcID = createdProcID else {
            throw CaptureError.osStatus(createStatus, "创建聚合设备 IOProc")
        }
        self.ioProcID = ioProcID

        let startStatus = AudioDeviceStart(deviceID, ioProcID)
        guard startStatus == noErr else {
            throw CaptureError.osStatus(startStatus, "启动聚合设备 IOProc")
        }
    }

    private func process(inputData: UnsafePointer<AudioBufferList>, timestamp: TimeInterval) {
        guard let spectrumAnalyzer else { return }
        let samples = analysisSamples(from: inputData)
        guard !samples.isEmpty else { return }
        onSpectrum(spectrumAnalyzer.process(samples: samples, timestamp: timestamp))
    }

    private func recreateAnalyzer() {
        guard let tapFormat else { return }
        spectrumAnalyzer = makeAnalyzer(sampleRate: Float(tapFormat.mSampleRate))
    }

    private func makeAnalyzer(sampleRate: Float) -> SpectrumAnalyzer {
        SpectrumAnalyzer(
            requestedSampleRate: sampleRate,
            requestedBandCount: bandPreset.rawValue,
            motionResponsePreset: motionResponsePreset
        )
    }

    private func analysisSamples(from inputData: UnsafePointer<AudioBufferList>) -> [Float] {
        let bufferList = UnsafeMutableAudioBufferListPointer(
            UnsafeMutablePointer<AudioBufferList>(mutating: inputData)
        )
        guard let audioBuffer = bufferList.first, let data = audioBuffer.mData else { return [] }
        let channels = max(1, Int(audioBuffer.mNumberChannels))
        let bytesPerFrame = max(channels, Int(tapFormat?.mBytesPerFrame ?? UInt32(channels * 2)))
        let frameCount = Int(audioBuffer.mDataByteSize) / bytesPerFrame
        guard frameCount > 0 else { return [] }

        let isFloat = tapFormat.map { $0.mFormatFlags & kAudioFormatFlagIsFloat != 0 } ?? true
        if channels == 1 {
            if isFloat {
                let samples = data.bindMemory(to: Float.self, capacity: frameCount)
                return Array(UnsafeBufferPointer(start: samples, count: frameCount))
            }
            let samples = data.bindMemory(to: Int16.self, capacity: frameCount)
            return UnsafeBufferPointer(start: samples, count: frameCount).map {
                Float($0) / Float(Int16.max)
            }
        }

        let valueCount = frameCount * channels
        var samples: [Float]
        if isFloat {
            let interleavedSamples = data.bindMemory(to: Float.self, capacity: valueCount)
            samples = Array(UnsafeBufferPointer(start: interleavedSamples, count: valueCount))
        } else {
            let interleavedSamples = data.bindMemory(to: Int16.self, capacity: valueCount)
            samples = UnsafeBufferPointer(start: interleavedSamples, count: valueCount).map {
                Float($0) / Float(Int16.max)
            }
        }

        var analysisSamples = [Float](repeating: 0, count: frameCount)
        for frame in 0..<frameCount {
            var total: Float = 0
            for channel in 0..<channels {
                total += samples[frame * channels + channel]
            }
            analysisSamples[frame] = total / Float(channels)
        }
        return analysisSamples
    }

    private func tapFormat(_ tapID: AudioObjectID) throws -> AudioStreamBasicDescription {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioTapPropertyFormat,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var format = AudioStreamBasicDescription()
        var size = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        let status = AudioObjectGetPropertyData(
            tapID,
            &propertyAddress,
            0,
            nil,
            &size,
            &format
        )
        guard status == noErr else {
            throw CaptureError.osStatus(status, "查询 Tap 音频格式")
        }
        return format
    }

    @available(macOS 14.2, *)
    private func cleanup() {
        if let aggregateDeviceID {
            if let ioProcID {
                AudioDeviceStop(aggregateDeviceID, ioProcID)
                AudioDeviceDestroyIOProcID(aggregateDeviceID, ioProcID)
            }
            AudioHardwareDestroyAggregateDevice(aggregateDeviceID)
        }
        if let tapID {
            AudioHardwareDestroyProcessTap(tapID)
        }
        aggregateDeviceID = nil
        ioProcID = nil
        tapID = nil
        isRunning = false
    }
}

enum CaptureError: LocalizedError {
    case osStatus(OSStatus, String)
    case message(String)

    var errorDescription: String? {
        switch self {
        case .osStatus(let status, let action):
            return "\(action)失败（\(status)）"
        case .message(let message):
            return message
        }
    }

    var failure: CaptureFailure {
        switch self {
        case .osStatus(let status, let action):
            return CaptureFailure.classify(status: status, action: action)
        case .message(let message):
            return CaptureFailure(kind: .runtime, message: message)
        }
    }
}
