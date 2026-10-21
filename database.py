# ====================================================================
# HANDWERKERHAUS HANSHANS - DEDICATED DATABASE LAYER (SQL)
# Modul: database.py
# Zweck: Verwaltet die relationale SQLite-Datenbank "hanshans.db",
#        Daten-Importe, Tabellenschemata und SQL-Abfragen getrennt von der UI.
# ====================================================================

import os
import sqlite3
import pandas as pd

# Pfad zur persistenten Datenbankdatei
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_FILE = os.path.join(BASE_DIR, "hanshans.db")
HANSHANS_CSV = os.path.join(BASE_DIR, "hanshans_projekte_stammdaten.csv")
ARCHIVE_CSV = os.path.join(BASE_DIR, "archive", "Construction_Data_PM_Tasks_All_Projects.csv")


def get_connection():
    """
    Stellt eine Verbindung zur persistenten SQLite-Datenbankdatei her.
    check_same_thread=False erlaubt thread-übergreifende Abfragen in Streamlit.
    """
    if not os.path.isfile(DB_FILE):
        raise FileNotFoundError(
            f"Die SQLite-Datenbank wurde nicht gefunden: {DB_FILE}"
        )
    return sqlite3.connect(DB_FILE, check_same_thread=False)


def init_database(force_recreate=False):
    """
    Initialisiert die Datenbanktabellen aus den externen CSV-Dateien.
    Wird nur ausgeführt, wenn die Datenbank noch nicht existiert oder force_recreate=True ist.
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    # 1. Tabelle hanshans_projekte aufbauen
    if os.path.exists(HANSHANS_CSV):
        df_hh = pd.read_csv(HANSHANS_CSV)
        df_hh.to_sql("hanshans_projekte", conn, if_exists="replace", index=False)
        
        # Performance-Indizes für schnelle Filterung in der Web-App anlegen
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_hh_status ON hanshans_projekte(Status);")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_hh_verantw ON hanshans_projekte(Verantwortlicher);")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_hh_gewerk ON hanshans_projekte(Gewerk);")
    
    # 2. Tabelle archive_tasks aufbauen (falls Archivdaten vorhanden sind)
    if os.path.exists(ARCHIVE_CSV):
        df_arch = pd.read_csv(ARCHIVE_CSV, low_memory=False)
        df_arch["Target_Num"] = pd.to_numeric(df_arch["Target"], errors="coerce")
        df_arch_clean = df_arch.dropna(subset=["Target_Num"])[
            ["project", "To Package", "Status", "Target_Num", "OverDue", "Description"]
        ]
        df_arch_clean.to_sql("archive_tasks", conn, if_exists="replace", index=False)
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_arch_project ON archive_tasks(project);")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_arch_status ON archive_tasks(Status);")
        
    conn.commit()
    conn.close()
    return True


def get_hanshans_projects():
    """
    Ruft alle Projekte der Firma Hanshans per SQL-Query sortiert nach Soll-Termin ab.
    """
    conn = get_connection()
    query = """
        SELECT 
            ProjektID,
            Projektname,
            Gewerk,
            Verantwortlicher,
            Status,
            Soll_Termin,
            Offene_Aufgaben,
            Aktuelle_Aufgabe,
            Material_Verfuegbar
        FROM hanshans_projekte
        ORDER BY Soll_Termin ASC
    """
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df


def get_archive_tasks():
    """
    Ruft die bereinigten Bau-Archivdaten per SQL-Query ab.
    """
    conn = get_connection()
    try:
        query = """
            SELECT 
                project, 
                `To Package` AS To_Package, 
                Status, 
                Target_Num, 
                OverDue, 
                Description 
            FROM archive_tasks
        """
        df = pd.read_sql_query(query, conn)
    except Exception:
        df = pd.DataFrame()
    finally:
        conn.close()
    return df


def execute_custom_query(sql_query, params=None):
    """
    Erlaubt das Ausführen beliebiger SQL-Abfragen für spätere Erweiterungen.
    """
    conn = get_connection()
    if params:
        df = pd.read_sql_query(sql_query, conn, params=params)
    else:
        df = pd.read_sql_query(sql_query, conn)
    conn.close()
    return df


if __name__ == "__main__":
    print("Initialisiere Datenbank:", DB_FILE)
    init_database(force_recreate=True)
    df_test = get_hanshans_projects()
    print("Erfolgreich initialisiert! Anzahl geladener Hanshans-Projekte:", len(df_test))
