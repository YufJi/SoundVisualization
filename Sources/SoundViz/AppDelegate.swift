import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var visualizer: AudioVisualizer
    private var settings: VisualizationSettings
    private var settingsStore: VisualizationSettingsStoring
    private var captureController: CaptureControlling?
    private var menu: NSMenu?
    private var statusMenuItem: NSMenuItem?
    private var toggleMenuItem: NSMenuItem?
    private var styleMenuItems: [NSMenuItem] = []

    init(
        visualizer: AudioVisualizer,
        settings: VisualizationSettings,
        settingsStore: VisualizationSettingsStoring
    ) {
        self.visualizer = visualizer
        self.settings = settings
        self.settingsStore = settingsStore
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
            onSpectrum: { [weak self] spectrum in
                self?.visualizer.push(spectrum: spectrum)
            },
            onStateChange: { [weak self] state in
                self?.updateStatus(state)
            }
        )
        captureController?.start()
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
        let quit = NSMenuItem(title: "退出 SoundViz", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(status)
        menu.addItem(.separator())
        menu.addItem(styleContainer)
        menu.addItem(.separator())
        menu.addItem(toggle)
        menu.addItem(.separator())
        menu.addItem(quit)
        statusMenuItem = status
        toggleMenuItem = toggle
        self.menu = menu
        statusItem?.menu = menu
        refreshStyleMenu()
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
        settings.style = style
        settingsStore.save(settings)
        visualizer.setStyle(style)
        refreshStyleMenu()
    }

    private func refreshStyleMenu() {
        for item in styleMenuItems {
            let style = VisualizationStyle(rawValue: item.representedObject as? String ?? "")
            item.state = style == settings.style ? .on : .off
        }
    }
}
