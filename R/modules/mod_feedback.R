# =============================================================================
# mod_feedback.R — Tab 5: Feedback & Retraining
# =============================================================================

RETRAIN_THRESHOLD <- 50
# Use tempdir on shinyapps.io where data/ may not be writable
FEEDBACK_PATH <- tryCatch({
  path <- "data/prediction_feedback.csv"
  write("", file.path(dirname(path), ".write_test"), append = FALSE)
  file.remove(file.path(dirname(path), ".write_test"))
  path
}, error = function(e) file.path(tempdir(), "prediction_feedback.csv"))

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
          div(class = "d-flex flex-wrap justify-content-between align-items-center gap-2 mb-2",
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
          div(class = "d-flex justify-content-between align-items-center mb-2",
            div(class = "section-title mb-0", "Feedback Log"),
            actionButton(ns("fb_refresh"), "Refresh",
              class = "btn btn-outline-secondary btn-sm",
              icon  = icon("rotate"),
              style = "height:31px; padding:0 0.75rem; font-size:0.85rem; line-height:1; display:inline-flex; align-items:center; gap:0.35rem;")
          ),
          div(class = "table-responsive", DTOutput(ns("fb_table")))
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
      df <- tryCatch(
        read.csv(FEEDBACK_PATH, stringsAsFactors = FALSE),
        error = function(e) NULL
      )
      if (is.null(df) || nrow(df) == 0) return(NULL)
      # Ensure correct column names regardless of how file was written
      expected <- c("timestamp","weight","age","height","predicted_size","actual_size")
      if (!all(expected %in% names(df))) names(df) <- expected
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
      div(
        div(style = paste0(
              "background:#1E293B; border-radius:999px; height:16px; overflow:hidden;",
              "border:1px solid #334155;"),
          div(style = paste0(
            "width:", pct, "%; height:16px; border-radius:999px;",
            "background:", colour, ";",
            "box-shadow:0 0 10px ", colour, "80;",
            "transition:width 0.5s ease; min-width:", if (pct > 0) "6px" else "0", ";"
          ))
        ),
        div(style = "margin-top:0.4rem; font-size:0.8rem; color:#94A3B8;",
          uiOutput(session$ns("fb_progress_label")))
      )
    })

    output$fb_progress_label <- renderUI({
      n         <- if (is.null(fb_data())) 0 else nrow(fb_data())
      remaining <- max(RETRAIN_THRESHOLD - n, 0)
      if (remaining == 0)
        tags$span(style = "color:#10B981;",
          paste0(n, " / ", RETRAIN_THRESHOLD, " submissions — threshold reached!"))
      else
        paste0(n, " / ", RETRAIN_THRESHOLD, " submissions — ", remaining, " more needed")
    })

    output$fb_table <- renderDT({
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

      datatable(df,
        options  = list(
          pageLength = 10,
          lengthMenu = c(5, 10, 25, 50),
          dom = "<'d-flex align-items-center gap-2 mb-2'f>ti<'d-flex align-items-center justify-content-between mt-2'lp>",
          language = list(search = "Search:", lengthMenu = "Show _MENU_")
        ),
        rownames = FALSE, escape = FALSE, class = "table-dark",
        colnames = c("Timestamp", "Weight", "Age", "Height", "Predicted", "Actual", "Correct")
      )
    })
  })
}
