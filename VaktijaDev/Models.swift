import Foundation

struct AladhanResponse: Codable, Sendable {
    let data: AladhanData
}

struct AladhanData: Codable, Sendable {
    let timings: Timings
    let date: AladhanDate
}

struct Timings: Codable, Sendable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct AladhanDate: Codable, Sendable {
    let readable: String
    let hijri: HijriDate
}

struct HijriDate: Codable, Sendable {
    let date: String
    let month: HijriMonth
    let year: String
}

struct HijriMonth: Codable, Sendable {
    let en: String
}
