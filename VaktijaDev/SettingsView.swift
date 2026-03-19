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

    @State private var permissionDenied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                sectionHeader("Notifikacije")

                Toggle("Uključi notifikacije za namaze", isOn: $notificationsEnabled)
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
                    Text("Dozvoli notifikacije u Postavkama → Notifikacije")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }

                if notificationsEnabled {
                    Divider().padding(.horizontal, 16)

                    sectionHeader("Namazi")

                    prayerToggle("Zora",     key: $fajrEnabled)
                    prayerToggle("Podne",    key: $dhuhrEnabled)
                    prayerToggle("Ikindija", key: $asrEnabled)
                    prayerToggle("Akšam",    key: $maghribEnabled)
                    prayerToggle("Jacija",   key: $ishaEnabled)

                    Divider().padding(.horizontal, 16)

                    sectionHeader("Minuta prije namaza")

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

                sectionHeader("Opće")

                Toggle("Pokreni pri startu", isOn: $launchAtLogin)
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

                Text("Zahtijeva da je app u /Applications folderu.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 300)
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
