import Foundation

// MARK: - Unified model used by UI

struct PrayerTimings: Sendable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
    let polaNoci: String?
    let zadnjaTrecina: String?
}

struct PrayerDateInfo: Sendable {
    let readable: String
    let hijriMonth: String
    let hijriYear: Int
}

// MARK: - Vaktija.dev API models (primary)

struct VaktijaResponse: Codable, Sendable {
    let success: Bool
    let data: VaktijaData
}

struct VaktijaData: Codable, Sendable {
    let date: String
    let date_formatted: String
    let hijri: VaktijaHijri
    let namaska_vremena: NamaskaVremena
}

struct VaktijaHijri: Codable, Sendable {
    let month: String
    let year: Int
}

struct NamaskaVremena: Codable, Sendable {
    let zora: String
    let izlazak: String
    let podne: String
    let ikindija: String
    let aksam: String
    let jacija: String
    let pola_noci: String
    let zadnja_trecina: String
}

// MARK: - Aladhan API models (fallback)

struct AladhanResponse: Codable, Sendable {
    let data: AladhanData
}

struct AladhanData: Codable, Sendable {
    let timings: AladhanTimings
    let date: AladhanDate
}

struct AladhanTimings: Codable, Sendable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct AladhanDate: Codable, Sendable {
    let readable: String
    let hijri: AladhanHijriDate
}

struct AladhanHijriDate: Codable, Sendable {
    let month: AladhanHijriMonth
    let year: String
}

struct AladhanHijriMonth: Codable, Sendable {
    let en: String
}
