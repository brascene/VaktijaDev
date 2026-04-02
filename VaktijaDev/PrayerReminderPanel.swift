import AppKit
import SwiftUI

// MARK: - Notification name

extension Notification.Name {
    static let prayerReminderDue = Notification.Name("com.nodi.VaktijaDev.prayerReminderDue")
}

// MARK: - Message model

struct ReminderMessage {
    let bodies: [String: String]
    let source: String?

    init(_ bodies: [String: String], source: String? = nil) {
        self.bodies = bodies
        self.source = source
    }

    func localizedBody() -> String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "bs"
        return bodies[lang] ?? bodies["en"] ?? bodies["bs"] ?? ""
    }
}

// MARK: - Messages pool

enum ReminderMessages {

    private static let fajr: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Ko klanja sabah u džematu, kao da je klanjao cijelu noć.",
            "en": "Whoever prays Fajr in congregation is as if he prayed all night.",
            "de": "Wer das Fajr-Gebet in der Gemeinschaft verrichtet, ist so, als hätte er die ganze Nacht gebetet.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Dva rekata sabaha vrjednija su od ovog dunjaluka i svega što je na njemu.",
            "en": "Two rak'ahs of Fajr are better than this world and everything in it.",
            "de": "Zwei Rak'ahs des Fajr-Gebets sind wertvoller als diese Welt und alles, was auf ihr ist.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Ko klanja sabah namaz, pod je Allahovom zaštitom cijeli dan. Nemoj taj dug uskratiti sebi.",
            "en": "Whoever prays Fajr is under Allah's protection for the entire day. Don't deprive yourself of that.",
            "de": "Wer das Fajr-Gebet verrichtet, steht den ganzen Tag unter dem Schutz Allahs. Verweigere dir diesen Schutz nicht.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Počni jutro namazom prije nego što dan preuzme kontrolu nad tobom.",
            "en": "Start your morning with prayer before the day takes control of you.",
            "de": "Beginne deinen Morgen mit dem Gebet, bevor der Tag die Kontrolle über dich übernimmt.",
        ]),
        ReminderMessage([
            "bs": "Uzmi abdest – hladna voda ujutro čisti i tijelo i um. Sabah ti čeka.",
            "en": "Make wudu – cool water in the morning cleanses both body and mind. Fajr awaits.",
            "de": "Vollziehe Wudu – kühles Wasser am Morgen reinigt Körper und Geist. Das Fajr-Gebet wartet auf dich.",
        ]),
    ]

    private static let dhuhr: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Najavi kolegama kratku molitvenu pauzu – namaz ne traje duže od 5 minuta.",
            "en": "Let your colleagues know you're taking a brief prayer break – it takes less than 5 minutes.",
            "de": "Kündige deinen Kollegen eine kurze Gebetspause an – das Gebet dauert nicht länger als 5 Minuten.",
        ]),
        ReminderMessage([
            "bs": "Allahov Poslanik ﷺ je klanjao podne odmah po prelasku sunca zenita. Slijedi njegov sunnet.",
            "en": "The Prophet ﷺ prayed Dhuhr immediately when the sun passed its zenith. Follow his sunnah.",
            "de": "Der Gesandte Allahs ﷺ betete Dhuhr unmittelbar nachdem die Sonne ihren Zenit überschritten hatte. Folge seiner Sunnah.",
        ]),
        ReminderMessage([
            "bs": "Usred napornog dana, namaz je reset – par minuta tišine za dušu i tijelo.",
            "en": "In the middle of a busy day, prayer is a reset – a few minutes of silence for the soul and body.",
            "de": "Mitten in einem anstrengenden Tag ist das Gebet ein Reset – ein paar Minuten Stille für Seele und Körper.",
        ]),
        ReminderMessage([
            "bs": "Zakon ti garantira pravo na kratku pauzu. Iskoristi je za podne.",
            "en": "You have a legal right to a short break. Use it for Dhuhr.",
            "de": "Das Gesetz garantiert dir das Recht auf eine kurze Pause. Nutze sie für das Dhuhr-Gebet.",
        ]),
        ReminderMessage([
            "bs": "Ko bude čuvao pet dnevnih namaza, oni će mu biti svjetlo, dokaz i spas na Sudnjem danu.",
            "en": "Whoever guards the five daily prayers, they will be for him a light, a proof and salvation on the Day of Judgment.",
            "de": "Wer die fünf täglichen Gebete einhält, für den werden sie am Tag des Jüngsten Gerichts Licht, Beweis und Rettung sein.",
        ], source: "Ahmed"),
    ]

    private static let asr: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Čuvajte namaze, a posebno srednji namaz – ikindiju.",
            "en": "Guard strictly the prayers, especially the middle prayer – Asr.",
            "de": "Haltet die Gebete ein, besonders das mittlere Gebet – Asr.",
        ], source: "Kur'an, 2:238"),
        ReminderMessage([
            "bs": "Ko propusti ikindiju, kao da mu je porodica i imetak upropašteni.",
            "en": "Whoever misses Asr is as if he has lost his family and wealth.",
            "de": "Wer das Asr-Gebet versäumt, ist so, als ob seine Familie und sein Besitz zugrunde gegangen wären.",
        ], source: "Buhari"),
        ReminderMessage([
            "bs": "Ikindija je namaz koji mnogi propuste zbog gužve poslijepodne. Nemoj biti od njih.",
            "en": "Asr is the prayer many miss due to afternoon busyness. Don't be among them.",
            "de": "Asr ist das Gebet, das viele wegen des nachmittäglichen Trubels versäumen. Sei nicht einer von ihnen.",
        ]),
        ReminderMessage([
            "bs": "Meleci noći i meleci dana izmjenjuju se na ikindiji. Neka te zateče u namazu.",
            "en": "The angels of night and day alternate at Asr. Let them find you in prayer.",
            "de": "Die Engel der Nacht und die Engel des Tages wechseln sich beim Asr-Gebet ab. Lass sie dich im Gebet vorfinden.",
        ], source: "Buhari, Muslim"),
        ReminderMessage([
            "bs": "Posao može pričekati 5 minuta – ikindija ne može.",
            "en": "Work can wait 5 minutes – Asr cannot.",
            "de": "Die Arbeit kann 5 Minuten warten – das Asr-Gebet nicht.",
        ]),
    ]

    private static let maghrib: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Akšam je jedan od najkraćih namaza – zatvori laptop na par minuta, vrijedi.",
            "en": "Maghrib is one of the shortest prayers – close your laptop for a few minutes, it's worth it.",
            "de": "Maghrib ist eines der kürzesten Gebete – klappe den Laptop für ein paar Minuten zu, es lohnt sich.",
        ]),
        ReminderMessage([
            "bs": "Ko klanja akšam i jaciju u džematu, kao da je stajao u ibadetu cijelu noć.",
            "en": "Whoever prays Maghrib and Isha in congregation is as if he stood in worship all night.",
            "de": "Wer Maghrib und Isha in der Gemeinschaft betet, ist so, als hätte er die ganze Nacht im Gottesdienst verbracht.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Kraj radnog dana. Nagradi sebe sa par minuta posvećenih Allahu.",
            "en": "End of the workday. Reward yourself with a few minutes devoted to Allah.",
            "de": "Ende des Arbeitstages. Belohne dich mit ein paar Minuten, die Allah gewidmet sind.",
        ]),
        ReminderMessage([
            "bs": "Požuri – akšamsko vrijeme je kratko. Uzmi abdest i kreni.",
            "en": "Hurry – Maghrib time is short. Make wudu and go.",
            "de": "Beeil dich – die Zeit für Maghrib ist kurz. Vollziehe Wudu und beginne.",
        ]),
        ReminderMessage([
            "bs": "Sunce zalazi i otvara se vrata ibadeta. Dočekaj ih namazom.",
            "en": "The sun sets and the doors of worship open. Welcome them with prayer.",
            "de": "Die Sonne geht unter und die Tore des Gottesdienstes öffnen sich. Empfange sie mit dem Gebet.",
        ]),
    ]

    private static let isha: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Ko klanja jaciju u džematu, kao da je klanjao pola noći.",
            "en": "Whoever prays Isha in congregation is as if he prayed half the night.",
            "de": "Wer das Isha-Gebet in der Gemeinschaft verrichtet, ist so, als hätte er die halbe Nacht gebetet.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Ko klanja jaciju i sabah u džematu, Allah mu upiše nagradu kao da je klanjao cijelu noć.",
            "en": "Whoever prays Isha and Fajr in congregation, Allah records for him the reward of praying all night.",
            "de": "Wer Isha und Fajr in der Gemeinschaft betet, dem schreibt Allah den Lohn für das Gebet der ganzen Nacht gut.",
        ], source: "Buhari, Muslim"),
        ReminderMessage([
            "bs": "Završi dan namazom i kratkom dovom – to je najljepši kraj svakog dana.",
            "en": "End your day with prayer and a brief supplication – that is the most beautiful way to close every day.",
            "de": "Beende deinen Tag mit dem Gebet und einem kurzen Bittgebet – das ist der schönste Abschluss eines jeden Tages.",
        ]),
        ReminderMessage([
            "bs": "Klanjaj jaciju u džematu, pa lezi sa nijom za sabah. Obje noći su pokrivene.",
            "en": "Pray Isha in congregation, then sleep with the intention for Fajr. Both nights are covered.",
            "de": "Bete Isha in der Gemeinschaft und gehe dann mit der Absicht für Fajr schlafen. Beide Nächte sind gesegnet.",
        ]),
        ReminderMessage([
            "bs": "Allahov Poslanik ﷺ nije spavao prije jacije niti razgovarao poslije nje.",
            "en": "The Prophet ﷺ never slept before Isha or conversed after it.",
            "de": "Der Gesandte Allahs ﷺ pflegte vor dem Isha-Gebet nicht zu schlafen und danach keine Gespräche mehr zu führen.",
        ], source: "Buhari"),
    ]

    private static let duha: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Ko klanja duha namaz, pripisat će mu se nagrada kao da je dao sadaku za svaki zglavak tijela.",
            "en": "Whoever prays Duha will have charity recorded for every joint in his body.",
            "de": "Wer das Duha-Gebet verrichtet, dem wird ein Lohn zugeschrieben, als hätte er für jedes Gelenk seines Körpers Sadaka gegeben.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Allahov Poslanik ﷺ je klanjao duha 4 do 8 rekata. Počni sa dva – Allah prima i najmanje.",
            "en": "The Prophet ﷺ prayed 4 to 8 rak'ahs of Duha. Start with two – Allah accepts even the smallest.",
            "de": "Der Gesandte Allahs ﷺ betete 4 bis 8 Rak'ahs Duha. Beginne mit zwei – Allah nimmt auch das Kleinste an.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Duha namaz je namaz pokajanja i zahvalnosti. Klanjaj ga dok si još svjež i napolju je jasno.",
            "en": "Duha is the prayer of repentance and gratitude. Pray it while you are still fresh.",
            "de": "Das Duha-Gebet ist das Gebet der Reue und Dankbarkeit. Bete es, während du noch frisch bist.",
        ]),
        ReminderMessage([
            "bs": "Ko klanja duha redovito, svi njegovi grijesi mu se opraste, makar bili kao morska pjena.",
            "en": "Whoever prays Duha regularly, his sins will be forgiven even if they are like the foam of the sea.",
            "de": "Wer das Duha-Gebet regelmäßig verrichtet, dem werden alle Sünden vergeben, auch wenn sie wie der Schaum des Meeres wären.",
        ], source: "Tirmizi"),
        ReminderMessage([
            "bs": "Ovo je duha doba – ptice slave Allaha, a ti možeš im se pridružiti sa dva rekata.",
            "en": "This is Duha time – birds glorify Allah, and you can join them with two rak'ahs.",
            "de": "Dies ist die Zeit des Duha – die Vögel preisen Allah, und du kannst dich ihnen mit zwei Rak'ahs anschließen.",
        ]),
    ]

    private static let polaNoci: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Probudi se i klanjaj bar dva rekata noćnog namaza. Allah voli one koji ustaju kada drugi spavaju.",
            "en": "Wake up and pray at least two rak'ahs of the night prayer. Allah loves those who rise while others sleep.",
            "de": "Wach auf und bete mindestens zwei Rak'ahs des Nachtgebets. Allah liebt diejenigen, die aufstehen, während andere schlafen.",
        ]),
        ReminderMessage([
            "bs": "Allahov Poslanik ﷺ je ustajao noću da klanja dok mu se noge ne bi otekle. Upitan zašto, odgovorio je: 'Zar ne bih bio zahvalan rob?'",
            "en": "The Prophet ﷺ used to stand in night prayer until his feet swelled. Asked why, he said: 'Should I not be a grateful servant?'",
            "de": "Der Gesandte Allahs ﷺ pflegte nachts so lange zu beten, bis seine Füße anschwollen. Gefragt nach dem Warum, antwortete er: 'Sollte ich nicht ein dankbarer Diener sein?'",
        ], source: "Buhari, Muslim"),
        ReminderMessage([
            "bs": "Kijamu-l-lejl – noćni namaz je dobrovoljni ibadet koji uzdiže stepene i briše grijehe.",
            "en": "Qiyam al-Layl – the night prayer is a voluntary act of worship that elevates ranks and erases sins.",
            "de": "Qiyam al-Layl – das Nachtgebet ist ein freiwilliger Gottesdienst, der die Stufen erhöht und Sünden auslöscht.",
        ]),
        ReminderMessage([
            "bs": "Ko ustane noću i probudi svoju porodicu da klanja, Allah im upiše nagradu kao onima koji stalno Allaha spominju.",
            "en": "Whoever rises at night and wakes his family to pray, Allah records for them the reward of those who constantly remember Him.",
            "de": "Wer nachts aufsteht und seine Familie zum Gebet weckt, dem schreibt Allah den Lohn derer gut, die Seiner ständig gedenken.",
        ], source: "Ebu Davud"),
        ReminderMessage([
            "bs": "Noćni namaz je počast vjerniku. Ustaj, abdest uzmi i klanjaj koliko možeš.",
            "en": "The night prayer is the honor of the believer. Rise, make wudu and pray as much as you can.",
            "de": "Das Nachtgebet ist die Ehre des Gläubigen. Steh auf, vollziehe Wudu und bete so viel du kannst.",
        ]),
    ]

    private static let zadnjaTrecina: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Allah pita u zadnjoj trećini noći: 'Ko Me zove da Mu se odazovem? Ko traži da mu dam? Ko traži oprost da mu oprostim?'",
            "en": "Allah asks in the last third of the night: 'Who is calling upon Me that I may answer? Who is asking that I may give? Who seeks forgiveness that I may forgive?'",
            "de": "Allah fragt im letzten Drittel der Nacht: 'Wer ruft Mich an, damit Ich ihm antworte? Wer bittet Mich, damit Ich ihm gebe? Wer bittet um Vergebung, damit Ich ihm vergebe?'",
        ], source: "Buhari, Muslim"),
        ReminderMessage([
            "bs": "Klanjaj noćni namaz, pa vitr, pa čini istigfar do zore. Ovo je najvrjednije doba noći za dovu.",
            "en": "Pray the night prayer, then witr, then seek forgiveness until dawn. This is the most precious time for supplication.",
            "de": "Verrichte das Nachtgebet, dann Witr, und bitte um Vergebung bis zum Morgengrauen. Dies ist die wertvollste Zeit der Nacht für Bittgebeten.",
        ]),
        ReminderMessage([
            "bs": "Istigfar u zadnjoj trećini noći: 'Estağfirullah' – učini ga 70 ili 100 puta do zore.",
            "en": "Istighfar in the last third of the night: 'Astaghfirullah' – say it 70 or 100 times until dawn.",
            "de": "Istighfar im letzten Drittel der Nacht: 'Astaghfirullah' – sprich es 70 oder 100 Mal bis zum Morgengrauen.",
        ]),
        ReminderMessage([
            "bs": "Oni koji traže oprost u jutarnjim satima – Allah ih hvali u Kur'anu.",
            "en": "Those who seek forgiveness in the early hours – Allah praises them in the Quran.",
            "de": "Diejenigen, die in den frühen Morgenstunden um Vergebung bitten – Allah lobt sie im Koran.",
        ], source: "Kur'an, 3:17"),
        ReminderMessage([
            "bs": "Vitr namaz je hak – ko ga nije klanjao, neka ga klanja sad. Zatvori noć sa vitrom.",
            "en": "Witr prayer is a right – if you haven't prayed it, do so now. Close the night with witr.",
            "de": "Das Witr-Gebet ist eine Pflicht – wer es noch nicht gebetet hat, sollte es jetzt tun. Schließe die Nacht mit Witr ab.",
        ], source: "Ebu Davud"),
    ]

    private static let general: [ReminderMessage] = [
        ReminderMessage([
            "bs": "Namaz u džematu je 27 puta bolji od namaza samog.",
            "en": "Prayer in congregation is 27 times better than prayer alone.",
            "de": "Das Gebet in der Gemeinschaft ist 27-mal besser als das Gebet alleine.",
        ], source: "Buhari, Muslim"),
        ReminderMessage([
            "bs": "Pet dnevnih namaza su poput rijeke koja teče pored tvoje kuće – ko se u njoj okupa pet puta dnevno, neće imati prljavštine na sebi.",
            "en": "The five daily prayers are like a river flowing past your door – whoever bathes in it five times a day will have no filth on him.",
            "de": "Die fünf täglichen Gebete sind wie ein Fluss, der an deiner Tür vorbeifließt – wer darin fünfmal am Tag badet, wird keinen Schmutz an sich haben.",
        ], source: "Muslim"),
        ReminderMessage([
            "bs": "Uzmi abdest na miru – ne ostavljaj to za zadnji tren. Sunnet je biti uvijek čist.",
            "en": "Make wudu calmly – don't leave it to the last minute. The sunnah is to always be in a state of purity.",
            "de": "Vollziehe Wudu in Ruhe – schiebe es nicht bis zum letzten Moment auf. Es ist Sunnah, immer im Zustand der Reinheit zu sein.",
        ]),
        ReminderMessage([
            "bs": "Provjeri kiblu, uzmi tesbih i pripremi se polako – namaz zaslužuje tvoju punu pažnju.",
            "en": "Check the qibla, take your prayer beads, prepare slowly – prayer deserves your full attention.",
            "de": "Prüfe die Qibla, nimm deine Gebetskette, bereite dich langsam vor – das Gebet verdient deine volle Aufmerksamkeit.",
        ]),
        ReminderMessage([
            "bs": "Najbitnija stvar za kojom će te Allah pitati na Sudnjem danu jeste namaz.",
            "en": "The most important thing Allah will ask you about on the Day of Judgment is prayer.",
            "de": "Das Wichtigste, wonach Allah dich am Tag des Jüngsten Gerichts fragen wird, ist das Gebet.",
        ], source: "Tirmizi"),
    ]

    static func expiring(prevKey: String, nextKey: String) -> ReminderMessage {
        let prev = loc("prayer.\(prevKey)", "bs")
        let next = loc("prayer.\(nextKey)", "bs")
        let prevEn = loc("prayer.\(prevKey)", "en")
        let nextEn = loc("prayer.\(nextKey)", "en")
        let prevDe = loc("prayer.\(prevKey)", "de")
        let nextDe = loc("prayer.\(nextKey)", "de")

        let bsTemplates: [(String, String?)] = [
            ("Za 30 minuta stiže \(next), a \(prev) još nije klanjan. Iskoristi ovo vrijeme – abdest, kibla, namaz.", nil),
            ("Bliži se \(next), a \(prev) još čeka. Ne ulazi u novi namaz sa dugom od prethodnog.", nil),
            ("Namaz u svom vremenu je najdraže djelo Allahu. Za 30 minuta \(prev) ističe – požuri.", "Buhari"),
            ("Za 30 minuta \(next) kuca na vrata, a \(prev) još nije klanjan. Ustaj odmah.", nil),
            ("Još 30 minuta pa \(prev) zatvara svoja vrata. Klanjaj ga dok možeš.", nil),
        ]
        let enTemplates: [(String, String?)] = [
            ("\(nextEn) is in 30 minutes and \(prevEn) hasn't been prayed yet. Use this time – wudu, qibla, prayer.", nil),
            ("\(nextEn) is approaching and \(prevEn) is still waiting. Don't enter a new prayer while in debt from the previous one.", nil),
            ("Prayer in its time is the most beloved deed to Allah. In 30 minutes \(prevEn) expires – hurry.", "Bukhari"),
            ("In 30 minutes \(nextEn) knocks on the door, and \(prevEn) hasn't been prayed yet. Get up now.", nil),
            ("30 more minutes and \(prevEn) closes its doors. Pray it while you still can.", nil),
        ]
        let deTemplates: [(String, String?)] = [
            ("In 30 Minuten beginnt \(nextDe), und \(prevDe) wurde noch nicht gebetet. Nutze diese Zeit – Wudu, Qibla, Gebet.", nil),
            ("\(nextDe) nähert sich und \(prevDe) wartet noch. Tritt nicht in ein neues Gebet mit Schulden aus dem vorherigen ein.", nil),
            ("Das Gebet zu seiner Zeit ist die liebste Tat bei Allah. In 30 Minuten läuft \(prevDe) ab – beeile dich.", "Bukhari"),
            ("In 30 Minuten klopft \(nextDe) an die Tür, und \(prevDe) ist noch nicht verrichtet. Steh jetzt auf.", nil),
            ("Noch 30 Minuten, dann schließt \(prevDe) seine Türen. Bete es, solange du noch kannst.", nil),
        ]

        let idx = Int.random(in: 0..<bsTemplates.count)
        return ReminderMessage([
            "bs": bsTemplates[idx].0,
            "en": enTemplates[idx].0,
            "de": deTemplates[idx].0,
        ], source: bsTemplates[idx].1)
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

    private let warningColor = Color.orange

    var body: some View {
        HStack(spacing: 0) {
            // Left accent border
            warningColor
                .frame(width: 4)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 12, bottomLeadingRadius: 12,
                    bottomTrailingRadius: 0, topTrailingRadius: 0
                ))

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(warningColor)
                        .font(.system(size: 15))
                        .symbolRenderingMode(.hierarchical)

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

                Text(message.localizedBody())
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
        }
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

            let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "bs"
            let reminderKey = "reminder.\(prayer)"
            let reminderLocalized = loc(reminderKey, lang)
            let displayName = reminderLocalized != reminderKey
                ? reminderLocalized
                : loc("prayer.\(prayer)", lang)
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
