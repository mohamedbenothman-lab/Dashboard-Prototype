# Comprehensive Technical Documentation & Code Explanation

**Project:** Handwerkerhaus Hanshans - Project Board, SQL Database & AI-Powered Task Management  
**Author:** Mohamed Ben Othman (Artificial Intelligence Student, TH Deggendorf)  
**Location:** `C:\Users\mdhia\OneDrive\Bureau\dashboard`

---

## Table of Contents
1. [Executive Summary & Architecture](#1-executive-summary--architecture)
2. [Folder & File Structure](#2-folder--file-structure)
3. [The Business Context & Requirements](#3-the-business-context--requirements)
4. [Python Dashboard Explanation (`app.py`)](#4-python-dashboard-explanation-apppy)
   - [Imports & Page Setup](#41-imports--page-setup)
   - [Database Layer: SQLite & Data Ingestion](#42-database-layer-sqlite--data-ingestion)
   - [SQL Queries & Feature Engineering](#43-sql-queries--feature-engineering)
   - [The AI Risk-Scoring Engine](#44-the-ai-risk-scoring-engine)
   - [Sidebar, Filtering & Dynamic State](#45-sidebar-filtering--dynamic-state)
   - [KPI Cards & Visual Analytics (Altair)](#46-kpi-cards--visual-analytics-altair)
   - [Tab Structure & Interactive UI](#47-tab-structure--interactive-ui)
5. [R Shiny Dashboards Explanation](#5-r-shiny-dashboards-explanation)
   - [`dashboard_simple.r` (Minimal 80-line version)](#51-dashboard_simpler-minimal-version)
   - [`dashboard_pro_ki.r` (Advanced SQL & AI version)](#52-dashboard_pro_kir-advanced-sql--ai-version)
   - [`dashboard_archive.r` (Raw Kaggle Construction Tasks)](#53-dashboard_archiver-raw-kaggle-data-version)
6. [Data Schema & File Formats](#6-data-schema--file-formats)
7. [How to Run Everything](#7-how-to-run-everything)
8. [Interview Cheat-Sheet (English Speaking Points)](#8-interview-cheat-sheet-english-speaking-points)

---

## 1. Executive Summary & Architecture

The system is designed as a **digital control center** for medium-sized craft, renovation, and modernization companies like **Handwerkerhaus Hanshans** (specializing in windows, entrance doors, sun protection, and patio roofs in the Regensburg / Lappersdorf area).

```
┌────────────────────────────────────────────────────────────────────────┐
│                          SYSTEM ARCHITECTURE                           │
├────────────────────────────────┬───────────────────────────────────────┤
│ 1. DATA LAYER                  │ - hanshans_projekte_stammdaten.csv    │
│    (External Flat Files)       │ - projekte_hanshans.csv               │
│                                │ - archive/*.csv (12k raw tasks)       │
├────────────────────────────────┼───────────────────────────────────────┤
│ 2. DATABASE / SQL LAYER        │ - In-Memory Relational Database       │
│    (Persistent / Structured)   │ - Python: sqlite3                     │
│                                │ - R: DBI + RSQLite                    │
├────────────────────────────────┼───────────────────────────────────────┤
│ 3. ANALYTICS & AI LAYER        │ - Overdue & Milestone Aging           │
│    (Predictive Risk Engine)    │ - Bottleneck & Supplier Delay Models  │
│                                │ - Predictive AI Risk Score (0-100%)   │
├────────────────────────────────┼───────────────────────────────────────┤
│ 4. PRESENTATION LAYER          │ - Option A: Python (Streamlit)        │
│    (Interactive Dashboards)    │ - Option B: R (Shiny + bslib + DT)    │
└────────────────────────────────┴───────────────────────────────────────┘
```

---

## 2. Folder & File Structure

All files reside in: `C:\Users\mdhia\OneDrive\Bureau\dashboard`

| File | Language | Purpose |
| :--- | :--- | :--- |
| **`database.py`** | Python | **Dedicated Database Layer:** Manages the SQLite database `hanshans.db`, handles table creation, indexing, and pure SQL queries (`SELECT ... FROM ...`) decoupled from the UI. |
| **`hanshans.db`** | SQLite | Persistent relational database file containing tables `hanshans_projekte` and `archive_tasks`. Shared by both Python and R! |
| **`app.py`** | Python | Main Python dashboard using **Streamlit**, **Pandas**, and **Altair**. Imports `database.py` to display KPIs, charts, and AI risk prediction. |
| **`start_python_dashboard.bat`** | Batch | 1-click Windows launcher. Double-clicking starts the Streamlit dashboard in your default browser. |
| **`dashboard_simple.r`** | R | Clean, minimal ~80-line Shiny dashboard. Reads `projekte_hanshans.csv` directly. Ideal for a simple, non-technical walkthrough. |
| **`dashboard_pro_ki.r`** | R | Advanced Shiny dashboard with SQL (`DBI` + `RSQLite`), connects directly to `hanshans.db`, AI risk scores, and roadmap. |
| **`dashboard_archive.r`** | R | Standalone dashboard reading directly from `archive/Construction_Data_PM_Tasks_All_Projects.csv` (2,568 tasks with deadlines). |
| **`hanshans_projekte_stammdaten.csv`** | CSV | Master dataset for the SQL database (16 Hanshans projects: windows, doors, sun protection). |
| **`projekte_hanshans.csv`** | CSV | Streamlined CSV dataset used by `dashboard_simple.r`. |
| **`archive/`** | Directory | Contains the original raw construction CSV files (12,424 tasks). |
| **`LEITFADEN_GESPRAECH.md`** | Markdown | German interview guide and talking points for the meeting with Tobias Kölbl. |
| **`CODE_EXPLANATION.md`** | Markdown | This file: complete English technical documentation. |

---

## 3. The Business Context & Requirements

Managing Director **Tobias Kölbl** explicitly requested 4 key dimensions in his email:
1. **Project Status (`Projektstatus`):** Where does the project currently stand? (Planning, Material Ordered, Scheduled, In Assembly, Accepted).
2. **Project Manager (`Projektverantwortlicher`):** Who is responsible on the ground? (Site Managers / Master Craftsmen: Markus Bauer, Stefan Huber, Christian Schmidt, Tobias Weber).
3. **Deadlines & Dates (`Termine`):** When must the milestone be delivered? Real calendar dates (`DD.MM.YYYY`) and ISO calendar weeks (`KW`).
4. **Overdue Tasks (`Überfällige Aufgaben`):** What is running late? How many days of delay? Clear color alerts (Red = Critical, Green = On Track).

In addition, since the role is **"Working Student - Project Board & AI"**, the dashboard provides a **Predictive AI Risk Engine** to transition from reactive reporting to proactive early warning.

---

## 4. Python Dashboard Explanation (`app.py`)

### 4.1. Imports & Page Setup

```python
import os
import sqlite3
import datetime
import pandas as pd
import numpy as np
import streamlit as st
import altair as alt
```

- **`sqlite3`**: Python's native relational SQL database engine (no external server required).
- **`pandas` & `numpy`**: Vectorized data manipulation, date operations, and mathematical calculations.
- **`streamlit`**: Rapid web application framework that transforms Python scripts into interactive browser dashboards.
- **`altair`**: Declarative statistical visualization library used for clean, modern charts.

```python
st.set_page_config(
    page_title="Hanshans Projektboard & KI",
    page_icon="",
    layout="wide",
    initial_sidebar_state="expanded"
)
```
- Sets the browser tab title, favicon, and enforces a **wide layout** so that charts and tables fit comfortably on standard office monitors.

---

### 4.2. Database Layer: Decoupled Architecture (`database.py` & `hanshans.db`)

Instead of embedding raw database setup inside the UI code, the data logic is decoupled into a dedicated module: **`database.py`**.

```python
# In database.py:
def get_connection():
    return sqlite3.connect("hanshans.db", check_same_thread=False)

def init_database(force_recreate=False):
    conn = get_connection()
    # Ingest CSVs into persistent SQL tables with performance indexes
    df_hh = pd.read_csv("hanshans_projekte_stammdaten.csv")
    df_hh.to_sql("hanshans_projekte", conn, if_exists="replace", index=False)
    conn.commit()
    conn.close()

def get_hanshans_projects():
    conn = get_connection()
    query = "SELECT * FROM hanshans_projekte ORDER BY Soll_Termin ASC"
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df
```

Then in **`app.py`** (the platform UI), the implementation is as clean as:
```python
import database as db

# Initialize the persistent database
db.init_database()

# Load projects directly through pure SQL abstraction
df = db.get_hanshans_projects()
```

#### Why Decouple Database into `database.py`?
1. **Separation of Concerns:** UI code (`app.py`) only manages user interaction, filters, and rendering. The data access layer (`database.py`) manages SQL schemas, connections, and migrations.
2. **Shared Persistence:** The SQLite database `hanshans.db` is saved on disk. Both **Python (`app.py`)** and **R (`dashboard_pro_ki.r`)** connect to this exact same database file simultaneously!
3. **Enterprise Migration Ready:** When Hanshans switches to a live SQL Server (PostgreSQL, MySQL, or KWP ERP database), you only update `database.py`'s connection function—the entire Streamlit dashboard continues to work without touching a single line of UI code.

---

### 4.3. SQL Queries & Feature Engineering

```python
query = """
    SELECT 
        ProjektID, Projektname, Gewerk, Verantwortlicher, Status,
        Soll_Termin, Offene_Aufgaben, Aktuelle_Aufgabe, Material_Verfuegbar
    FROM hanshans_projekte
    ORDER BY Soll_Termin ASC
"""
df = pd.read_sql_query(query, conn)
```

Once loaded via SQL, the code computes the following calculated columns:
- **`Tage_Bis_Termin` (Days until deadline):**
  $$\text{Tage\_Bis\_Termin} = \text{Soll\_Termin} - \text{heute}$$
- **`IsOverdue` (Boolean flag):**
  $$\text{IsOverdue} = (\text{Tage\_Bis\_Termin} < 0) \land (\text{Status} \notin \{\text{"5. Abnahme \& Übergabe"}, \text{"7. Abgeschlossen"}\})$$
- **`Verzugstage` (Days of delay):** Absolute value of negative buffer days.

---

### 4.4. The AI Risk-Scoring Engine

Instead of merely checking if an item is *already* overdue, the algorithm computes a **Predictive Risk Score (0% to 100%)**:

```python
score = 5 # Baseline minimum risk

# Factor 1: Already overdue?
if row["IsOverdue"]:
    score += 45

# Factor 2: Material missing with deadline approaching (<= 14 days)?
if row["Material_Verfuegbar"] == 0 and row["Tage_Bis_Termin"] <= 14:
    score += 35

# Factor 3: Open action items penalty (8% per open task)
score += row["Offene_Aufgaben"] * 8

# Factor 4: Tight buffer penalty (Due within 3 days)
if 0 <= row["Tage_Bis_Termin"] <= 3:
    score += 15

score = min(100, max(5, score))
```

#### Categorization & Next Best Action:
- **`Score >= 70%` (Critical / Red):** Triggers specific actionable recommendations:
  - Missing material: *"Dringend Lieferant eskalieren; Montageteam umplanen"*
  - Overdue: *"Bauleiter-Einsatz vor Ort nötig; Kunde proaktiv anrufen"*
- **`40% <= Score < 70%` (Warning / Amber):** *"Terminüberwachung; Puffer prüfen"*
- **`Score < 40%` (Normal / Green):** *"Im Regelablauf; keine Sondermaßnahme nötig"*

---

### 4.5. Sidebar, Filtering & Dynamic State

In `with st.sidebar:`, users have access to:
1. **Data Source Selector (`st.selectbox`):** Switch between Hanshans Craft Data and the Raw Kaggle Archive (12,424 tasks).
2. **Project Manager (`st.selectbox`):** Dropdown populated dynamically from `df_base["Verantwortlicher"].unique()`.
3. **Status (`st.selectbox`):** Filter by installation stage.
4. **Trade / Category (`st.selectbox`):** Filter by Windows, Doors, Sun Protection, etc.
5. **Toggles (`st.toggle`):** 
   - *"Nur überfällige Aufgaben"* (Only overdue)
   - *"Nur hohes KI-Risiko"* (Only high AI risk)

The filtering logic applies sequential boolean masks to `df_filtered`:
```python
if sel_verantw != "Alle Verantwortlichen":
    df_filtered = df_filtered[df_filtered["Verantwortlicher"] == sel_verantw]
```

---

### 4.6. KPI Cards & Visual Analytics (Altair)

```python
col1, col2, col3, col4 = st.columns(4)
col1.metric("Gefilterte Projekte", len(df_filtered), delta=f"{len(df_base)} Gesamt")
col2.metric("In aktiver Montage", in_montage)
col3.metric("Überfällige Aufgaben", n_ueberfaellig, delta=f"-{n_ueberfaellig} Verzug")
col4.metric("Kritische KI-Warnungen", n_ki_risk, delta=f"{n_ki_risk} Alarm")
```
- Provides an immediate executive summary at the very top of the screen.

```python
chart_status = alt.Chart(df_filtered).mark_bar().encode(
    y=alt.Y("Status:N", sort="-x", title=""),
    x=alt.X("count():Q", title="Anzahl Projekte"),
    color=alt.Color("IsOverdue:N", scale=alt.Scale(domain=[False, True], range=["#1e3a5f", "#c0392b"])),
    tooltip=["Status", "count()"]
)
```
- Horizontal bar chart colored by overdue status (Navy Blue = On Track, Crimson Red = Overdue).

---

### 4.7. Tab Structure & Interactive UI

`st.tabs([...])` partitions the dashboard into three logical areas:
1. **Tab 1: Project Board & Overview:** Interactive Altair charts and a clean `st.dataframe` showing formatted dates, overdue badges, and open action items.
2. **Tab 2: AI Early Warning & Risks:** Contains the automated CEO Executive Briefing and a breakdown of root causes for delays (material lead times, rework, capacity shortages).
3. **Tab 3: Implementation Roadmap & ROI:** Details the 3-month transition plan and proves the 0 € software licensing cost.

---

## 5. R Shiny Dashboards Explanation

### 5.1. `dashboard_simple.r` (Minimal Version)

Designed for absolute simplicity:
- **Lines of code:** ~80 lines.
- **Architecture:** Classic Shiny `fluidPage` with `sidebarLayout(sidebarPanel(), mainPanel())`.
- **Data Loading:** Reads `projekte_hanshans.csv` directly using `read_csv()`.
- **Reactive Engine:** 
  ```r
  gefilterte_daten <- reactive({
    daten <- projekte
    if (input$filter_verantwortlicher != "Alle") {
      daten <- daten %>% filter(Verantwortlicher == input$filter_verantwortlicher)
    }
    # ...
    daten
  })
  ```
  Whenever any dropdown or checkbox changes, `reactive()` invalidates only the affected outputs, triggering recalculation.
- **Outputs:**
  - `renderText`: Renders counts for total, overdue, and open tasks.
  - `renderPlot`: Simple `ggplot2` bar chart with `geom_bar(width = 0.5)`.
  - `renderDT`: Clean interactive HTML table via the `DT` package with red/green conditional styling.

---

### 5.2. `dashboard_pro_ki.r` (Advanced SQL & AI Version)

The enterprise-grade R version:
- **Framework:** `bslib::page_navbar` with modern Bootstrap 5 styling.
- **SQL Backend:**
  ```r
  con <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
  dbWriteTable(con, "hanshans_projekte", raw_hanshans, overwrite = TRUE)
  daten_hanshans_raw <- dbGetQuery(con, "SELECT ... FROM hanshans_projekte")
  ```
- **Lifecycle Management:** Includes `onStop(function() dbDisconnect(con))` to cleanly terminate database connections when the Shiny server stops.
- **Integrated Tabs:** Includes the AI risk scoring tables, dynamic KPI value boxes (`bslib::value_box`), and the complete implementation roadmap.

---

### 5.3. `dashboard_archive.r` (Raw Kaggle Data Version)

Specifically targets `archive/Construction_Data_PM_Tasks_All_Projects.csv`:
- **The Date Conversion Challenge:** Excel serial numbers (e.g., `44094`) are parsed via:
  ```r
  Termin = as.Date(as.numeric(Target), origin = "1899-12-30")
  ```
- **Filters:** Filters out empty tasks, leaving **2,568 structured tasks** and correctly displaying the **858 overdue tasks**.
- Proves your data engineering capability: taking uncleaned raw third-party data and converting it into actionable insights.

---

## 6. Data Schema & File Formats

### `hanshans_projekte_stammdaten.csv` Schema

| Column Name | Data Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `ProjektID` | String | Unique project identifier | `HH-2026-001` |
| `Projektname` | String | Building site & scope description | `BV Lappersdorf - EFH 3-fach Fenstertausch` |
| `Gewerk` | String | Craft trade / product group | `Fensterbau`, `Haustüren`, `Sonnenschutz` |
| `Verantwortlicher` | String | Responsible site manager / craftsman | `Markus Bauer (Bauleitung)` |
| `Status` | String | Current process stage | `4. In Montage vor Ort` |
| `Soll_Termin` | Date (ISO) | Target delivery / completion date | `2026-10-18` |
| `Offene_Aufgaben` | Integer | Count of unresolved checklist items | `3` |
| `Aktuelle_Aufgabe` | String | Critical active milestone description | `Dichtungsbänder RAL-Montage nacharbeiten` |
| `Material_Verfuegbar`| Boolean (0/1) | Whether required materials are on-site | `1` (True) or `0` (False) |

---

## 7. How to Run Everything

### Running the Python Dashboard
**Method 1 (1-Click Launcher):**
- Double-click [`start_python_dashboard.bat`](file:///C:/Users/mdhia/OneDrive/Bureau/dashboard/start_python_dashboard.bat).

**Method 2 (PowerShell):**
```powershell
python -m streamlit run C:\Users\mdhia\OneDrive\Bureau\dashboard\app.py
```

### Running the R Dashboards
**In RStudio:**
- Open any `.r` file (`dashboard_simple.r`, `dashboard_pro_ki.r`, or `dashboard_archive.r`) and click **"Run App"** in the top right corner.

**In PowerShell:**
```powershell
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" -e "shiny::runApp('C:/Users/mdhia/OneDrive/Bureau/dashboard/dashboard_simple.r', launch.browser = TRUE)"
```

---

## 8. Interview Cheat-Sheet (English Speaking Points)

If you need to discuss the architecture or ideas in English, use these concise points:

### 1. High-Level Concept
> *"My goal was to create a digital control cockpit tailored specifically to Hanshans' daily operations. Instead of an abstract software tool, it focuses on four practical questions: **What** is being done (Status), **who** is responsible (Site Manager), **when** is it due (Deadlines), and **where are the bottlenecks** (Overdue Tasks)."*

### 2. Architecture & SQL
> *"The solution is built on a clean three-tier architecture: raw data is stored externally in CSV files, ingested into an in-memory SQL database (`SQLite`), and queried using standard SQL statements (`SELECT`, `WHERE`, `ORDER BY`). In production, this allows us to connect directly to Hanshans' existing ERP or database without changing the frontend code."*

### 3. Dual Technology Stack (Python & R)
> *"As an Artificial Intelligence student at TH Deggendorf, Python is my primary programming language. To demonstrate flexibility, I implemented the dashboard in two industry standards: modern **Python (Streamlit)** and **R (Shiny)**. Both share the exact same relational data model and demonstrate that we are not locked into any single vendor or framework."*

### 4. Transition from Reactive to AI Early Warning
> *"Standard project boards only show what is already late—that's looking in the rearview mirror. As an AI student, my contribution is predictive early warning: the AI risk model evaluates supplier lead times, open tasks, and deadline buffers to flag high-risk projects **10 to 14 days in advance**, allowing site managers to reschedule teams before idle time or penalties occur."*

### 5. Economics & Implementation
> *"The entire software stack is 100% open-source, which means **zero software license fees**. It runs securely inside your local network without external cloud risks, and at 20 hours per week as a working student, the role pays for itself if we prevent just one delayed installation per month."*
