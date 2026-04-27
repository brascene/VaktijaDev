import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let prayerVM = PrayerTimesViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Close any default window that SwiftUI might open
        for window in NSApplication.shared.windows {
            window.close()
        }

        // Fetch prayer times immediately at launch (before popover is opened)
        Task { await prayerVM.fetchIfNeeded() }

        // Setup popover
        popover = NSPopover()
        popover.behavior = .transient
        let hostingController = NSHostingController(rootView: ContentView(prayerVM: prayerVM))
        hostingController.sizingOptions = .preferredContentSize
        popover.contentViewController = hostingController

        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "moon.stars.fill", accessibilityDescription: "Prayer Times")
            button.action = #selector(handleStatusItemClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Prayer reminder panel
        NotificationCenter.default.addObserver(
            forName: .prayerReminderDue,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let prayer = notification.userInfo?["prayer"] as? String,
                  let subtitle = notification.userInfo?["subtitle"] as? String,
                  let button = self.statusItem.button,
                  let window = button.window else { return }

            let buttonFrame = window.convertToScreen(button.frame)
            let screen = window.screen ?? NSScreen.main!

            // Expiring reminder — generiši poruku sa imenima namaza
            var message: ReminderMessage? = nil
            if let prev = notification.userInfo?["expiringPrev"] as? String,
               let next = notification.userInfo?["expiringNext"] as? String {
                message = ReminderMessages.expiring(prevKey: prev, nextKey: next)
            }

            PrayerReminderPanel.show(prayer: prayer, subtitle: subtitle, message: message, buttonFrame: buttonFrame, screen: screen)
        }
    }

    @objc private func handleStatusItemClick() {
        guard let button = statusItem.button else { return }

        if NSApp.currentEvent?.type == .rightMouseUp {
            if popover.isShown { popover.performClose(nil) }
            showContextMenu(from: button)
            return
        }

        togglePopover()
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

    private func showContextMenu(from button: NSStatusBarButton) {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "bs"
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: loc("s.quit", lang), action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        button.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
