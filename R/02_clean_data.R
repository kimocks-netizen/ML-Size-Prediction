# =============================================================================
# 02_clean_data.R
# Phase 2 — Data Cleaning
# Output: data/clothing_clean.csv, data/prediction_feedback.csv (headers only)
# clothing_raw.csv is NEVER modified
# =============================================================================

library(tidyverse)

RAW_PATH      <- "data/clothing_raw.csv"
CLEAN_PATH    <- "data/clothing_clean.csv"
FEEDBACK_PATH <- "data/prediction_feedback.csv"
SIZE_LEVELS   <- c("XXS", "S", "M", "L", "XL", "XXL", "XXXL")

cat("\n========== LOADING RAW DATA ==========\n")
raw <- read_csv(RAW_PATH, show_col_types = FALSE)
cat("Raw rows:", nrow(raw), "\n")

# =============================================================================
# STEP 1 — Remove exact duplicates
# =============================================================================
cat("\n========== STEP 1: REMOVE EXACT DUPLICATES ==========\n")
deduped <- raw %>% distinct()
removed_dupes <- nrow(raw) - nrow(deduped)
cat("Rows removed :", removed_dupes, "\n")
cat("Rows remaining:", nrow(deduped), "\n")

# =============================================================================
# STEP 2 — Investigate and handle missing values
# =============================================================================
cat("\n========== STEP 2: MISSING VALUES ==========\n")
cat("Missing age   :", sum(is.na(deduped$age)), "\n")
cat("Missing height:", sum(is.na(deduped$height)), "\n")
cat("Missing weight:", sum(is.na(deduped$weight)), "\n")
cat("Missing size  :", sum(is.na(deduped$size)), "\n")

# Decision: impute missing age and height with their medians.
# Median is preferred over mean because it is robust to skew.
# The number of missing values is small relative to the dataset size.
age_median    <- median(deduped$age,    na.rm = TRUE)
height_median <- median(deduped$height, na.rm = TRUE)

cat("Imputing missing age    with median:", age_median, "\n")
cat("Imputing missing height with median:", height_median, "\n")

cleaned <- deduped %>%
  mutate(
    age    = if_else(is.na(age),    age_median,    age),
    height = if_else(is.na(height), height_median, height)
  )

cat("Missing values after imputation:", sum(is.na(cleaned)), "\n")

# =============================================================================
# STEP 3 — Investigate unusual values
# =============================================================================
cat("\n========== STEP 3: UNUSUAL VALUES ==========\n")

unusual_weight <- cleaned %>% filter(weight <= 0 | weight > 300)
unusual_height <- cleaned %>% filter(height <= 0 | height > 250)
unusual_age    <- cleaned %>% filter(age <= 0 | age > 120)

cat("Weight outside (0, 300]:", nrow(unusual_weight), "\n")
cat("Height outside (0, 250]:", nrow(unusual_height), "\n")
cat("Age outside (0, 120]   :", nrow(unusual_age), "\n")

if (nrow(unusual_age) > 0) {
  cat("\nUnusual age rows:\n")
  print(unusual_age %>% arrange(age))
  # Decision: remove biologically implausible ages only (<=0 or >120)
  cleaned <- cleaned %>% filter(age > 0 & age <= 120)
  cat("Rows removed for implausible age:", nrow(deduped) - nrow(cleaned), "\n")
}

# =============================================================================
# STEP 4 — Investigate ambiguous observations
# =============================================================================
cat("\n========== STEP 4: AMBIGUOUS OBSERVATIONS ==========\n")
# Same weight + age + height mapped to more than one size label
ambiguous <- cleaned %>%
  group_by(weight, age, height) %>%
  summarise(n_sizes = n_distinct(size), .groups = "drop") %>%
  filter(n_sizes > 1)

cat("Ambiguous combos (same inputs, different sizes):", nrow(ambiguous), "\n")
cat("Rows affected:", sum(ambiguous$n_sizes), "\n")

# Decision: retain ambiguous observations.
# Removing them would discard valid data. The ambiguity reflects real-world
# variation in sizing and will be disclosed as a dataset limitation in the report.
# The model will learn the most probable label from the distribution.
cat("Decision: retaining ambiguous observations (disclosed as limitation)\n")

# =============================================================================
# STEP 5 — Encode size as ordered factor
# =============================================================================
cat("\n========== STEP 5: ENCODE TARGET VARIABLE ==========\n")
cleaned <- cleaned %>%
  mutate(size = factor(size, levels = SIZE_LEVELS, ordered = TRUE))

cat("Size levels:", paste(levels(cleaned$size), collapse = " < "), "\n")
cat("Any NA in size after encoding:", sum(is.na(cleaned$size)), "\n")

# =============================================================================
# STEP 6 — Final class distribution
# =============================================================================
cat("\n========== STEP 6: FINAL CLASS DISTRIBUTION ==========\n")
size_dist <- cleaned %>%
  count(size, name = "n") %>%
  mutate(pct = round(n / sum(n) * 100, 2))
print(size_dist)
cat("Imbalance ratio (max/min):",
    round(max(size_dist$n) / min(size_dist$n), 1), ":1\n")

# =============================================================================
# STEP 7 — Final dataset summary
# =============================================================================
cat("\n========== STEP 7: FINAL DATASET SUMMARY ==========\n")
cat("Final rows  :", nrow(cleaned), "\n")
cat("Columns     :", paste(names(cleaned), collapse = ", "), "\n")
cat("Missing vals:", sum(is.na(cleaned)), "\n")

cat("\nNumeric ranges:\n")
cat("  weight — min:", min(cleaned$weight), "| max:", max(cleaned$weight),
    "| mean:", round(mean(cleaned$weight), 1), "\n")
cat("  height — min:", min(cleaned$height), "| max:", max(cleaned$height),
    "| mean:", round(mean(cleaned$height), 1), "\n")
cat("  age    — min:", min(cleaned$age),    "| max:", max(cleaned$age),
    "| mean:", round(mean(cleaned$age), 1), "\n")

# =============================================================================
# STEP 8 — Write outputs
# =============================================================================
cat("\n========== STEP 8: WRITING OUTPUTS ==========\n")

write_csv(cleaned, CLEAN_PATH)
cat("Written:", CLEAN_PATH, "(", nrow(cleaned), "rows )\n")

# Initialise feedback file with headers only if it doesn't already exist
if (!file.exists(FEEDBACK_PATH) || file.size(FEEDBACK_PATH) == 0) {
  write_csv(
    tibble(
      timestamp      = character(),
      weight         = numeric(),
      age            = numeric(),
      height         = numeric(),
      predicted_size = character(),
      actual_size    = character()
    ),
    FEEDBACK_PATH
  )
  cat("Initialised:", FEEDBACK_PATH, "(headers only)\n")
}

cat("\n✓ Phase 2 complete. Run R/03_exploratory_analysis.R next.\n")
