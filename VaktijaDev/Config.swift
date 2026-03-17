import Foundation

enum Config {
    static let apiBaseURL = "https://api.aladhan.com/v1/timingsByCity"
    static let apiBaseURLByCoords = "https://api.aladhan.com/v1/timings"
    static let calculationMethod = 99 // Custom
    static let methodSettings = "14.5,null,14.5" // Fajr 14.5°, Maghrib default, Isha 14.5°
    static let defaultCity = "Konjic"
    static let defaultCountry = "Bosnia and Herzegovina"
}
