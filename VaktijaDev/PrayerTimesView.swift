import SwiftUI

struct PrayerTimesView: View {
    @Bindable var viewModel: PrayerTimesViewModel
    @State private var showingCityPicker = false
    @Environment(\.appLanguage) private var lang

    private func prayerName(_ key: String) -> String {
        loc("prayer.\(key)", lang)
    }

    var body: some View {
        Group {
            if showingCityPicker {
                CityPickerView(selectedCity: $viewModel.selectedCity) { didSelect in
                    showingCityPicker = false
                    guard didSelect else { return }
                    if viewModel.useLocation {
                        viewModel.useLocation = false
                    } else {
                        Task { await viewModel.fetchPrayerTimes() }
                    }
                }
            } else {
                mainView
            }
        }
        .frame(width: 300)
        .task {
            await viewModel.fetchIfNeeded()
        }
        .onChange(of: viewModel.useLocation) {
            viewModel.timings = nil
            viewModel.errorMessage = nil
            Task { await viewModel.fetchPrayerTimes() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            if viewModel.useLocation && viewModel.errorMessage != nil {
                Task { await viewModel.fetchPrayerTimes() }
            }
        }
    }

    private var mainView: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider()

            if let error = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Text(error)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        if viewModel.locationManager.permissionDenied {
                            Button(loc("btn.openSettings", lang)) {
                                viewModel.locationManager.openLocationSettings()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        Button(loc("btn.tryAgain", lang)) {
                            viewModel.errorMessage = nil
                            Task { await viewModel.fetchPrayerTimes() }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(viewModel.isLoading)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else if let timings = viewModel.timings {
                prayerList(timings)
            }

            Divider()

            footer
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                Button {
                    showingCityPicker = true
                } label: {
                    HStack(spacing: 4) {
                        if viewModel.useLocation {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Text(viewModel.locationManager.locationName ?? loc("location.mine", lang))
                                .font(.system(size: 13, weight: .medium))
                        } else {
                            Text(viewModel.selectedCity.name)
                                .font(.system(size: 13, weight: .medium))
                        }
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    viewModel.useLocation.toggle()
                } label: {
                    Image(systemName: viewModel.useLocation ? "location.fill" : "location")
                        .font(.system(size: 12))
                        .foregroundStyle(viewModel.useLocation ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.borderless)
                .help(viewModel.useLocation ? loc("location.useCity", lang) : loc("location.useMine", lang))

                Button {
                    Task { await viewModel.fetchPrayerTimes() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderless)
                .disabled(viewModel.isLoading)
            }

            if let dateInfo = viewModel.dateInfo {
                HStack {
                    Text(dateInfo.readable)
                    Spacer()
                    Text("\(HijriMonths.localized(dateInfo.hijriMonth, lang: lang)) \(dateInfo.hijriYear)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func prayerList(_ timings: PrayerTimings) -> some View {
        VStack(spacing: 0) {
            prayerRow("fajr",    time: timings.fajr)
            Divider().padding(.horizontal, 16)
            prayerRow("sunrise", time: timings.sunrise, isSecondary: true)
            Divider().padding(.horizontal, 16)
            prayerRow("dhuhr",   time: timings.dhuhr)
            Divider().padding(.horizontal, 16)
            prayerRow("asr",     time: timings.asr)
            Divider().padding(.horizontal, 16)
            prayerRow("maghrib", time: timings.maghrib)
            Divider().padding(.horizontal, 16)
            prayerRow("isha",    time: timings.isha)

            if timings.polaNoci != nil || timings.zadnjaTrecina != nil {
                Divider()
                nocnaVremena(timings)
            }
        }
    }

    private func nocnaVremena(_ timings: PrayerTimings) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(loc("night.section", lang))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 2)

            if let polaNoci = timings.polaNoci {
                nocnaRow(loc("night.midnight", lang), time: polaNoci)
            }
            if let zadnjaTrecina = timings.zadnjaTrecina {
                nocnaRow(loc("night.lastThird", lang), time: zadnjaTrecina)
            }
        }
    }

    private func nocnaRow(_ label: String, time: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(time)
                .monospacedDigit()
        }
        .foregroundStyle(.secondary)
        .font(.system(size: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    private func prayerRow(_ key: String, time: String, isSecondary: Bool = false) -> some View {
        let cleanTime = time.components(separatedBy: " ").first ?? time
        let isNext = viewModel.nextPrayer == key
        let displayName = prayerName(key)

        return HStack {
            HStack(spacing: 6) {
                if isNext {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                }
                Text(displayName)
                    .fontWeight(isNext ? .semibold : .regular)
                if isNext, let countdown = viewModel.timeUntilNextPrayer {
                    Text(countdown)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            Spacer()
            Text(cleanTime)
                .monospacedDigit()
                .fontWeight(isNext ? .semibold : .regular)
        }
        .foregroundStyle(isSecondary ? .secondary : .primary)
        .font(.system(size: 13))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isNext ? Color.accentColor.opacity(0.08) : Color.clear)
    }

    private var footer: some View {
        HStack {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            }
            Spacer()
            Button(loc("btn.close", lang)) {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PrayerTimesView(viewModel: PrayerTimesViewModel())
}
