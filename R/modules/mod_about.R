# =============================================================================
# mod_about.R — Tab 6: About (static UI, no server)
# =============================================================================

aboutUI <- function(id) {
  ns <- NS(id)
  div(class = "container-fluid py-4",

    # Top two columns
    div(class = "row g-4 mb-4",

      # Left column
      div(class = "col-md-6",
        div(class = "card p-4 mb-4",
          div(class = "section-title", "Project"),
          tags$table(class = "table table-sm",
            style = "color:#94A3B8; font-size:0.9rem;",
            tags$tbody(
              tags$tr(tags$td("Module"),   tags$td("Business Intelligence (6029CMD)")),
              tags$tr(tags$td("Title"),    tags$td("ML-Based Clothing Size Prediction")),
              tags$tr(tags$td("Model"),    tags$td("Supervised Multiclass Classification")),
              tags$tr(tags$td("Target"),   tags$td("XXS, S, M, L, XL, XXL, XXXL")),
              tags$tr(tags$td("Inputs"),   tags$td("Weight (kg), Height (cm), Age, BMI")),
              tags$tr(tags$td("Live URL"), tags$td(
                tags$a("sizepredictionml.shinyapps.io",
                  href = "https://sizepredictionml.shinyapps.io/ML-Size-Prediction/",
                  target = "_blank", style = "color:#3B82F6;")
              ))
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
            tags$li("Height values originate from inch measurements converted to cm"),
            tags$li("Dataset reflects women's sizing — EU conversion uses women's standard")
          )
        )
      ),

      # Right column
      div(class = "col-md-6",
        div(class = "card p-4 mb-4",
          div(class = "section-title", "Dataset"),
          tags$table(class = "table table-sm",
            style = "color:#94A3B8; font-size:0.9rem;",
            tags$tbody(
              tags$tr(tags$td("Raw records"),        tags$td("119,734")),
              tags$tr(tags$td("After cleaning"),     tags$td("27,391")),
              tags$tr(tags$td("Duplicates removed"), tags$td("92,330 (77.1%)")),
              tags$tr(tags$td("Missing values"),     tags$td("Imputed with column median")),
              tags$tr(tags$td("Height encoding"),    tags$td("Inches converted to cm (×2.54)")),
              tags$tr(tags$td("Class imbalance"),    tags$td("XXL: 67 records vs XXXL: 6,766"))
            )
          )
        ),
        div(class = "card p-4",
          div(class = "section-title", "AI Use Acknowledgement"),
          tags$table(class = "table table-sm",
            style = "color:#94A3B8; font-size:0.85rem;",
            tags$thead(tags$tr(tags$th("Tool"), tags$th("How used"))),
            tags$tbody(
              tags$tr(tags$td("Copilot"), tags$td("Project planning")),
              tags$tr(tags$td("ChatGPT"), tags$td("Data analysis and identifying suitable model algorithms and equations")),
              tags$tr(tags$td("Claude"),  tags$td("Guidance on integrating ML model equations with the dataset")),
              tags$tr(
                tags$td(tags$a("YouTube",
                  href = "https://www.youtube.com/watch?v=jxsKUxkiaLI",
                  target = "_blank", style = "color:#3B82F6;")),
                tags$td("Learning R Shiny application development")
              )
            )
          )
        )
      )
    ),

    # Full-width Size Conversion strip
    div(class = "row",
      div(class = "col-12",
        div(class = "card p-3",
          div(class = "section-title", "Size Conversion"),
          tags$table(
            style = "width:100%; border-collapse:separate; border-spacing:4px;",
            tags$thead(
              tags$tr(
                lapply(names(US_TO_EU), function(us)
                  tags$th(us, style = "
                    text-align:center; background:#0F172A; color:#F8FAFC;
                    font-size:0.95rem; font-weight:700; padding:0.55rem 0;
                    border-radius:6px 6px 0 0; border-bottom:2px solid #3B82F6;
                  ")
                )
              )
            ),
            tags$tbody(
              tags$tr(
                lapply(names(US_TO_EU), function(us)
                  tags$td(US_TO_EU[[us]], style = "
                    text-align:center; background:#0F172A; color:#3B82F6;
                    font-size:0.9rem; font-weight:600; padding:0.45rem 0;
                    border-radius:0 0 6px 6px;
                  ")
                )
              )
            )
          ),
          div(class = "d-flex justify-content-between mt-2 px-1",
            tags$span(style = "font-size:0.7rem; color:#475569;", "US Size"),
            tags$span(style = "font-size:0.7rem; color:#475569;", "EU Women's Standard")
          )
        )
      )
    )
  )
}
