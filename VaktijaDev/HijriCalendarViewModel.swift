import Foundation

@Observable
final class HijriCalendarViewModel {
    var days: [VaktijaDayData] = []
    var selectedDate: String
    var isLoading = false
    var displayMonth: Int
    var displayYear: Int

    var fetchedKey: String?

    init() {
        let now = Date()
        let cal = Calendar.current
        displayMonth = cal.component(.month, from: now)
        displayYear = cal.component(.year, from: now)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        selectedDate = formatter.string(from: now)
    }

    func fetchIfNeeded(cityId: Int?) async {
        guard let cityId else { return }
        let key = "\(displayMonth)-\(displayYear)-\(cityId)"
        guard fetchedKey != key else { return }
        await fetch(cityId: cityId)
    }

    func fetch(cityId: Int?) async {
        guard let cityId else { return }
        isLoading = true
        var components = URLComponents(string: Config.vaktijaMonthlyURL)!
        components.queryItems = [
            URLQueryItem(name: "month", value: String(displayMonth)),
            URLQueryItem(name: "year", value: String(displayYear)),
            URLQueryItem(name: "city_id", value: String(cityId)),
        ]
        guard let url = components.url else { isLoading = false; return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(VaktijaMonthlyResponse.self, from: data)
            days = response.data.days
            fetchedKey = "\(displayMonth)-\(displayYear)-\(cityId)"
        } catch {
            days = []
        }
        isLoading = false
    }

    func previousMonth() {
        if displayMonth == 1 { displayMonth = 12; displayYear -= 1 }
        else { displayMonth -= 1 }
        fetchedKey = nil
    }

    func nextMonth() {
        if displayMonth == 12 { displayMonth = 1; displayYear += 1 }
        else { displayMonth += 1 }
        fetchedKey = nil
    }

    var selectedDayData: VaktijaDayData? {
        days.first { $0.date == selectedDate }
    }

    var startOffset: Int {
        guard let firstDay = days.first else { return 0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: firstDay.date) else { return 0 }
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)
        return weekday == 1 ? 6 : weekday - 2 // Mon=0 .. Sun=6
    }

    var monthYearLabel: String {
        var comps = DateComponents()
        comps.month = displayMonth
        comps.year = displayYear
        comps.day = 1
        let date = Calendar.current.date(from: comps) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "bs")
        return formatter.string(from: date).capitalized
    }

    var hijriMonthLabel: String? {
        // Show hijri month of the majority of days in this month
        days.first?.hijri.month
    }

    var todayISO: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
