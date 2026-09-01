import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var visualizer: AudioVisualizer
    private let settingsModel: VisualizationSettingsModel
    private var captureController: CaptureControlling?
    private var menu: NSMenu?
    private var statusMenuItem: NSMenuItem?
    private var toggleMenuItem: NSMenuItem?
    private var styleMenuItems: [NSMenuItem] = []
    private var settingsWindowController: SettingsWindowController?
    private var sceneAdaptationMenuItem: NSMenuItem?
    private var openSystemSettingsMenuItem: NSMenuItem?
    private var retryCaptureMenuItem: NSMenuItem?

    init(
        visualizer: AudioVisualizer,
        settingsModel: VisualizationSettingsModel
    ) {
        self.visualizer = visualizer
        self.settingsModel = settingsModel
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: 46)
        statusItem = item
        configureMenu()
        item.button?.image = visualizer.image
        visualizer.onUpdate = { [weak self] image in
            self?.statusItem?.button?.image = image
        }

        captureController = SystemAudioCaptureController(
            bandPreset: settingsModel.settings.bandPreset,
            motionResponsePreset: settingsModel.settings.motionResponsePreset,
            onSpectrum: { [weak self] spectrum in
                self?.visualizer.push(spectrum: spectrum)
            },
            onStateChange: { [weak self] state in
                self?.updateStatus(state)
            }
        )
        captureController?.start()
        visualizer.updateReduceMotion(
            NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        )
        observeReduceMotion()
        observeLowPowerMode()
    }

    func applicationWillTerminate(_ notification: Notification) {
        captureController?.stop()
    }

    private func configureMenu() {
        let menu = NSMenu()
        let status = NSMenuItem(title: AppText.starting.localized, action: nil, keyEquivalent: "")
        let toggle = NSMenuItem(
            title: AppText.stopVisualization.localized,
            action: #selector(toggleCapture),
            keyEquivalent: ""
        )
        toggle.target = self
        let styleContainer = NSMenuItem(title: AppText.visualizationStyle.localized, action: nil, keyEquivalent: "")
        let styleMenu = NSMenu()
        styleMenuItems = VisualizationStyle.allCases.map { style in
            let item = NSMenuItem(
                title: style.title,
                action: #selector(changeVisualizationStyle(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = style.rawValue
            styleMenu.addItem(item)
            return item
        }
        styleContainer.submenu = styleMenu
        let settingsItem = NSMenuItem(
            title: AppText.settings.localized,
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        let sceneAdaptationItem = NSMenuItem(
            title: AppText.audioAdaptiveMotion.localized,
            action: #selector(toggleSceneAdaptation),
            keyEquivalent: ""
        )
        sceneAdaptationItem.target = self
        let openSystemSettingsItem = NSMenuItem(
            title: AppText.openAudioCaptureSettings.localized,
            action: #selector(openAudioCaptureSettings),
            keyEquivalent: ""
        )
        openSystemSettingsItem.target = self
        openSystemSettingsItem.isHidden = true
        let retryCaptureItem = NSMenuItem(
            title: AppText.retryCapture.localized,
            action: #selector(retryCapture),
            keyEquivalent: ""
        )
        retryCaptureItem.target = self
        retryCaptureItem.isHidden = true
        let quit = NSMenuItem(title: AppText.quitSoundViz.localized, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(status)
        menu.addItem(.separator())
        menu.addItem(styleContainer)
        menu.addItem(.separator())
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(sceneAdaptationItem)
        menu.addItem(.separator())
        menu.addItem(toggle)
        menu.addItem(.separator())
        menu.addItem(openSystemSettingsItem)
        menu.addItem(retryCaptureItem)
        menu.addItem(.separator())
        menu.addItem(quit)
        statusMenuItem = status
        toggleMenuItem = toggle
        sceneAdaptationMenuItem = sceneAdaptationItem
        openSystemSettingsMenuItem = openSystemSettingsItem
        retryCaptureMenuItem = retryCaptureItem
        self.menu = menu
        statusItem?.menu = menu
        refreshStyleMenu()
        refreshSceneAdaptationMenu()
    }

    private func observeReduceMotion() {
        NotificationCenter.default.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: NSWorkspace.shared,
            queue: .main
        ) { [weak self] _ in
            self?.visualizer.updateReduceMotion(
                NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
            )
        }
    }

    private func observeLowPowerMode() {
        NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: ProcessInfo.processInfo,
            queue: .main
        ) { [weak self] _ in
            self?.visualizer.updateLowPowerMode(
                ProcessInfo.processInfo.isLowPowerModeEnabled
            )
        }
    }

    private func updateStatus(_ state: CaptureState) {
        switch state {
        case .starting:
            statusMenuItem?.title = AppText.starting.localized
            toggleMenuItem?.isEnabled = false
            visualizer.setCaptureActive(false)
        case .running:
            statusMenuItem?.title = AppText.running.localized
            toggleMenuItem?.title = AppText.stopVisualization.localized
            toggleMenuItem?.isEnabled = true
            visualizer.setCaptureActive(true)
        case .permissionRequired:
            statusMenuItem?.title = AppText.permissionRequired.localized
            toggleMenuItem?.title = AppText.startVisualization.localized
            toggleMenuItem?.isEnabled = true
            visualizer.setCaptureActive(false)
        case .failed(let failure):
            statusMenuItem?.title = AppText.captureFailed(failure.message).localized
            toggleMenuItem?.title = AppText.retry.localized
            toggleMenuItem?.isEnabled = true
            visualizer.setCaptureActive(false)
        case .stopped:
            statusMenuItem?.title = AppText.stopped.localized
            toggleMenuItem?.title = AppText.startVisualization.localized
            toggleMenuItem?.isEnabled = true
            visualizer.setCaptureActive(false)
        }

        refreshRecoveryMenu(for: state)
    }

    private func refreshRecoveryMenu(for state: CaptureState) {
        let permissionRequired: Bool
        let runtimeFailed: Bool

        switch state {
        case .permissionRequired:
            permissionRequired = true
            runtimeFailed = false
        case .failed(let failure):
            permissionRequired = failure.kind == .permissionRequired
            runtimeFailed = failure.kind == .runtime
        default:
            permissionRequired = false
            runtimeFailed = false
        }

        openSystemSettingsMenuItem?.isHidden = !permissionRequired
        retryCaptureMenuItem?.isHidden = !(permissionRequired || runtimeFailed)
    }

    @objc private func openAudioCaptureSettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Microphone"
        ) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func retryCapture() {
        captureController?.start()
    }

    @objc private func toggleCapture() {
        guard let captureController else { return }
        if captureController.isRunning {
            captureController.stop()
            return
        }
        captureController.start()
    }

    @objc private func changeVisualizationStyle(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let style = VisualizationStyle(rawValue: rawValue) else { return }
        var settings = settingsModel.settings
        settings.style = style
        settingsModel.update(settings)
    }

    @objc private func openSettings() {
        if let settingsWindowController {
            settingsWindowController.showAndFocus()
            return
        }

        let controller = SettingsWindowController(
            model: settingsModel,
            onRestoreDefaults: { [weak self] in
                guard let self else { return }
                self.settingsModel.restoreDefaults()
            }
        )
        settingsWindowController = controller
        controller.showAndFocus()
    }

    @objc private func toggleSceneAdaptation() {
        var settings = settingsModel.settings
        settings.sceneAdaptationEnabled.toggle()
        settingsModel.update(settings)
    }

    func applyVisualSettings(_ newSettings: VisualizationSettings) {
        if newSettings.style != visualizer.style {
            visualizer.setStyle(newSettings.style)
        }
        visualizer.updateBandPreset(newSettings.bandPreset)
        captureController?.updateBandPreset(newSettings.bandPreset)
        visualizer.updateMotionResponse(newSettings.motionResponsePreset)
        captureController?.updateMotionResponse(newSettings.motionResponsePreset)
        visualizer.updateBeatPulseIntensity(newSettings.beatPulseIntensity)
        visualizer.updateSceneAdaptation(newSettings.sceneAdaptationEnabled)
        visualizer.updateRenderingCadence(newSettings.renderingCadence)
        refreshStyleMenu()
        refreshSceneAdaptationMenu()
    }

    private func refreshStyleMenu() {
        for item in styleMenuItems {
            let style = VisualizationStyle(rawValue: item.representedObject as? String ?? "")
            item.state = style == settingsModel.settings.style ? .on : .off
        }
    }

    private func refreshSceneAdaptationMenu() {
        sceneAdaptationMenuItem?.state = settingsModel.settings.sceneAdaptationEnabled ? .on : .off
    }
}
