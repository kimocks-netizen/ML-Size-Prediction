# =============================================================================
# mod_predict.R — Tab 2: Predict Size
# =============================================================================

predictUI <- function(id) {
  ns <- NS(id)
  div(class = "container-fluid py-4",
    div(class = "row g-4",

      # Input panel
      div(class = "col-md-5",
        div(class = "card p-4 mb-4",
          div(class = "section-title", "Customer Information"),
          numericInput(ns("weight"), "Weight (kg)",
            value = 65, min = WEIGHT_MIN, max = WEIGHT_MAX, step = 1),
          numericInput(ns("height"), "Height (cm)",
            value = 170, min = HEIGHT_MIN, max = HEIGHT_MAX, step = 1),
          numericInput(ns("age"), "Age",
            value = 28, min = AGE_MIN, max = AGE_MAX, step = 1),
          br(),
          actionButton(ns("predict_btn"), "Predict Size",
            class = "btn btn-primary btn-predict w-100",
            icon  = icon("wand-magic-sparkles")),
          br(), br(),
          div(class = "limitation-note",
            icon("triangle-exclamation"), " ",
            "Estimate based on historical patterns. Size standards vary across brands."
          )
        ),
        div(class = "card p-4",
          div(class = "section-title", "Was this correct?"),
          uiOutput(ns("feedback_ui"))
        )
      ),

      # Result panel
      div(class = "col-md-7",
        div(class = "card p-4 mb-4",
          div(class = "section-title", "Prediction Result"),
          uiOutput(ns("result_ui"))
        ),
        div(class = "card p-4",
          div(class = "section-title", "Size Probabilities"),
          plotlyOutput(ns("prob_chart"), height = "300px")
        )
      )
    )
  )
}

predictServer <- function(id, model, model_ready, feedback_trigger) {
  moduleServer(id, function(input, output, session) {

    rv <- reactiveValues(prediction = NULL, feedback_done = FALSE)

    # ---- Prediction ----
    observeEvent(input$predict_btn, {
      rv$feedback_done <- FALSE

      if (!validate_input(input$weight, WEIGHT_MIN, WEIGHT_MAX) ||
          !validate_input(input$height, HEIGHT_MIN, HEIGHT_MAX) ||
          !validate_input(input$age,    AGE_MIN,    AGE_MAX)) {
        showNotification("Please enter valid weight, height and age values.",
                         type = "error", duration = 4)
        return()
      }

      if (!model_ready) {
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
        rv$prediction       <- predict_size(model, input$weight, input$age, input$height)
        rv$prediction$demo  <- FALSE
      }
    })

    # ---- Result UI ----
    output$result_ui <- renderUI({
      if (is.null(rv$prediction)) {
        return(div(style = "text-align:center; padding:2rem; color:#94A3B8;",
          icon("shirt", style = "font-size:3rem; margin-bottom:1rem;"),
          p("Enter your measurements and click Predict Size")
        ))
      }

      p  <- rv$prediction
      cl <- p$conf_level

      div(class = "result-card",
        if (p$demo)
          div(class = "limitation-note mb-3",
            icon("flask"), " Demo mode — model not yet trained. Showing placeholder output."),
        div(class = "result-label", "Recommended Size"),
        div(class = "d-flex align-items-center gap-4 justify-content-center flex-wrap",
          div(
            div(style = "color:#94A3B8; font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; margin-bottom:0.2rem;", "US"),
            div(class = "result-size", style = "font-size:3rem;", p$predicted_size)
          ),
          div(style = "color:#334155; font-size:2rem;", "|"),
          div(
            div(style = "color:#94A3B8; font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; margin-bottom:0.2rem;", "EU"),
            div(class = "result-size", style = "font-size:3rem;", to_eu_size(p$predicted_size))
          )
        ),
        div(class = "result-confidence",
          tags$span(class = paste0("confidence-badge badge-", cl),
            paste0(round(p$probability * 100), "% confidence"))
        ),
        br(),
        p(style = "color:#94A3B8; font-size:0.85rem; margin-top:0.5rem;",
          paste0("Based on weight: ", input$weight, " kg | height: ",
                 input$height, " cm | age: ", input$age)),
        # BMI health insight
        local({
          bmi      <- round(input$weight / (input$height / 100)^2, 1)
          bmi_info <- if (bmi < 18.5) {
            list(cat = "Underweight", colour = "#06B6D4", icon = "weight-scale",
                 advice = paste0("BMI ", bmi, " — Your weight is below the healthy range. ",
                   "Consider a nutrient-rich diet and consult your GP for a personalised health plan."))
          } else if (bmi < 25) {
            list(cat = "Healthy Weight", colour = "#10B981", icon = "circle-check",
                 advice = paste0("BMI ", bmi, " — You are within a healthy weight range. ",
                   "Maintain this with balanced nutrition and regular exercise (150 min/week)."))
          } else if (bmi < 30) {
            list(cat = "Overweight", colour = "#F59E0B", icon = "triangle-exclamation",
                 advice = paste0("BMI ", bmi, " — A calorie-controlled diet and 30 min of daily exercise ",
                   "can help. Consider speaking to your GP for personalised guidance."))
          } else {
            list(cat = "Obese", colour = "#F43F5E", icon = "heart-pulse",
                 advice = paste0("BMI ", bmi, " — Please consult your GP as soon as possible. ",
                   "A structured diet plan and supervised exercise programme are recommended."))
          }
          div(class = "bmi-insight",
            style = paste0("background:", bmi_info$colour, "18; border-left:3px solid ", bmi_info$colour, ";"),
            div(class = "bmi-category", style = paste0("color:", bmi_info$colour, ";"),
              icon(bmi_info$icon), " ", bmi_info$cat),
            div(class = "bmi-advice", bmi_info$advice)
          )
        })
      )
    })

    # ---- Probability chart ----
    output$prob_chart <- renderPlotly({
      if (is.null(rv$prediction)) {
        return(plot_ly() %>% layout(
          paper_bgcolor = "transparent", plot_bgcolor = "transparent",
          xaxis = list(visible = FALSE), yaxis = list(visible = FALSE),
          annotations = list(list(
            text = "Make a prediction to see probabilities",
            x = 0.5, y = 0.5, xref = "paper", yref = "paper",
            showarrow = FALSE, font = list(color = "#94A3B8", size = 14)
          ))
        ))
      }

      probs     <- rv$prediction$all_probs
      df        <- data.frame(size = factor(SIZE_LEVELS, levels = SIZE_LEVELS),
                              prob = as.numeric(probs) * 100)
      df$colour <- ifelse(df$size == rv$prediction$predicted_size, "#3B82F6", "#334155")
      df$label  <- paste0(as.character(df$size), " / ", US_TO_EU[as.character(df$size)])
      df$label  <- factor(df$label, levels = df$label)

      plot_ly(df, x = ~prob, y = ~label, type = "bar", orientation = "h",
        marker = list(color = ~colour),
        text = ~paste0(round(prob, 1), "%"), textposition = "outside",
        hovertemplate = "%{y}: %{x:.1f}%<extra></extra>"
      ) %>%
      layout(
        paper_bgcolor = "transparent", plot_bgcolor = "transparent",
        xaxis = list(title = "Probability (%)", color = "#94A3B8",
                     gridcolor = "#1E293B", range = c(0, 105)),
        yaxis = list(title = "", color = "#94A3B8",
                     categoryorder = "array", categoryarray = rev(levels(df$label)),
                     ticklabelposition = "outside", ticklen = 8),
        font = list(color = "#F8FAFC", family = "Inter"),
        margin = list(l = 60, r = 60, t = 10, b = 40),
        showlegend = FALSE
      )
    })

    # ---- Feedback UI ----
    output$feedback_ui <- renderUI({
      if (is.null(rv$prediction))
        return(p(style = "color:#94A3B8; font-size:0.9rem;",
                 "Feedback will appear after a prediction is made."))

      if (rv$feedback_done)
        return(div(style = "color:#10B981; font-weight:600;",
          icon("circle-check"), " Thank you for your feedback."))

      div(
        p(style = "color:#94A3B8; font-size:0.9rem; margin-bottom:1rem;",
          "Was this recommendation correct?"),
        div(class = "d-flex gap-3",
          actionButton(session$ns("fb_yes"), "Yes", class = "btn btn-outline-success"),
          actionButton(session$ns("fb_no"),  "No",  class = "btn btn-outline-danger")
        ),
        uiOutput(session$ns("feedback_correction"))
      )
    })

    output$feedback_correction <- renderUI({
      if (is.null(input$fb_no) || input$fb_no == 0) return(NULL)
      div(class = "mt-3",
        selectInput(session$ns("actual_size"), "What was the actual size?",
          choices = SIZE_LEVELS, selected = NULL),
        actionButton(session$ns("fb_submit"), "Submit", class = "btn btn-primary mt-2")
      )
    })

    observeEvent(input$fb_yes, {
      req(rv$prediction)
      save_feedback("data/prediction_feedback.csv",
        input$weight, input$age, input$height,
        rv$prediction$predicted_size, rv$prediction$predicted_size)
      rv$feedback_done <- TRUE
      feedback_trigger(feedback_trigger() + 1)
    })

    observeEvent(input$fb_submit, {
      req(rv$prediction, input$actual_size)
      save_feedback("data/prediction_feedback.csv",
        input$weight, input$age, input$height,
        rv$prediction$predicted_size, input$actual_size)
      rv$feedback_done <- TRUE
      feedback_trigger(feedback_trigger() + 1)
    })
  })
}
