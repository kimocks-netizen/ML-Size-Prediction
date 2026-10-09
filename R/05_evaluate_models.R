# =============================================================================
# 05_evaluate_models.R
# Phase 5 — Evaluate models, select best, save outputs
# Outputs: outputs/model_metrics.csv
#          outputs/confusion_matrix.csv
#          models/best_model.rds
# =============================================================================

library(tidyverse)
library(caret)
library(ranger)

source("R/helpers.R")

dir.create("outputs", showWarnings = FALSE)

# ---- Load test set and models ----
cat("\n========== LOADING MODELS & TEST DATA ==========\n")
test_df        <- readRDS("models/test_df.rds") %>%
  mutate(size = factor(size, levels = SIZE_LEVELS))
logistic_model <- readRDS("models/logistic_model.rds")
tree_model     <- readRDS("models/decision_tree_model.rds")
rf_model       <- readRDS("models/random_forest_model.rds")
cat("Test rows:", nrow(test_df), "\n")

# ---- Helper: compute metrics from predictions ----
compute_metrics <- function(preds, actuals, model_name) {
  cm      <- confusionMatrix(preds, actuals)
  overall <- cm$overall
  byclass <- cm$byClass  # matrix: rows = classes

  # Macro-averaged F1 (mean across all classes, ignoring NA)
  f1_per_class <- byclass[, "F1"]
  macro_f1     <- mean(f1_per_class, na.rm = TRUE)

  data.frame(
    Model    = model_name,
    Accuracy = round(overall["Accuracy"] * 100, 2),
    Kappa    = round(overall["Kappa"], 4),
    MacroF1  = round(macro_f1, 4),
    stringsAsFactors = FALSE
  )
}

# ---- Logistic Regression ----
cat("\n--- Evaluating Logistic Regression ---\n")
log_preds  <- predict(logistic_model, test_df)
log_preds  <- factor(log_preds, levels = SIZE_LEVELS)
log_metrics <- compute_metrics(log_preds, test_df$size, "Logistic Regression")
print(log_metrics)

# ---- Decision Tree ----
cat("\n--- Evaluating Decision Tree ---\n")
tree_preds  <- predict(tree_model, test_df, type = "class")
tree_preds  <- factor(tree_preds, levels = SIZE_LEVELS)
tree_metrics <- compute_metrics(tree_preds, test_df$size, "Decision Tree")
print(tree_metrics)

# ---- Random Forest ----
cat("\n--- Evaluating Random Forest ---\n")
rf_raw   <- predict(rf_model, data = test_df)$predictions  # probability matrix
rf_preds <- factor(SIZE_LEVELS[apply(rf_raw, 1, which.max)], levels = SIZE_LEVELS)
rf_metrics <- compute_metrics(rf_preds, test_df$size, "Random Forest")
print(rf_metrics)

# ---- Combine and save metrics ----
metrics <- bind_rows(log_metrics, tree_metrics, rf_metrics) %>%
  arrange(desc(MacroF1))

write_csv(metrics, "outputs/model_metrics.csv")
cat("\nSaved: outputs/model_metrics.csv\n")
cat("\nModel comparison:\n")
print(metrics)

# ---- Select best model by macro F1 ----
best_name <- metrics$Model[1]
cat("\nBest model:", best_name, "(MacroF1 =", metrics$MacroF1[1], ")\n")

best_model <- switch(best_name,
  "Random Forest"        = rf_model,
  "Logistic Regression"  = logistic_model,
  "Decision Tree"        = tree_model
)

saveRDS(best_model, "models/best_model.rds")
cat("Saved: models/best_model.rds\n")

# ---- Confusion matrix for best model ----
cat("\n--- Confusion Matrix (", best_name, ") ---\n")
best_preds <- switch(best_name,
  "Random Forest"       = rf_preds,
  "Logistic Regression" = log_preds,
  "Decision Tree"       = tree_preds
)

cm_table <- table(Predicted = best_preds, Actual = test_df$size)
cm_df    <- as.data.frame.matrix(cm_table)
write_csv(cbind(Predicted = rownames(cm_df), cm_df), "outputs/confusion_matrix.csv")
cat("Saved: outputs/confusion_matrix.csv\n")

# Per-class F1 for best model
cat("\nPer-class F1 (", best_name, "):\n")
cm_full     <- confusionMatrix(best_preds, test_df$size)
f1_by_class <- round(cm_full$byClass[, "F1"], 4)
names(f1_by_class) <- SIZE_LEVELS
print(f1_by_class)

# =============================================================================
# Summary
# =============================================================================
cat("\n========== PHASE 5 COMPLETE ==========\n")
cat("Best model:  ", best_name, "\n")
cat("Accuracy:    ", metrics$Accuracy[1], "%\n")
cat("Macro F1:    ", metrics$MacroF1[1], "\n")
cat("\nNext step: shiny::runApp('.')\n")
