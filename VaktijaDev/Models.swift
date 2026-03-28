import Foundation

// MARK: - Hijri month names

enum HijriMonths {
    private static let bs: [String: String] = [
        "Muharram":           "Muharrem",
        "Safar":              "Safer",
        "Rabi al-Awwal":      "Rebi'ul-evvel",
        "Rabi' al-Awwal":     "Rebi'ul-evvel",
        "Rabi' I":            "Rebi'ul-evvel",
        "Rabi al-Thani":      "Rebi'ul-ahir",
        "Rabi' al-Thani":     "Rebi'ul-ahir",
        "Rabi' II":           "Rebi'ul-ahir",
        "Jumada al-Ula":      "Džumadel-ula",
        "Jumada al-Awwal":    "Džumadel-ula",
        "Jumada I":           "Džumadel-ula",
        "Jumada al-Akhirah":  "Džumadel-uhra",
        "Jumada al-Thani":    "Džumadel-uhra",
        "Jumada II":          "Džumadel-uhra",
        "Rajab":              "Redžeb",
        "Sha'ban":            "Ša'ban",
        "Shaban":             "Ša'ban",
        "Ramadan":            "Ramazan",
        "Shawwal":            "Ševval",
        "Dhu al-Qi'dah":      "Zul-ka'de",
        "Dhu al-Qadah":       "Zul-ka'de",
        "Dhu al-Hijjah":      "Zul-hidždže",
        "Dhu al-Hijja":       "Zul-hidždže",
    ]

    private static let de: [String: String] = [
        "Muharram":           "Muharram",
        "Safar":              "Safar",
        "Rabi al-Awwal":      "Rabi' al-Awwal",
        "Rabi' al-Awwal":     "Rabi' al-Awwal",
        "Rabi' I":            "Rabi' al-Awwal",
        "Rabi al-Thani":      "Rabi' ath-Thani",
        "Rabi' al-Thani":     "Rabi' ath-Thani",
        "Rabi' II":           "Rabi' ath-Thani",
        "Jumada al-Ula":      "Dschumada al-Ula",
        "Jumada al-Awwal":    "Dschumada al-Ula",
        "Jumada I":           "Dschumada al-Ula",
        "Jumada al-Akhirah":  "Dschumada al-Achira",
        "Jumada al-Thani":    "Dschumada al-Achira",
        "Jumada II":          "Dschumada al-Achira",
        "Rajab":              "Radschab",
        "Sha'ban":            "Scha'ban",
        "Shaban":             "Scha'ban",
        "Ramadan":            "Ramadan",
        "Shawwal":            "Schawwal",
        "Dhu al-Qi'dah":      "Dhu l-Qi'da",
        "Dhu al-Qadah":       "Dhu l-Qi'da",
        "Dhu al-Hijjah":      "Dhu l-Hidscha",
        "Dhu al-Hijja":       "Dhu l-Hidscha",
    ]

    static func localized(_ english: String, lang: String) -> String {
        switch lang {
        case "bs": return bs[english] ?? english
        case "de": return de[english] ?? english
        default:   return english
        }
    }

    // kept for backwards compatibility
    static func bosnian(_ english: String) -> String {
        localized(english, lang: "bs")
    }
}

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
    let date: String
    let formatted: String
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

// MARK: - Vaktija.dev Monthly API

struct VaktijaMonthlyResponse: Codable {
    let success: Bool
    let data: VaktijaMonthlyData
}

struct VaktijaMonthlyData: Codable {
    let month: String
    let year: String
    let days: [VaktijaDayData]
}

struct VaktijaDayData: Codable, Identifiable {
    let date: String
    let date_formatted: String
    let day_name: String
    let hijri: VaktijaHijri
    let namaska_vremena: NamaskaVremena
    var id: String { date }
}

// MARK: - Vaktija.dev Locations API

struct VaktijaLocationsResponse: Codable {
    let data: VaktijaLocationsPage
}

struct VaktijaLocationsPage: Codable {
    let data: [VaktijaLocation]
    let last_page: Int
}

struct VaktijaLocation: Codable {
    let id: Int
    let name: String
    let latitude: String
    let longitude: String
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
