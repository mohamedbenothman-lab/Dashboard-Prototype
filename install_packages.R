pakete <- c("shiny", "tidyverse", "DT", "bslib", "lubridate", "DBI", "RSQLite")
fehlende_pakete <- pakete[!vapply(pakete, requireNamespace, logical(1), quietly = TRUE)]

if (length(fehlende_pakete) > 0) {
  install.packages(fehlende_pakete, repos = "https://cloud.r-project.org")
}
