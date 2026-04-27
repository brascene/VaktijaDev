import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func scheduleIfEnabled(timings: PrayerTimings) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else { return }

        let minutesBefore = {
            let v = UserDefaults.standard.integer(forKey: "minutesBefore")
            return v == 0 ? 10 : v
        }()

        let allPrayers = ["fajr", "dhuhr", "asr", "maghrib", "isha"]
        let enabledPrayers = Set(allPrayers.filter {
            let key = "prayerEnabled_\($0)"
            return UserDefaults.standard.object(forKey: key) == nil
                ? true
                : UserDefaults.standard.bool(forKey: key)
        })

        schedule(timings: timings, minutesBefore: minutesBefore, enabledPrayers: enabledPrayers)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func schedule(timings: PrayerTimings, minutesBefore: Int, enabledPrayers: Set<String>) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: enabledPrayers.map { "prayer_\($0)" })

        let lang = currentLang()
        let prayers: [(String, String)] = [
            ("fajr",    timings.fajr),
            ("dhuhr",   timings.dhuhr),
            ("asr",     timings.asr),
            ("maghrib", timings.maghrib),
            ("isha",    timings.isha),
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        for (key, timeStr) in prayers {
            guard enabledPrayers.contains(key) else { continue }
            let cleanTime = timeStr.components(separatedBy: " ").first ?? timeStr
            guard let prayerTime = formatter.date(from: cleanTime) else { continue }

            var todayComps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            let timeComps = Calendar.current.dateComponents([.hour, .minute], from: prayerTime)
            todayComps.hour = timeComps.hour
            todayComps.minute = timeComps.minute

            guard let prayerDate = Calendar.current.date(from: todayComps) else { continue }
            let notifDate = prayerDate.addingTimeInterval(-Double(minutesBefore) * 60)
            guard notifDate > Date() else { continue }

            let name = loc("prayer.\(key)", lang)
            let content = UNMutableNotificationContent()
            content.title = minutesBefore == 0
                ? name
                : "\(name) \(loc("notif.in", lang)) \(minutesBefore) \(loc("notif.min", lang))"
            content.body = "\(loc("notif.prayerAt", lang)) \(cleanTime)"
            content.sound = .default

            let notifComps = Calendar.current.dateComponents([.hour, .minute], from: notifDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: notifComps, repeats: false)
            let request = UNNotificationRequest(identifier: "prayer_\(key)", content: content, trigger: trigger)
            center.add(request)
        }
    }
}
