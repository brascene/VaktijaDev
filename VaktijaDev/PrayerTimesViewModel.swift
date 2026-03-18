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
    var useLocation = false
    @ObservationIgnored var locationManager = LocationManager()

    @ObservationIgnored private var lastFetchDate: String?

    init() {
        let defaultCity = CityList.all.first {
            $0.name == Config.defaultCity && $0.country == Config.defaultCountry
        } ?? CityList.all[0]
        self.selectedCity = defaultCity
    }

    func fetchPrayerTimes() async {
        isLoading = true
        errorMessage = nil

        let lat: Double
        let lon: Double

        if useLocation {
            await locationManager.requestLocation()
            if let error = locationManager.error {
                errorMessage = error
                isLoading = false
                return
            }
            guard let locLat = locationManager.latitude, let locLon = locationManager.longitude else {
                errorMessage = "Lokacija nije dostupna"
                isLoading = false
                return
            }
            lat = locLat
            lon = locLon
        } else {
            lat = selectedCity.latitude
            lon = selectedCity.longitude
        }

        // Try primary API (vaktija.dev)
        if let result = await fetchFromVaktijaDev(lat: lat, lon: lon) {
            timings = result.timings
            dateInfo = result.dateInfo
            lastFetchDate = todayISO()
            updateNextPrayer()
            isLoading = false
            return
        }

        // Fallback to Aladhan
        if let result = await fetchFromAladhan(lat: lat, lon: lon) {
            timings = result.timings
            dateInfo = result.dateInfo
            lastFetchDate = todayISO()
            updateNextPrayer()
        } else {
            errorMessage = "Greška pri učitavanju vaktije"
        }

        isLoading = false
    }

    private func fetchFromVaktijaDev(lat: Double, lon: Double) async -> (timings: PrayerTimings, dateInfo: PrayerDateInfo)? {
        var components = URLComponents(string: Config.vaktijaDevBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(format: "%.6f", lat)),
            URLQueryItem(name: "lon", value: String(format: "%.6f", lon)),
        ]
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

        nextPrayer = nil
        for (name, time) in prayerOrder {
            let cleanTime = time.components(separatedBy: " ").first ?? time
            if cleanTime > now {
                nextPrayer = name
                return
            }
        }
    }

    private func todayISO() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
