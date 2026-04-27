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
    let location: VaktijaResponseLocation?
}

struct VaktijaResponseLocation: Codable, Sendable {
    let city: String?
    let country: String?
    let timezone: String?
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
    let location: VaktijaResponseLocation?
    var id: String { date }

    func withConvertedTimes() -> VaktijaDayData {
        VaktijaDayData(
            date: date,
            date_formatted: date_formatted,
            day_name: day_name,
            hijri: hijri,
            namaska_vremena: namaska_vremena.converted(from: location?.timezone, on: date),
            location: location
        )
    }
}

// MARK: - API timezone conversion
//
// vaktija.dev returns prayer times in `Europe/Sarajevo` regardless of the queried
// location. We convert each "HH:mm" string into the device's local timezone at
// the API boundary so all downstream code (Calendar.current, notification
// triggers) sees device-local times.
enum APITimeConverter {
    static func convert(_ time: String, from sourceTimezoneId: String?, on isoDate: String) -> String {
        let cleanTime = String(time.components(separatedBy: " ").first ?? time)
        guard !cleanTime.isEmpty,
              let sourceTZ = TimeZone(identifier: sourceTimezoneId ?? "Europe/Sarajevo")
                ?? TimeZone(identifier: "Europe/Sarajevo")
        else { return time }

        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd HH:mm"
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.timeZone = sourceTZ
        guard let date = parser.date(from: "\(isoDate) \(cleanTime)") else { return time }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}

extension NamaskaVremena {
    func converted(from sourceTimezone: String?, on isoDate: String) -> NamaskaVremena {
        NamaskaVremena(
            zora: APITimeConverter.convert(zora, from: sourceTimezone, on: isoDate),
            izlazak: APITimeConverter.convert(izlazak, from: sourceTimezone, on: isoDate),
            podne: APITimeConverter.convert(podne, from: sourceTimezone, on: isoDate),
            ikindija: APITimeConverter.convert(ikindija, from: sourceTimezone, on: isoDate),
            aksam: APITimeConverter.convert(aksam, from: sourceTimezone, on: isoDate),
            jacija: APITimeConverter.convert(jacija, from: sourceTimezone, on: isoDate),
            pola_noci: APITimeConverter.convert(pola_noci, from: sourceTimezone, on: isoDate),
            zadnja_trecina: APITimeConverter.convert(zadnja_trecina, from: sourceTimezone, on: isoDate)
        )
    }
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
