import SwiftUI

struct CityPickerView: View {
    @Binding var selectedCity: City
    let onDismiss: () -> Void
    @Environment(\.appLanguage) private var lang

    @State private var selectedCountry = "Bosna i Hercegovina"
    @State private var cities: [City] = CityList.bih
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            Picker(loc("city.country", lang), selection: $selectedCountry) {
                ForEach(CountryList.all, id: \.self) { country in
                    Text(country).tag(country)
                }
            }
            .labelsHidden()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(cities) { city in
                            cityRow(city)
                            if city.id != cities.last?.id {
                                Divider().padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .frame(height: 260)
            }
        }
        .onChange(of: selectedCountry) {
            Task { await loadCities(for: selectedCountry) }
        }
    }

    private var header: some View {
        HStack {
            Button {
                onDismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                    Text(loc("city.back", lang))
                        .font(.system(size: 13))
                }
            }
            .buttonStyle(.borderless)
            Spacer()
            Text(loc("city.title", lang))
                .font(.system(size: 13, weight: .medium))
            Spacer()
        }
    }

    private func cityRow(_ city: City) -> some View {
        let isSelected = city.id == selectedCity.id
        return Button {
            selectedCity = city
            onDismiss()
        } label: {
            HStack {
                Text(city.name)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.accentColor : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .font(.system(size: 13))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
    }

    private func loadCities(for country: String) async {
        isLoading = true
        cities = []

        guard let firstResult = await fetchPage(country: country, page: 1) else {
            isLoading = false
            return
        }

        var allCities = firstResult.cities

        if firstResult.lastPage > 1 {
            await withTaskGroup(of: [City].self) { group in
                for page in 2...firstResult.lastPage {
                    group.addTask { await self.fetchPage(country: country, page: page)?.cities ?? [] }
                }
                for await batch in group {
                    allCities += batch
                }
            }
        }

        cities = allCities.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        isLoading = false
    }

    private func fetchPage(country: String, page: Int) async -> (cities: [City], lastPage: Int)? {
        var components = URLComponents(string: Config.vaktijaLocationsURL)!
        components.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "page", value: String(page)),
        ]
        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(VaktijaLocationsResponse.self, from: data)
            let mapped = response.data.data.compactMap { loc -> City? in
                guard let lat = Double(loc.latitude), let lon = Double(loc.longitude) else { return nil }
                return City(name: loc.name, countryName: country, latitude: lat, longitude: lon, cityId: loc.id)
            }
            return (mapped, response.data.last_page)
        } catch {
            return nil
        }
    }
}
