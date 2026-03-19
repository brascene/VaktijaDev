# VaktijaDev

Minimalna macOS menu bar aplikacija za praćenje vaktije (namaz vremena) u gradovima Bosne i Hercegovine.

![macOS](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Pregled

<p align="center">
  <video src="https://github.com/user-attachments/assets/41aed689-08f2-4214-a7c9-c624da815f56" autoplay loop muted playsinline width="600"></video>
</p>

## Mogućnosti

- Prikaz 5 dnevnih namaza + izlazak sunca
- Hidžretski i gregorijanski datum
- Automatsko označavanje sljedećeg namaza
- 16 gradova iz BiH
- Opcija "Koristi moju lokaciju" — GPS za korisnike koji ne nađu svoj grad
- Račun sa uglom od 14.5° za sabah i jaciju — [zašto 14.5°?](https://github.com/brascene/VaktijaDev/wiki)
- Bez Dock ikone — živi samo u menu baru

## Instalacija

### Opcija 1 — Preuzmi gotovu aplikaciju

1. Idi na [Releases](https://github.com/brascene/VaktijaDev/releases) stranicu
2. Preuzmi `VaktijaDev.app.zip`
3. Raspakiraj i premjesti `VaktijaDev.app` u `/Applications`
4. Desni klik na app → **Open** (samo prvi put, zbog Gatekeeper zaštite)
5. Ako macOS i dalje ne dozvoljava otvaranje — idi u **System Settings → Privacy & Security**, skrolaj do dna i klikni **Open Anyway**

### Opcija 2 — Izgradi sam iz koda

Potrebno: Xcode 15+ i macOS 14+

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
4. Ili klikni na ikonu lokacije (📍) da koristiš svoju GPS poziciju
5. Klikni bilo gdje van popovera da ga zatvoriš

## API

Koristi [vaktija.dev API](https://vaktija.dev) kao primarni izvor namaz vremena, sa [Aladhan API](https://aladhan.com/prayer-times-api) kao rezervnim izvorom u slučaju greške.

- **Primarna:** `GET https://vaktija.dev/api/v1/prayers/today?lat=43.651100&lon=17.961100`
- **Rezervna:** `GET https://api.aladhan.com/v1/timings/{timestamp}?latitude=...&longitude=...&method=99&methodSettings=14.5,null,14.5`

Primarni API vraća i dodatna islamska vremena: pola noći i zadnju trećinu noći. Rezervni API koristi prilagođenu metodu sa uglom od **14.5°** za sabah i jaciju.

## Web verzija

Za korištenje u browseru posjetite [vaktija.dev](https://vaktija.dev) — web aplikacija istog tima čiji API koristimo.

## Licenca

MIT — koristi slobodno.
