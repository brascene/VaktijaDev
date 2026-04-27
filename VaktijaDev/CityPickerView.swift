import SwiftUI
import MapKit

// MARK: - MKLocalSearchCompleter wrapper

@Observable
final class CitySearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    var results: [MKLocalSearchCompletion] = []
    var isSearching: Bool = false

    @ObservationIgnored private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = .address
        completer.delegate = self
    }

    func update(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            results = []
            isSearching = false
            completer.queryFragment = ""
            return
        }
        isSearching = true
        completer.queryFragment = trimmed
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        isSearching = false
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
        isSearching = false
    }
}

// MARK: - CityPickerView

struct CityPickerView: View {
    @Binding var selectedCity: City
    let onDismiss: (_ didSelect: Bool) -> Void
    @Environment(\.appLanguage) private var lang

    @State private var searchText = ""
    @State private var completer = CitySearchCompleter()
    @State private var isResolving = false

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            searchField
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    if searchText.isEmpty {
                        sectionHeader("Bosna i Hercegovina")
                        ForEach(CityList.bih) { city in
                            cityRow(city)
                            if city.id != CityList.bih.last?.id {
                                Divider().padding(.horizontal, 16)
                            }
                        }
                    } else if completer.isSearching && completer.results.isEmpty {
                        ProgressView()
                            .controlSize(.small)
                            .frame(maxWidth: .infinity, minHeight: 80)
                    } else if completer.results.isEmpty {
                        Text(String(format: loc("search.noResults", lang), searchText))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, minHeight: 80)
                    } else {
                        ForEach(Array(completer.results.enumerated()), id: \.offset) { idx, result in
                            completionRow(result)
                            if idx < completer.results.count - 1 {
                                Divider().padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
            .frame(height: 260)
            .overlay {
                if isResolving {
                    ZStack {
                        Color.black.opacity(0.15)
                        ProgressView().controlSize(.small)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                onDismiss(false)
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

    // MARK: - Search field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            TextField(loc("search.placeholder", lang), text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .onChange(of: searchText) {
                    completer.update(query: searchText)
                }
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    completer.update(query: "")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Rows

    private func cityRow(_ city: City) -> some View {
        let isSelected = city.id == selectedCity.id
        return Button {
            selectedCity = city
            onDismiss(true)
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

    private func completionRow(_ completion: MKLocalSearchCompletion) -> some View {
        Button {
            Task { await resolveAndSelect(completion) }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(completion.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if !completion.subtitle.isEmpty {
                        Text(completion.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.tertiary)
            .kerning(0.6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    // MARK: - Actions

    private func resolveAndSelect(_ completion: MKLocalSearchCompletion) async {
        isResolving = true
        defer { isResolving = false }

        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        guard let response = try? await search.start(),
              let item = response.mapItems.first else { return }

        let coord = item.placemark.coordinate
        let name = item.placemark.locality
                ?? item.placemark.subAdministrativeArea
                ?? item.placemark.name
                ?? completion.title
        let country = item.placemark.country ?? ""

        let city = City(
            name: name,
            countryName: country,
            latitude: coord.latitude,
            longitude: coord.longitude,
            cityId: nil
        )
        selectedCity = city
        onDismiss(true)
    }
}
