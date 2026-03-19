import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var prayerVM = PrayerTimesViewModel()

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            tabContent
        }
    }

    private var sidebar: some View {
        VStack(spacing: 4) {
            tabButton(icon: "moon.stars.fill", tab: 0)
            tabButton(icon: "calendar",        tab: 1)
            tabButton(icon: "gearshape",       tab: 2)
        }
        .frame(width: 44)
        .frame(maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.4))
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 1:  HijriCalendarView(prayerViewModel: prayerVM)
        case 2:  SettingsView()
        default: PrayerTimesView(viewModel: prayerVM)
        }
    }

    private func tabButton(icon: String, tab: Int) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}
