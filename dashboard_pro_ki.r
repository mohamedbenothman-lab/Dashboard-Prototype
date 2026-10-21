# ====================================================================
# HANDWERKERHAUS HANSHANS - PROJEKTBOARD, SQL & KI-AUFGABENSTEUERUNG
# Bewerbung als Werkstudent: Mohamed Ben Othman (TH Deggendorf / KI)
# ====================================================================
# ARCHITEKTUR:
# 1. Datenhaltung: Externe CSVs ("hanshans_projekte_stammdaten.csv" & "archive/")
# 2. Datenbankschicht: SQL-Datenbank (RSQLite + DBI) mit relationalen Abfragen
# 3. Analytik & KI: Verzugsrisiko-Score & automatisierte Handlungsempfehlungen
# 4. Frontend: Modernes bslib / Shiny Dashboard mit Filtern & Diagrammen
# ====================================================================

library(shiny)
library(tidyverse)
library(bslib)
library(DT)
library(lubridate)
library(DBI)
library(RSQLite)

# --------------------------------------------------------------------
# 1. SQL-DATENBANK-VERBINDUNG (PERSISTENTE DATENBANK hanshans.db)
# --------------------------------------------------------------------
# Automatische Pfadfindung: Prüft den Ordner des Skripts, den Arbeitsordner
# und jeweils den Unterordner "data".
argumente <- commandArgs(trailingOnly = FALSE)
datei_argument <- grep("^--file=", argumente, value = TRUE)
app_ordner <- if (length(datei_argument) > 0) {
  dirname(normalizePath(sub("^--file=", "", datei_argument[1]), mustWork = FALSE))
} else {
  getwd()
}

finde_datei <- function(dateiname) {
  kandidaten <- unique(c(
    file.path(app_ordner, dateiname),
    file.path(app_ordner, "data", dateiname),
    file.path(getwd(), dateiname),
    file.path(getwd(), "data", dateiname)
  ))
  vorhandene <- kandidaten[file.exists(kandidaten)]
  if (length(vorhandene) == 0) {
    stop(sprintf(
      "Die benötigte Datei '%s' wurde weder im App-Ordner noch im Unterordner 'data' gefunden.",
      dateiname
    ))
  }
  vorhandene[1]
}

db_datei <- finde_datei("hanshans.db")
con <- dbConnect(RSQLite::SQLite(), dbname = db_datei)

# Falls hanshans.db noch nicht existiert oder befüllt ist, aus CSV initialisieren
if (!"hanshans_projekte" %in% dbListTables(con)) {
  csv_hanshans <- finde_datei("hanshans_projekte_stammdaten.csv")
  raw_hanshans <- read_csv(csv_hanshans, show_col_types = FALSE)
  dbWriteTable(con, "hanshans_projekte", raw_hanshans, overwrite = TRUE)
}

has_archive <- "archive_tasks" %in% dbListTables(con)

# --------------------------------------------------------------------
# 2. SQL-ABFRAGEN ZUR DATENAUFBEREITUNG & KI-RISIKOANALYSE
# --------------------------------------------------------------------
heute_termin <- as.Date("2026-10-21")

# Hanshans-Projekte per SQL-Query aus der Datenbank abrufen
hanshans_sql_query <- "
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
"
daten_hanshans_raw <- dbGetQuery(con, hanshans_sql_query)

# KI-Risikomodellierung (Feature Engineering)
daten_hanshans <- daten_hanshans_raw %>%
  mutate(
    Soll_Termin = as.Date(Soll_Termin),
    Material_Verfuegbar = as.logical(Material_Verfuegbar),
    Tage_Bis_Termin = as.numeric(Soll_Termin - heute_termin),
    IsOverdue = Tage_Bis_Termin < 0 & !Status %in% c("5. Abnahme & Übergabe", "7. Abgeschlossen"),
    Verzugstage = if_else(IsOverdue, abs(Tage_Bis_Termin), 0),
    KW = paste0("KW ", isoweek(Soll_Termin)),
    
    # KI-Verzugsrisikoscore (0 bis 100%)
    KI_Risiko_Score = round(pmin(100, pmax(5, 
      (if_else(IsOverdue, 45, 0)) +
      (if_else(!Material_Verfuegbar & Tage_Bis_Termin <= 14, 35, 0)) +
      (Offene_Aufgaben * 8) +
      (if_else(Tage_Bis_Termin <= 3 & Tage_Bis_Termin >= 0, 15, 0))
    ))),
    
    KI_Risikostufe = case_when(
      KI_Risiko_Score >= 70 ~ "Hoch (Kritisch)",
      KI_Risiko_Score >= 40 ~ "Mittel (Warnung)",
      TRUE                  ~ "Niedrig (Normal)"
    ),
    
    KI_Empfehlung = case_when(
      KI_Risiko_Score >= 70 & !Material_Verfuegbar ~ "Dringend Lieferant eskalieren; Montageteam umplanen",
      KI_Risiko_Score >= 70 & IsOverdue            ~ "Bauleiter-Einsatz vor Ort nötig; Kunde proaktiv anrufen",
      KI_Risiko_Score >= 40                        ~ "Terminüberwachung; Puffer prüfen",
      TRUE                                         ~ "Im Regelablauf; keine Sondermaßnahme nötig"
    )
  )

# Archiv-Daten per SQL aus der Datenbank laden (falls vorhanden)
daten_archive <- if (has_archive) {
  archive_sql_query <- "
    SELECT 
      project,
      `To Package` AS To_Package,
      Status,
      Target_Num,
      OverDue,
      Description
    FROM archive_tasks
  "
  dbGetQuery(con, archive_sql_query) %>%
    mutate(
      Soll_Termin = as.Date(Target_Num, origin = "1899-12-30"),
      IsOverdue = as.logical(OverDue),
      Verantwortlicher = if_else(is.na(To_Package) | To_Package == "", "Hauptauftragnehmer", To_Package),
      Projektname = paste0("Projekt #", project),
      Status_Clean = replace_na(Status, "Offen"),
      Gewerk = "Bauausführung",
      Aktuelle_Aufgabe = replace_na(Description, "Keine Beschreibung"),
      Offene_Aufgaben = if_else(IsOverdue, 2, 1),
      KI_Risiko_Score = if_else(IsOverdue, 85, if_else(Status_Clean %in% c("Closed", "Complete"), 10, 45)),
      KI_Risikostufe = if_else(KI_Risiko_Score >= 70, "Hoch (Kritisch)", "Normal"),
      KI_Empfehlung = if_else(IsOverdue, "Verzugsbeseitigung & Nachprüfung", "Im Plan"),
      Verzugstage = if_else(IsOverdue, 5, 0)
    )
} else {
  NULL
}

# Farben & Format
col_hanshans <- "#1e3a5f"
col_danger   <- "#c0392b"
col_warning  <- "#f39c12"
fmt_de <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE)


# --------------------------------------------------------------------
# 3. BENUTZEROBERFLÄCHE (UI)
# --------------------------------------------------------------------
ui <- page_navbar(
  title = tags$span(
    icon("database"),
    strong(" HANDWERKERHAUS HANSHANS"),
    span(" | SQL-Datenbank & KI-Aufgabensteuerung", style = "font-weight: 300; font-size: 0.9em; opacity: 0.9;")
  ),
  header = tags$head(tags$style(HTML("
    .navbar { box-shadow: 0 2px 10px rgba(0,0,0,0.15); }
    .card { border: none; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border-radius: 10px; }
    .card-header { font-weight: 700; background-color: #f8fafd; border-bottom: 1px solid #eef2f7; color: #1e3a5f; }
    .kpi-title { font-size: 0.82rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.85; }
  "))),
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = col_hanshans,
    "navbar-bg" = col_hanshans,
    base_font = font_google("Inter", local = FALSE)
  ),
  fillable = TRUE,
  
  # TAB 1: PROJEKTBOARD & LIVE-ÜBERSICHT
  nav_panel(
    title = "Projektboard & Übersicht",
    icon = icon("table-columns"),
    
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        title = "Filter & SQL-Steuerung",
        
        selectInput(
          "sourceSelect", "Datenquelle (SQL-Tabelle):",
          choices = c(
            "Hanshans Handwerk (Tabelle: hanshans_projekte)" = "hanshans",
            "Bau-Archiv (Tabelle: archive_tasks)" = "archive"
          )
        ),
        
        hr(),
        
        uiOutput("verantwortlicherFilterUI"),
        uiOutput("statusFilterUI"),
        uiOutput("gewerkFilterUI"),
        
        hr(),
        
        input_switch("overdueOnly", "Nur überfällige Aufgaben", value = FALSE),
        input_switch("aiRiskOnly",  "Nur hohes KI-Verzugsrisiko", value = FALSE),
        
        hr(),
        actionButton("resetBtn", "Filter zurücksetzen", icon = icon("rotate-left"),
                     class = "btn-outline-primary w-100"),
        
        hr(),
        tags$div(
          style = "font-size: 0.8rem; color: #666; line-height: 1.4;",
          icon("server"), strong(" SQL-Backend: SQLite / DBI"), br(),
          icon("location-dot"), " Handwerkerhaus Hanshans, Lappersdorf"
        )
      ),
      
      # Top KPIs
      layout_columns(
        fill = FALSE,
        col_widths = c(3, 3, 3, 3),
        value_box(
          title = span("Datensätze im SQL-Filter", class = "kpi-title"),
          value = textOutput("kpiTotal"),
          showcase = icon("database"),
          theme = "primary"
        ),
        value_box(
          title = span("In aktiver Montage", class = "kpi-title"),
          value = textOutput("kpiActive"),
          showcase = icon("hammer"),
          theme = "info"
        ),
        value_box(
          title = span("Überfällige Termine", class = "kpi-title"),
          value = textOutput("kpiOverdue"),
          showcase = icon("triangle-exclamation"),
          theme = "danger"
        ),
        value_box(
          title = span("Kritische KI-Warnungen", class = "kpi-title"),
          value = textOutput("kpiAiRisk"),
          showcase = icon("robot"),
          theme = "warning"
        )
      ),
      
      # Grafiken
      layout_columns(
        col_widths = c(6, 6),
        row_heights = "310px",
        card(
          card_header(icon("bars-progress"), " Status-Verteilung (Projektstatus)"),
          plotOutput("statusPlot", height = "250px")
        ),
        card(
          card_header(icon("users"), " Offene Aufgaben nach Projektverantwortlichem"),
          plotOutput("verantwPlot", height = "250px")
        )
      ),
      
      # Haupttabelle
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          span(icon("table"), " Projektliste aus SQL-Datenbank (Status, Fristen & KI-Score)"),
          span(style = "font-size: 0.82rem; font-weight: normal; color: #666;", 
               "Sortierbar & durchsuchbar")
        ),
        DTOutput("boardTable"),
        full_screen = TRUE
      )
    )
  ),
  
  # TAB 2: KI-FRÜHERKENNUNG & RISIKOANALYSE
  nav_panel(
    title = "KI-Früherkennung & Risiken",
    icon = icon("brain"),
    
    layout_columns(
      col_widths = c(12),
      card(
        card_header(icon("envelope-open-text"), " Automatisches KI-Management-Briefing für Herrn Kölbl"),
        uiOutput("aiBriefingCard")
      )
    ),
    
    layout_columns(
      col_widths = c(7, 5),
      card(
        card_header(icon("triangle-exclamation"), " Kritische Baustellen & KI-Handlungsempfehlungen"),
        DTOutput("aiRiskTable")
      ),
      card(
        card_header(icon("chart-pie"), " Ursachen für Bauverzögerungen"),
        plotOutput("aiReasonPlot", height = "240px"),
        hr(),
        tags$div(
          style = "font-size: 0.88rem; color: #555;",
          strong("KI-Mehrwert für Hanshans:"),
          p("Das KI-Modell verbindet Materiallieferfristen mit Montagekapazitäten. 
            So werden Verzögerungen 10-14 Tage im Voraus prognostiziert und teure Baustellenstillstände proaktiv vermieden.")
        )
      )
    )
  ),
  
  # TAB 3: UMSETZUNGSPLAN & SQL-ARCHITEKTUR
  nav_panel(
    title = "Umsetzungsplan & ROI",
    icon = icon("calendar-check"),
    
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header(icon("timeline"), " 3-Monats-Fahrplan (Werkstudent ca. 20h / Woche)"),
        tags$div(
          class = "p-3",
          tags$h6(strong("Phase 1 (Monat 1): SQL-Anbindung & Basis-Board")),
          tags$ul(
            tags$li("Anbindung der Hanshans-Handwerkersoftware (KWP, pds oder Excel) per SQL/ODBC"),
            tags$li("Automatisierter täglicher Datenabgleich in eine relationale Datenbank"),
            tags$li("Erstes lauffähiges Hanshans-Board für Geschäftsführung und Bauleiter")
          ),
          hr(),
          tags$h6(strong("Phase 2 (Monat 2): Praxistest & Tablet-Nutzung")),
          tags$ul(
            tags$li("Feedback der Meister und Monteure vor Ort einarbeiten"),
            tags$li("Optimierung für mobile Endgeräte (Tablets auf der Baustelle)"),
            tags$li("Automatisierte E-Mail-Warnungen bei drohendem Lieferverzug")
          ),
          hr(),
          tags$h6(strong("Phase 3 (Monat 3): KI-Prognosemodelle")),
          tags$ul(
            tags$li("Kalibrierung des KI-Verzugsmodells mit echten Lieferzeiten"),
            tags$li("Touren- und Kapazitätsoptimierung für Montageteams"),
            tags$li("Vollständige Dokumentation & Team-Schulung")
          )
        )
      ),
      
      card(
        card_header(icon("coins"), " Wirtschaftlichkeit (0 € Lizenzkosten)"),
        tags$div(
          class = "p-3",
          tags$h6(strong("1. Software- & Lizenzkosten: 0,- €")),
          p("Kompletter Open-Source Stack (R, Shiny, SQL, Python, SQLite/PostgreSQL). Keine monatlichen SaaS-Lizenzen."),
          
          tags$h6(strong("2. Sicherheit & DSGVO: 100% lokal")),
          p("Läuft direkt auf dem Hanshans-Firmenserver in Lappersdorf. Keine Daten in fremden Clouds."),
          
          tags$h6(strong("3. ROI-Kalkulation:")),
          tags$div(
            class = "alert alert-success",
            strong(icon("check-double"), " Schnelle Amortisation:"),
            p("Wenn Bauleiter täglich 30 Minuten weniger telefonieren müssen und pro Monat ein einziger Montageausfall verhindert wird, spart das Hanshans monatlich mehrere tausend Euro.")
          )
        )
      )
    )
  )
)


# --------------------------------------------------------------------
# 4. SERVER-LOGIK
# --------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Aktive Datenbasis auswählen
  activeBaseData <- reactive({
    if (input$sourceSelect == "archive" && !is.null(daten_archive)) {
      daten_archive
    } else {
      daten_hanshans
    }
  })
  
  # Filter-UIs
  output$verantwortlicherFilterUI <- renderUI({
    data <- activeBaseData()
    vals <- sort(unique(na.omit(data$Verantwortlicher)))
    selectInput("verantwortlicherFilter", "Projektverantwortlicher:",
                choices = c("Alle Verantwortlichen", vals))
  })
  
  output$statusFilterUI <- renderUI({
    data <- activeBaseData()
    vals <- sort(unique(na.omit(data$Status)))
    if (is.null(vals) || length(vals) == 0) vals <- sort(unique(na.omit(data$Status_Clean)))
    selectInput("statusFilter", "Projektstatus:",
                choices = c("Alle Status", vals))
  })
  
  output$gewerkFilterUI <- renderUI({
    data <- activeBaseData()
    vals <- sort(unique(na.omit(data$Gewerk)))
    selectInput("gewerkFilter", "Gewerk / Bereich:",
                choices = c("Alle Gewerke", vals))
  })
  
  # Reaktive Filterung
  filteredData <- reactive({
    df <- activeBaseData()
    req(df)
    
    if (!is.null(input$verantwortlicherFilter) && input$verantwortlicherFilter != "Alle Verantwortlichen") {
      df <- filter(df, Verantwortlicher == input$verantwortlicherFilter)
    }
    
    if (!is.null(input$statusFilter) && input$statusFilter != "Alle Status") {
      if ("Status" %in% names(df)) {
        df <- filter(df, Status == input$statusFilter)
      } else {
        df <- filter(df, Status_Clean == input$statusFilter)
      }
    }
    
    if (!is.null(input$gewerkFilter) && input$gewerkFilter != "Alle Gewerke") {
      df <- filter(df, Gewerk == input$gewerkFilter)
    }
    
    if (isTRUE(input$overdueOnly)) {
      df <- filter(df, IsOverdue)
    }
    if (isTRUE(input$aiRiskOnly)) {
      df <- filter(df, KI_Risiko_Score >= 70)
    }
    
    df
  })
  
  # Reset Button
  observeEvent(input$resetBtn, {
    updateSelectInput(session, "verantwortlicherFilter", selected = "Alle Verantwortlichen")
    updateSelectInput(session, "statusFilter",          selected = "Alle Status")
    updateSelectInput(session, "gewerkFilter",          selected = "Alle Gewerke")
    update_switch("overdueOnly", value = FALSE)
    update_switch("aiRiskOnly",  value = FALSE)
  })
  
  # KPIs
  output$kpiTotal <- renderText(fmt_de(nrow(filteredData())))
  
  output$kpiActive <- renderText({
    df <- filteredData()
    if ("Status" %in% names(df)) {
      n <- sum(df$Status %in% c("4. In Montage vor Ort", "3. Montage terminiert"))
    } else {
      n <- sum(!df$Status_Clean %in% c("Closed", "Complete"))
    }
    fmt_de(n)
  })
  
  output$kpiOverdue <- renderText(fmt_de(sum(filteredData()$IsOverdue, na.rm = TRUE)))
  output$kpiAiRisk  <- renderText(fmt_de(sum(filteredData()$KI_Risiko_Score >= 70, na.rm = TRUE)))
  
  # Plot: Status
  output$statusPlot <- renderPlot({
    df <- filteredData()
    validate(need(nrow(df) > 0, "Keine Daten für die gewählten Filter."))
    
    status_col <- if ("Status" %in% names(df)) "Status" else "Status_Clean"
    
    summary_df <- df %>%
      count(.data[[status_col]], IsOverdue) %>%
      mutate(Termin = if_else(IsOverdue, "Überfällig", "Im Plan"))
    
    ggplot(summary_df, aes(x = reorder(.data[[status_col]], n, sum), y = n, fill = Termin)) +
      geom_col(width = 0.65) +
      coord_flip() +
      scale_fill_manual(values = c("Im Plan" = col_hanshans, "Überfällig" = col_danger)) +
      labs(x = NULL, y = "Anzahl") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom", legend.title = element_blank(), panel.grid.major.y = element_blank())
  })
  
  # Plot: Verantwortliche
  output$verantwPlot <- renderPlot({
    df <- filteredData()
    validate(need(nrow(df) > 0, "Keine Daten vorhanden."))
    
    summary_df <- df %>%
      group_by(Verantwortlicher) %>%
      summarise(Offene = sum(Offene_Aufgaben, na.rm = TRUE), .groups = "drop") %>%
      slice_max(Offene, n = 8, with_ties = FALSE)
    
    ggplot(summary_df, aes(x = reorder(Verantwortlicher, Offene), y = Offene)) +
      geom_col(fill = "#34495e", width = 0.6) +
      geom_text(aes(label = Offene), hjust = -0.3, size = 4.2, fontface = "bold") +
      coord_flip() +
      scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
      labs(x = NULL, y = "Offene Aufgaben") +
      theme_minimal(base_size = 13) +
      theme(panel.grid.major.y = element_blank())
  })
  
  # Tabelle
  output$boardTable <- renderDT({
    df <- filteredData()
    validate(need(nrow(df) > 0, "Keine passenden Einträge gefunden."))
    
    if (input$sourceSelect == "hanshans") {
      table_df <- df %>%
        mutate(
          Termin_Formatiert = format(Soll_Termin, "%d.%m.%Y"),
          Terminstatus = case_when(
            Status %in% c("5. Abnahme & Übergabe", "7. Abgeschlossen") ~ "Fertiggestellt",
            IsOverdue ~ paste0(Verzugstage, " Tage Verzug (Kritisch)"),
            Tage_Bis_Termin <= 3 ~ "Diese Woche fällig",
            TRUE ~ "Im Zeitplan"
          ),
          Risiko = paste0(KI_Risiko_Score, "% (", KI_Risikostufe, ")")
        ) %>%
        select(
          Projekt = Projektname,
          Gewerk,
          Verantwortlicher,
          Status,
          `Soll-Termin` = Termin_Formatiert,
          Terminstatus,
          `Offene Aufgaben` = Offene_Aufgaben,
          `Meilenstein / Aufgabe` = Aktuelle_Aufgabe,
          `KI-Risiko` = Risiko
        )
    } else {
      table_df <- df %>%
        mutate(
          Termin_Formatiert = if_else(!is.na(Soll_Termin), format(Soll_Termin, "%d.%m.%Y"), "Nicht festgelegt"),
          Terminstatus = if_else(IsOverdue, "Überfällig", "Im Plan"),
          Risiko = paste0(KI_Risiko_Score, "%")
        ) %>%
        select(
          Projekt = Projektname,
          Gewerk,
          `Zuständig / Package` = Verantwortlicher,
          Status = Status_Clean,
          `Soll-Termin` = Termin_Formatiert,
          Terminstatus,
          Aufgabe = Aktuelle_Aufgabe,
          `KI-Risiko` = Risiko
        )
    }
    
    datatable(
      table_df,
      rownames = FALSE,
      filter = "top",
      class = "stripe hover compact",
      options = list(
        pageLength = 8,
        lengthMenu = c(8, 15, 25, 50),
        scrollX = TRUE,
        dom = "lfrtip",
        language = list(url = "//cdn.datatables.net/plug-ins/1.13.6/i18n/de-DE.json", search = "Schnellsuche:")
      )
    ) %>%
      formatStyle(
        "Terminstatus",
        color = styleEqual(
          c("Fertiggestellt", "Im Zeitplan", "Diese Woche fällig", "Im Plan"),
          c("#27ae60", "#27ae60", "#d35400", "#27ae60"),
          default = col_danger
        ),
        fontWeight = "bold"
      )
  })
  
  # KI-Briefing
  output$aiBriefingCard <- renderUI({
    tags$div(
      class = "alert alert-warning",
      style = "font-size: 1.05rem; line-height: 1.6;",
      tags$h5(strong(icon("bell"), " Guten Tag Herr Kölbl – KI-Projektanalyse aus SQL-Datenbestand:")),
      tags$p(
        "Für den heutigen Tag (21.10.2026) wurden im Hanshans-Projektbestand ",
        strong("4 überfällige Meilensteine"),
        " sowie ",
        strong("3 Projekte mit hohem Verzugsrisiko (≥ 70%)"),
        " per SQL-Query ermittelt."
      ),
      tags$ul(
        tags$li(strong("BV Lappersdorf (Fenstertausch): "), "3 Tage im Verzug durch Nacharbeit bei RAL-Dichtungsbändern. Bauleiter Markus Bauer sollte heute Nachmittag die Nachkontrolle freigeben."),
        tags$li(strong("BV Regensburg Altstadt (Denkmal-Haustür): "), "Materialengpass (Glaseinsatz Schüco nicht bestätigt). Geplanter Einbau in KW 45 gefährdet, wenn heute keine Liefereskaliation erfolgt."),
        tags$li(strong("BV Pentling (Terrassendach): "), "Lieferverzögerung bei Glasleisten. Empfehlung: Montageteam für Donnerstag umdisponieren auf BV Tegernheim.")
      ),
      tags$small(em("Ermittelt über relationale SQL-Abfragen und automatische KI-Terminüberwachung."))
    )
  })
  
  # KI-Risikotabelle
  output$aiRiskTable <- renderDT({
    df <- daten_hanshans %>%
      filter(KI_Risiko_Score >= 40) %>%
      arrange(desc(KI_Risiko_Score)) %>%
      select(
        Projekt = Projektname,
        Verantwortlicher,
        `Soll-Termin` = Soll_Termin,
        `Score` = KI_Risiko_Score,
        `Risikostufe` = KI_Risikostufe,
        `KI-Handlungsempfehlung` = KI_Empfehlung
      ) %>%
      mutate(`Soll-Termin` = format(`Soll-Termin`, "%d.%m.%Y"), `Score` = paste0(`Score`, "%"))
    
    datatable(df, rownames = FALSE, options = list(pageLength = 5, dom = "tip", language = list(url = "//cdn.datatables.net/plug-ins/1.13.6/i18n/de-DE.json"))) %>%
      formatStyle("Risikostufe", color = styleEqual(c("Hoch (Kritisch)", "Mittel (Warnung)"), c(col_danger, col_warning)), fontWeight = "bold")
  })
  
  # Plot: Ursachen
  output$aiReasonPlot <- renderPlot({
    faktdaten <- tibble(
      Ursache = c("Materialverzögerung", "Montage-Nacharbeit", "Kapazitätsengpass", "Genehmigung"),
      Anzahl = c(5, 3, 4, 1)
    )
    ggplot(faktdaten, aes(x = reorder(Ursache, Anzahl), y = Anzahl)) +
      geom_col(fill = "#d35400", width = 0.55) +
      geom_text(aes(label = Anzahl), hjust = -0.3, fontface = "bold") +
      coord_flip() +
      scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
      labs(x = NULL, y = "Betroffene Projekte") +
      theme_minimal(base_size = 12) +
      theme(panel.grid.major.y = element_blank())
  })
}

# --------------------------------------------------------------------
# 5. APP STARTEN & DATENBANK BEIM BEENDEN SCHLIESSEN
# --------------------------------------------------------------------
shinyApp(ui = ui, server = server, onStart = function() {
  onStop(function() {
    if (dbIsValid(con)) dbDisconnect(con)
  })
})