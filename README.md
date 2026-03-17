# VaktijaDev

Minimalna macOS menu bar aplikacija za praćenje vaktije (namaz vremena) u gradovima Bosne i Hercegovine.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Mogućnosti

- Prikaz 5 dnevnih namaza + izlazak sunca
- Hidžretski i gregorijanski datum
- Automatsko označavanje sljedećeg namaza
- 16 gradova iz BiH
- Račun sa uglom od 14.5° za zoru i jaciu
- Bez Dock ikone — živi samo u menu baru

## Instalacija

### Opcija 1 — Preuzmi gotovu aplikaciju

1. Idi na [Releases](https://github.com/brascene/VaktijaDev/releases) stranicu
2. Preuzmi `VaktijaDev.app.zip`
3. Raspakiraj i premjesti `VaktijaDev.app` u `/Applications`
4. Desni klik na app → **Open** (samo prvi put, zbog Gatekeeper zaštite)

### Opcija 2 — Izgradi sam iz koda

Potrebno: Xcode 15+ i macOS 13+

```bash
git clone https://github.com/brascene/VaktijaDev.git
cd VaktijaDev
xcodebuild -scheme VaktijaDev -configuration Release build
```

Aplikacija će biti u:
```
~/Library/Developer/Xcode/DerivedData/VaktijaDev-*/Build/Products/Release/VaktijaDev.app
```

Ili jednostavno otvori `VaktijaDev.xcodeproj` u Xcode-u i pokreni (⌘R).

## Korištenje

1. Pokreni aplikaciju — ikona mjeseca (🌙) se pojavi u menu baru
2. Klikni na ikonu — otvori se popover sa vaktijom
3. Odaberi grad iz padajućeg menija
4. Klikni bilo gdje van popovera da ga zatvoriš

## API

Koristi [Aladhan API](https://aladhan.com/prayer-times-api) za dohvat namaz vremena.

## Licenca

MIT — koristi slobodno.
