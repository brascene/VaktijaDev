import Foundation
import SwiftUI

@Observable
final class PrayerTimesViewModel {
    var selectedCity: City
    var timings: Timings?
    var dateInfo: AladhanDate?
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

        let url: URL?

        if useLocation {
            await locationManager.requestLocation()
            if let error = locationManager.error {
                errorMessage = error
                isLoading = false
                return
            }
            guard let lat = locationManager.latitude, let lon = locationManager.longitude else {
                errorMessage = "Lokacija nije dostupna"
                isLoading = false
                return
            }
            let timestamp = Int(Date().timeIntervalSince1970)
            var components = URLComponents(string: "\(Config.apiBaseURLByCoords)/\(timestamp)")!
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(lat)),
                URLQueryItem(name: "longitude", value: String(lon)),
                URLQueryItem(name: "method", value: String(Config.calculationMethod)),
                URLQueryItem(name: "methodSettings", value: Config.methodSettings),
            ]
            url = components.url
        } else {
            var components = URLComponents(string: Config.apiBaseURL)!
            components.queryItems = [
                URLQueryItem(name: "city", value: selectedCity.name),
                URLQueryItem(name: "country", value: selectedCity.country),
                URLQueryItem(name: "method", value: String(Config.calculationMethod)),
                URLQueryItem(name: "methodSettings", value: Config.methodSettings),
            ]
            url = components.url
        }

        guard let url else {
            errorMessage = "Neispravan URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AladhanResponse.self, from: data)
            timings = response.data.timings
            dateInfo = response.data.date
            lastFetchDate = response.data.date.readable
            updateNextPrayer()
        } catch {
            errorMessage = "Greška pri učitavanju vaktije"
        }

        isLoading = false
    }

    func fetchIfNeeded() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let today = formatter.string(from: Date())

        if timings == nil || lastFetchDate != today {
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
            ("Fajr", timings.Fajr),
            ("Dhuhr", timings.Dhuhr),
            ("Asr", timings.Asr),
            ("Maghrib", timings.Maghrib),
            ("Isha", timings.Isha),
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
}
