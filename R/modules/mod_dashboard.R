# =============================================================================
# mod_dashboard.R — Tab 1: Dashboard
# =============================================================================

dashboardUI <- function(id) {
  ns <- NS(id)
  div(class = "container-fluid py-4",

    # Hero
    div(class = "row mb-4",
      div(class = "col-12",
        div(class = "card p-4",
          div(class = "d-flex align-items-center gap-3 mb-3",
            tags$img(src = "logo/logo.png", height = "64px",
                     style = "border-radius:10px;"),
            div(
              h2("Clothing Size Prediction",
                 style = "color:#3B82F6; font-weight:800; margin-bottom:0.15rem;"),
              p("Machine Learning Decision Support System",
                style = "color:#94A3B8; font-size:1rem; margin:0;")
            )
          ),
          p("A supervised machine learning model trained on historical clothing data
             to predict the most likely size category from customer weight, height and age.
             Built for Business Intelligence module 6029CMD.",
            style = "color:#F8FAFC; max-width:700px; margin:0;")
        )
      )
    ),

    # Stat boxes
    div(class = "row g-3 mb-4",
      div(class = "col-6 col-md-3",
        div(class = "stat-box",
          div(class = "stat-value", uiOutput(ns("total_records"))),
          div(class = "stat-label", "Training Records")
        )
      ),
      div(class = "col-6 col-md-3",
        div(class = "stat-box",
          div(class = "stat-value", uiOutput(ns("n_classes"))),
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
          div(class = "stat-value", uiOutput(ns("model_status"))),
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
                list("1. Data", "#3B82F6"), list("→", "#334155"),
                list("2. Clean", "#3B82F6"), list("→", "#334155"),
                list("3. EDA", "#3B82F6"), list("→", "#334155"),
                list("4. Train", "#3B82F6"), list("→", "#334155"),
                list("5. Evaluate", "#3B82F6"), list("→", "#334155"),
                list("6. Deploy", "#10B981")
              ),
              function(x) tags$span(x[[1]], style = paste0("color:", x[[2]], "; font-weight:600;"))
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
          div(class = "d-flex flex-nowrap gap-2 mb-3 align-items-center",
            tags$span(class = "input-pill",
              tags$span(style = "color:#06B6D4;", icon("scale-balanced")), " Weight (kg), ",
              tags$span(class = "pill-value", uiOutput(ns("pill_weight")))),
            tags$span(class = "input-pill",
              tags$span(style = "color:#3B82F6;", icon("arrows-up-down")), " Height (cm), ",
              tags$span(class = "pill-value", uiOutput(ns("pill_height")))),
            tags$span(class = "input-pill",
              tags$span(style = "color:#10B981;", icon("user")), " Age, ",
              tags$span(class = "pill-value", uiOutput(ns("pill_age")))),
            tags$span(class = "input-pill",
              tags$span(style = "color:#F59E0B;", icon("heart-pulse")), " BMI (auto) - ",
              tags$span(class = "pill-value", uiOutput(ns("pill_bmi"))))
          ),
          p(style = "color:#94A3B8; font-size:0.75rem; margin-bottom:0.5rem;",
            icon("arrow-right"), " Predicted size output:"),
          div(class = "d-flex flex-wrap gap-1",
            lapply(SIZE_LEVELS, function(s)
              tags$span(class = "input-pill input-pill-output", s)
            )
          )
        )
      )
    )
  )
}

dashboardServer <- function(id, clean_data, model_ready) {
  moduleServer(id, function(input, output, session) {

    output$total_records <- renderUI({
      if (!is.null(clean_data)) nrow(clean_data) else "—"
    })

    output$n_classes <- renderUI({ length(SIZE_LEVELS) })

    output$model_status <- renderUI({
      if (model_ready)
        tags$span(icon("circle-check"), style = "color:#10B981;")
      else
        tags$span(icon("clock"), style = "color:#F59E0B;")
    })

    # Static default pill values (mirrors Predict tab defaults)
    output$pill_weight <- renderUI(NULL)
    output$pill_height <- renderUI(NULL)
    output$pill_age    <- renderUI(NULL)
    output$pill_bmi    <- renderUI(tags$span("weight ÷ height²"))
  })
}
