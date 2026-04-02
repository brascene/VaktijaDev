import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("minutesBefore") private var minutesBefore = 10
    @AppStorage("prayerEnabled_fajr")    private var fajrEnabled    = true
    @AppStorage("prayerEnabled_dhuhr")   private var dhuhrEnabled   = true
    @AppStorage("prayerEnabled_asr")     private var asrEnabled     = true
    @AppStorage("prayerEnabled_maghrib") private var maghribEnabled = true
    @AppStorage("prayerEnabled_isha")    private var ishaEnabled    = true
    @AppStorage("launchAtLogin")         private var launchAtLogin  = false
    @AppStorage("reminders10MinEnabled")     private var reminders10MinEnabled     = true
    @AppStorage("remindersSpecialEnabled")   private var remindersSpecialEnabled   = true
    @AppStorage("appLanguage")           private var language = "bs"

    @State private var permissionDenied = false
    @State private var showLockedInfo = false
    @Environment(\.appLanguage) private var lang

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                sectionHeader(loc("s.language", lang))

                HStack(spacing: 8) {
                    languageButton(code: "bs", flag: "🇧🇦", name: "Bosanski")
                    languageButton(code: "en", flag: "🇬🇧", name: "English")
                    languageButton(code: "de", flag: "🇩🇪", name: "Deutsch")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider().padding(.horizontal, 16)

                sectionHeader(loc("s.notifications", lang))

                Toggle(loc("s.notificationsToggle", lang), isOn: $notificationsEnabled)
                    .font(.system(size: 13))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            Task {
                                let granted = await NotificationManager.shared.requestPermission()
                                if !granted {
                                    notificationsEnabled = false
                                    permissionDenied = true
                                }
                            }
                        } else {
                            NotificationManager.shared.cancelAll()
                        }
                    }

                if permissionDenied {
                    Text(loc("s.notificationsDenied", lang))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }

                if notificationsEnabled {
                    Divider().padding(.horizontal, 16)

                    sectionHeader(loc("s.prayers", lang))

                    prayerToggle(loc("prayer.fajr",    lang), key: $fajrEnabled)
                    prayerToggle(loc("prayer.dhuhr",   lang), key: $dhuhrEnabled)
                    prayerToggle(loc("prayer.asr",     lang), key: $asrEnabled)
                    prayerToggle(loc("prayer.maghrib", lang), key: $maghribEnabled)
                    prayerToggle(loc("prayer.isha",    lang), key: $ishaEnabled)

                    Divider().padding(.horizontal, 16)

                    sectionHeader(loc("s.minutesBefore", lang))

                    Picker("", selection: $minutesBefore) {
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                        Text("15 min").tag(15)
                        Text("20 min").tag(20)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                Divider().padding(.horizontal, 16)

                sectionHeader(loc("s.reminders", lang))

                Toggle(loc("s.10min", lang), isOn: $reminders10MinEnabled)
                    .font(.system(size: 13))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                Text(loc("s.10minNote", lang))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)

                Toggle(loc("s.spiritual", lang), isOn: $remindersSpecialEnabled)
                    .font(.system(size: 13))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                Text(loc("s.spiritualNote", lang))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showLockedInfo = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.easeInOut(duration: 0.2)) { showLockedInfo = false }
                    }
                } label: {
                    HStack {
                        Text(loc("s.30min", lang))
                            .font(.system(size: 13))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        Toggle("", isOn: .constant(true))
                            .labelsHidden()
                            .disabled(true)
                            .scaleEffect(0.8)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if showLockedInfo {
                    Text(loc("s.30minLocked", lang))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider().padding(.horizontal, 16)

                sectionHeader(loc("s.general", lang))

                Toggle(loc("s.launchAtLogin", lang), isOn: $launchAtLogin)
                    .font(.system(size: 13))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .onChange(of: launchAtLogin) { _, enabled in
                        do {
                            if enabled {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = !enabled
                        }
                    }

                Text(loc("s.launchAtLoginNote", lang))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                Divider().padding(.horizontal, 16)

                Button {
                    let url = Bundle.main.bundleURL
                    let task = Process()
                    task.launchPath = "/bin/sh"
                    task.arguments = ["-c", "sleep 0.5; open \"\(url.path)\""]
                    try? task.run()
                    NSApp.terminate(nil)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                        Text(loc("s.restart", lang))
                            .font(.system(size: 13))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Text(loc("s.restartNote", lang))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 300)
    }

    private func languageButton(code: String, flag: String, name: String) -> some View {
        Button {
            language = code
        } label: {
            HStack(spacing: 6) {
                Text(flag)
                    .font(.system(size: 16))
                Text(name)
                    .font(.system(size: 13))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(language == code ? Color.accentColor.opacity(0.15) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(language == code ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundStyle(language == code ? Color.accentColor : .primary)
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.tertiary)
            .textCase(.uppercase)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }

    private func prayerToggle(_ name: String, key: Binding<Bool>) -> some View {
        Toggle(name, isOn: key)
            .font(.system(size: 13))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
    }
}
