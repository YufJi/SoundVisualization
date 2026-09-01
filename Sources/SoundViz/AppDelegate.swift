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
    }

    func applicationWillTerminate(_ notification: Notification) {
        captureController?.stop()
    }

    private func configureMenu() {
        let menu = NSMenu()
        let status = NSMenuItem(title: "正在准备…", action: nil, keyEquivalent: "")
        let toggle = NSMenuItem(
            title: "停止可视化",
            action: #selector(toggleCapture),
            keyEquivalent: ""
        )
        toggle.target = self
        let styleContainer = NSMenuItem(title: "可视化样式", action: nil, keyEquivalent: "")
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
            title: "设置…",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        let sceneAdaptationItem = NSMenuItem(
            title: "根据音频调整动态",
            action: #selector(toggleSceneAdaptation),
            keyEquivalent: ""
        )
        sceneAdaptationItem.target = self
        let quit = NSMenuItem(title: "退出 SoundViz", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
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
        menu.addItem(quit)
        statusMenuItem = status
        toggleMenuItem = toggle
        sceneAdaptationMenuItem = sceneAdaptationItem
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

    private func updateStatus(_ state: CaptureState) {
        switch state {
        case .starting:
            statusMenuItem?.title = "正在准备…"
            toggleMenuItem?.isEnabled = false
        case .running:
            statusMenuItem?.title = "正在监听系统声音"
            toggleMenuItem?.title = "停止可视化"
            toggleMenuItem?.isEnabled = true
        case .permissionRequired:
            statusMenuItem?.title = "需要在系统设置中授权音频捕获"
            toggleMenuItem?.title = "重新检查权限"
            toggleMenuItem?.isEnabled = true
        case .failed(let message):
            statusMenuItem?.title = "失败：\(message)"
            toggleMenuItem?.title = "重试"
            toggleMenuItem?.isEnabled = true
        case .stopped:
            statusMenuItem?.title = "已停止"
            toggleMenuItem?.title = "开始可视化"
            toggleMenuItem?.isEnabled = true
        }
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
