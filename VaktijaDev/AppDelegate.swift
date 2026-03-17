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
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: PrayerTimesView())

        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "moon.stars.fill", accessibilityDescription: "Prayer Times")
            button.action = #selector(togglePopover)
            button.target = self
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
