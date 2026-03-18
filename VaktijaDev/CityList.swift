import Foundation

struct City: Identifiable, Hashable {
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    var id: String { "\(name)-\(country)" }
}

enum CityList {
    static let all: [City] = [
        City(name: "Konjic",     country: "Bosnia and Herzegovina", latitude: 43.6511, longitude: 17.9611),
        City(name: "Sarajevo",   country: "Bosnia and Herzegovina", latitude: 43.8563, longitude: 18.4131),
        City(name: "Mostar",     country: "Bosnia and Herzegovina", latitude: 43.3438, longitude: 17.8078),
        City(name: "Zenica",     country: "Bosnia and Herzegovina", latitude: 44.2014, longitude: 17.9078),
        City(name: "Tuzla",      country: "Bosnia and Herzegovina", latitude: 44.5386, longitude: 18.6733),
        City(name: "Banja Luka", country: "Bosnia and Herzegovina", latitude: 44.7722, longitude: 17.1910),
        City(name: "Bihać",      country: "Bosnia and Herzegovina", latitude: 44.8120, longitude: 15.8686),
        City(name: "Travnik",    country: "Bosnia and Herzegovina", latitude: 44.2247, longitude: 17.6613),
        City(name: "Goražde",    country: "Bosnia and Herzegovina", latitude: 43.6686, longitude: 18.9778),
        City(name: "Livno",      country: "Bosnia and Herzegovina", latitude: 43.8211, longitude: 17.0072),
        City(name: "Cazin",      country: "Bosnia and Herzegovina", latitude: 44.9690, longitude: 15.9432),
        City(name: "Visoko",     country: "Bosnia and Herzegovina", latitude: 44.0025, longitude: 18.1781),
        City(name: "Prijedor",   country: "Bosnia and Herzegovina", latitude: 44.9797, longitude: 16.7142),
        City(name: "Bijeljina",  country: "Bosnia and Herzegovina", latitude: 44.7574, longitude: 19.2178),
        City(name: "Jablanica",  country: "Bosnia and Herzegovina", latitude: 43.6561, longitude: 17.7592),
        City(name: "Bugojno",    country: "Bosnia and Herzegovina", latitude: 44.0562, longitude: 17.4498),
    ]
}
