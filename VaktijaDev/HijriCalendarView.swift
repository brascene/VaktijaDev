import SwiftUI

struct HijriCalendarView: View {
    var prayerViewModel: PrayerTimesViewModel
    @State private var calendarVM = HijriCalendarViewModel()

    private let dayNames = ["Po", "Ut", "Sr", "Če", "Pe", "Su", "Ne"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            if calendarVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if calendarVM.days.isEmpty {
                Text("Odaberi grad za prikaz kalendara")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                calendarGrid
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)

                Divider()

                selectedDayView
            }
        }
        .task {
            await calendarVM.fetchIfNeeded(cityId: prayerViewModel.selectedCity.cityId)
        }
        .onChange(of: prayerViewModel.selectedCity) {
            calendarVM.fetchedKey = nil
            Task { await calendarVM.fetch(cityId: prayerViewModel.selectedCity.cityId) }
        }
        .onChange(of: calendarVM.displayMonth) {
            Task { await calendarVM.fetch(cityId: prayerViewModel.selectedCity.cityId) }
        }
        .onChange(of: calendarVM.displayYear) {
            Task { await calendarVM.fetch(cityId: prayerViewModel.selectedCity.cityId) }
        }
    }

    private var header: some View {
        VStack(spacing: 2) {
            HStack {
                Button { calendarVM.previousMonth() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.borderless)

                Spacer()

                Text(calendarVM.monthYearLabel)
                    .font(.system(size: 13, weight: .semibold))

                Spacer()

                Button { calendarVM.nextMonth() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.borderless)
            }

            if let hijriMonth = calendarVM.hijriMonthLabel {
                Text(hijriMonth)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var calendarGrid: some View {
        VStack(spacing: 2) {
            // Day name headers
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(dayNames, id: \.self) { name in
                    Text(name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                }
            }

            // Day cells
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<calendarVM.startOffset, id: \.self) { _ in
                    Color.clear.frame(height: 36)
                }
                ForEach(calendarVM.days) { day in
                    dayCell(day)
                }
            }
        }
    }

    private func dayCell(_ day: VaktijaDayData) -> some View {
        let isToday = day.date == calendarVM.todayISO
        let isSelected = day.date == calendarVM.selectedDate
        let gregDay = day.date_formatted.prefix(2)
        let hijriDay = String(day.hijri.date.split(separator: "-").last ?? "")

        return Button {
            calendarVM.selectedDate = day.date
        } label: {
            VStack(spacing: 1) {
                Text(gregDay)
                    .font(.system(size: 12, weight: isToday ? .bold : .regular))
                Text(hijriDay)
                    .font(.system(size: 9))
                    .foregroundStyle(isToday || isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background {
                if isToday {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor)
                } else if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor.opacity(0.2))
                }
            }
            .foregroundStyle(isToday ? .white : .primary)
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    private var selectedDayView: some View {
        if let day = calendarVM.selectedDayData {
            VStack(spacing: 0) {
                HStack {
                    Text(day.day_name.capitalized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(day.hijri.formatted)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)

                let v = day.namaska_vremena
                let prayers: [(String, String)] = [
                    ("Zora", v.zora),
                    ("Izlazak", v.izlazak),
                    ("Podne", v.podne),
                    ("Ikindija", v.ikindija),
                    ("Akšam", v.aksam),
                    ("Jacija", v.jacija),
                ]
                ForEach(prayers, id: \.0) { name, time in
                    HStack {
                        Text(name).foregroundStyle(name == "Izlazak" ? .secondary : .primary)
                        Spacer()
                        Text(time).monospacedDigit().foregroundStyle(name == "Izlazak" ? .secondary : .primary)
                    }
                    .font(.system(size: 12))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }
            .padding(.bottom, 8)
        }
    }
}
