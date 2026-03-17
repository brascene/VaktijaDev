import Foundation

struct City: Identifiable, Hashable {
    let name: String
    let country: String
    var id: String { "\(name)-\(country)" }
}

enum CityList {
    static let all: [City] = [
        City(name: "Konjic", country: "Bosnia and Herzegovina"),
        City(name: "Sarajevo", country: "Bosnia and Herzegovina"),
        City(name: "Mostar", country: "Bosnia and Herzegovina"),
        City(name: "Zenica", country: "Bosnia and Herzegovina"),
        City(name: "Tuzla", country: "Bosnia and Herzegovina"),
        City(name: "Banja Luka", country: "Bosnia and Herzegovina"),
        City(name: "Bihac", country: "Bosnia and Herzegovina"),
        City(name: "Travnik", country: "Bosnia and Herzegovina"),
        City(name: "Gorazde", country: "Bosnia and Herzegovina"),
        City(name: "Livno", country: "Bosnia and Herzegovina"),
        City(name: "Cazin", country: "Bosnia and Herzegovina"),
        City(name: "Visoko", country: "Bosnia and Herzegovina"),
        City(name: "Prijedor", country: "Bosnia and Herzegovina"),
        City(name: "Bijeljina", country: "Bosnia and Herzegovina"),
        City(name: "Jablanica", country: "Bosnia and Herzegovina"),
        City(name: "Bugojno", country: "Bosnia and Herzegovina"),
    ]
}
