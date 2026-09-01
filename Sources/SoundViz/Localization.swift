import Foundation

enum AppLanguage: Equatable {
    case english
    case simplifiedChinese

    static var current: AppLanguage {
        from(preferredLanguages: Locale.preferredLanguages)
    }

    static func from(preferredLanguages: [String]) -> AppLanguage {
        guard let preferredLanguage = preferredLanguages.first else {
            return .english
        }

        let identifier = Locale(identifier: preferredLanguage)
        let languageCode = identifier.language.languageCode?.identifier
        let scriptCode = identifier.language.script?.identifier
        let regionCode = identifier.region?.identifier

        guard languageCode == "zh" else { return .english }

        if scriptCode == "Hans" || regionCode == "CN" || regionCode == "SG" {
            return .simplifiedChinese
        }

        return .english
    }
}

enum CaptureAction: Equatable {
    case createSystemAudioTap
    case createPrivateAggregateDevice
    case createAggregateDeviceIOProc
    case startAggregateDeviceIOProc
    case queryTapAudioFormat
    case readSystemAudio
}

enum AppText {
    case starting
    case running
    case stopVisualization
    case startVisualization
    case visualizationStyle
    case settings
    case settingsWindowTitle
    case audioAdaptiveMotion
    case openAudioCaptureSettings
    case retryCapture
    case quitSoundViz
    case permissionRequired
    case captureFailed(String)
    case retry
    case stopped
    case spectrumBars
    case waveformLine
    case spectrumArea
    case bandPreset(Int)
    case motionSnappy
    case motionBalanced
    case motionSmooth
    case beatPulseOff
    case beatPulseLow
    case beatPulseNormal
    case beatPulseHigh
    case renderingCadenceStandard
    case renderingCadenceHigh
    case visualizationSection
    case styleLabel
    case frequencyBandsLabel
    case frequencyBandsHelp
    case motionResponseSection
    case presetLabel
    case beatPulseSection
    case intensityLabel
    case sceneAdaptationSection
    case audioAdaptiveMotionToggle
    case renderingFrequencySection
    case refreshRateLabel
    case restoreDefaults
    case unsupportedMacOS
    case createSystemAudioTap
    case createPrivateAggregateDevice
    case createAggregateDeviceIOProc
    case startAggregateDeviceIOProc
    case queryTapAudioFormat
    case readSystemAudio
    case capturePermissionRequired(CaptureAction)
    case captureRuntimeFailure(action: CaptureAction, status: OSStatus)

    var localized: String {
        localized(in: .current)
    }

    func localized(in language: AppLanguage) -> String {
        switch self {
        case .starting:
            return language == .simplifiedChinese ? "正在准备…" : "Starting…"
        case .running:
            return language == .simplifiedChinese ? "正在监听系统声音" : "Listening to system audio"
        case .stopVisualization:
            return language == .simplifiedChinese ? "停止可视化" : "Stop Visualization"
        case .startVisualization:
            return language == .simplifiedChinese ? "开始可视化" : "Start Visualization"
        case .visualizationStyle:
            return language == .simplifiedChinese ? "可视化样式" : "Visualization Style"
        case .settings:
            return language == .simplifiedChinese ? "设置…" : "Settings…"
        case .settingsWindowTitle:
            return language == .simplifiedChinese ? "SoundViz 设置" : "SoundViz Settings"
        case .audioAdaptiveMotion:
            return language == .simplifiedChinese ? "根据音频调整动态" : "Audio-adaptive Motion"
        case .openAudioCaptureSettings:
            return language == .simplifiedChinese ? "打开音频捕获设置…" : "Open Audio Capture Settings…"
        case .retryCapture:
            return language == .simplifiedChinese ? "重试捕获" : "Retry Capture"
        case .quitSoundViz:
            return language == .simplifiedChinese ? "退出 SoundViz" : "Quit SoundViz"
        case .permissionRequired:
            return language == .simplifiedChinese ? "需要在系统设置中授权音频捕获" : "Audio capture permission required"
        case .captureFailed(let message):
            return language == .simplifiedChinese ? "捕获失败：\(message)" : "Capture failed: \(message)"
        case .retry:
            return language == .simplifiedChinese ? "重试" : "Retry"
        case .stopped:
            return language == .simplifiedChinese ? "已停止" : "Stopped"
        case .spectrumBars:
            return language == .simplifiedChinese ? "柱状频谱" : "Spectrum Bars"
        case .waveformLine:
            return language == .simplifiedChinese ? "波形线" : "Waveform Line"
        case .spectrumArea:
            return language == .simplifiedChinese ? "频谱带" : "Spectrum Area"
        case .bandPreset(let count):
            return language == .simplifiedChinese ? "\(count) 段" : "\(count) bands"
        case .motionSnappy:
            return language == .simplifiedChinese ? "迅速" : "Snappy"
        case .motionBalanced:
            return language == .simplifiedChinese ? "平衡" : "Balanced"
        case .motionSmooth:
            return language == .simplifiedChinese ? "平滑" : "Smooth"
        case .beatPulseOff:
            return language == .simplifiedChinese ? "关闭" : "Off"
        case .beatPulseLow:
            return language == .simplifiedChinese ? "低" : "Low"
        case .beatPulseNormal:
            return language == .simplifiedChinese ? "正常" : "Normal"
        case .beatPulseHigh:
            return language == .simplifiedChinese ? "高" : "High"
        case .renderingCadenceStandard:
            return language == .simplifiedChinese ? "标准 30 fps" : "Standard 30 fps"
        case .renderingCadenceHigh:
            return language == .simplifiedChinese ? "高 60 fps" : "High 60 fps"
        case .visualizationSection:
            return language == .simplifiedChinese ? "可视化" : "Visualization"
        case .styleLabel:
            return language == .simplifiedChinese ? "样式" : "Style"
        case .frequencyBandsLabel:
            return language == .simplifiedChinese ? "频段" : "Frequency bands"
        case .frequencyBandsHelp:
            return language == .simplifiedChinese ? "频段设置仅影响频谱样式。" : "Frequency bands affect spectrum styles only."
        case .motionResponseSection:
            return language == .simplifiedChinese ? "动态响应" : "Motion Response"
        case .presetLabel:
            return language == .simplifiedChinese ? "预设" : "Preset"
        case .beatPulseSection:
            return language == .simplifiedChinese ? "节拍脉冲" : "Beat Pulse"
        case .intensityLabel:
            return language == .simplifiedChinese ? "强度" : "Intensity"
        case .sceneAdaptationSection:
            return language == .simplifiedChinese ? "场景自适应" : "Scene Adaptation"
        case .audioAdaptiveMotionToggle:
            return language == .simplifiedChinese ? "根据音频调整动态" : "Adjust motion from audio"
        case .renderingFrequencySection:
            return language == .simplifiedChinese ? "渲染频率" : "Rendering Frequency"
        case .refreshRateLabel:
            return language == .simplifiedChinese ? "刷新率" : "Refresh rate"
        case .restoreDefaults:
            return language == .simplifiedChinese ? "恢复默认设置" : "Restore Defaults"
        case .unsupportedMacOS:
            return language == .simplifiedChinese ? "Core Audio Tap 需要 macOS 14.2 或更高版本。" : "Core Audio Tap requires macOS 14.2 or later."
        case .createSystemAudioTap:
            return language == .simplifiedChinese ? "创建系统音频 Tap" : "Create system audio tap"
        case .createPrivateAggregateDevice:
            return language == .simplifiedChinese ? "创建私有聚合设备" : "Create private aggregate device"
        case .createAggregateDeviceIOProc:
            return language == .simplifiedChinese ? "创建聚合设备 IOProc" : "Create aggregate device IOProc"
        case .startAggregateDeviceIOProc:
            return language == .simplifiedChinese ? "启动聚合设备 IOProc" : "Start aggregate device IOProc"
        case .queryTapAudioFormat:
            return language == .simplifiedChinese ? "查询 Tap 音频格式" : "Query tap audio format"
        case .readSystemAudio:
            return language == .simplifiedChinese ? "读取系统音频" : "Read system audio"
        case .capturePermissionRequired(let action):
            let actionName = action.localized(in: language)
            return language == .simplifiedChinese
                ? "\(actionName)需要音频捕获权限。"
                : "\(actionName) requires audio capture permission."
        case .captureRuntimeFailure(let action, let status):
            let actionName = action.localized(in: language)
            return language == .simplifiedChinese
                ? "\(actionName)失败（\(status)）。"
                : "\(actionName) failed (\(status))."
        }
    }
}

extension CaptureAction {
    func localized(in language: AppLanguage) -> String {
        let text: AppText
        switch self {
        case .createSystemAudioTap:
            text = .createSystemAudioTap
        case .createPrivateAggregateDevice:
            text = .createPrivateAggregateDevice
        case .createAggregateDeviceIOProc:
            text = .createAggregateDeviceIOProc
        case .startAggregateDeviceIOProc:
            text = .startAggregateDeviceIOProc
        case .queryTapAudioFormat:
            text = .queryTapAudioFormat
        case .readSystemAudio:
            text = .readSystemAudio
        }
        return text.localized(in: language)
    }
}
