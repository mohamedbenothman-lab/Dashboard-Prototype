# ====================================================================
# HANDWERKERHAUS HANSHANS - EINFACHES PROJEKTBOARD
# Entwickelt für das Gespräch mit Herrn Tobias Kölbl (21.10.2026)
# ====================================================================
# 1. Daten einlesen (aus der Datei "projekte_hanshans.csv")
# 2. Benutzeroberfläche (UI: Filter links, Ergebnisse rechts)
# 3. Server-Logik (Filtern, Kennzahlen, Diagramm, Tabelle)
# ====================================================================

library(shiny)
library(tidyverse)
library(DT)

# --------------------------------------------------------------------
# 1. DATEN EINLESEN
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

csv_datei <- finde_datei("projekte_hanshans.csv")
projekte <- read_csv(csv_datei, show_col_types = FALSE)


# --------------------------------------------------------------------
# 2. BENUTZEROBERFLÄCHE (UI)
# --------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Handwerkerhaus Hanshans - Einfaches Projektboard"),
  hr(),
  
  sidebarLayout(
    # LINKE SEITE: DIE FILTER
    sidebarPanel(
      width = 3,
      h4("Filter"),
      
      # Filter 1: Projektverantwortlicher
      selectInput(
        inputId = "filter_verantwortlicher",
        label = "Projektverantwortlicher:",
        choices = c("Alle", sort(unique(projekte$Verantwortlicher)))
      ),
      
      # Filter 2: Status
      selectInput(
        inputId = "filter_status",
        label = "Projektstatus:",
        choices = c("Alle", sort(unique(projekte$Status)))
      ),
      
      # Filter 3: Nur überfällige Aufgaben
      checkboxInput(
        inputId = "filter_ueberfaellig",
        label = "Nur überfällige Projekte anzeigen",
        value = FALSE
      ),
      
      hr(),
      helpText("Klicken Sie auf die Filter, um die Daten live zu aktualisieren.")
    ),
    
    # RECHTE SEITE: DIE ERGEBNISSE
    mainPanel(
      width = 9,
      
      # 3 einfache Kennzahlen nebeneinander
      fluidRow(
        column(4, wellPanel(h5("Projekte gesamt:"), h3(textOutput("anzahl_gesamt")))),
        column(4, wellPanel(h5("Überfällige Projekte:"), h3(textOutput("anzahl_ueberfaellig"), style = "color: red;"))),
        column(4, wellPanel(h5("Offene Einzelaufgaben:"), h3(textOutput("anzahl_aufgaben"))))
      ),
      
      # Diagramm: Status-Verteilung
      h4("Übersicht nach Status"),
      plotOutput("diagramm_status", height = "240px"),
      hr(),
      
      # Interaktive Tabelle
      h4("Projekt- und Aufgabenliste"),
      DTOutput("tabelle_projekte")
    )
  )
)


# --------------------------------------------------------------------
# 3. SERVER-LOGIK
# --------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Schritt A: Reaktive Filterung nach Nutzerauswahl
  gefilterte_daten <- reactive({
    daten <- projekte
    
    # Filter Verantwortlicher
    if (input$filter_verantwortlicher != "Alle") {
      daten <- daten %>% filter(Verantwortlicher == input$filter_verantwortlicher)
    }
    
    # Filter Status
    if (input$filter_status != "Alle") {
      daten <- daten %>% filter(Status == input$filter_status)
    }
    
    # Checkbox Überfällig
    if (input$filter_ueberfaellig) {
      daten <- daten %>% filter(Ueberfaellig == TRUE)
    }
    
    daten
  })
  
  # Schritt B: Kennzahlen ausgeben
  output$anzahl_gesamt      <- renderText(nrow(gefilterte_daten()))
  output$anzahl_ueberfaellig <- renderText(sum(gefilterte_daten()$Ueberfaellig))
  output$anzahl_aufgaben    <- renderText(sum(gefilterte_daten()$Offene_Aufgaben))
  
  # Schritt C: Einfaches Balkendiagramm
  output$diagramm_status <- renderPlot({
    daten <- gefilterte_daten()
    if (nrow(daten) == 0) return(NULL)
    
    ggplot(daten, aes(x = Status, fill = Ueberfaellig)) +
      geom_bar(width = 0.5) +
      scale_fill_manual(values = c("FALSE" = "#2c3e50", "TRUE" = "#e74c3c"),
                        labels = c("Im Plan", "Überfällig"),
                        name = "Termintreue") +
      labs(x = "Status", y = "Anzahl Projekte") +
      theme_minimal(base_size = 14)
  })
  
  # Schritt D: Tabelle mit roter Warnfarbe für Verzug anzeigen
  output$tabelle_projekte <- renderDT({
    daten <- gefilterte_daten() %>%
      mutate(
        Termin = format(Termin, "%d.%m.%Y"),
        Überfällig = if_else(Ueberfaellig, "JA (Verzug)", "Nein (Im Plan)")
      ) %>%
      select(Projekt, Gewerk, Verantwortlicher, Status, Termin, `Offene Aufgaben` = Offene_Aufgaben, Überfällig)
    
    datatable(
      daten,
      rownames = FALSE,
      options = list(pageLength = 6, dom = "tp")
    ) %>%
      formatStyle(
        "Überfällig",
        color = styleEqual(c("JA (Verzug)", "Nein (Im Plan)"), c("red", "green")),
        fontWeight = "bold"
      )
  })
}

# --------------------------------------------------------------------
# 4. APP STARTEN
# --------------------------------------------------------------------
shinyApp(ui = ui, server = server)
