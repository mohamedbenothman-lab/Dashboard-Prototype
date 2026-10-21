# ====================================================================
# DASHBOARD DIREKT MIT DEN ARCHIV-DATEN (Construction Tasks CSV)
# ====================================================================
# Dieses Skript liest direkt die Datei aus dem Ordner "archive" ein:
# Construction_Data_PM_Tasks_All_Projects.csv (12.424 Datensätze)
# ====================================================================

library(shiny)
library(tidyverse)
library(DT)

# --------------------------------------------------------------------
# 1. DATEN DIREKT AUS DEM ARCHIV LADEN & BEREINIGEN
# --------------------------------------------------------------------
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

archive_pfad <- finde_datei("archive/Construction_Data_PM_Tasks_All_Projects.csv")

# CSV einlesen
rohdaten <- read_csv(archive_pfad, show_col_types = FALSE)

# Aufbereitung für das Projektboard:
# - Excel-Datumsseriennummer in echtes Datum umwandeln
# - Spalten für Herrn Kölbls Anforderungen zuordnen
projekte <- rohdaten %>%
  mutate(Target_Num = suppressWarnings(as.numeric(Target))) %>%
  filter(!is.na(Target_Num)) %>% # Nur Zeilen mit echtem Zieldatum (2.568 Tasks)
  mutate(
    Projekt = paste("Projekt #", project),
    Verantwortlicher = if_else(is.na(`To Package`) | `To Package` == "", "Hauptauftragnehmer", `To Package`),
    Status = replace_na(Status, "Offen"),
    Termin = as.Date(Target_Num, origin = "1899-12-30"),
    Ueberfaellig = replace_na(as.logical(OverDue), FALSE),
    Aufgabe = replace_na(Description, "Keine Beschreibung")
  ) %>%
  select(Projekt, Verantwortlicher, Status, Termin, Ueberfaellig, Aufgabe)


# --------------------------------------------------------------------
# 2. BENUTZEROBERFLÄCHE (UI)
# --------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Bau-Projektboard (Archiv-Daten: 2.568 Tasks mit Fristen)"),
  hr(),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Filter"),
      
      selectInput("filter_projekt", "Projekt:",
                  choices = c("Alle", sort(unique(projekte$Projekt)))),
      
      selectInput("filter_verantwortlicher", "Zuständiges Gewerk / Package:",
                  choices = c("Alle", sort(unique(projekte$Verantwortlicher)))),
      
      selectInput("filter_status", "Status:",
                  choices = c("Alle", sort(unique(projekte$Status)))),
      
      checkboxInput("filter_ueberfaellig", "Nur überfällige Aufgaben", value = FALSE),
      
      hr(),
      helpText("Datenquelle: Construction_Data_PM_Tasks_All_Projects.csv")
    ),
    
    mainPanel(
      width = 9,
      
      fluidRow(
        column(4, wellPanel(h5("Tasks im Filter:"), h3(textOutput("anzahl_gesamt")))),
        column(4, wellPanel(h5("Überfällig:"), h3(textOutput("anzahl_ueberfaellig"), style = "color: red;"))),
        column(4, wellPanel(h5("Quote überfällig:"), h3(textOutput("quote_ueberfaellig"))))
      ),
      
      h4("Aufgaben nach Status"),
      plotOutput("diagramm_status", height = "260px"),
      hr(),
      
      h4("Aufgabenliste"),
      DTOutput("tabelle_projekte")
    )
  )
)


# --------------------------------------------------------------------
# 3. SERVER-LOGIK
# --------------------------------------------------------------------
server <- function(input, output, session) {
  
  gefilterte_daten <- reactive({
    daten <- projekte
    
    if (input$filter_projekt != "Alle") {
      daten <- daten %>% filter(Projekt == input$filter_projekt)
    }
    if (input$filter_verantwortlicher != "Alle") {
      daten <- daten %>% filter(Verantwortlicher == input$filter_verantwortlicher)
    }
    if (input$filter_status != "Alle") {
      daten <- daten %>% filter(Status == input$filter_status)
    }
    if (input$filter_ueberfaellig) {
      daten <- daten %>% filter(Ueberfaellig == TRUE)
    }
    daten
  })
  
  output$anzahl_gesamt <- renderText(nrow(gefilterte_daten()))
  output$anzahl_ueberfaellig <- renderText(sum(gefilterte_daten()$Ueberfaellig))
  output$quote_ueberfaellig <- renderText({
    n <- nrow(gefilterte_daten())
    if (n == 0) "0 %" else paste0(round(100 * sum(gefilterte_daten()$Ueberfaellig) / n, 1), " %")
  })
  
  output$diagramm_status <- renderPlot({
    daten <- gefilterte_daten()
    if (nrow(daten) == 0) return(NULL)
    
    summary_df <- daten %>% count(Status, Ueberfaellig)
    
    ggplot(summary_df, aes(x = reorder(Status, n, sum), y = n, fill = Ueberfaellig)) +
      geom_col(width = 0.6) +
      coord_flip() +
      scale_fill_manual(values = c("FALSE" = "#2c3e50", "TRUE" = "#e74c3c"),
                        labels = c("Im Plan", "Überfällig"), name = "Termin") +
      labs(x = NULL, y = "Anzahl Tasks") +
      theme_minimal(base_size = 13)
  })
  
  output$tabelle_projekte <- renderDT({
    daten <- gefilterte_daten() %>%
      mutate(
        Termin = format(Termin, "%d.%m.%Y"),
        Überfällig = if_else(Ueberfaellig, "JA", "Nein")
      ) %>%
      select(Projekt, `Gewerk / Package` = Verantwortlicher, Status, Termin, Überfällig, Aufgabe)
    
    datatable(daten, rownames = FALSE, options = list(pageLength = 8, dom = "lfrtip")) %>%
      formatStyle("Überfällig", color = styleEqual(c("JA", "Nein"), c("red", "green")), fontWeight = "bold")
  })
}

shinyApp(ui = ui, server = server)
