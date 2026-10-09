# =============================================================================
# 04_train_models.R
# Phase 4 — Train Logistic Regression, Decision Tree, Random Forest
# Outputs: models/logistic_model.rds
#          models/decision_tree_model.rds
#          models/random_forest_model.rds
# =============================================================================

library(tidyverse)
library(caret)
library(nnet)      # multinom (logistic)
library(rpart)     # decision tree
library(ranger)    # random forest

source("R/helpers.R")

dir.create("models", showWarnings = FALSE)

# ---- Load data ----
cat("\n========== LOADING DATA ==========\n")
df <- read_csv("data/clothing_clean.csv", show_col_types = FALSE) %>%
  mutate(size = factor(size, levels = SIZE_LEVELS))
cat("Rows:", nrow(df), "| Classes:", nlevels(df$size), "\n")

# ---- Train / test split (80/20, stratified) ----
set.seed(SEED)
train_idx <- createDataPartition(df$size, p = 0.8, list = FALSE)
train_df  <- df[train_idx, ]
test_df   <- df[-train_idx, ]
cat("Train:", nrow(train_df), "| Test:", nrow(test_df), "\n")

# Save test split for Phase 5
saveRDS(test_df, "models/test_df.rds")

# ---- Class weights for imbalance (used by ranger) ----
class_counts <- table(train_df$size)
class_weights <- as.numeric(1 / class_counts)
names(class_weights) <- names(class_counts)
cat("\nClass weights:\n")
print(round(class_weights, 5))

# =============================================================================
# MODEL 1 — Multinomial Logistic Regression
# =============================================================================
cat("\n========== MODEL 1: Logistic Regression ==========\n")

logistic_model <- multinom(
  size ~ weight + height + age,
  data    = train_df,
  MaxNWts = 5000,
  maxit   = 300,
  trace   = FALSE
)

saveRDS(logistic_model, "models/logistic_model.rds")
cat("Saved: models/logistic_model.rds\n")

# Quick train accuracy
log_preds <- predict(logistic_model, train_df)
log_acc   <- mean(log_preds == train_df$size)
cat("Train accuracy:", round(log_acc * 100, 2), "%\n")

# =============================================================================
# MODEL 2 — Decision Tree (rpart)
# =============================================================================
cat("\n========== MODEL 2: Decision Tree ==========\n")

tree_model <- rpart(
  size ~ weight + height + age,
  data   = train_df,
  method = "class",
  control = rpart.control(
    cp      = 0.001,
    maxdepth = 15,
    minsplit = 20
  )
)

# Prune to best cp
best_cp    <- tree_model$cptable[which.min(tree_model$cptable[, "xerror"]), "CP"]
tree_model <- prune(tree_model, cp = best_cp)
cat("Best cp:", round(best_cp, 6), "\n")

saveRDS(tree_model, "models/decision_tree_model.rds")
cat("Saved: models/decision_tree_model.rds\n")

tree_preds <- predict(tree_model, train_df, type = "class")
tree_acc   <- mean(tree_preds == train_df$size)
cat("Train accuracy:", round(tree_acc * 100, 2), "%\n")

# =============================================================================
# MODEL 3 — Random Forest (ranger)
# =============================================================================
cat("\n========== MODEL 3: Random Forest ==========\n")
cat("Training with 500 trees — this may take 1-2 minutes...\n")

rf_model <- ranger(
  size ~ weight + height + age,
  data              = train_df,
  num.trees         = 500,
  mtry              = 2,
  min.node.size     = 5,
  class.weights     = class_weights,
  probability       = TRUE,   # needed for predict_size() in prediction.R
  seed              = SEED,
  num.threads       = parallel::detectCores() - 1,
  importance        = "impurity"
)

saveRDS(rf_model, "models/random_forest_model.rds")
cat("Saved: models/random_forest_model.rds\n")

# Train OOB accuracy
cat("OOB prediction error:", round(rf_model$prediction.error * 100, 2), "%\n")
cat("OOB accuracy:        ", round((1 - rf_model$prediction.error) * 100, 2), "%\n")

# Variable importance
cat("\nVariable importance:\n")
print(round(sort(rf_model$variable.importance, decreasing = TRUE), 2))

# =============================================================================
# Summary
# =============================================================================
cat("\n========== PHASE 4 COMPLETE ==========\n")
cat("Models saved to models/\n")
cat("Next step: Run R/05_evaluate_models.R\n")
