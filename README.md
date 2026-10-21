# Hanshans Project Board & AI Prototype

## English

This repository contains a prototype project board for Handwerkerhaus Hanshans.
It includes a simple R Shiny dashboard, an R Shiny dashboard with SQLite and
AI risk analysis, and a Python Streamlit dashboard.

### Folder structure

- `app.py`, `database.py`: Python Streamlit application and SQLite helper
- `dashboard_simple.r`: simple R Shiny application using CSV data
- `dashboard_pro_ki.r`: R Shiny application using SQLite data
- `hanshans.db`: SQLite database
- `*.csv`: project data
- `archive/`: archive data used by the SQL dashboards
- `requirements.txt`: Python dependencies
- `install_packages.R`: R dependency installer

Data files may be stored beside the app scripts or in a `data/` subfolder.

### Installation

Python:

```text
python -m venv .venv
.venv\Scripts\activate
python -m pip install -r requirements.txt
```

R:

```r
source("install_packages.R")
```

### Run

Python:

```text
python -m streamlit run app.py
```

Simple R dashboard:

```r
Rscript dashboard_simple.r
```

R dashboard with SQLite and AI analysis:

```r
Rscript dashboard_pro_ki.r
```

## Deutsch

Dieses Repository enthält einen Prototyp für ein digitales Projektboard der
Handwerkerhaus Hanshans GmbH. Enthalten sind ein einfaches R-Shiny-Dashboard,
ein R-Shiny-Dashboard mit SQLite und KI-Risikoanalyse sowie ein Python-
Streamlit-Dashboard.

### Ordnerstruktur

- `app.py`, `database.py`: Python-Streamlit-Anwendung und SQLite-Hilfsmodul
- `dashboard_simple.r`: einfaches R-Shiny-Dashboard mit CSV-Daten
- `dashboard_pro_ki.r`: R-Shiny-Dashboard mit SQLite-Daten
- `hanshans.db`: SQLite-Datenbank
- `*.csv`: Projektdaten
- `archive/`: Archivdaten für die SQL-Dashboards
- `requirements.txt`: Python-Abhängigkeiten
- `install_packages.R`: Installation der R-Abhängigkeiten

Die Datendateien können neben den App-Skripten oder in einem Unterordner
`data/` liegen.

### Installation

Python:

```text
python -m venv .venv
.venv\Scripts\activate
python -m pip install -r requirements.txt
```

R:

```r
source("install_packages.R")
```

### Start

Python:

```text
python -m streamlit run app.py
```

Einfaches R-Dashboard:

```r
Rscript dashboard_simple.r
```

R-Dashboard mit SQLite und KI-Analyse:

```r
Rscript dashboard_pro_ki.r
```
