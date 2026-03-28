import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Close any default window that SwiftUI might open
        for window in NSApplication.shared.windows {
            window.close()
        }

        // Setup popover
        popover = NSPopover()
        popover.behavior = .transient
        let hostingController = NSHostingController(rootView: ContentView())
        hostingController.sizingOptions = .preferredContentSize
        popover.contentViewController = hostingController

        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "moon.stars.fill", accessibilityDescription: "Prayer Times")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Prayer reminder panel
        NotificationCenter.default.addObserver(
            forName: .prayerReminderDue,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let prayer = notification.userInfo?["prayer"] as? String,
                  let time = notification.userInfo?["time"] as? String,
                  let button = self.statusItem.button,
                  let window = button.window else { return }

            let buttonFrame = window.convertToScreen(button.frame)
            let screen = window.screen ?? NSScreen.main!
            PrayerReminderPanel.show(prayer: prayer, time: time, buttonFrame: buttonFrame, screen: screen)
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Ensure the popover's window becomes key so it can receive events
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
