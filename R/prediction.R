# =============================================================================
# prediction.R
# Model loading and prediction logic for the Shiny app
# =============================================================================

source("R/helpers.R")

# Load the best saved model once at startup
load_model <- function(path = "models/best_model.rds") {
  if (!file.exists(path)) return(NULL)
  readRDS(path)
}

# Run prediction and return a named list with predicted size + probabilities
predict_size <- function(model, weight, age, height) {
  new_obs <- data.frame(weight = weight, age = age, height = height)

  # ranger returns a prediction object with $predictions matrix
  raw <- predict(model, data = new_obs)$predictions

  probs       <- as.numeric(raw[1, ])
  names(probs) <- SIZE_LEVELS

  top_idx     <- which.max(probs)
  pred_size   <- SIZE_LEVELS[top_idx]
  top_prob    <- probs[top_idx]
  conf_level  <- confidence_level(top_prob)

  list(
    predicted_size = pred_size,
    probability    = top_prob,
    conf_level     = conf_level,
    all_probs      = probs
  )
}

# Write one feedback row to CSV
save_feedback <- function(path, weight, age, height,
                          predicted_size, actual_size) {
  row <- data.frame(
    timestamp      = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    weight         = weight,
    age            = age,
    height         = height,
    predicted_size = predicted_size,
    actual_size    = actual_size,
    stringsAsFactors = FALSE
  )
  write.table(row, path,
    sep = ",", append = TRUE,
    col.names = FALSE, row.names = FALSE, quote = TRUE
  )
}
