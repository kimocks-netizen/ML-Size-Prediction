# =============================================================================
# mod_insights.R — Tab 4: Data Insights
# =============================================================================

insightsUI <- function(id) {
  ns <- NS(id)
  div(class = "container-fluid py-4",

    div(class = "row g-3 mb-4",
      div(class = "col-12",
        div(class = "card p-4",
          div(class = "d-flex justify-content-between align-items-center mb-3",
            div(class = "section-title mb-0", "Size Class Distribution"),
            downloadButton(ns("download_plots"),
              tags$span(class = "d-none d-sm-inline", "Download All Plots"),
              class = "btn btn-outline-secondary btn-sm", icon = icon("download"))
          ),
          plotlyOutput(ns("size_dist_chart"), height = "320px")
        )
      )
    ),

    div(class = "row g-3",
      div(class = "col-md-4",
        div(class = "card p-4",
          div(class = "section-title", "Weight Distribution"),
          plotlyOutput(ns("weight_chart"), height = "260px")
        )
      ),
      div(class = "col-md-4",
        div(class = "card p-4",
          div(class = "section-title", "Height Distribution"),
          plotlyOutput(ns("height_chart"), height = "260px")
        )
      ),
      div(class = "col-md-4",
        div(class = "card p-4",
          div(class = "section-title", "Age Distribution"),
          plotlyOutput(ns("age_chart"), height = "260px")
        )
      )
    )
  )
}

insightsServer <- function(id, clean_data) {
  moduleServer(id, function(input, output, session) {

    make_hist <- function(col, xlab, colour) {
      if (is.null(clean_data))
        return(plot_ly() %>% layout(
          paper_bgcolor = "transparent", plot_bgcolor = "transparent",
          annotations = list(list(text = "Data not loaded", x = 0.5, y = 0.5,
            xref = "paper", yref = "paper", showarrow = FALSE,
            font = list(color = "#94A3B8")))
        ))
      plot_ly(clean_data, x = as.formula(paste0("~", col)),
        type = "histogram",
        marker = list(color = colour, line = list(color = "#0F172A", width = 0.5))
      ) %>%
      layout(
        paper_bgcolor = "transparent", plot_bgcolor = "transparent",
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
        marker = list(color = c("#06B6D4","#3B82F6","#10B981","#F59E0B",
                                "#F43F5E","#8B5CF6","#EC4899")),
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

    output$download_plots <- downloadHandler(
      filename = function() paste0("eda_plots_", format(Sys.Date(), "%Y%m%d"), ".zip"),
      content  = function(file) {
        plots <- list.files("outputs/figures", pattern = "\\.png$", full.names = TRUE)
        if (length(plots) == 0) {
          writeLines("No EDA plots found. Run R/03_exploratory_analysis.R first.", con = file)
          return()
        }
        zip(file, files = plots, flags = "-j")
      },
      contentType = "application/zip"
    )
  })
}
