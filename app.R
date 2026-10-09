# =============================================================================
# app.R
# Clothing Size Prediction — R Shiny Application
# =============================================================================

library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)

source("R/helpers.R")
source("R/prediction.R")

# ---- Load assets once at startup ----
model      <- load_model("models/best_model.rds")
model_ready <- !is.null(model)

clean_data <- tryCatch(
  read.csv("data/clothing_clean.csv", stringsAsFactors = FALSE),
  error = function(e) NULL
)

# Summary stats for dashboard
total_records  <- if (!is.null(clean_data)) nrow(clean_data) else "—"
n_size_classes <- length(SIZE_LEVELS)
model_name     <- if (model_ready) "Random Forest" else "Not yet trained"

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
  title = tags$span(
    tags$img(src = NULL, height = "20px"),
    "SizePredict ML"
  ),
  theme    = app_theme,
  bg       = "#1E293B",
  fillable = FALSE,
  header   = tags$head(
    tags$link(rel = "stylesheet", href = "styles.css")
  ),

  # ---- Tab 1: Dashboard ----
  nav_panel(
    title = "Dashboard",
    icon  = icon("gauge"),

    div(class = "container-fluid py-4",

      # Hero
      div(class = "row mb-4",
        div(class = "col-12",
          div(class = "card p-4",
            h2("Clothing Size Prediction",
               style = "color:#3B82F6; font-weight:800; margin-bottom:0.25rem;"),
            p("Machine Learning Decision Support System",
              style = "color:#94A3B8; font-size:1rem; margin-bottom:1rem;"),
            p("A supervised machine learning model trained on historical clothing data
               to predict the most likely size category from customer weight, height and age.
               Built for Business Intelligence module 6029CMD.",
              style = "color:#F8FAFC; max-width:700px;")
          )
        )
      ),

      # Stat boxes
      div(class = "row g-3 mb-4",
        div(class = "col-6 col-md-3",
          div(class = "stat-box",
            div(class = "stat-value", total_records),
            div(class = "stat-label", "Training Records")
          )
        ),
        div(class = "col-6 col-md-3",
          div(class = "stat-box",
            div(class = "stat-value", n_size_classes),
            div(class = "stat-label", "Size Classes")
          )
        ),
        div(class = "col-6 col-md-3",
          div(class = "stat-box",
            div(class = "stat-value", "3"),
            div(class = "stat-label", "Models Compared")
          )
        ),
        div(class = "col-6 col-md-3",
          div(class = "stat-box",
            div(class = "stat-value",
              if (model_ready)
                tags$span(icon("circle-check"), style = "color:#10B981;")
              else
                tags$span(icon("clock"), style = "color:#F59E0B;")
            ),
            div(class = "stat-label", "Model Status")
          )
        )
      ),

      # Workflow
      div(class = "row mb-4",
        div(class = "col-12",
          div(class = "card p-4",
            div(class = "section-title", "Project Workflow"),
            div(class = "d-flex flex-wrap gap-2 align-items-center",
              style = "font-size:0.9rem;",
              lapply(
                list(
                  list("1. Data", "#3B82F6"),
                  list("→", "#334155"),
                  list("2. Clean", "#3B82F6"),
                  list("→", "#334155"),
                  list("3. EDA", "#3B82F6"),
                  list("→", "#334155"),
                  list("4. Train", "#3B82F6"),
                  list("→", "#334155"),
                  list("5. Evaluate", "#3B82F6"),
                  list("→", "#334155"),
                  list("6. Deploy", "#10B981")
                ),
                function(x)
                  tags$span(x[[1]], style = paste0("color:", x[[2]], "; font-weight:600;"))
              )
            )
          )
        )
      ),

      # Business context
      div(class = "row",
        div(class = "col-md-6 mb-3",
          div(class = "card p-4 h-100",
            div(class = "section-title", "Business Problem"),
            p("Online clothing retailers face high return rates caused by customers
               selecting incorrect sizes. A traditional size guide provides static
               recommendations, but a machine learning system can use historical
               purchase data to estimate the most likely size for a new customer
               based on their physical characteristics.",
              style = "color:#94A3B8; font-size:0.9rem;")
          )
        ),
        div(class = "col-md-6 mb-3",
          div(class = "card p-4 h-100",
            div(class = "section-title", "Model Inputs & Output"),
            tags$ul(
              style = "color:#94A3B8; font-size:0.9rem; padding-left:1.2rem;",
              tags$li(tags$strong("Weight"), " (kg) — customer body weight"),
              tags$li(tags$strong("Height"), " (cm) — customer height"),
              tags$li(tags$strong("Age"), " — customer age in years"),
              tags$li(tags$strong("→ Predicted Size"),
                      " — XXS, S, M, L, XL, XXL or XXXL")
            )
          )
        )
      )
    )
  ),

  # ---- Tab 2: Predict Size ----
  nav_panel(
    title = "Predict Size",
    icon  = icon("shirt"),

    div(class = "container-fluid py-4",
      div(class = "row g-4",

        # Input panel
        div(class = "col-md-4",
          div(class = "card p-4",
            div(class = "section-title", "Customer Information"),

            numericInput("weight", "Weight (kg)",
              value = 65, min = WEIGHT_MIN, max = WEIGHT_MAX, step = 1),

            numericInput("height", "Height (cm)",
              value = 170, min = HEIGHT_MIN, max = HEIGHT_MAX, step = 1),

            numericInput("age", "Age",
              value = 28, min = AGE_MIN, max = AGE_MAX, step = 1),

            br(),
            actionButton("predict_btn", "Predict Size",
              class = "btn btn-primary btn-predict",
              icon  = icon("wand-magic-sparkles")),

            br(), br(),
            div(class = "limitation-note",
              icon("triangle-exclamation"), " ",
              "This prediction is an estimate based on historical patterns.
               Size standards vary across brands and garment types."
            )
          )
        ),

        # Result panel
        div(class = "col-md-8",

          # Result card
          div(class = "card p-4 mb-4",
            div(class = "section-title", "Prediction Result"),
            uiOutput("result_ui")
          ),

          # Probability chart
          div(class = "card p-4 mb-4",
            div(class = "section-title", "Size Probabilities"),
            plotlyOutput("prob_chart", height = "280px")
          ),

          # Feedback
          div(class = "card p-4",
            div(class = "section-title", "Feedback"),
            uiOutput("feedback_ui")
          )
        )
      )
    )
  ),

  # ---- Tab 3: Model Performance ----
  nav_panel(
    title = "Model",
    icon  = icon("chart-bar"),

    div(class = "container-fluid py-4",

      div(class = "row g-3 mb-4",
        div(class = "col-12",
          div(class = "card p-4",
            div(class = "section-title", "Model Comparison"),
            uiOutput("model_table_ui")
          )
        )
      ),

      div(class = "row g-3",
        div(class = "col-md-6",
          div(class = "card p-4",
            div(class = "section-title", "Selected Model"),
            uiOutput("selected_model_ui")
          )
        ),
        div(class = "col-md-6",
          div(class = "card p-4",
            div(class = "section-title", "Confusion Matrix"),
            uiOutput("confusion_matrix_ui")
          )
        )
      )
    )
  ),

  # ---- Tab 4: Data Insights ----
  nav_panel(
    title = "Data Insights",
    icon  = icon("chart-pie"),

    div(class = "container-fluid py-4",

      div(class = "row g-3 mb-4",
        div(class = "col-12",
          div(class = "card p-4",
            div(class = "section-title", "Size Class Distribution"),
            plotlyOutput("size_dist_chart", height = "320px")
          )
        )
      ),

      div(class = "row g-3",
        div(class = "col-md-4",
          div(class = "card p-4",
            div(class = "section-title", "Weight Distribution"),
            plotlyOutput("weight_chart", height = "260px")
          )
        ),
        div(class = "col-md-4",
          div(class = "card p-4",
            div(class = "section-title", "Height Distribution"),
            plotlyOutput("height_chart", height = "260px")
          )
        ),
        div(class = "col-md-4",
          div(class = "card p-4",
            div(class = "section-title", "Age Distribution"),
            plotlyOutput("age_chart", height = "260px")
          )
        )
      )
    )
  ),

  # ---- Tab 5: About ----
  nav_panel(
    title = "About",
    icon  = icon("circle-info"),

    div(class = "container-fluid py-4",
      div(class = "row",
        div(class = "col-md-8",

          div(class = "card p-4 mb-4",
            div(class = "section-title", "Project"),
            tags$table(class = "table table-sm",
              style = "color:#94A3B8; font-size:0.9rem;",
              tags$tbody(
                tags$tr(tags$td("Module"),  tags$td("Business Intelligence (6029CMD)")),
                tags$tr(tags$td("Title"),   tags$td("Machine Learning-Based Clothing Size Prediction")),
                tags$tr(tags$td("Model"),   tags$td("Supervised Multiclass Classification")),
                tags$tr(tags$td("Target"),  tags$td("Clothing size: XXS, S, M, L, XL, XXL, XXXL")),
                tags$tr(tags$td("Inputs"),  tags$td("Weight (kg), Height (cm), Age"))
              )
            )
          ),

          div(class = "card p-4 mb-4",
            div(class = "section-title", "Dataset"),
            tags$table(class = "table table-sm",
              style = "color:#94A3B8; font-size:0.9rem;",
              tags$tbody(
                tags$tr(tags$td("Raw records"),    tags$td("119,734")),
                tags$tr(tags$td("After cleaning"), tags$td("27,391")),
                tags$tr(tags$td("Duplicates removed"), tags$td("92,330 (77.1%)")),
                tags$tr(tags$td("Missing values"), tags$td("Imputed with column median")),
                tags$tr(tags$td("Height encoding"), tags$td("Inches converted to cm (×2.54)")),
                tags$tr(tags$td("Class imbalance"), tags$td("XXL: 67 records vs XXXL: 6,766"))
              )
            )
          ),

          div(class = "card p-4",
            div(class = "section-title", "Limitations"),
            tags$ul(
              style = "color:#94A3B8; font-size:0.9rem; padding-left:1.2rem;",
              tags$li("Size standards vary across brands — predictions are estimates only"),
              tags$li("XXL class has very few training examples (67 records)"),
              tags$li("6,805 ambiguous observations where identical inputs map to different sizes"),
              tags$li("Dataset does not contain return or fit confirmation data"),
              tags$li("Height values appear to originate from inch measurements converted to cm")
            )
          )
        ),

        div(class = "col-md-4",
          div(class = "card p-4",
            div(class = "section-title", "AI Use Acknowledgement"),
            tags$table(class = "table table-sm",
              style = "color:#94A3B8; font-size:0.85rem;",
              tags$thead(
                tags$tr(tags$th("Tool"), tags$th("How used"))
              ),
              tags$tbody(
                tags$tr(
                  tags$td("Amazon Q Developer"),
                  tags$td("Code generation, debugging, project planning")
                )
              )
            )
          )
        )
      )
    )
  )
)

# =============================================================================
# SERVER
# =============================================================================
server <- function(input, output, session) {

  # Reactive values
  rv <- reactiveValues(
    prediction   = NULL,
    feedback_done = FALSE
  )

  # ---- Prediction ----
  observeEvent(input$predict_btn, {
    rv$feedback_done <- FALSE

    # Validate inputs
    if (!validate_input(input$weight, WEIGHT_MIN, WEIGHT_MAX) ||
        !validate_input(input$height, HEIGHT_MIN, HEIGHT_MAX) ||
        !validate_input(input$age,    AGE_MIN,    AGE_MAX)) {
      showNotification(
        "Please enter valid weight, height and age values.",
        type = "error", duration = 4
      )
      return()
    }

    if (!model_ready) {
      # Demo mode — random probabilities while model is not yet trained
      set.seed(as.integer(input$weight + input$height + input$age))
      raw_probs <- runif(7)
      probs     <- raw_probs / sum(raw_probs)
      names(probs) <- SIZE_LEVELS
      top_idx   <- which.max(probs)

      rv$prediction <- list(
        predicted_size = SIZE_LEVELS[top_idx],
        probability    = probs[top_idx],
        conf_level     = confidence_level(probs[top_idx]),
        all_probs      = probs,
        demo           = TRUE
      )
    } else {
      rv$prediction <- predict_size(
        model, input$weight, input$age, input$height
      )
      rv$prediction$demo <- FALSE
    }
  })

  # ---- Result UI ----
  output$result_ui <- renderUI({
    if (is.null(rv$prediction)) {
      return(
        div(style = "text-align:center; padding:2rem; color:#94A3B8;",
          icon("shirt", style = "font-size:3rem; margin-bottom:1rem;"),
          p("Enter your measurements and click Predict Size")
        )
      )
    }

    p  <- rv$prediction
    cl <- p$conf_level
    colour <- switch(cl, high = "#10B981", medium = "#F59E0B", low = "#F43F5E")

    div(class = "result-card",
      if (p$demo)
        div(class = "limitation-note mb-3",
          icon("flask"), " Demo mode — model not yet trained. Showing placeholder output."
        ),
      div(class = "result-label", "Recommended Size"),
      div(class = "result-size", p$predicted_size),
      div(class = "result-confidence",
        tags$span(
          class = paste0("confidence-badge badge-", cl),
          paste0(round(p$probability * 100), "% confidence")
        )
      ),
      br(),
      p(style = "color:#94A3B8; font-size:0.85rem; margin-top:0.5rem;",
        paste0(
          "Based on weight: ", input$weight, " kg | ",
          "height: ", input$height, " cm | ",
          "age: ", input$age
        )
      )
    )
  })

  # ---- Probability chart ----
  output$prob_chart <- renderPlotly({
    if (is.null(rv$prediction)) {
      p <- plot_ly() %>%
        layout(
          paper_bgcolor = "transparent",
          plot_bgcolor  = "transparent",
          xaxis = list(visible = FALSE),
          yaxis = list(visible = FALSE),
          annotations = list(list(
            text = "Make a prediction to see probabilities",
            x = 0.5, y = 0.5, xref = "paper", yref = "paper",
            showarrow = FALSE,
            font = list(color = "#94A3B8", size = 14)
          ))
        )
      return(p)
    }

    probs <- rv$prediction$all_probs
    df    <- data.frame(
      size  = factor(SIZE_LEVELS, levels = SIZE_LEVELS),
      prob  = as.numeric(probs) * 100
    )
    top   <- rv$prediction$predicted_size
    df$colour <- ifelse(df$size == top, "#3B82F6", "#334155")

    plot_ly(df,
      x = ~prob, y = ~size, type = "bar", orientation = "h",
      marker = list(color = ~colour),
      text   = ~paste0(round(prob, 1), "%"),
      textposition = "outside",
      hovertemplate = "%{y}: %{x:.1f}%<extra></extra>"
    ) %>%
    layout(
      paper_bgcolor = "transparent",
      plot_bgcolor  = "transparent",
      xaxis = list(
        title = "Probability (%)",
        color = "#94A3B8",
        gridcolor = "#1E293B",
        range = c(0, 105)
      ),
      yaxis = list(
        title = "",
        color = "#94A3B8",
        categoryorder = "array",
        categoryarray = rev(SIZE_LEVELS)
      ),
      font   = list(color = "#F8FAFC", family = "Inter"),
      margin = list(l = 10, r = 60, t = 10, b = 40),
      showlegend = FALSE
    )
  })

  # ---- Feedback UI ----
  output$feedback_ui <- renderUI({
    if (is.null(rv$prediction)) {
      return(p(style = "color:#94A3B8; font-size:0.9rem;",
               "Feedback will appear after a prediction is made."))
    }

    if (rv$feedback_done) {
      return(
        div(style = "color:#10B981; font-weight:600;",
          icon("circle-check"), " Thank you for your feedback.")
      )
    }

    div(
      p(style = "color:#94A3B8; font-size:0.9rem; margin-bottom:1rem;",
        "Was this recommendation correct?"),
      div(class = "d-flex gap-3",
        actionButton("fb_yes", "Yes", class = "btn btn-outline-success"),
        actionButton("fb_no",  "No",  class = "btn btn-outline-danger")
      ),
      uiOutput("feedback_correction")
    )
  })

  output$feedback_correction <- renderUI({
    if (is.null(input$fb_no) || input$fb_no == 0) return(NULL)
    div(class = "mt-3",
      selectInput("actual_size", "What was the actual size?",
        choices = SIZE_LEVELS, selected = NULL),
      actionButton("fb_submit", "Submit",
        class = "btn btn-primary mt-2")
    )
  })

  observeEvent(input$fb_yes, {
    req(rv$prediction)
    save_feedback(
      "data/prediction_feedback.csv",
      input$weight, input$age, input$height,
      rv$prediction$predicted_size,
      rv$prediction$predicted_size
    )
    rv$feedback_done <- TRUE
  })

  observeEvent(input$fb_submit, {
    req(rv$prediction, input$actual_size)
    save_feedback(
      "data/prediction_feedback.csv",
      input$weight, input$age, input$height,
      rv$prediction$predicted_size,
      input$actual_size
    )
    rv$feedback_done <- TRUE
  })

  # ---- Model tab ----
  output$model_table_ui <- renderUI({
    metrics_path <- "outputs/model_metrics.csv"
    if (!file.exists(metrics_path)) {
      return(
        div(class = "limitation-note",
          icon("clock"), " Model evaluation results will appear here after Phase 5 is complete."
        )
      )
    }
    metrics <- read.csv(metrics_path)
    DTOutput("metrics_dt")
  })

  output$metrics_dt <- renderDT({
    req(file.exists("outputs/model_metrics.csv"))
    read.csv("outputs/model_metrics.csv") %>%
      datatable(
        options = list(dom = "t", paging = FALSE),
        rownames = FALSE,
        class = "table-dark"
      )
  })

  output$selected_model_ui <- renderUI({
    if (!model_ready) {
      return(div(class = "limitation-note",
        icon("clock"), " Model not yet trained. Run Phase 4 and 5 first."))
    }
    div(
      div(class = "stat-value mb-2", "Random Forest"),
      p(style = "color:#94A3B8; font-size:0.9rem;",
        "Selected based on highest macro F1-score across all size classes.
         500 decision trees with class weights applied to address XXL imbalance.")
    )
  })

  output$confusion_matrix_ui <- renderUI({
    if (!file.exists("outputs/confusion_matrix.csv")) {
      return(div(class = "limitation-note",
        icon("clock"), " Confusion matrix will appear after Phase 5 is complete."))
    }
    DTOutput("cm_dt")
  })

  output$cm_dt <- renderDT({
    req(file.exists("outputs/confusion_matrix.csv"))
    read.csv("outputs/confusion_matrix.csv", row.names = 1) %>%
      datatable(options = list(dom = "t", paging = FALSE), class = "table-dark")
  })

  # ---- Data Insights charts ----
  make_hist <- function(col, xlab, colour) {
    if (is.null(clean_data)) {
      return(plot_ly() %>% layout(
        paper_bgcolor = "transparent", plot_bgcolor = "transparent",
        annotations = list(list(
          text = "Data not loaded", x = 0.5, y = 0.5,
          xref = "paper", yref = "paper", showarrow = FALSE,
          font = list(color = "#94A3B8")
        ))
      ))
    }
    plot_ly(clean_data, x = as.formula(paste0("~", col)),
      type = "histogram",
      marker = list(color = colour, line = list(color = "#0F172A", width = 0.5))
    ) %>%
    layout(
      paper_bgcolor = "transparent", plot_bgcolor  = "transparent",
      xaxis  = list(title = xlab, color = "#94A3B8", gridcolor = "#1E293B"),
      yaxis  = list(title = "Count", color = "#94A3B8", gridcolor = "#1E293B"),
      font   = list(color = "#F8FAFC", family = "Inter"),
      margin = list(l = 10, r = 10, t = 10, b = 40),
      showlegend = FALSE
    )
  }

  output$size_dist_chart <- renderPlotly({
    if (is.null(clean_data)) return(NULL)
    df <- clean_data %>%
      count(size) %>%
      mutate(size = factor(size, levels = SIZE_LEVELS)) %>%
      arrange(size)

    plot_ly(df, x = ~size, y = ~n, type = "bar",
      marker = list(
        color = c("#06B6D4","#3B82F6","#10B981","#F59E0B",
                  "#F43F5E","#8B5CF6","#EC4899")
      ),
      text = ~n, textposition = "outside",
      hovertemplate = "%{x}: %{y:,}<extra></extra>"
    ) %>%
    layout(
      paper_bgcolor = "transparent", plot_bgcolor = "transparent",
      xaxis  = list(title = "Size", color = "#94A3B8"),
      yaxis  = list(title = "Count", color = "#94A3B8", gridcolor = "#1E293B"),
      font   = list(color = "#F8FAFC", family = "Inter"),
      margin = list(l = 10, r = 10, t = 10, b = 40),
      showlegend = FALSE
    )
  })

  output$weight_chart <- renderPlotly(make_hist("weight", "Weight (kg)", "#3B82F6"))
  output$height_chart <- renderPlotly(make_hist("height", "Height (cm)", "#06B6D4"))
  output$age_chart    <- renderPlotly(make_hist("age",    "Age",         "#10B981"))
}

# =============================================================================
# RUN
# =============================================================================
shinyApp(ui = ui, server = server)
