# Leitfaden für das Vorstellungsgespräch bei Handwerkerhaus Hanshans
**Termin:** Mittwoch, 21.10.2026 um 10:00 Uhr  
**Ort:** Am Kuffholz 10, 93138 Lappersdorf-Hainsacker  
**Ansprechpartner:** Tobias Kölbl (Geschäftsführer)  
**Bewerber:** Mohamed Ben Othman (KI-Student an der TH Deggendorf, Empfehlung Prof. Dr. Glauner)  
**Position:** Werkstudent – Projektboard & KI (m/w/d) (ca. 20 Std./Woche)

---

## 1. Übersicht über die Dateien in diesem Ordner (`dashboard`)

| Datei | Funktion |
| :--- | :--- |
| **`app.py`** | **Python-Version (Streamlit):** Das vollständige Dashboard in reinem Python mit SQLite-Datenbank, interaktiven Filtern, Altair-Diagrammen und KI-Risikoanalyse! |
| **`start_python_dashboard.bat`** | **1-Klick-Starter für Python:** Einfach doppelklicken, um das Python-Dashboard sofort im Browser zu öffnen. |
| **`dashboard_simple.r`** | **Einfaches R-Shiny-Board:** Schlanke ~80-Zeilen-Version, liest die CSV ein, erfüllt alle 4 Anforderungen von Herrn Kölbl. |
| **`dashboard_pro_ki.r`** | **Erweiterte R-Version (SQL & KI):** Liest CSVs in eine relationale SQLite-Datenbank (DBI) und berechnet den KI-Risikoscore. |
| **`hanshans_projekte_stammdaten.csv`** | **Stammdaten-Tabelle:** Externe CSV-Datei für die SQL-Datenbank (kein Hardcoding im Code!). |
| **`projekte_hanshans.csv`** | **Datengrundlage für einfaches Board:** 12 Handwerksprojekte aus Lappersdorf & Regensburg. |
| **`dashboard_archive.r`** | **Direkt mit Archiv-Daten:** Verarbeitet 2.568 Tasks mit Fristen direkt aus `archive/`. |
| **`archive/`** | Ordner mit den ursprünglichen Bau-Archivdaten (12.424 Tasks). |

---

## 2. Der Gesprächsablauf (Die 4 Punkte aus Herrn Kölbls Einladung)

### Punkt 1: Persönliche Vorstellung (2–3 Minuten)
- **Wer bin ich?** Mohamed Ben Othman, Student der Künstlichen Intelligenz an der TH Deggendorf (Empfehlung durch Prof. Dr. Patrick Glauner).
- **Warum Handwerkerhaus Hanshans?** Hands-on-Mentalität: Keine abstrakte Software im Elfenbeinturm, sondern praktische Digitalisierung für das regionale Handwerk in Regensburg/Lappersdorf.
- **Wichtig:** *Nicht* von E-Commerce oder Reisebranche sprechen! Hanshans ist Bauelemente & Modernisierung (Fenster, Türen, Fassade).

---

### Punkt 2: Vorstellung des Projektboards (5–7 Minuten Live-Demo)
Starten Sie `dashboard_simple.r` auf Ihrem Laptop.

1. **Die Datenbasis zeigen:**
   - *„Das Board liest eine ganz normale CSV-Tabelle ein (`projekte_hanshans.csv`). Ich habe anonymisierte Beispieldaten aus Ihrem echten Gewerkespektrum vorbereitet: Fensterbau, Denkmal-Haustüren, Sonnenschutz und Terrassendächer aus Lappersdorf, Regensburg und Umgebung.“*
2. **Die 4 Kernanforderungen aus der E-Mail vorführen:**
   - **Status:** *„Hier sehen wir die Phasen vom Aufmaß bis zur Montage und Abnahme.“*
   - **Verantwortlicher:** *„Wenn Sie im Filter auf 'Markus Bauer' klicken, sehen Sie montags sofort alle seine Baustellen.“*
   - **Termine:** *„Alle Meilensteine haben ein festes Zieldatum im deutschen Format.“*
   - **Überfällige Aufgaben:** *„Klick auf die Checkbox 'Nur überfällige' – sofort werden die kritischen Baustellen rot markiert.“*
3. **Die Brücke zur KI schlagen:**
   - *„Aktuell zeigt das Board reaktiv, was heute schon überfällig ist. Mein Ziel als KI-Student ist es, daraus ein vorausschauendes Frühwarnsystem zu bauen: Ein Algorithmus erkennt drohende Liefer- und Montageengpässe schon 10 bis 14 Tage vor Baustellenbeginn.“*

---

### Punkt 3: Möglichkeit der praktischen Umsetzung (5 Minuten)
- **Woher kommen die Daten?**
  - Bestehende Handwerkersoftware (z. B. KWP, pds, Streit V.1 oder Excel) exportiert täglich eine CSV-Datei auf ein Netzlaufwerk. Das Dashboard liest sie automatisch ein.
  - Kein teurer Softwareumbau nötig!
- **Datenschutz & Hosting:**
  - Läuft lokal auf einem Büro-PC oder Server im Hanshans-Netzwerk.
  - 100 % DSGVO-konform, keine Datenübertragung in fremde Clouds.
- **Mobilität:**
  - Bauleiter und Monteure können das Board auf Tablets im Büro oder per sicherem Firmen-WLAN nutzen.

---

### Punkt 4: Planungsansatz der Kosten- und Zeitaufwendungen (5 Minuten)

#### Zeitplan (3 Monate bei ca. 20 Std./Woche als Werkstudent):
- **Monat 1 (Woche 1–4):** Anbindung der Handwerkersoftware / Datenexporte & Bereitstellung des Basis-Boards im Firmennetz.
- **Monat 2 (Woche 5–8):** Praxistest mit den Bauleitern, Feedback einarbeiten, mobile Tablet-Optimierung.
- **Monat 3 (Woche 9–12):** KI-Modell zur Verzugsprognose kalibrieren, automatisierte E-Mail-Warnungen, Schulung & Dokumentation.

#### Kostenaufstellung:
- **Softwarelizenzen: 0,- €** (R, Shiny, Python, Datenbanken sind Open Source – keine monatlichen Lizenzgebühren pro Arbeitsplatz).
- **Hardware: 0,- €** (Vorhandene Büro-Rechner genügen).
- **Personalkosten:** Werkstudent ca. 20h/Woche (ca. 14–16 €/Std. = ca. 1.200–1.400 € / Monat).
- **Return on Investment (ROI):** Wenn Bauleiter täglich nur 30 Minuten weniger nach Projektständen telefonieren müssen und pro Monat auch nur ein einziger Baustellenstillstand verhindert wird, hat sich die Stelle ab dem ersten Monat gerechnet.

---

## 3. Clevere Fragen an Herrn Kölbl am Ende
1. *„Mit welcher Branchensoftware arbeiten Sie aktuell bei Hanshans für Angebote und Auftragsabwicklung (z. B. KWP, pds oder Excel)?“*
2. *„Wo entstehen bei Ihnen in der Praxis die meisten Reibungsverluste – eher bei Materiallieferzeiten oder bei der Montageplanung vor Ort?“*
3. *„Wie stimmen sich Ihre Bauleiter aktuell ab – gibt es eine feste wöchentliche Montagsrunde?“*
