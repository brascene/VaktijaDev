import SwiftUI

// MARK: - Environment key

struct AppLanguageKey: EnvironmentKey {
    static let defaultValue = "bs"
}

extension EnvironmentValues {
    var appLanguage: String {
        get { self[AppLanguageKey.self] }
        set { self[AppLanguageKey.self] = newValue }
    }
}

// MARK: - Helper

func loc(_ key: String, _ lang: String) -> String {
    translations[lang]?[key] ?? translations["bs"]?[key] ?? key
}

// Current language from AppStorage — used by non-SwiftUI code paths (managers, panels).
func currentLang() -> String {
    UserDefaults.standard.string(forKey: "appLanguage") ?? "bs"
}

// Translates a Bosnian weekday name returned by the vaktija.dev API into the current locale.
func localizedWeekday(_ bosnianDayName: String, lang: String) -> String {
    let key = bosnianDayName.lowercased().folding(options: .diacriticInsensitive, locale: Locale(identifier: "bs"))
    let mapping: [String: String] = [
        "ponedjeljak": "day.full.mon",
        "utorak":      "day.full.tue",
        "srijeda":     "day.full.wed",
        "cetvrtak":    "day.full.thu",
        "petak":       "day.full.fri",
        "subota":      "day.full.sat",
        "nedjelja":    "day.full.sun",
    ]
    guard let locKey = mapping[key] else { return bosnianDayName.capitalized }
    return loc(locKey, lang)
}

// MARK: - All translations

let translations: [String: [String: String]] = [
    "bs": [
        // Prayer names
        "prayer.fajr":    "Zora",
        "prayer.sunrise": "Izlazak sunca",
        "prayer.dhuhr":   "Podne",
        "prayer.asr":     "Ikindija",
        "prayer.maghrib": "Akšam",
        "prayer.isha":    "Jacija",
        // Prayer names (short, for calendar)
        "prayer.short.fajr":    "Zora",
        "prayer.short.sunrise": "Izlazak",
        "prayer.short.dhuhr":   "Podne",
        "prayer.short.asr":     "Ikindija",
        "prayer.short.maghrib": "Akšam",
        "prayer.short.isha":    "Jacija",
        // Night times
        "night.section":   "Noćna vremena",
        "night.midnight":  "Pola noći",
        "night.lastThird": "Zadnja trećina",
        // Location / errors
        "location.mine":        "Moja lokacija",
        "location.useCity":     "Koristi listu gradova",
        "location.useMine":     "Koristi moju lokaciju",
        "location.unavailable": "Lokacija nije dostupna",
        "location.denied":      "Lokacija nije dozvoljena",
        "location.unknown":     "Nije moguće odrediti lokaciju",
        "error.fetch":          "Greška pri učitavanju vaktije",
        "btn.tryAgain":         "Pokušaj ponovo",
        "btn.openSettings":     "Postavke",
        "btn.close":            "Zatvori",
        // Calendar
        "cal.empty":   "Odaberi grad za prikaz kalendara",
        "cal.day.mon": "Po", "cal.day.tue": "Ut", "cal.day.wed": "Sr",
        "cal.day.thu": "Če", "cal.day.fri": "Pe", "cal.day.sat": "Su", "cal.day.sun": "Ne",
        "day.full.mon": "Ponedjeljak",
        "day.full.tue": "Utorak",
        "day.full.wed": "Srijeda",
        "day.full.thu": "Četvrtak",
        "day.full.fri": "Petak",
        "day.full.sat": "Subota",
        "day.full.sun": "Nedjelja",
        // City picker
        "city.title":      "Odaberi grad",
        "city.back":       "Nazad",
        "city.country":    "Država",
        "search.placeholder": "Pretraži grad…",
        "search.noResults":   "Nema rezultata za \"%@\"",
        // Settings sections
        "s.language":   "Jezik",
        "s.notifications":        "Notifikacije",
        "s.notificationsToggle":  "Uključi notifikacije za namaze",
        "s.notificationsDenied":  "Dozvoli notifikacije u Postavkama → Notifikacije",
        "s.prayers":              "Namazi",
        "s.minutesBefore":        "Minuta prije namaza",
        "s.reminders":            "Podsjetnici",
        "s.10min":                "10-minutni podsjetnici",
        "s.10minNote":            "Motivacijska poruka ili hadis 10 minuta prije svakog namaza.",
        "s.spiritual":            "Duhovni podsjetnici",
        "s.spiritualNote":        "Duha namaz, noćni namaz (polanoć) i zadnja trećina noći.",
        "s.30min":                "30-minutno upozorenje",
        "s.30minLocked":          "Ovo upozorenje je namjerno uvijek uključeno — kada se bliži sljedeći namaz, podsjećamo te da klanjanje prethodnog ne odlažeš. Cilj je da ti ne prođe namasko vrijeme.",
        "s.general":              "Opće",
        "s.launchAtLogin":        "Pokreni pri startu",
        "s.launchAtLoginNote":    "Zahtijeva da je app u /Applications folderu.",
        "s.restart":              "Restartuj aplikaciju",
        "s.restartNote":          "Primijeni ažuriranja ili osvježi podatke.",
        "s.quit":                 "Izađi",
        // Notification format
        "notif.in":        "za",
        "notif.min":       "min",
        "notif.prayerAt":  "Namaz u",
        // Reminder panel
        "reminder.duha":          "Duha namaz",
        "reminder.polaNoci":      "Noćni namaz",
        "reminder.zadnjaTrecina": "Zadnja trećina noći",
        "reminder.sub.10min":     "za 10 minuta",
        "reminder.sub.duha":      "Duha namaz",
        "reminder.sub.night":     "Nastupilo je noćno doba",
        "reminder.sub.lastThird": "Zadnja trećina noći",
        "reminder.sub.expiring":  "ističe za 30 minuta",
    ],
    "en": [
        // Prayer names
        "prayer.fajr":    "Fajr",
        "prayer.sunrise": "Sunrise",
        "prayer.dhuhr":   "Dhuhr",
        "prayer.asr":     "Asr",
        "prayer.maghrib": "Maghrib",
        "prayer.isha":    "Isha",
        // Prayer names (short, for calendar)
        "prayer.short.fajr":    "Fajr",
        "prayer.short.sunrise": "Sunrise",
        "prayer.short.dhuhr":   "Dhuhr",
        "prayer.short.asr":     "Asr",
        "prayer.short.maghrib": "Maghrib",
        "prayer.short.isha":    "Isha",
        // Night times
        "night.section":   "Night Times",
        "night.midnight":  "Midnight",
        "night.lastThird": "Last Third",
        // Location / errors
        "location.mine":        "My Location",
        "location.useCity":     "Use city list",
        "location.useMine":     "Use my location",
        "location.unavailable": "Location unavailable",
        "location.denied":      "Location access denied",
        "location.unknown":     "Unable to determine location",
        "error.fetch":          "Error loading prayer times",
        "btn.tryAgain":         "Try again",
        "btn.openSettings":     "Settings",
        "btn.close":            "Close",
        // Calendar
        "cal.empty":   "Select a city to view the calendar",
        "cal.day.mon": "Mo", "cal.day.tue": "Tu", "cal.day.wed": "We",
        "cal.day.thu": "Th", "cal.day.fri": "Fr", "cal.day.sat": "Sa", "cal.day.sun": "Su",
        "day.full.mon": "Monday",
        "day.full.tue": "Tuesday",
        "day.full.wed": "Wednesday",
        "day.full.thu": "Thursday",
        "day.full.fri": "Friday",
        "day.full.sat": "Saturday",
        "day.full.sun": "Sunday",
        // City picker
        "city.title":      "Select city",
        "city.back":       "Back",
        "city.country":    "Country",
        "search.placeholder": "Search city…",
        "search.noResults":   "No results for \"%@\"",
        // Settings sections
        "s.language":   "Language",
        "s.notifications":        "Notifications",
        "s.notificationsToggle":  "Enable prayer notifications",
        "s.notificationsDenied":  "Allow notifications in Settings → Notifications",
        "s.prayers":              "Prayers",
        "s.minutesBefore":        "Minutes before prayer",
        "s.reminders":            "Reminders",
        "s.10min":                "10-minute reminders",
        "s.10minNote":            "A motivational message or hadith 10 minutes before each prayer.",
        "s.spiritual":            "Spiritual reminders",
        "s.spiritualNote":        "Duha prayer, night prayer (midnight) and last third of the night.",
        "s.30min":                "30-minute warning",
        "s.30minLocked":          "This warning is intentionally always on — when the next prayer approaches, we remind you not to delay the previous one. The goal is to make sure prayer time doesn't pass you by.",
        "s.general":              "General",
        "s.launchAtLogin":        "Launch at login",
        "s.launchAtLoginNote":    "Requires the app to be in /Applications folder.",
        "s.restart":              "Restart app",
        "s.restartNote":          "Apply updates or refresh data.",
        "s.quit":                 "Quit",
        // Notification format
        "notif.in":        "in",
        "notif.min":       "min",
        "notif.prayerAt":  "Prayer at",
        // Reminder panel
        "reminder.duha":          "Duha Prayer",
        "reminder.polaNoci":      "Night Prayer",
        "reminder.zadnjaTrecina": "Last Third of Night",
        "reminder.sub.10min":     "in 10 minutes",
        "reminder.sub.duha":      "Duha prayer",
        "reminder.sub.night":     "Night time has begun",
        "reminder.sub.lastThird": "Last third of the night",
        "reminder.sub.expiring":  "expires in 30 minutes",
    ],
    "de": [
        // Prayer names
        "prayer.fajr":    "Morgengebet",
        "prayer.sunrise": "Sonnenaufgang",
        "prayer.dhuhr":   "Mittagsgebet",
        "prayer.asr":     "Nachmittagsgebet",
        "prayer.maghrib": "Abendgebet",
        "prayer.isha":    "Nachtgebet",
        // Prayer names (short, for calendar)
        "prayer.short.fajr":    "Fajr",
        "prayer.short.sunrise": "Aufgang",
        "prayer.short.dhuhr":   "Dhuhr",
        "prayer.short.asr":     "Asr",
        "prayer.short.maghrib": "Maghrib",
        "prayer.short.isha":    "Isha",
        // Night times
        "night.section":   "Nächtliche Zeiten",
        "night.midnight":  "Mitternacht",
        "night.lastThird": "Letztes Drittel",
        // Location / errors
        "location.mine":        "Mein Standort",
        "location.useCity":     "Städteliste verwenden",
        "location.useMine":     "Meinen Standort verwenden",
        "location.unavailable": "Standort nicht verfügbar",
        "location.denied":      "Standortzugriff verweigert",
        "location.unknown":     "Standort konnte nicht ermittelt werden",
        "error.fetch":          "Fehler beim Laden der Gebetszeiten",
        "btn.tryAgain":         "Erneut versuchen",
        "btn.openSettings":     "Einstellungen",
        "btn.close":            "Schließen",
        // Calendar
        "cal.empty":   "Stadt auswählen, um den Kalender anzuzeigen",
        "cal.day.mon": "Mo", "cal.day.tue": "Di", "cal.day.wed": "Mi",
        "cal.day.thu": "Do", "cal.day.fri": "Fr", "cal.day.sat": "Sa", "cal.day.sun": "So",
        "day.full.mon": "Montag",
        "day.full.tue": "Dienstag",
        "day.full.wed": "Mittwoch",
        "day.full.thu": "Donnerstag",
        "day.full.fri": "Freitag",
        "day.full.sat": "Samstag",
        "day.full.sun": "Sonntag",
        // City picker
        "city.title":      "Stadt auswählen",
        "city.back":       "Zurück",
        "city.country":    "Land",
        "search.placeholder": "Stadt suchen…",
        "search.noResults":   "Keine Ergebnisse für \"%@\"",
        // Settings sections
        "s.language":   "Sprache",
        "s.notifications":        "Benachrichtigungen",
        "s.notificationsToggle":  "Gebetsbenachrichtigungen aktivieren",
        "s.notificationsDenied":  "Benachrichtigungen in Einstellungen → Benachrichtigungen erlauben",
        "s.prayers":              "Gebete",
        "s.minutesBefore":        "Minuten vor dem Gebet",
        "s.reminders":            "Erinnerungen",
        "s.10min":                "10-Minuten-Erinnerungen",
        "s.10minNote":            "Eine motivierende Nachricht oder Hadith 10 Minuten vor jedem Gebet.",
        "s.spiritual":            "Spirituelle Erinnerungen",
        "s.spiritualNote":        "Duha-Gebet, Nachtgebet (Mitternacht) und letztes Drittel der Nacht.",
        "s.30min":                "30-Minuten-Warnung",
        "s.30minLocked":          "Diese Warnung ist absichtlich immer aktiv — wenn das nächste Gebet naht, erinnern wir dich daran, das vorherige nicht zu verzögern. Das Ziel ist, dass dir keine Gebetszeit entgeht.",
        "s.general":              "Allgemein",
        "s.launchAtLogin":        "Bei Anmeldung starten",
        "s.launchAtLoginNote":    "Erfordert, dass sich die App im /Applications-Ordner befindet.",
        "s.restart":              "App neu starten",
        "s.restartNote":          "Updates anwenden oder Daten aktualisieren.",
        "s.quit":                 "Beenden",
        // Notification format
        "notif.in":        "in",
        "notif.min":       "Min",
        "notif.prayerAt":  "Gebet um",
        // Reminder panel
        "reminder.duha":          "Duha-Gebet",
        "reminder.polaNoci":      "Nachtgebet",
        "reminder.zadnjaTrecina": "Letztes Drittel der Nacht",
        "reminder.sub.10min":     "in 10 Minuten",
        "reminder.sub.duha":      "Duha-Gebet",
        "reminder.sub.night":     "Die Nachtzeit hat begonnen",
        "reminder.sub.lastThird": "Letztes Drittel der Nacht",
        "reminder.sub.expiring":  "läuft in 30 Minuten ab",
    ],
]
