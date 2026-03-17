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

    private var lastFetchDate: String?

    init() {
        let defaultCity = CityList.all.first {
            $0.name == Config.defaultCity && $0.country == Config.defaultCountry
        } ?? CityList.all[0]
        self.selectedCity = defaultCity
    }

    func fetchPrayerTimes() async {
        isLoading = true
        errorMessage = nil

        var components = URLComponents(string: Config.apiBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "city", value: selectedCity.name),
            URLQueryItem(name: "country", value: selectedCity.country),
            URLQueryItem(name: "method", value: String(Config.calculationMethod)),
            URLQueryItem(name: "methodSettings", value: Config.methodSettings),
        ]

        guard let url = components.url else {
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
