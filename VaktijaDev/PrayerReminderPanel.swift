import AppKit
import SwiftUI

// MARK: - Notification name

extension Notification.Name {
    static let prayerReminderDue = Notification.Name("com.nodi.VaktijaDev.prayerReminderDue")
}

// MARK: - Message model

struct ReminderMessage {
    let body: String
    let source: String?
}

// MARK: - Messages pool

enum ReminderMessages {

    private static let fajr: [ReminderMessage] = [
        ReminderMessage(
            body: "Ko klanja sabah u džematu, kao da je klanjao cijelu noć.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Dva rekata sabaha vrjednija su od ovog dunjaluka i svega što je na njemu.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Ko klanja sabah namaz, pod je Allahovom zaštitom cijeli dan. Nemoj taj dug uskratiti sebi.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Počni jutro namazom prije nego što dan preuzme kontrolu nad tobom.",
            source: nil
        ),
        ReminderMessage(
            body: "Uzmi abdest – hladna voda ujutro čisti i tijelo i um. Sabah ti čeka.",
            source: nil
        ),
    ]

    private static let dhuhr: [ReminderMessage] = [
        ReminderMessage(
            body: "Najavi kolegama kratku molitvenu pauzu – namaz ne traje duže od 5 minuta.",
            source: nil
        ),
        ReminderMessage(
            body: "Allahov Poslanik ﷺ je klanjao podne odmah po prelasku sunca zenita. Slijedi njegov sunnet.",
            source: nil
        ),
        ReminderMessage(
            body: "Usred napornog dana, namaz je reset – par minuta tišine za dušu i tijelo.",
            source: nil
        ),
        ReminderMessage(
            body: "Zakon ti garantira pravo na kratku pauzu. Iskoristi je za podne.",
            source: nil
        ),
        ReminderMessage(
            body: "Ko bude čuvao pet dnevnih namaza, oni će mu biti svjetlo, dokaz i spas na Sudnjem danu.",
            source: "Ahmed"
        ),
    ]

    private static let asr: [ReminderMessage] = [
        ReminderMessage(
            body: "Čuvajte namaze, a posebno srednji namaz – ikindiju.",
            source: "Kur'an, 2:238"
        ),
        ReminderMessage(
            body: "Ko propusti ikindiju, kao da mu je porodica i imetak upropašteni.",
            source: "Buhari"
        ),
        ReminderMessage(
            body: "Ikindija je namaz koji mnogi propuste zbog gužve poslijepodne. Nemoj biti od njih.",
            source: nil
        ),
        ReminderMessage(
            body: "Meleci noći i meleci dana izmjenjuju se na ikindiji. Neka te zateče u namazu.",
            source: "Buhari, Muslim"
        ),
        ReminderMessage(
            body: "Posao može pričekati 5 minuta – ikindija ne može.",
            source: nil
        ),
    ]

    private static let maghrib: [ReminderMessage] = [
        ReminderMessage(
            body: "Akšam je jedan od najkraćih namaza – zatvori laptop na par minuta, vrijedi.",
            source: nil
        ),
        ReminderMessage(
            body: "Ko klanja akšam i jaciju u džematu, kao da je stajao u ibadetu cijelu noć.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Kraj radnog dana. Nagradi sebe sa par minuta posvećenih Allahu.",
            source: nil
        ),
        ReminderMessage(
            body: "Požuri – akšamsko vrijeme je kratko. Uzmi abdest i kreni.",
            source: nil
        ),
        ReminderMessage(
            body: "Sunce zalazi i otvara se vrata ibadeta. Dočekaj ih namazom.",
            source: nil
        ),
    ]

    private static let isha: [ReminderMessage] = [
        ReminderMessage(
            body: "Ko klanja jaciju u džematu, kao da je klanjao pola noći.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Ko klanja jaciju i sabah u džematu, Allah mu upiše nagradu kao da je klanjao cijelu noć.",
            source: "Buhari, Muslim"
        ),
        ReminderMessage(
            body: "Završi dan namazom i kratkom dovom – to je najljepši kraj svakog dana.",
            source: nil
        ),
        ReminderMessage(
            body: "Klanjaj jaciju u džematu, pa lezi sa nijom za sabah. Obje noći su pokrivene.",
            source: nil
        ),
        ReminderMessage(
            body: "Allahov Poslanik ﷺ nije spavao prije jacije niti razgovarao poslije nje. Jača se kad je klanjao.",
            source: "Buhari"
        ),
    ]

    private static let duha: [ReminderMessage] = [
        ReminderMessage(
            body: "Ko klanja duha namaz, pripisat će mu se nagrada kao da je dao sadaku za svaki zglavak tijela.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Allahov Poslanik ﷺ je klanjao duha 4 do 8 rekata. Počni sa dva – Allah prima i najmanje.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Duha namaz je namaz pokajanja i zahvalnosti. Klanjaj ga dok si još svjež i napolju je jasno.",
            source: nil
        ),
        ReminderMessage(
            body: "Ko klanja duha redovito, svi njegovi grijesi mu se opraste, makar bili kao morska pjena.",
            source: "Tirmizi"
        ),
        ReminderMessage(
            body: "Ovo je duha doba – ptice slave Allaha, a ti možeš im se pridružiti sa dva rekata.",
            source: nil
        ),
    ]

    private static let polaNoci: [ReminderMessage] = [
        ReminderMessage(
            body: "Probudi se i klanjaj bar dva rekata noćnog namaza. Allah voli one koji ustaju kada drugi spavaju.",
            source: nil
        ),
        ReminderMessage(
            body: "Allahov Poslanik ﷺ je ustajao noću da klanja dok mu se noge ne bi otekle. Upitan zašto, odgovorio je: 'Zar ne bih bio zahvalan rob?'",
            source: "Buhari, Muslim"
        ),
        ReminderMessage(
            body: "Kijamu-l-lejl – noćni namaz je dobrovoljni ibadet koji uzdiže stepene i briše grijehe.",
            source: nil
        ),
        ReminderMessage(
            body: "Ko ustane noću i probudi svoju porodicu da klanja, Allah im upiše nagradu kao onima koji stalno Allaha spominju.",
            source: "Ebu Davud"
        ),
        ReminderMessage(
            body: "Noćni namaz je počast vjerniku. Ustaj, abdest uzmi i klanjaj koliko možeš.",
            source: nil
        ),
    ]

    private static let zadnjaTrecina: [ReminderMessage] = [
        ReminderMessage(
            body: "Allah pita u zadnjoj trećini noći: 'Ko Me zove da Mu se odazovem? Ko traži da mu dam? Ko traži oprost da mu oprostim?'",
            source: "Buhari, Muslim"
        ),
        ReminderMessage(
            body: "Klanjaj noćni namaz, pa vitr, pa čini istigfar do zore. Ovo je najvrjednije doba noći za dovu.",
            source: nil
        ),
        ReminderMessage(
            body: "Istigfar u zadnjoj trećini noći: 'Estağfirullah' – učini ga 70 ili 100 puta do zore.",
            source: nil
        ),
        ReminderMessage(
            body: "Oni koji traže oprost u jutarnjim satima – Allah ih hvali u Kur'anu.",
            source: "Kur'an, 3:17"
        ),
        ReminderMessage(
            body: "Vitr namaz je hak – ko ga nije klanjao, neka ga klanja sad. Zatvori noć sa vitrom.",
            source: "Ebu Davud"
        ),
    ]

    private static let general: [ReminderMessage] = [
        ReminderMessage(
            body: "Namaz u džematu je 27 puta bolji od namaza samog.",
            source: "Buhari, Muslim"
        ),
        ReminderMessage(
            body: "Pet dnevnih namaza su poput rijeke koja teče pored tvoje kuće – ko se u njoj okupa pet puta dnevno, neće imati prljavštine na sebi.",
            source: "Muslim"
        ),
        ReminderMessage(
            body: "Uzmi abdest na miru – ne ostavljaj to za zadnji tren. Sunnet je biti uvijek čist.",
            source: nil
        ),
        ReminderMessage(
            body: "Provjeri kiblu, uzmi tesbih i pripremi se polako – namaz zaslužuje tvoju punu pažnju.",
            source: nil
        ),
        ReminderMessage(
            body: "Najbitnija stvar za kojom će te Allah pitati na Sudnjem danu jeste namaz.",
            source: "Tirmizi"
        ),
    ]

    static func expiring(prev: String, next: String) -> ReminderMessage {
        let templates: [(String, String?)] = [
            ("Za 30 minuta stiže \(next), a \(prev) još nije klanjan. Iskoristi ovo vrijeme – abdest, kibla, namaz.", nil),
            ("Bliži se \(next), a \(prev) još čeka. Ne ulazi u novi namaz sa dugom od prethodnog.", nil),
            ("Namaz u svom vremenu je najdraže djelo Allahu. Za 30 minuta \(prev) ističe – požuri.", "Buhari"),
            ("Za 30 minuta \(next) kuca na vrata, a \(prev) još nije klanjan. Ustaj odmah.", nil),
            ("Još 30 minuta pa \(prev) zatvara svoja vrata. Klanjaj ga dok možeš.", nil),
        ]
        let (body, source) = templates.randomElement()!
        return ReminderMessage(body: body, source: source)
    }

    static func random(for prayer: String) -> ReminderMessage {
        let pool: [ReminderMessage]
        switch prayer {
        case "fajr":          pool = fajr + general
        case "dhuhr":         pool = dhuhr + general
        case "asr":           pool = asr + general
        case "maghrib":       pool = maghrib + general
        case "isha":          pool = isha + general
        case "duha":          pool = duha
        case "polaNoci":      pool = polaNoci
        case "zadnjaTrecina": pool = zadnjaTrecina
        default:              pool = general
        }
        return pool.randomElement() ?? general[0]
    }
}

// MARK: - SwiftUI content view

private struct PrayerReminderContent: View {
    let prayerDisplayName: String
    let subtitle: String
    let message: ReminderMessage
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Color.accentColor)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 1) {
                    Text(prayerDisplayName)
                        .font(.system(size: 14, weight: .semibold))
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(.tertiary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .help("Zatvori")
            }

            Divider()

            Text(message.body)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

            if let source = message.source {
                HStack {
                    Spacer()
                    Text("— \(source)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
        }
        .padding(14)
        .frame(width: 300)
    }
}

// MARK: - NSPanel

final class PrayerReminderPanel: NSPanel {
    private static var current: PrayerReminderPanel?
    private var dismissTimer: Timer?

    static func show(prayer: String, subtitle: String, message: ReminderMessage? = nil, buttonFrame: NSRect, screen: NSScreen) {
        DispatchQueue.main.async {
            Self.current?.forceClose()

            let prayerNames: [String: String] = [
                "fajr": "Zora",
                "dhuhr": "Podne",
                "asr": "Ikindija",
                "maghrib": "Akšam",
                "isha": "Jacija",
                "duha": "Duha namaz",
                "polaNoci": "Noćni namaz",
                "zadnjaTrecina": "Zadnja trećina noći",
            ]
            let displayName = prayerNames[prayer] ?? prayer.capitalized
            let resolvedMessage = message ?? ReminderMessages.random(for: prayer)

            let panel = PrayerReminderPanel(prayer: displayName, subtitle: subtitle, message: resolvedMessage)
            panel.position(below: buttonFrame, screen: screen)
            panel.animateIn()
            NSSound(named: NSSound.Name("Ping"))?.play()
            Self.current = panel
        }
    }

    private init(prayer: String, subtitle: String, message: ReminderMessage) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 160),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = .statusBar
        hasShadow = true
        isMovableByWindowBackground = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let content = PrayerReminderContent(
            prayerDisplayName: prayer,
            subtitle: subtitle,
            message: message,
            onDismiss: { [weak self] in self?.animateOut() }
        )

        let hostingView = NSHostingView(rootView:
            content
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )

        // Compute height from SwiftUI layout
        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 500)
        hostingView.layoutSubtreeIfNeeded()
        let height = max(hostingView.fittingSize.height, 120)

        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: height)
        setFrame(NSRect(x: 0, y: 0, width: 300, height: height), display: false)
        contentView = hostingView

        dismissTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            self?.animateOut()
        }
    }

    private func position(below buttonFrame: NSRect, screen: NSScreen) {
        let panelW = frame.width
        let panelH = frame.height
        let screenFrame = screen.frame

        var x = buttonFrame.midX - panelW / 2
        x = max(screenFrame.minX + 8, min(x, screenFrame.maxX - panelW - 8))
        let y = buttonFrame.minY - panelH - 6

        setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func animateIn() {
        let finalOrigin = frame.origin
        setFrameOrigin(NSPoint(x: frame.minX, y: frame.minY + 12))
        alphaValue = 0
        orderFront(nil)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1
            self.animator().setFrameOrigin(finalOrigin)
        }
    }

    private func animateOut() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        let targetOrigin = NSPoint(x: frame.minX, y: frame.minY + 10)
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            self.animator().alphaValue = 0
            self.animator().setFrameOrigin(targetOrigin)
        }, completionHandler: { [weak self] in
            self?.close()
            if Self.current === self { Self.current = nil }
        })
    }

    func forceClose() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        close()
        if Self.current === self { Self.current = nil }
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
