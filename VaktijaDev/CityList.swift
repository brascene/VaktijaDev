import Foundation

struct City: Identifiable, Hashable {
    let name: String
    let countryName: String
    let latitude: Double
    let longitude: Double
    let cityId: Int?
    var id: String { cityId.map(String.init) ?? "\(name)-\(countryName)" }
}

enum CityList {
    // Default BiH cities shown before user picks from API
    static let defaultCity = City(name: "Konjic", countryName: "Bosna i Hercegovina", latitude: 43.6511, longitude: 17.9611, cityId: 52)

    static let bih: [City] = [
        City(name: "Konjic",     countryName: "Bosna i Hercegovina", latitude: 43.6511, longitude: 17.9611, cityId: 52),
        City(name: "Sarajevo",   countryName: "Bosna i Hercegovina", latitude: 43.8563, longitude: 18.4131, cityId: 1),
        City(name: "Mostar",     countryName: "Bosna i Hercegovina", latitude: 43.3438, longitude: 17.8078, cityId: 65),
        City(name: "Zenica",     countryName: "Bosna i Hercegovina", latitude: 44.2014, longitude: 17.9078, cityId: 107),
        City(name: "Tuzla",      countryName: "Bosna i Hercegovina", latitude: 44.5386, longitude: 18.6733, cityId: 97),
        City(name: "Banja Luka", countryName: "Bosna i Hercegovina", latitude: 44.7722, longitude: 17.1910, cityId: 8),
        City(name: "Bihać",      countryName: "Bosna i Hercegovina", latitude: 44.8120, longitude: 15.8686, cityId: 14),
        City(name: "Travnik",    countryName: "Bosna i Hercegovina", latitude: 44.2247, longitude: 17.6613, cityId: 95),
        City(name: "Goražde",    countryName: "Bosna i Hercegovina", latitude: 43.6686, longitude: 18.9778, cityId: 39),
        City(name: "Livno",      countryName: "Bosna i Hercegovina", latitude: 43.8211, longitude: 17.0072, cityId: 57),
        City(name: "Cazin",      countryName: "Bosna i Hercegovina", latitude: 44.9690, longitude: 15.9432, cityId: 27),
        City(name: "Visoko",     countryName: "Bosna i Hercegovina", latitude: 44.0025, longitude: 18.1781, cityId: 103),
        City(name: "Prijedor",   countryName: "Bosna i Hercegovina", latitude: 44.9797, longitude: 16.7142, cityId: 80),
        City(name: "Bijeljina",  countryName: "Bosna i Hercegovina", latitude: 44.7574, longitude: 19.2178, cityId: 15),
        City(name: "Jablanica",  countryName: "Bosna i Hercegovina", latitude: 43.6561, longitude: 17.7592, cityId: 45),
        City(name: "Bugojno",    countryName: "Bosna i Hercegovina", latitude: 44.0562, longitude: 17.4498, cityId: 24),
    ]
}

enum CountryList {
    static let all: [String] = [
        "Bosna i Hercegovina",
        "Albanija",
        "Austrija",
        "Belgija",
        "Crna Gora",
        "Češka",
        "Finska",
        "Francuska",
        "Hrvatska",
        "Japan",
        "Kipar",
        "Kosovo",
        "Luksemburg",
        "Norveška",
        "Njemačka",
        "Rumunija",
        "Saudijska Arabija",
        "Sjeverna Makedonija",
        "Slovenija",
        "Srbija",
        "Švicarska",
        "Švedska",
        "Turska",
        "Ujedinjeni Arapski Emirati",
        "Velika Britanija",
    ]
}
