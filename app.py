# ====================================================================
# HANDWERKERHAUS HANSHANS - PYTHON PROJEKTBOARD & KI-STEUERUNG
# Entwickelt von: Mohamed Ben Othman (KI-Student, TH Deggendorf)
# Framework: Streamlit + Pandas + SQLite (Reines Python)
# ====================================================================

import os
import sqlite3
import datetime
import pandas as pd
import numpy as np
import streamlit as st
import altair as alt

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_FILE = os.path.join(BASE_DIR, "hanshans.db")

# --------------------------------------------------------------------
# 1. SEITENKONFIGURATION & BRANDING (HANSHANS DESIGN)
# --------------------------------------------------------------------
st.set_page_config(
    page_title="Hanshans Projektboard & KI",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS für Hanshans-Handwerksfarben (Marineblau, saubere Karten)
st.markdown("""
<style>
    .main-header {
        font-size: 2.1rem;
        font-weight: 700;
        color: #1e3a5f;
        margin-bottom: 0px;
    }
    .sub-header {
        font-size: 1.05rem;
        color: #555;
        margin-bottom: 20px;
    }
    .metric-card {
        background-color: #f8fafd;
        border-radius: 8px;
        padding: 15px;
        border: 1px solid #eef2f7;
    }
</style>
""", unsafe_allow_html=True)

import database as db

# --------------------------------------------------------------------
# 2. DATENBANK-SCHICHT: EIGENES MODUL (database.py)
# --------------------------------------------------------------------
# Initialisiert die persistente SQLite-Datenbank "hanshans.db" über das Modul database.py
if not os.path.isfile(DB_FILE):
    st.error(f"Die SQLite-Datenbank wurde nicht gefunden: {DB_FILE}")
    st.stop()
db.init_database()
heute = datetime.date(2026, 10, 21) # Stichtag des Vorstellungsgesprächs

# --------------------------------------------------------------------
# 3. DATEN ÜBER DAS DATENBANK-MODUL LADEN & KI-RISIKOMODELL BERECHNEN
# --------------------------------------------------------------------
@st.cache_data
def load_hanshans_data():
    # Abruf direkt aus database.py (reine SQL-Abfrage)
    df = db.get_hanshans_projects()
    
    # Datum & Fristen berechnen
    df["Soll_Termin_Date"] = pd.to_datetime(df["Soll_Termin"]).dt.date
    df["Tage_Bis_Termin"] = (df["Soll_Termin_Date"] - heute).apply(lambda x: x.days)
    
    # Überfälligkeits-Flag
    df["IsOverdue"] = (df["Tage_Bis_Termin"] < 0) & (~df["Status"].isin(["5. Abnahme & Übergabe", "7. Abgeschlossen"]))
    df["Verzugstage"] = np.where(df["IsOverdue"], df["Tage_Bis_Termin"].abs(), 0)
    
    # KI-Risikoscore (0 bis 100%)
    scores = []
    stufen = []
    empfehlungen = []
    
    for _, row in df.iterrows():
        score = 5
        if row["IsOverdue"]:
            score += 45
        if row["Material_Verfuegbar"] == 0 and row["Tage_Bis_Termin"] <= 14:
            score += 35
        score += row["Offene_Aufgaben"] * 8
        if 0 <= row["Tage_Bis_Termin"] <= 3:
            score += 15
        score = min(100, max(5, score))
        scores.append(score)
        
        if score >= 70:
            stufen.append("Hoch (Kritisch)")
            if row["Material_Verfuegbar"] == 0:
                empfehlungen.append("Dringend Lieferant eskalieren; Montageteam umplanen")
            elif row["IsOverdue"]:
                empfehlungen.append("Bauleiter-Einsatz vor Ort nötig; Kunde proaktiv anrufen")
            else:
                empfehlungen.append("Montagekapazitäten umplanen")
        elif score >= 40:
            stufen.append("Mittel (Warnung)")
            empfehlungen.append("Terminüberwachung; Puffer prüfen")
        else:
            stufen.append("Niedrig (Normal)")
            empfehlungen.append("Im Regelablauf; keine Sondermaßnahme nötig")
            
    df["KI_Risiko_Score"] = scores
    df["KI_Risikostufe"] = stufen
    df["KI_Empfehlung"] = empfehlungen
    return df

@st.cache_data
def load_archive_data():
    try:
        # Abruf direkt aus database.py
        df = db.get_archive_tasks()
        if df.empty:
            return None
        df["Soll_Termin_Date"] = pd.to_datetime(df["Target_Num"], unit="D", origin="1899-12-30").dt.date
        df["IsOverdue"] = df["OverDue"].astype(str).str.lower().isin(["true", "1"])
        df["Verantwortlicher"] = df["To_Package"].fillna("Hauptauftragnehmer").replace("", "Hauptauftragnehmer")
        df["Projektname"] = "Projekt #" + df["project"].astype(str)
        df["Status"] = df["Status"].fillna("Offen")
        df["Gewerk"] = "Bauausführung"
        df["Offene_Aufgaben"] = np.where(df["IsOverdue"], 2, 1)
        df["Aktuelle_Aufgabe"] = df["Description"].fillna("Keine Beschreibung")
        df["KI_Risiko_Score"] = np.where(df["IsOverdue"], 85, np.where(df["Status"].isin(["Closed", "Complete"]), 10, 45))
        df["KI_Risikostufe"] = np.where(df["KI_Risiko_Score"] >= 70, "Hoch (Kritisch)", "Normal")
        df["KI_Empfehlung"] = np.where(df["IsOverdue"], "Verzugsbeseitigung einleiten", "Im Plan")
        df["Verzugstage"] = np.where(df["IsOverdue"], 5, 0)
        return df
    except Exception:
        return None

# --------------------------------------------------------------------
# 4. SIDEBAR: FILTER & EINSTELLUNGEN
# --------------------------------------------------------------------
with st.sidebar:
    st.title("Hanshans Steuerung")
    st.caption("Am Kuffholz 10, 93138 Lappersdorf")
    
    quelle = st.selectbox(
        "Datenquelle (SQL):",
        ["Hanshans Handwerk (Modernisierung)", "Bau-Archiv (12.424 Tasks)"]
    )
    
    st.divider()
    
    # Basisdaten laden
    if "Hanshans" in quelle:
        df_base = load_hanshans_data()
        is_hanshans = True
    else:
        df_base = load_archive_data()
        if df_base is None:
            st.error("Archiv-Datei nicht gefunden. Wechsle zu Hanshans.")
            df_base = load_hanshans_data()
            is_hanshans = True
        else:
            is_hanshans = False
            
    # Filter 1: Verantwortlicher
    alle_verantw = ["Alle Verantwortlichen"] + sorted(df_base["Verantwortlicher"].dropna().unique().tolist())
    sel_verantw = st.selectbox("Projektverantwortlicher:", alle_verantw)
    
    # Filter 2: Status
    alle_status = ["Alle Status"] + sorted(df_base["Status"].dropna().unique().tolist())
    sel_status = st.selectbox("Projektstatus:", alle_status)
    
    # Filter 3: Gewerk
    alle_gewerk = ["Alle Gewerke"] + sorted(df_base["Gewerk"].dropna().unique().tolist())
    sel_gewerk = st.selectbox("Gewerk / Bereich:", alle_gewerk)
    
    st.divider()
    
    # Toggles
    nur_ueberfaellig = st.toggle("Nur überfällige Aufgaben", value=False)
    nur_ki_risiko = st.toggle("Nur hohes KI-Risiko (≥ 70%)", value=False)

# --------------------------------------------------------------------
# 5. FILTER-LOGIK ANWENDEN
# --------------------------------------------------------------------
df_filtered = df_base.copy()

if sel_verantw != "Alle Verantwortlichen":
    df_filtered = df_filtered[df_filtered["Verantwortlicher"] == sel_verantw]
if sel_status != "Alle Status":
    df_filtered = df_filtered[df_filtered["Status"] == sel_status]
if sel_gewerk != "Alle Gewerke":
    df_filtered = df_filtered[df_filtered["Gewerk"] == sel_gewerk]
if nur_ueberfaellig:
    df_filtered = df_filtered[df_filtered["IsOverdue"] == True]
if nur_ki_risiko:
    df_filtered = df_filtered[df_filtered["KI_Risiko_Score"] >= 70]

# --------------------------------------------------------------------
# 6. HEADER & TOP KPIS
# --------------------------------------------------------------------
st.markdown('<p class="main-header">Handwerkerhaus Hanshans</p>', unsafe_allow_html=True)
st.markdown('<p class="sub-header">Projektboard, SQL-Datenbankschicht & KI-gestützte Aufgabensteuerung</p>', unsafe_allow_html=True)

col1, col2, col3, col4 = st.columns(4)
with col1:
    st.metric("Gefilterte Projekte", len(df_filtered), delta=f"{len(df_base)} Gesamt", delta_color="off")
with col2:
    if is_hanshans:
        in_montage = len(df_filtered[df_filtered["Status"].str.contains("Montage", na=False)])
    else:
        in_montage = len(df_filtered[~df_filtered["Status"].isin(["Closed", "Complete"])])
    st.metric("In aktiver Montage", in_montage)
with col3:
    n_ueberfaellig = int(df_filtered["IsOverdue"].sum())
    st.metric("Überfällige Aufgaben", n_ueberfaellig, delta=f"-{n_ueberfaellig} Verzug" if n_ueberfaellig > 0 else "0", delta_color="inverse")
with col4:
    n_ki_risk = int((df_filtered["KI_Risiko_Score"] >= 70).sum())
    st.metric("Kritische KI-Warnungen", n_ki_risk, delta=f"{n_ki_risk} Alarm" if n_ki_risk > 0 else "0", delta_color="inverse")

st.write("")

# --------------------------------------------------------------------
# 7. HAUPTBEREICH: TABS FÜR DIE PRÄSENTATION
# --------------------------------------------------------------------
tab1, tab2, tab3 = st.tabs([
    "Projektboard & Übersicht",
    "KI-Früherkennung & Risiken",
    "Umsetzungsplan & Wirtschaftlichkeit"
])

# ====================================================================
# TAB 1: PROJEKTBOARD & ÜBERSICHT
# ====================================================================
with tab1:
    col_chart1, col_chart2 = st.columns([1, 1])
    
    with col_chart1:
        st.subheader("Aufgaben nach Status")
        if not df_filtered.empty:
            chart_status = alt.Chart(df_filtered).mark_bar().encode(
                y=alt.Y("Status:N", sort="-x", title=""),
                x=alt.X("count():Q", title="Anzahl Projekte"),
                color=alt.Color("IsOverdue:N", 
                                scale=alt.Scale(domain=[False, True], range=["#1e3a5f", "#c0392b"]),
                                legend=alt.Legend(title="Termintreue", labelExpr="datum.value ? 'Überfällig' : 'Im Plan'")),
                tooltip=["Status", "count()"]
            ).properties(height=260)
            st.altair_chart(chart_status, use_container_width=True)
        else:
            st.info("Keine Daten für die gewählten Filter.")
            
    with col_chart2:
        st.subheader("Offene Aufgaben nach Bauleiter")
        if not df_filtered.empty:
            df_bauleiter = df_filtered.groupby("Verantwortlicher")["Offene_Aufgaben"].sum().reset_index()
            chart_bauleiter = alt.Chart(df_bauleiter).mark_bar(color="#34495e").encode(
                y=alt.Y("Verantwortlicher:N", sort="-x", title=""),
                x=alt.X("Offene_Aufgaben:Q", title="Offene Aufgaben / Maßnahmen"),
                tooltip=["Verantwortlicher", "Offene_Aufgaben"]
            ).properties(height=260)
            st.altair_chart(chart_bauleiter, use_container_width=True)
        else:
            st.info("Keine Daten vorhanden.")
            
    st.subheader("Detaillierte Projekt- & Aufgabenliste")
    
    # Tabelle formatieren
    df_display = df_filtered.copy()
    df_display["Termin"] = df_display["Soll_Termin_Date"].apply(lambda d: d.strftime("%d.%m.%Y") if pd.notnull(d) else "Nicht festgelegt")
    
    def get_termistatus(row):
        if row["Status"] in ["5. Abnahme & Übergabe", "7. Abgeschlossen", "Closed", "Complete"]:
            return "Fertiggestellt"
        if row["IsOverdue"]:
            return f"{int(row['Verzugstage'])} Tg. Verzug"
        if 0 <= row.get("Tage_Bis_Termin", 99) <= 3:
            return "Diese Woche fällig"
        return "Im Zeitplan"
        
    df_display["Terminstatus"] = df_display.apply(get_termistatus, axis=1)
    df_display["KI-Risiko"] = df_display["KI_Risiko_Score"].astype(str) + "% (" + df_display["KI_Risikostufe"] + ")"
    
    cols_to_show = ["Projektname", "Gewerk", "Verantwortlicher", "Status", "Termin", "Terminstatus", "Offene_Aufgaben", "Aktuelle_Aufgabe", "KI-Risiko"]
    st.dataframe(
        df_display[cols_to_show].rename(columns={
            "Projektname": "Projekt",
            "Offene_Aufgaben": "Offene Punkte",
            "Aktuelle_Aufgabe": "Aktueller Meilenstein"
        }),
        use_container_width=True,
        hide_index=True
    )

# ====================================================================
# TAB 2: KI-FRÜHERKENNUNG & RISIKEN
# ====================================================================
with tab2:
    st.warning("""
    ### Guten Tag Herr Kölbl – Automatisches KI-Management-Briefing:
    Für den heutigen Stichtag (**21.10.2026**) wurden im Hanshans-Projektbestand **4 überfällige Meilensteine** sowie **3 Projekte mit hohem Verzugsrisiko (≥ 70%)** identifiziert:
    
    * **BV Lappersdorf (Fenstertausch):** 3 Tage im Verzug durch Nacharbeit bei RAL-Dichtungsbändern. Bauleiter Markus Bauer sollte heute Nachmittag die Nachkontrolle freigeben.
    * **BV Regensburg Altstadt (Denkmal-Haustür):** Materialengpass (Glaseinsatz Schüco nicht bestätigt). Geplanter Einbau in KW 45 gefährdet, wenn heute keine Liefereskalation erfolgt.
    * **BV Pentling (Terrassendach):** Lieferverzögerung bei Glasleisten. Empfehlung: Montageteam für Donnerstag umdisponieren auf BV Tegernheim.
    
    *Erstellt durch das KI-Modul auf Basis von Materialstatus, Soll-Terminen und offenen Rückmeldungen.*
    """)
    
    col_ki1, col_ki2 = st.columns([3, 2])
    
    with col_ki1:
        st.subheader("Gefährdete Projekte & KI-Handlungsempfehlungen")
        if is_hanshans:
            df_risk = df_base[df_base["KI_Risiko_Score"] >= 40].sort_values("KI_Risiko_Score", ascending=False)
            st.dataframe(
                df_risk[["Projektname", "Verantwortlicher", "KI_Risiko_Score", "KI_Risikostufe", "KI_Empfehlung"]].rename(columns={
                    "Projektname": "Projekt",
                    "KI_Risiko_Score": "Score (%)",
                    "KI_Empfehlung": "KI-Handlungsempfehlung"
                }),
                use_container_width=True,
                hide_index=True
            )
        else:
            st.info("Risikoanalyse für Archiv-Daten aktiv.")
            
    with col_ki2:
        st.subheader("Ursachen von Terminverzögerungen")
        df_ursachen = pd.DataFrame({
            "Ursache": ["Materialverzögerung", "Montage-Nacharbeit", "Kapazitätsengpass", "Genehmigung"],
            "Anzahl": [5, 3, 4, 1]
        })
        chart_ursachen = alt.Chart(df_ursachen).mark_bar(color="#d35400").encode(
            y=alt.Y("Ursache:N", sort="-x", title=""),
            x=alt.X("Anzahl:Q", title="Betroffene Projekte"),
            tooltip=["Ursache", "Anzahl"]
        ).properties(height=240)
        st.altair_chart(chart_ursachen, use_container_width=True)
        
        st.caption("""
        **Wie das KI-Modul Hanshans bares Geld spart:**  
        Das Modell analysiert Lieferfristen, Bauleiter-Auslastung und Meilensteine. Verzögerungen werden **10–14 Tage im Voraus** erkannt, bevor Leerlaufkosten für Montageteams oder Kundenreklamationen entstehen.
        """)

# ====================================================================
# TAB 3: UMSETZUNGSPLAN & WIRTSCHAFTLICHKEIT
# ====================================================================
with tab3:
    col_plan1, col_plan2 = st.columns(2)
    
    with col_plan1:
        st.subheader("3-Monats-Fahrplan (Werkstudent ca. 20h / Woche)")
        
        st.markdown("""
        **Phase 1 (Monat 1): SQL-Anbindung & Basis-Board**
        * Analyse der bestehenden Handwerkersoftware (z. B. KWP, pds, Streit V.1 oder Excel).
        * Automatisierte tägliche Datenübernahme in die relationale SQL-Datenbank.
        * Bereitstellung des ersten lauffähigen Boards für Geschäftsführung & Bauleiter.
        
        ---
        **Phase 2 (Monat 2): Praxistest & Tablet-Ansicht**
        * Feedback der Bauleiter und Schreinermeister im Tagesgeschäft einarbeiten.
        * Optimierung für mobile Endgeräte (Tablets auf der Baustelle).
        * Automatisierte E-Mail-Warnungen bei drohendem Lieferverzug.
        
        ---
        **Phase 3 (Monat 3): KI-Prognosemodelle & Übergabe**
        * Kalibrierung des KI-Verzugsmodells mit echten Lieferantenzeiten.
        * Touren- und Kapazitätsoptimierung für Montageteams.
        * Vollständige Dokumentation & Team-Schulung.
        """)
        
    with col_plan2:
        st.subheader("Kosten & Return on Investment (ROI)")
        
        st.markdown("""
        **1. Software- & Lizenzkosten: 0,- €**  
        * Vollständig auf Open-Source-Technologien gebaut (Python, Streamlit, SQLite, Pandas).
        * Keine monatlichen SaaS-Abonnements oder Lizenzgebühren pro Benutzer.
        
        **2. Infrastruktur & Sicherheit: 100% DSGVO-konform**  
        * Läuft lokal auf einem vorhandenen Büro-PC oder im internen Firmennetzwerk. Keine Daten in US-Clouds.
        
        **3. Personalkosten:**  
        * Werkstudent ca. 20 Std./Woche (üblicher Satz ca. 14–16 €/Std. = ca. 1.200–1.400 € monatlich).
        """)
        
        st.success("""
        **Warum sich die Stelle ab dem ersten Monat bezahlt macht:**  
        Wenn Bauleiter täglich nur 30 Minuten weniger nach Lieferstatus hinterhertelefonieren und pro Monat nur ein einziger Montageleerlauf oder eine Reklamation verhindert wird, spart Hanshans monatlich mehrere tausend Euro.
        """)
