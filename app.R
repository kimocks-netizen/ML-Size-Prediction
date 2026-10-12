# =============================================================================
# app.R — Entry point
# Sources all modules and wires UI + server
# =============================================================================

library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(DT)
library(nnet)

source("R/helpers.R")
source("R/prediction.R")
source("R/modules/mod_dashboard.R")
source("R/modules/mod_predict.R")
source("R/modules/mod_model.R")
source("R/modules/mod_insights.R")
source("R/modules/mod_feedback.R")
source("R/modules/mod_about.R")

# ---- Startup assets (loaded once) ----
model       <- load_model("models/best_model.rds")
model_ready <- !is.null(model)

clean_data  <- tryCatch(
  read.csv("data/clothing_clean.csv", stringsAsFactors = FALSE),
  error = function(e) NULL
)

# ---- Theme ----
app_theme <- bs_theme(
  version      = 5,
  bg           = "#0F172A",
  fg           = "#F8FAFC",
  primary      = "#3B82F6",
  secondary    = "#06B6D4",
  success      = "#10B981",
  warning      = "#F59E0B",
  danger       = "#F43F5E",
  base_font    = font_google("Inter"),
  heading_font = font_google("Inter")
)

# =============================================================================
# UI
# =============================================================================
ui <- page_navbar(
  title = tags$a(
    href    = "#",
    onclick = "$('.nav-link').filter(function(){ return $(this).text().trim().startsWith('Dashboard'); }).tab('show'); return false;",
    style   = "text-decoration:none; display:flex; align-items:center;",
    tags$img(src = "logo/logo.png", height = "32px",
             style = "margin-right:10px; border-radius:6px; vertical-align:middle;"),
    tags$span("SizePredict ML",
      style = "vertical-align:middle; font-weight:700; letter-spacing:0.02em; color:#F8FAFC;")
  ),
  theme    = app_theme,
  bg       = "#1E293B",
  fillable = FALSE,
  header   = tags$head(
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$link(rel = "icon", type = "image/png", href = "logo/logo.png")
  ),
  nav_spacer(),
  nav_panel(title = "Dashboard",    icon = icon("gauge"),       dashboardUI("dashboard")),
  nav_panel(title = "Predict Size", icon = icon("shirt"),       predictUI("predict")),
  nav_panel(title = "Model",        icon = icon("chart-bar"),   modelUI("model")),
  nav_panel(title = "Data Insights",icon = icon("chart-pie"),   insightsUI("insights")),
  nav_panel(title = "Feedback",     icon = icon("database"),    feedbackUI("feedback")),
  nav_panel(title = "About",        icon = icon("circle-info"), aboutUI("about"))
)

# =============================================================================
# SERVER
# =============================================================================
server <- function(input, output, session) {
  dashboardServer("dashboard", clean_data = clean_data, model_ready = model_ready)
  predictServer("predict",     model = model,           model_ready = model_ready)
  modelServer("model",         model_ready = model_ready)
  insightsServer("insights",   clean_data = clean_data)
  feedbackServer("feedback")
  # aboutUI is static — no server needed
}

shinyApp(ui = ui, server = server)
