# =============================================================================
# mod_feedback.R — Tab 5: Feedback & Retraining
# =============================================================================

RETRAIN_THRESHOLD <- 50
FEEDBACK_PATH     <- "data/prediction_feedback.csv"

feedbackUI <- function(id) {
  ns <- NS(id)
  div(class = "container-fluid py-4",

    # Stat row
    div(class = "row g-3 mb-4",
      div(class = "col-6 col-md-3",
        div(class = "stat-box",
          div(class = "stat-value", uiOutput(ns("fb_total"))),
          div(class = "stat-label", "Total Submissions")
        )
      ),
      div(class = "col-6 col-md-3",
        div(class = "stat-box",
          div(class = "stat-value", uiOutput(ns("fb_correct"))),
          div(class = "stat-label", "Correct Predictions")
        )
      ),
      div(class = "col-6 col-md-3",
        div(class = "stat-box",
          div(class = "stat-value", uiOutput(ns("fb_incorrect"))),
          div(class = "stat-label", "Incorrect Predictions")
        )
      ),
      div(class = "col-6 col-md-3",
        div(class = "stat-box",
          div(class = "stat-value", uiOutput(ns("fb_accuracy"))),
          div(class = "stat-label", "Feedback Accuracy")
        )
      )
    ),

    # Retraining readiness
    div(class = "row g-3 mb-4",
      div(class = "col-12",
        div(class = "card p-4",
          div(class = "d-flex justify-content-between align-items-center mb-2",
            div(class = "section-title mb-0", "Retraining Readiness"),
            uiOutput(ns("fb_ready_badge"))
          ),
          p(style = "color:#94A3B8; font-size:0.85rem; margin-bottom:0.75rem;",
            "Model retraining is recommended once 50 feedback submissions are collected."),
          uiOutput(ns("fb_progress_bar"))
        )
      )
    ),

    # Feedback log
    div(class = "row g-3",
      div(class = "col-12",
        div(class = "card p-4",
          div(class = "d-flex justify-content-between align-items-center mb-3",
            div(class = "section-title mb-0", "Feedback Log"),
            div(class = "d-flex gap-2",
              selectInput(ns("fb_filter"), NULL,
                choices  = c("All" = "all", "Correct" = "correct", "Incorrect" = "incorrect"),
                selected = "all", width = "140px"),
              actionButton(ns("fb_refresh"), "Refresh",
                class = "btn btn-outline-secondary btn-sm", icon = icon("rotate"))
            )
          ),
          DTOutput(ns("fb_table"))
        )
      )
    )
  )
}

feedbackServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    fb_data <- reactive({
      input$fb_refresh
      if (!file.exists(FEEDBACK_PATH)) return(NULL)
      df <- read.csv(FEEDBACK_PATH, stringsAsFactors = FALSE)
      if (nrow(df) == 0) return(NULL)
      df
    })

    output$fb_total <- renderUI({
      df <- fb_data()
      tags$span(if (is.null(df)) 0 else nrow(df), style = "color:#3B82F6;")
    })

    output$fb_correct <- renderUI({
      df <- fb_data()
      n  <- if (is.null(df)) 0 else sum(df$predicted_size == df$actual_size)
      tags$span(n, style = "color:#10B981;")
    })

    output$fb_incorrect <- renderUI({
      df <- fb_data()
      n  <- if (is.null(df)) 0 else sum(df$predicted_size != df$actual_size)
      tags$span(n, style = "color:#F43F5E;")
    })

    output$fb_accuracy <- renderUI({
      df  <- fb_data()
      pct <- if (is.null(df) || nrow(df) == 0) "—" else
        paste0(round(mean(df$predicted_size == df$actual_size) * 100), "%")
      tags$span(pct, style = "color:#F59E0B;")
    })

    output$fb_ready_badge <- renderUI({
      n <- if (is.null(fb_data())) 0 else nrow(fb_data())
      if (n >= RETRAIN_THRESHOLD)
        tags$span(class = "confidence-badge badge-high", icon("circle-check"), " Ready to retrain")
      else
        tags$span(class = "confidence-badge badge-low", icon("clock"), " Not yet ready")
    })

    output$fb_progress_bar <- renderUI({
      n      <- if (is.null(fb_data())) 0 else nrow(fb_data())
      pct    <- min(round(n / RETRAIN_THRESHOLD * 100), 100)
      colour <- if (pct >= 100) "#10B981" else if (pct >= 50) "#F59E0B" else "#3B82F6"
      remaining <- max(RETRAIN_THRESHOLD - n, 0)
      label <- if (remaining == 0)
        paste0(n, " / ", RETRAIN_THRESHOLD, " — threshold reached!")
      else
        paste0(remaining, " more submissions needed to retrain")

      div(
        # Track labels
        div(class = "d-flex justify-content-between align-items-center mb-1",
          div(style = "font-size:0.8rem; color:#94A3B8;", label),
          div(style = paste0("font-size:0.9rem; font-weight:700; color:", colour, ";"),
            paste0(pct, "%"))
        ),
        # Track
        div(class = "progress-track",
          div(class = "progress-fill",
            style = paste0("width:", pct, "%; background:", colour, ";")
          )
        ),
        # Milestone ticks
        div(class = "d-flex justify-content-between mt-1",
          style = "font-size:0.72rem; color:#475569;",
          tags$span("0"),
          tags$span("25%"),
          tags$span("50%"),
          tags$span("75%"),
          tags$span("100%")
        )
      )
    })

    output$fb_progress_label <- renderUI({ NULL })

    output$fb_table <- renderDT({
      input$fb_filter
      df <- fb_data()
      if (is.null(df))
        return(datatable(data.frame(Message = "No feedback submitted yet."),
          options = list(dom = "t"), rownames = FALSE))

      df$correct <- ifelse(
        df$predicted_size == df$actual_size,
        as.character(icon("circle-check", style = "color:#10B981;")),
        as.character(icon("circle-xmark", style = "color:#F43F5E;"))
      )
      df <- df[order(df$timestamp, decreasing = TRUE), ]

      if (!is.null(input$fb_filter) && input$fb_filter == "correct")
        df <- df[df$predicted_size == df$actual_size, ]
      else if (!is.null(input$fb_filter) && input$fb_filter == "incorrect")
        df <- df[df$predicted_size != df$actual_size, ]

      datatable(df,
        options  = list(pageLength = 10, lengthMenu = c(5, 10, 25, 50),
                        dom = "<'d-flex align-items-center gap-2 mb-2'lf>tip",
                        language = list(search = "Search:", lengthMenu = "Show _MENU_")),
        rownames = FALSE, escape = FALSE, class = "table-dark",
        colnames = c("Timestamp", "Weight", "Age", "Height", "Predicted", "Actual", "Correct")
      )
    })
  })
}
