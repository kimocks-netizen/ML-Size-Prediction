# =============================================================================
# mod_model.R — Tab 3: Model Performance
# =============================================================================

modelUI <- function(id) {
  ns <- NS(id)
  div(class = "container-fluid py-4",

    div(class = "row g-3 mb-4",
      div(class = "col-12",
        div(class = "card p-4",
          div(class = "section-title", "Model Comparison"),
          uiOutput(ns("model_table_ui"))
        )
      )
    ),

    div(class = "row g-3",
      div(class = "col-md-4",
        div(class = "card p-4",
          div(class = "section-title", "Selected Model"),
          uiOutput(ns("selected_model_ui"))
        )
      ),
      div(class = "col-md-8",
        div(class = "card p-4",
          div(class = "section-title", "Confusion Matrix"),
          uiOutput(ns("confusion_matrix_ui"))
        )
      )
    )
  )
}

modelServer <- function(id, model_ready) {
  moduleServer(id, function(input, output, session) {

    output$model_table_ui <- renderUI({
      if (!file.exists("outputs/model_metrics.csv"))
        return(div(class = "limitation-note",
          icon("clock"), " Model evaluation results will appear here after Phase 5 is complete."))
      DTOutput(session$ns("metrics_dt"))
    })

    output$metrics_dt <- renderDT({
      req(file.exists("outputs/model_metrics.csv"))
      read.csv("outputs/model_metrics.csv") %>%
        datatable(options = list(dom = "t", paging = FALSE),
                  rownames = FALSE, class = "table-dark")
    })

    output$selected_model_ui <- renderUI({
      if (!model_ready)
        return(div(class = "limitation-note",
          icon("clock"), " Model not yet trained. Run Phase 4 and 5 first."))

      div(
        div(class = "d-flex justify-content-between align-items-center mb-2",
          div(style = "font-size:1.1rem; font-weight:700; color:#F8FAFC;", "Logistic Regression"),
          tags$span(class = "confidence-badge badge-high", "Best Model")
        ),
        div(class = "d-flex flex-column gap-2 mt-3",
          div(style = "background:#0F172A; border-radius:8px; padding:0.6rem 0.9rem;",
            div(style = "font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:0.08em;", "Macro F1 Score"),
            div(style = "font-size:1.3rem; font-weight:700; color:#3B82F6;", "0.3763")
          ),
          div(style = "background:#0F172A; border-radius:8px; padding:0.6rem 0.9rem;",
            div(style = "font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:0.08em;", "Test Accuracy"),
            div(style = "font-size:1.3rem; font-weight:700; color:#10B981;", "43.21%")
          ),
          div(style = "background:#0F172A; border-radius:8px; padding:0.6rem 0.9rem;",
            div(style = "font-size:0.72rem; color:#94A3B8; text-transform:uppercase; letter-spacing:0.08em;", "Selection Criterion"),
            div(style = "font-size:0.85rem; color:#F8FAFC; margin-top:0.2rem;", "Highest macro F1 across 7 size classes")
          )
        )
      )
    })

    output$confusion_matrix_ui <- renderUI({
      if (!file.exists("outputs/confusion_matrix.csv"))
        return(div(class = "limitation-note",
          icon("clock"), " Confusion matrix will appear after Phase 5 is complete."))
      DTOutput(session$ns("cm_dt"))
    })

    output$cm_dt <- renderDT({
      req(file.exists("outputs/confusion_matrix.csv"))
      read.csv("outputs/confusion_matrix.csv", row.names = 1) %>%
        datatable(options = list(dom = "t", paging = FALSE), class = "table-dark")
    })
  })
}
