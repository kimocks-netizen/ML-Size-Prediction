# =============================================================================
# 01_inspect_data.R
# Phase 1 — Data Inspection
# Purpose: Profile clothing_raw.csv. No files are written.
# =============================================================================

library(tidyverse)

RAW_PATH <- "data/clothing_raw.csv"
SIZE_LEVELS <- c("XXS", "S", "M", "L", "XL", "XXL", "XXXL")

# -----------------------------------------------------------------------------
# 1. Load
# -----------------------------------------------------------------------------
cat("\n========== 1. LOAD ==========\n")
raw <- read_csv(RAW_PATH, show_col_types = FALSE)
cat("Rows   :", nrow(raw), "\n")
cat("Columns:", ncol(raw), "\n")
cat("Names  :", paste(names(raw), collapse = ", "), "\n")

# -----------------------------------------------------------------------------
# 2. Column types & head
# -----------------------------------------------------------------------------
cat("\n========== 2. STRUCTURE ==========\n")
glimpse(raw)

cat("\n--- First 6 rows ---\n")
print(head(raw))

cat("\n--- Last 6 rows ---\n")
print(tail(raw))

# -----------------------------------------------------------------------------
# 3. Summary statistics
# -----------------------------------------------------------------------------
cat("\n========== 3. SUMMARY STATISTICS ==========\n")
print(summary(raw))

# -----------------------------------------------------------------------------
# 4. Missing values
# -----------------------------------------------------------------------------
cat("\n========== 4. MISSING VALUES ==========\n")
missing_counts <- raw %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing")

print(missing_counts)
cat("Total missing cells:", sum(missing_counts$missing), "\n")

# -----------------------------------------------------------------------------
# 5. Exact duplicates
# -----------------------------------------------------------------------------
cat("\n========== 5. EXACT DUPLICATES ==========\n")
n_dupes <- sum(duplicated(raw))
n_unique <- nrow(raw) - n_dupes
cat("Total rows         :", nrow(raw), "\n")
cat("Exact duplicates   :", n_dupes, "\n")
cat("Unique rows        :", n_unique, "\n")
cat("Duplicate rate     :", round(n_dupes / nrow(raw) * 100, 1), "%\n")

# -----------------------------------------------------------------------------
# 6. Size class distribution
# -----------------------------------------------------------------------------
cat("\n========== 6. SIZE CLASS DISTRIBUTION ==========\n")
size_dist <- raw %>%
  count(size, name = "n") %>%
  mutate(
    pct       = round(n / sum(n) * 100, 2),
    size      = factor(size, levels = SIZE_LEVELS)
  ) %>%
  arrange(size)

print(size_dist)

cat("\nSmallest class:", size_dist$size[which.min(size_dist$n)],
    "—", min(size_dist$n), "records\n")
cat("Largest class :", size_dist$size[which.max(size_dist$n)],
    "—", max(size_dist$n), "records\n")
cat("Imbalance ratio (max/min):", round(max(size_dist$n) / min(size_dist$n), 1), "\n")

# -----------------------------------------------------------------------------
# 7. Numeric ranges — weight, height, age
# -----------------------------------------------------------------------------
cat("\n========== 7. NUMERIC RANGES ==========\n")

range_summary <- raw %>%
  summarise(
    weight_min = min(weight, na.rm = TRUE),
    weight_max = max(weight, na.rm = TRUE),
    weight_mean = round(mean(weight, na.rm = TRUE), 2),
    weight_sd   = round(sd(weight, na.rm = TRUE), 2),
    height_min  = min(height, na.rm = TRUE),
    height_max  = max(height, na.rm = TRUE),
    height_mean = round(mean(height, na.rm = TRUE), 2),
    height_sd   = round(sd(height, na.rm = TRUE), 2),
    age_min     = min(age, na.rm = TRUE),
    age_max     = max(age, na.rm = TRUE),
    age_mean    = round(mean(age, na.rm = TRUE), 2),
    age_sd      = round(sd(age, na.rm = TRUE), 2)
  )

cat("Weight (kg) — min:", range_summary$weight_min,
    "| max:", range_summary$weight_max,
    "| mean:", range_summary$weight_mean,
    "| sd:", range_summary$weight_sd, "\n")

cat("Height (cm) — min:", range_summary$height_min,
    "| max:", range_summary$height_max,
    "| mean:", range_summary$height_mean,
    "| sd:", range_summary$height_sd, "\n")

cat("Age         — min:", range_summary$age_min,
    "| max:", range_summary$age_max,
    "| mean:", range_summary$age_mean,
    "| sd:", range_summary$age_sd, "\n")

# -----------------------------------------------------------------------------
# 8. Height decimal precision — check for inch-converted values
# -----------------------------------------------------------------------------
cat("\n========== 8. HEIGHT DECIMAL PRECISION ==========\n")
height_decimals <- raw %>%
  filter(!is.na(height)) %>%
  mutate(decimal_part = height - floor(height)) %>%
  count(decimal_part, name = "n") %>%
  arrange(desc(n)) %>%
  head(20)

cat("Top 20 most common decimal parts in height:\n")
print(height_decimals)

# Check if heights cluster around inch-to-cm conversion values
# 1 inch = 2.54 cm, so converted heights will have .xx decimals like .72, .64 etc.
inch_pattern <- raw %>%
  filter(!is.na(height)) %>%
  mutate(
    possible_inches = height / 2.54,
    is_whole_inch   = abs(possible_inches - round(possible_inches)) < 0.01
  ) %>%
  summarise(
    total           = n(),
    whole_inch_hits = sum(is_whole_inch),
    pct             = round(mean(is_whole_inch) * 100, 1)
  )

cat("\nRows where height appears to be a whole-inch converted to cm:",
    inch_pattern$whole_inch_hits, "/", inch_pattern$total,
    "(", inch_pattern$pct, "%)\n")

# -----------------------------------------------------------------------------
# 9. Unusual / suspicious values
# -----------------------------------------------------------------------------
cat("\n========== 9. UNUSUAL VALUES ==========\n")

unusual_weight <- raw %>% filter(weight <= 0 | weight > 300)
unusual_height <- raw %>% filter(!is.na(height) & (height <= 0 | height > 250))
unusual_age    <- raw %>% filter(!is.na(age) & (age <= 0 | age > 120))

cat("Weight outside (0, 300]:", nrow(unusual_weight), "rows\n")
cat("Height outside (0, 250]:", nrow(unusual_height), "rows\n")
cat("Age outside (0, 120]   :", nrow(unusual_age), "rows\n")

if (nrow(unusual_age) > 0) {
  cat("\nUnusual age values:\n")
  print(unusual_age %>% select(weight, age, height, size) %>% arrange(age))
}

# -----------------------------------------------------------------------------
# 10. Ambiguous observations (same inputs → different sizes)
# -----------------------------------------------------------------------------
cat("\n========== 10. AMBIGUOUS OBSERVATIONS ==========\n")

ambiguous <- raw %>%
  drop_na(weight, age, height) %>%
  group_by(weight, age, height) %>%
  summarise(
    n_records    = n(),
    n_sizes      = n_distinct(size),
    sizes_found  = paste(sort(unique(size)), collapse = ", "),
    .groups      = "drop"
  ) %>%
  filter(n_sizes > 1) %>%
  arrange(desc(n_records))

cat("Unique (weight, age, height) combos with >1 size label:",
    nrow(ambiguous), "\n")
cat("Total rows affected:", sum(ambiguous$n_records), "\n")

if (nrow(ambiguous) > 0) {
  cat("\nTop 10 most ambiguous combinations:\n")
  print(head(ambiguous, 10))
}

# -----------------------------------------------------------------------------
# 11. Unique combinations after deduplication (preview)
# -----------------------------------------------------------------------------
cat("\n========== 11. POST-DEDUP PREVIEW ==========\n")
deduped_preview <- raw %>% distinct()
cat("Rows after removing exact duplicates:", nrow(deduped_preview), "\n")

size_dist_deduped <- deduped_preview %>%
  count(size, name = "n") %>%
  mutate(
    pct  = round(n / sum(n) * 100, 2),
    size = factor(size, levels = SIZE_LEVELS)
  ) %>%
  arrange(size)

cat("\nSize distribution after deduplication:\n")
print(size_dist_deduped)

# -----------------------------------------------------------------------------
# 12. Inspection summary
# -----------------------------------------------------------------------------
cat("\n========== 12. INSPECTION SUMMARY ==========\n")
cat("[ ] Total rows              :", nrow(raw), "\n")
cat("[ ] Exact duplicates        :", n_dupes, "(", round(n_dupes/nrow(raw)*100,1), "%)\n")
cat("[ ] Missing age             :", missing_counts$missing[missing_counts$column == "age"], "\n")
cat("[ ] Missing height          :", missing_counts$missing[missing_counts$column == "height"], "\n")
cat("[ ] Missing weight          :", missing_counts$missing[missing_counts$column == "weight"], "\n")
cat("[ ] Missing size            :", missing_counts$missing[missing_counts$column == "size"], "\n")
cat("[ ] Smallest class (XXL)    :", size_dist$n[size_dist$size == "XXL"], "records\n")
cat("[ ] Imbalance ratio         :", round(max(size_dist$n) / min(size_dist$n), 1), ":1\n")
cat("[ ] Ambiguous combos        :", nrow(ambiguous), "\n")
cat("[ ] Height likely inch→cm   :", inch_pattern$pct, "%\n")
cat("\nNext step: Run R/02_clean_data.R\n")
