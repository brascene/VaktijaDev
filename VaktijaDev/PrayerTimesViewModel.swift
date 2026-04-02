import Foundation
import SwiftUI

@Observable
final class PrayerTimesViewModel {
    var selectedCity: City
    var timings: PrayerTimings?
    var dateInfo: PrayerDateInfo?
    var isLoading = false
    var errorMessage: String?
    var nextPrayer: String?
    var timeUntilNextPrayer: String?
    var useLocation = false
    @ObservationIgnored var locationManager = LocationManager()

    @ObservationIgnored private var lastFetchDate: String?
    @ObservationIgnored private var countdownTimer: Timer?
    @ObservationIgnored private var reminderFiredKeys: Set<String> = []

    init() {
        self.selectedCity = CityList.defaultCity
    }

    func fetchPrayerTimes() async {
        isLoading = true
        errorMessage = nil

        // Determine coordinates and optional city_id
        let lat: Double
        let lon: Double
        let cityId: Int?

        if useLocation {
            await locationManager.requestLocation()
            if let error = locationManager.error {
                errorMessage = error
                isLoading = false
                return
            }
            guard let locLat = locationManager.latitude, let locLon = locationManager.longitude else {
                let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "bs"
                errorMessage = loc("location.unavailable", lang)
                isLoading = false
                return
            }
            lat = locLat
            lon = locLon
            cityId = nil
        } else {
            lat = selectedCity.latitude
            lon = selectedCity.longitude
            cityId = selectedCity.cityId
        }

        // Try primary API (vaktija.dev)
        if let result = await fetchFromVaktijaDev(lat: lat, lon: lon, cityId: cityId) {
            timings = result.timings
            dateInfo = result.dateInfo
            lastFetchDate = todayISO()
            updateNextPrayer()
            startCountdownTimer()
            NotificationManager.shared.scheduleIfEnabled(timings: result.timings)
            isLoading = false
            return
        }

        // Fallback to Aladhan
        if let result = await fetchFromAladhan(lat: lat, lon: lon) {
            timings = result.timings
            dateInfo = result.dateInfo
            lastFetchDate = todayISO()
            updateNextPrayer()
            startCountdownTimer()
            NotificationManager.shared.scheduleIfEnabled(timings: result.timings)
        } else {
            let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "bs"
            errorMessage = loc("error.fetch", lang)
        }

        isLoading = false
    }

    private func fetchFromVaktijaDev(lat: Double, lon: Double, cityId: Int?) async -> (timings: PrayerTimings, dateInfo: PrayerDateInfo)? {
        var components = URLComponents(string: Config.vaktijaDevBaseURL)!
        if let cityId {
            components.queryItems = [URLQueryItem(name: "city_id", value: String(cityId))]
        } else {
            components.queryItems = [
                URLQueryItem(name: "lat", value: String(format: "%.6f", lat)),
                URLQueryItem(name: "lon", value: String(format: "%.6f", lon)),
            ]
        }
        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(VaktijaResponse.self, from: data)
            guard response.success else { return nil }
            let v = response.data
            let timings = PrayerTimings(
                fajr: v.namaska_vremena.zora,
                sunrise: v.namaska_vremena.izlazak,
                dhuhr: v.namaska_vremena.podne,
                asr: v.namaska_vremena.ikindija,
                maghrib: v.namaska_vremena.aksam,
                isha: v.namaska_vremena.jacija,
                polaNoci: v.namaska_vremena.pola_noci,
                zadnjaTrecina: v.namaska_vremena.zadnja_trecina
            )
            let dateInfo = PrayerDateInfo(
                readable: v.date_formatted,
                hijriMonth: v.hijri.month,
                hijriYear: v.hijri.year
            )
            return (timings, dateInfo)
        } catch {
            return nil
        }
    }

    private func fetchFromAladhan(lat: Double, lon: Double) async -> (timings: PrayerTimings, dateInfo: PrayerDateInfo)? {
        let timestamp = Int(Date().timeIntervalSince1970)
        var components = URLComponents(string: "\(Config.apiBaseURLByCoords)/\(timestamp)")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(format: "%.6f", lat)),
            URLQueryItem(name: "longitude", value: String(format: "%.6f", lon)),
            URLQueryItem(name: "method", value: String(Config.calculationMethod)),
            URLQueryItem(name: "methodSettings", value: Config.methodSettings),
        ]
        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AladhanResponse.self, from: data)
            let a = response.data
            let timings = PrayerTimings(
                fajr: a.timings.Fajr,
                sunrise: a.timings.Sunrise,
                dhuhr: a.timings.Dhuhr,
                asr: a.timings.Asr,
                maghrib: a.timings.Maghrib,
                isha: a.timings.Isha,
                polaNoci: nil,
                zadnjaTrecina: nil
            )
            let dateInfo = PrayerDateInfo(
                readable: a.date.readable,
                hijriMonth: a.date.hijri.month.en,
                hijriYear: Int(a.date.hijri.year) ?? 0
            )
            return (timings, dateInfo)
        } catch {
            return nil
        }
    }

    func fetchIfNeeded() async {
        if timings == nil || lastFetchDate != todayISO() {
            await fetchPrayerTimes()
        } else {
            updateNextPrayer()
            startCountdownTimer()
        }
    }

    func updateNextPrayer() {
        guard let timings else {
            nextPrayer = nil
            return
        }

        let prayerOrder: [(String, String)] = [
            ("fajr", timings.fajr),
            ("dhuhr", timings.dhuhr),
            ("asr", timings.asr),
            ("maghrib", timings.maghrib),
            ("isha", timings.isha),
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let now = formatter.string(from: Date())

        for (name, time) in prayerOrder {
            let cleanTime = time.components(separatedBy: " ").first ?? time
            if cleanTime > now {
                nextPrayer = name
                return
            }
        }
        // Nakon jacije, sljedeći namaz je sutrašnja zora
        nextPrayer = "fajr"
    }

    private func startCountdownTimer() {
        stopCountdownTimer()
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickCountdown()
        }
        RunLoop.main.add(timer, forMode: .common)
        countdownTimer = timer
        tickCountdown()
    }

    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func tickCountdown() {
        updateNextPrayer()
        updateCountdownString()
        checkSpecialReminders()
    }

    private func updateCountdownString() {
        guard let nextPrayer, let timings else {
            timeUntilNextPrayer = nil
            return
        }

        let prayerTimeMap: [String: String] = [
            "fajr": timings.fajr,
            "dhuhr": timings.dhuhr,
            "asr": timings.asr,
            "maghrib": timings.maghrib,
            "isha": timings.isha,
        ]

        guard let timeStr = prayerTimeMap[nextPrayer] else {
            timeUntilNextPrayer = nil
            return
        }

        let cleanTime = timeStr.components(separatedBy: " ").first ?? timeStr
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let parsedTime = formatter.date(from: cleanTime) else {
            timeUntilNextPrayer = nil
            return
        }

        let now = Date()
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: now)
        let timeComps = calendar.dateComponents([.hour, .minute], from: parsedTime)
        comps.hour = timeComps.hour
        comps.minute = timeComps.minute
        comps.second = 0

        guard var targetDate = calendar.date(from: comps) else {
            timeUntilNextPrayer = nil
            return
        }

        // Ako je namaz već prošao danas (npr. zora = sutrašnji), prebaci na sutra
        if targetDate <= now {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }

        let interval = targetDate.timeIntervalSince(now)
        guard interval > 0 else {
            timeUntilNextPrayer = nil
            return
        }

        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours >= 1 {
            timeUntilNextPrayer = "\(hours)h \(minutes)m"
        } else {
            timeUntilNextPrayer = String(format: "%dm %02ds", minutes, seconds)
        }

        // 30 minuta prije — uvijek uključeno, upozori da prethodni namaz još nije klanjan
        let expiringPrevMap: [String: String] = [
            "asr": "dhuhr", "maghrib": "asr", "isha": "maghrib", "fajr": "isha",
        ]
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "bs"
        let expiringKey = "\(nextPrayer)_expiring_\(todayISO())"
        if totalSeconds <= 1800 && reminderFiredKeys.insert(expiringKey).inserted,
           let prevKey = expiringPrevMap[nextPrayer] {
            NotificationCenter.default.post(
                name: .prayerReminderDue,
                object: nil,
                userInfo: [
                    "prayer": prevKey,
                    "subtitle": loc("reminder.sub.expiring", lang),
                    "expiringPrev": prevKey,
                    "expiringNext": nextPrayer,
                ]
            )
        }

        // Pokreni panel reminder kad padne na 10 minuta (jednom po namazu)
        let reminderKey = "\(nextPrayer)_\(todayISO())"
        let reminders10MinEnabled = UserDefaults.standard.object(forKey: "reminders10MinEnabled") as? Bool ?? true
        if reminders10MinEnabled && totalSeconds <= 600 && reminderFiredKeys.insert(reminderKey).inserted {
            NotificationCenter.default.post(
                name: .prayerReminderDue,
                object: nil,
                userInfo: [
                    "prayer": nextPrayer,
                    "time": cleanTime,
                    "subtitle": "\(loc("reminder.sub.10min", lang)) · \(cleanTime)",
                ]
            )
        }
    }

    private func checkSpecialReminders() {
        guard let timings else { return }
        guard UserDefaults.standard.object(forKey: "remindersSpecialEnabled") as? Bool ?? true else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let now = formatter.string(from: Date())
        let today = todayISO()

        // Duha: 65% puta između izlaska sunca i podne-a
        if let duhaTime = calculateDuhaTime() {
            let key = "duha_\(today)"
            if now >= duhaTime && now < (timings.dhuhr.components(separatedBy: " ").first ?? timings.dhuhr)
                && reminderFiredKeys.insert(key).inserted {
                NotificationCenter.default.post(
                    name: .prayerReminderDue,
                    object: nil,
                    userInfo: [
                        "prayer": "duha",
                        "time": duhaTime,
                        "subtitle": "Duha namaz · \(duhaTime)",
                    ]
                )
            }
        }

        // Polanoć i zadnja trećina — aktivni samo između ponoći i 06:00
        guard now >= "00:00" && now < "06:00" else { return }

        if let polaNoci = timings.polaNoci {
            let clean = polaNoci.components(separatedBy: " ").first ?? polaNoci
            let key = "polaNoci_\(today)"
            if now >= clean && reminderFiredKeys.insert(key).inserted {
                NotificationCenter.default.post(
                    name: .prayerReminderDue,
                    object: nil,
                    userInfo: [
                        "prayer": "polaNoci",
                        "time": clean,
                        "subtitle": "Nastupilo je noćno doba · \(clean)",
                    ]
                )
            }
        }

        if let zadnjaTrecina = timings.zadnjaTrecina {
            let clean = zadnjaTrecina.components(separatedBy: " ").first ?? zadnjaTrecina
            let key = "zadnjaTrecina_\(today)"
            if now >= clean && reminderFiredKeys.insert(key).inserted {
                NotificationCenter.default.post(
                    name: .prayerReminderDue,
                    object: nil,
                    userInfo: [
                        "prayer": "zadnjaTrecina",
                        "time": clean,
                        "subtitle": "Zadnja trećina noći · \(clean)",
                    ]
                )
            }
        }
    }

    private func calculateDuhaTime() -> String? {
        guard let timings else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let sunriseClean = timings.sunrise.components(separatedBy: " ").first ?? timings.sunrise
        let dhuhrClean = timings.dhuhr.components(separatedBy: " ").first ?? timings.dhuhr
        guard let sunriseDate = formatter.date(from: sunriseClean),
              let dhuhrDate = formatter.date(from: dhuhrClean) else { return nil }
        let interval = dhuhrDate.timeIntervalSince(sunriseDate)
        guard interval > 0 else { return nil }
        let duhaDate = sunriseDate.addingTimeInterval(interval * 0.65)
        return formatter.string(from: duhaDate)
    }

    private func todayISO() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
