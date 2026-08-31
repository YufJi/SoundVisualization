import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    init(
        settings: Binding<VisualizationSettings>,
        onRestoreDefaults: @escaping () -> Void
    ) {
        let contentView = NSHostingView(
            rootView: VisualizationSettingsView(
                settings: settings,
                onRestoreDefaults: onRestoreDefaults
            )
        )
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 460),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "SoundViz 设置"
        window.contentView = contentView
        window.isReleasedWhenClosed = false

        super.init(window: window)
        window.delegate = self
        window.center()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func showAndFocus() {
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
