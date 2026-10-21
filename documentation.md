# Technische und Konzeptionelle Gesamtdokumentation

**Projekt:** Handwerkerhaus Hanshans - Digitales Projektboard, SQL-Architektur und KI-gestützte Aufgabensteuerung  
**Autor:** Mohamed Ben Othman (Student der Kuenstlichen Intelligenz, Technische Hochschule Deggendorf)  
**Zielunternehmen:** Hanshans Fachbetrieb Bauelemente und Handel GmbH, Lappersdorf/Regensburg  
**Datum:** Oktober 2026  
**Speicherort:** `C:\Users\mdhia\OneDrive\Bureau\dashboard\documentation.md`

---

## Inhaltsverzeichnis
1. [Management Summary und Problemstellung](#1-management-summary-und-problemstellung)
2. [Anforderungsanalyse aus der Aufgabenstellung](#2-anforderungsanalyse-aus-der-aufgabenstellung)
3. [Datenanalyse und Audit der Ausgangsdaten](#3-datenanalyse-und-audit-der-ausgangsdaten)
4. [Fachliche Datenmodellierung fuer Handwerkerhaus Hanshans](#4-fachliche-datenmodellierung-fuer-handwerkerhaus-hanshans)
5. [Systemarchitektur und Schichtenmodell](#5-systemarchitektur-und-schichtenmodell)
6. [Die relationale Datenbankschicht (database.py und hanshans.db)](#6-die-relationale-datenbankschicht-databasepy-und-hanshansdb)
7. [Frontend-Implementierung: Dual-Stack Ansatz (Python und R)](#7-frontend-implementierung-dual-stack-ansatz-python-und-r)
   - [7.1. Python-Architektur (Streamlit, Altair, Pandas)](#71-python-architektur-streamlit-altair-pandas)
   - [7.2. R-Architektur (Shiny, DT, bslib)](#72-r-architektur-shiny-dt-bslib)
8. [Das KI-Fruehwarnmodul: Praediktive Risikobewertung](#8-das-ki-fruehwarnmodul-praediktive-risikobewertung)
9. [Automatisierung und Hintergrund-Synchronisation](#9-automatisierung-und-hintergrund-synchronisation)
10. [Wirtschaftlichkeitsanalyse und Umsetzungsfahrplan (ROI)](#10-wirtschaftlichkeitsanalyse-und-umsetzungsfahrplan-roi)

---

## 1. Management Summary und Problemstellung

Handwerkerhaus Hanshans ist ein fuehrender Modernisierungsbetrieb im Landkreis Regensburg, spezialisiert auf Bauelemente wie Fenster, Haustueren, Sonnenschutzsysteme, Raffstores und Terrassenueberdachungen. In der handwerklichen Praxis haengen Kundenzufriedenheit und Wirtschaftlichkeit direkt von der reibungslosen Koordination zwischen Angebot, Aufmass, Lieferzeiten der Hersteller (z. B. Schueco, Internorm, Warema) und der Kapazitaetsplanung der Montageteams vor Ort ab.

Das Ziel dieses Projekts ist die Entwicklung eines praxistauglichen Prototyps fuer ein digitales Projektboard mit KI-gestuetzter Aufgabensteuerung. Das System ueberfuehrt fragmentierte Datenquellen (z. B. Excel-Listen, ERP-Exporte) in eine zentrale, relationale Datenstruktur und ergaenzt die reine Rueckschau um ein praediktives KI-Fruehwarnsystem zur Vermeidung von Montageverzoegerungen.

---

## 2. Anforderungsanalyse aus der Aufgabenstellung

Im Rahmen der Projektvorbereitung wurden folgende Kernanforderungen formuliert:

1. **Projektstatus:** Luetenlose Visualisierung der Prozessschritte eines Auftrags (Aufmass, Bestellung beim Werk, Montageplanung, Montage vor Ort, Abnahme, Reklamation).
2. **Projektverantwortlicher:** Eindeutige Zuordnung der Baustellen zu den zustaendigen Bauleitern, Meistern und Montageverantwortlichen zur Laststeuerung.
3. **Termine und Fristen:** Praezise Verfolgung von verbindlichen Fertigstellungsterminen (Soll-Termine), Kalenderwochen (KW) und Restfristen.
4. **Ueberfaellige Aufgaben:** Sofortige optische Hervorhebung von Projektverzoegerungen inklusive konkreter Verzugstage und offener Einzelmassnahmen.
5. **KI-Mehrwert:** Einbindung intelligenter Analysemethoden im Rahmen der ausgeschriebenen Werkstudentenstelle ("Projektboard & KI"), um ueber eine rein statische Tabellenansicht hinauszugehen.

---

## 3. Datenanalyse und Audit der Ausgangsdaten

Zu Beginn der Entwicklung lagen im Archivordner (`archive/`) zwei Rohdatensaetze vor. Eine eingehende datenanalytische Pruefung fuehrte zu folgenden Erkenntnissen:

### 3.1. Datensatz `Construction_Data_PM_Forms_All_Projects.csv`
* **Inhalt:** 10.254 Datensaetze administrativer Formulare (z. B. taegliche Bautagebuecher).
* **Defizite:**
  * Die Spalte `OverDue` wies in 100 % aller Faelle den Wert `FALSE` auf (0 ueberfaellige Aufgaben).
  * Es existierten keine Ziel- oder Fertigstellungstermine.
  * Es fehlte jegliche Zuordnung zu verantwortlichen Personen.
  * Eine direkte Verwendung dieses Datensatzes haette saemtliche Filter fuer Ueberfaelligkeiten ins Leere laufen lassen.

### 3.2. Datensatz `Construction_Data_PM_Tasks_All_Projects.csv`
* **Inhalt:** 12.424 konkrete Aufgaben und Maengelberichte.
* **Besonderheiten:**
  * Enthielt 858 tatsaechlich ueberfaellige Aufgaben (`OverDue == TRUE`).
  * Zieldaten (`Target`) waren als Excel-Seriennummern formatiert (z. B. `44094`).
  * Inhaltlicher Kontext: Englisches Grossprojekt eines irischen Generalunternehmers fuer Beton- und Rohbauarbeiten (John Paul Construction, Gewerke: Precast Concrete, Groundworks).
  * Fazit: Technisch wertvoll fuer Stresstests und Parsing-Nachweise, aber fuer ein Gespraech mit einem regionalen Modernisierungsbetrieb unzureichend im Branchenbezug.

---

## 4. Fachliche Datenmodellierung fuer Handwerkerhaus Hanshans

Um die unmittelbare Praxistauglichkeit fuer den Betrieb zu demonstrieren, wurde ein branchenspezifischer, anonymisierter Datensatz (`hanshans_projekte_stammdaten.csv`) modelliert:

### 4.1. Definition der Attribute

| Feldname | Datentyp | Fachliche Beschreibung |
| :--- | :--- | :--- |
| `ProjektID` | TEXT (PK) | Eindeutige Vorgangsnummer im Betrieb (z. B. `HH-2026-001`) |
| `Projektname` | TEXT | Bezeichnung des Bauvorhabens inklusive Ortsangabe (z. B. `BV Lappersdorf - EFH 3-fach Fenstertausch`) |
| `Gewerk` | TEXT | Fachbereich (Fensterbau, Haustueren, Sonnenschutz, Terrassendach, Wintergarten) |
| `Verantwortlicher` | TEXT | Zustaendiger Bauleiter oder Meister (z. B. Markus Bauer, Stefan Huber, Christian Schmidt, Tobias Weber) |
| `Status` | TEXT | Prozessstatus im Handwerksablauf |
| `Soll_Termin` | DATE | Vereinbarter Montage- bzw. Fertigstellungstermin im Format `YYYY-MM-DD` |
| `Offene_Aufgaben` | INTEGER | Anzahl noch ausstehender Massnahmen auf der Checkliste |
| `Aktuelle_Aufgabe` | TEXT | Der operativ kritischste naechste Meilenstein |
| `Material_Verfuegbar`| INTEGER | Verfuegbarkeitsstatus (1 = Material im Lager, 0 = Lieferantenausstand) |

### 4.2. Prozessphasen im Statusmodell
1. `1. Aufmass & Planung` (Erfassung der Rohbaumasse mit Lasertechnik, statische Pruefung)
2. `2. Material bestellt (Lieferant)` (Freigabe an Hersteller fuer Profile, Isolierglas, Motoren)
3. `3. Montage terminiert` (Bauzeitenabstimmung mit Bauherr, Gerueststellung, Kraneinsatz)
4. `4. In Montage vor Ort` (Laufende Arbeiten durch Hanshans-Montageteams)
5. `5. Abnahme & Uebergabe` (Kundenunterschrift auf Abnahmeprotokoll, Schlussrechnung)
6. `6. Nacharbeit / Reklamation` (Justierung von Beschlaegen, Reklamation von Transportschaeden)
7. `7. Abgeschlossen` (Vollstaendig abgerechnet und archiviert)

---

## 5. Systemarchitektur und Schichtenmodell

Das Gesamtsystem folgt einer klassischen Drei-Schichten-Architektur mit Entkopplung von Speicherung, Geschaeftslogik und Benutzeroberflaeche:

```
[ EXT-DATA ]   hanshans_projekte_stammdaten.csv / archive/*.csv
      |
      v
[ DB-LAYER ]   database.py  ==>  hanshans.db (Persistente SQLite SQL-Datenbank)
                                 - Indizierung auf Status, Verantwortlicher, Gewerk
                                 - SQL Queries: SELECT, WHERE, ORDER BY
      |
      +-----------------------------------------+
      |                                         |
      v                                         v
[ UI: PYTHON STREAMLIT ]               [ UI: R SHINY ]
app.py                                 dashboard_pro_ki.r / dashboard_simple.r
- Altair Charts                        - bslib & ggplot2
- KPI Metric Cards                     - DT Interactive Tables
- KI-Risikobewertung (0-100%)          - Filtersteuerung nach Bauleiter
- Management-Briefing                  - 3-Monats-Umsetzungsplan
```

---

## 6. Die relationale Datenbankschicht (database.py und hanshans.db)

Um dem Vorwurf von "fest verdrahtetem Code" (Hardcoding) von vornherein zu begegnen, wurde die Datenbanklogik vollstaendig in das Modul `database.py` ausgelagert.

### 6.1. Kernfunktionen von `database.py`
* **`get_connection()`**: Stellt eine threadsichere Verbindung zur persistenten Datei `hanshans.db` her (`check_same_thread=False`).
* **`init_database()`**: Liest die externen CSV-Dateien ein, erstellt die relationalen Tabellenschemata und legt performante Suchbaeume (`B-Tree-Indizes`) an:
  ```sql
  CREATE INDEX IF NOT EXISTS idx_hh_status ON hanshans_projekte(Status);
  CREATE INDEX IF NOT EXISTS idx_hh_verantw ON hanshans_projekte(Verantwortlicher);
  CREATE INDEX IF NOT EXISTS idx_hh_gewerk ON hanshans_projekte(Gewerk);
  ```
* **`get_hanshans_projects()`**: Fuehrt strukturierte SQL-Abfragen aus, um die Datensaetze geordnet nach Fristfaelligkeit zurueckzugeben.
* **`get_archive_tasks()`**: Laedt die bereinigten Archivdaten fuer historische Vergleiche.

### 6.2. Bedeutung der Shared-Database-Architektur
Die Datei `hanshans.db` existiert als eigenstaendige Binaerdatei auf der Festplatte. Sowohl das **Python-Dashboard** als auch das **R-Dashboard** greifen auf dieselbe physische Datenbank zu. Dies verdeutlicht gegenueber dem Kunden, dass die Datenbasis technologieunabhaengig operiert.

---

## 7. Frontend-Implementierung: Dual-Stack Ansatz (Python und R)

Da Mohamed Ben Othman im Schwerpunkt Kuenstliche Intelligenz studiert, ist Python die Primaersprache. Um dem Kunden jedoch maximale Integrationsfaehigkeit aufzuzeigen, wurden vollwertige Implementierungen in beiden Industriestandards bereitgestellt.

### 7.1. Python-Architektur (`app.py`)
* **Framework:** Streamlit (in Kombination mit Pandas und Altair).
* **Vorteile:** Native Python-Umgebung, ideal fuer Machine-Learning-Modelle, schlanke Syntax, reaktives Rerendering.
* **Komponenten:**
  * **Sidebar:** Umschaltung der Datenquelle (Hanshans Handwerk vs. Bau-Archiv), dynamische Filter fuer Verantwortliche, Status, Gewerke sowie Verzugs-Toggles.
  * **KPI-Metriken:** Vier globale Kennzahlen (Gefilterte Projekte, In Montage, Ueberfaellig, KI-Warnungen) mit Differenzwerten.
  * **Visualisierung:** Altair-Balkendiagramme mit Farbkodierung (Marineblau fuer termingerecht, Karmesinrot fuer Verzug).
  * **Reiterstruktur (Tabs):** Trennung zwischen operativer Projektliste, KI-Risikoanalyse und Umsetzungsfahrplan.

### 7.2. R-Architektur (`dashboard_simple.r` und `dashboard_pro_ki.r`)
* **Framework:** R Shiny in Verbindung mit `bslib` (Bootstrap 5) und `DT` (DataTables).
* **Variante `dashboard_simple.r`:** Reduzierte 80-Zeilen-Version, die direkt `projekte_hanshans.csv` liest. Sie dient dazu, auch fachfremden Gespraechspartnern die Logik von reaktiven Webanwendungen in zwei Minuten nahezubringen.
* **Variante `dashboard_pro_ki.r`:** Vollstaendige Enterprise-Version mit SQL-Anbindung an `hanshans.db`, Value-Boxes und Risikomatrix.

---

## 8. Das KI-Fruehwarnmodul: Praediktive Risikobewertung

Der zentrale Unterschied zwischen einem herkoemmlichen Projektboard (z. B. Trello, Excel) und einem KI-gestuetzten Cockpit liegt im Zeithorizont:
* **Traditionelles Board:** *Reaktiv* (zeigt an, welche Baustelle heute bereits verspaetet ist).
* **KI-Projektboard:** *Praediktiv* (erkennt 10 bis 14 Tage vor Montagetermin, welche Baustellen gefaehrdet sind).

### 8.1. Mathematische Formulierung des Risikoscores

Fuer jedes Projekt $i$ wird ein normalisierter Risikoscore $R_i \in [5, 100]$ in Prozent berechnet:

$$R_i = \min\left(100, \max\left(5, S_{\text{overdue}} + S_{\text{material}} + S_{\text{tasks}} + S_{\text{buffer}}\right)\right)$$

Hierbei gelten folgende Gewichtungsparameter:

1. **Verzugskomponente ($S_{\text{overdue}}$):**
   $$S_{\text{overdue}} = \begin{cases} 45, & \text{falls Ist-Datum} > \text{Soll-Termin} \land \text{Status nicht abgeschlossen} \\ 0, & \text{sonst} \end{cases}$$

2. **Material-Vorlaufzeitkomponente ($S_{\text{material}}$):**
   $$S_{\text{material}} = \begin{cases} 35, & \text{falls } \text{Material\_Verfuegbar} = 0 \land \text{Tage\_Bis\_Termin} \le 14 \\ 0, & \text{sonst} \end{cases}$$

3. **Massnahmen-Dichte ($S_{\text{tasks}}$):**
   $$S_{\text{tasks}} = \text{Offene\_Aufgaben} \times 8$$

4. **Kritische Pufferzeit ($S_{\text{buffer}}$):**
   $$S_{\text{buffer}} = \begin{cases} 15, & \text{falls } 0 \le \text{Tage\_Bis\_Termin} \le 3 \\ 0, & \text{sonst} \end{cases}$$

### 8.2. Risikoklassen und Handlungsempfehlungen ("Next Best Action")

* **Klasse Hoch ($R_i \ge 70\,\%$):** Rot markiert. Automatische Eskalation:
  * Bei fehlendem Material: *"Dringend Lieferant eskalieren; Montageteam umplanen"*
  * Bei Baustellenverzug: *"Bauleiter-Einsatz vor Ort noetig; Kunde proaktiv anrufen"*
* **Klasse Mittel ($40\,\% \le R_i < 70\,\%$):** Gelb markiert. *"Terminueberwachung; Puffer pruefen"*.
* **Klasse Niedrig ($R_i < 40\,\%$):** Gruen markiert. *"Im Regelablauf; keine Sondermassnahme noetig"*.

### 8.3. Automatisches Management-Briefing
Das System generiert fuer die Geschaeftsfuehrung taeglich einen synthetisierten Lagebericht in natuerlicher Sprache, der die drei kritischsten Brennpunkte des Tages zusammenfasst (z. B. Glaslieferungsverzug Schueco fuer Objekt Regensburg Altstadt).

---

## 9. Automatisierung und Hintergrund-Synchronisation

Auf die Frage, wie sich die Daten im betrieblichen Alltag ohne manuelle Eingriffe aktualisieren, greift das System auf zwei etablierte Mechanismen zurueck:

### 9.1. SQL-Polling ueber Cache-Invalidierung (TTL)
Wenn das Dashboard direkt mit einer SQL-Datenbank gekoppelt ist:
* Streamlit nutzt `@st.cache_data(ttl=60)`. Der Cache verfaellt automatisch nach 60 Sekunden.
* R Shiny nutzt `reactiveTimer(60000)`.
* Sobald ein Mitarbeiter im Buero in der Handwerkersoftware (z. B. KWP) einen Lieferschein erfasst oder einen Termin verschiebt, liest das Board beim naechsten Intervall den neuen Stand aus der Datenbank.

### 9.2. Zeitgesteuerter Batch-Import (Windows-Aufgabenplanung)
Falls das fuehrende Handwerkersystem keine offene Datenbankschnittstelle bereitstellt:
* Ein leichtgewichtiges Skript exportiert taeglich um 06:00 Uhr morgens die Projektliste als CSV auf ein internes Netzlaufwerk.
* `database.py` synchronisiert die Tabellen vor Arbeitsbeginn der Bauleiter.

---

## 10. Wirtschaftlichkeitsanalyse und Umsetzungsfahrplan (ROI)

### 10.1. Zwoelf-Monats-Fahrplan (ca. 20 Stunden/Woche als Werkstudent)

Die Entwicklung ist bewusst als mindestens einjaehriges Vorhaben angelegt. Dadurch entsteht
nicht nur ein Prototyp, sondern ein dauerhaft betreutes System, das in den Arbeitsalltag
integriert, gemessen und schrittweise erweitert werden kann.

* **Monat 1-2: Bestandsaufnahme und technische Basis**
  * Analyse der bestehenden Hanshans-Software (KWP, pds, Excel) und ihrer Schnittstellen.
  * Abstimmung der fachlichen Anforderungen mit Geschaeftsfuehrung, Bauleitern und Meistern.
  * Aufbau der Datenbank-, Import- und Berechtigungsstruktur.
* **Monat 3-4: Basis-Board und erster Pilot**
  * Bereitstellung des Basis-Boards im internen Firmennetzwerk.
  * Pilotbetrieb mit einer begrenzten Zahl von Projekten und Verantwortlichen.
  * Erfassung von Ausgangswerten, zum Beispiel Suchaufwand, offene Aufgaben und Lieferverzuege.
* **Monat 5-6: Praxiseinsatz und mobile Optimierung**
  * Test des Boards in den woechentlichen Besprechungen.
  * Einarbeitung des Feedbacks von Bauleitern und Meistern.
  * Optimierung fuer Werkstatt- und Baustellen-Tablets.
  * Einrichtung automatischer E-Mail-Warnungen bei kritischem Lieferverzug.
* **Monat 7-8: KI-Fruehwarnung und Prozessintegration**
  * Kalibrierung des Risikomodells mit historischen Lieferfristen und Projektdaten.
  * Integration der Warnungen in die taeglichen und woechentlichen Arbeitsablaeufe.
  * Entwicklung des Management-Briefings und der Handlungsempfehlungen.
* **Monat 9-10: Rollout und Stabilisierung**
  * Schrittweise Ausweitung auf weitere Projekte, Gewerke und Verantwortliche.
  * Schulung der Mitarbeitenden und Erstellung von Betriebs- und Anwenderdokumentation.
  * Fehlerbehebung, Performance-Optimierung und Sicherung der Datenqualitaet.
* **Monat 11-12: Wirkungsmessung und Weiterentwicklung**
  * Vergleich der Kennzahlen mit den zu Beginn erfassten Ausgangswerten.
  * Messung von vermiedenen Leerlauffahrten, eingesparter Koordinationszeit und Warnqualitaet.
  * Uebergabe eines Jahresberichts mit Verbesserungsvorschlaegen fuer das Folgejahr.
  * Planung der weiteren Betreuung, Wartung und Anbindung an fuehrende Systeme.

### 10.2. Kostenaufstellung
* **Softwarelizenzen: 0,- Euro.** Saemtliche verwendeten Werkzeuge (Python, Streamlit, R, SQLite, Pandas) sind freie Open-Source-Software ohne Arbeitsplatzgebuehren.
* **Serverkosten: 0,- Euro.** Die Anwendung laeuft lokal auf vorhandenen Buero-PCs oder im Firmennetzwerk (100 % DSGVO-konform, keine Datenuebertragung an Drittanbieter).
* **Personalkosten:** Werkstudentenverguetung (ca. 14 bis 16 Euro/Stunde bei 20 Wochenstunden = ca. 1.200 bis 1.400 Euro brutto/Monat).
  Fuer ein Jahr entspricht dies bei 12 Monaten ungefaehr 14.400 bis 16.800 Euro brutto
  beziehungsweise bei einer Berechnung mit 52 Wochen etwa 14.560 bis 16.640 Euro.

### 10.3. Return on Investment (ROI)
Ein Montageausfall im Handwerk (z. B. zwei Monteure fahren zu einer Baustelle, auf der die Glaselemente fehlen) verursacht durch Ruestzeiten, Fahrzeiten und Reklamationsbearbeitung unproduktive Kosten von mehreren hundert bis ueber tausend Euro. Bei einer mindestens einjaehrigen Beschaeftigung wird der ROI nicht nur durch die erste vermiedene Fehlfahrt betrachtet. Entscheidend ist die kumulierte Wirkung aus vermiedenen Leerlaufzeiten, weniger Such- und Telefonieraufwand, besserer Terminplanung und einer kontinuierlichen Verbesserung des Risikomodells.

Die Investition kann sich innerhalb des ersten Jahres amortisieren, wenn das System beispielsweise regelmaessig unproduktive Montagefahrten verhindert oder den Bauleitern taeglich Koordinationsaufwand erspart. Der laengere Zeitraum ist zudem wirtschaftlich sinnvoll, weil erst ueber mehrere Monate ausreichend reale Projektdaten gesammelt werden, um die KI-Fruehwarnung zu kalibrieren und die Verbesserung gegenueber dem Ausgangszustand belastbar zu messen.

---

*Dokumentation vollstaendig erstellt fuer Handwerkerhaus Hanshans Projektboard & KI.*
