# =============================================================================
# 03_exploratory_analysis.R
# Phase 3 — Exploratory Data Analysis
# Output: outputs/figures/*.png
# =============================================================================

library(tidyverse)
library(scales)
library(viridis)

CLEAN_PATH  <- "data/clothing_clean.csv"
FIGURES_DIR <- "outputs/figures"
SIZE_LEVELS <- c("XXS", "S", "M", "L", "XL", "XXL", "XXXL")

# Colour palette — matches app dark theme accents
SIZE_COLOURS <- c(
  XXS  = "#06B6D4",
  S    = "#3B82F6",
  M    = "#10B981",
  L    = "#F59E0B",
  XL   = "#F43F5E",
  XXL  = "#8B5CF6",
  XXXL = "#EC4899"
)

DARK_BG    <- "#0F172A"
DARK_PANEL <- "#1E293B"
DARK_GRID  <- "#334155"
TEXT_MAIN  <- "#F8FAFC"
TEXT_MUTED <- "#94A3B8"
ACCENT     <- "#3B82F6"

dir.create(FIGURES_DIR, showWarnings = FALSE, recursive = TRUE)

# ---- Dark theme base ----
theme_dark_bi <- function() {
  theme_minimal(base_size = 12, base_family = "sans") +
    theme(
      plot.background    = element_rect(fill = DARK_BG,    colour = NA),
      panel.background   = element_rect(fill = DARK_PANEL, colour = NA),
      panel.grid.major   = element_line(colour = DARK_GRID, linewidth = 0.4),
      panel.grid.minor   = element_blank(),
      axis.text          = element_text(colour = TEXT_MUTED, size = 10),
      axis.title         = element_text(colour = TEXT_MAIN,  size = 11),
      plot.title         = element_text(colour = TEXT_MAIN,  size = 14,
                                        face = "bold", margin = margin(b = 6)),
      plot.subtitle      = element_text(colour = TEXT_MUTED, size = 10,
                                        margin = margin(b = 12)),
      plot.caption       = element_text(colour = TEXT_MUTED, size = 8,
                                        hjust = 0),
      legend.background  = element_rect(fill = DARK_PANEL, colour = NA),
      legend.text        = element_text(colour = TEXT_MUTED, size = 9),
      legend.title       = element_text(colour = TEXT_MAIN,  size = 10),
      strip.background   = element_rect(fill = DARK_GRID,   colour = NA),
      strip.text         = element_text(colour = TEXT_MAIN,  size = 10,
                                        face = "bold"),
      plot.margin        = margin(16, 16, 16, 16)
    )
}

save_plot <- function(name, width = 10, height = 6) {
  path <- file.path(FIGURES_DIR, paste0(name, ".png"))
  ggsave(path, width = width, height = height, dpi = 150,
         bg = DARK_BG)
  cat("Saved:", path, "\n")
}

# ---- Load data ----
cat("\n========== LOADING CLEAN DATA ==========\n")
df <- read_csv(CLEAN_PATH, show_col_types = FALSE) %>%
  mutate(size = factor(size, levels = SIZE_LEVELS))
cat("Rows:", nrow(df), "\n")

# =============================================================================
# PLOT 1 — Size class frequency
# =============================================================================
cat("\n--- Plot 1: Size class frequency ---\n")

size_counts <- df %>%
  count(size) %>%
  mutate(pct = n / sum(n) * 100)

ggplot(size_counts, aes(x = size, y = n, fill = size)) +
  geom_col(width = 0.7, show.legend = FALSE) +
  geom_text(aes(label = paste0(round(pct, 1), "%")),
            vjust = -0.5, colour = TEXT_MUTED, size = 3.5) +
  scale_fill_manual(values = SIZE_COLOURS) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.12))) +
  labs(
    title    = "Size Class Distribution",
    subtitle = paste0("n = ", comma(nrow(df)), " records after cleaning"),
    x        = "Clothing Size",
    y        = "Count",
    caption  = "Note: XXL severely underrepresented (67 records)"
  ) +
  theme_dark_bi()

save_plot("01_size_distribution")

# =============================================================================
# PLOT 2 — Weight distribution
# =============================================================================
cat("--- Plot 2: Weight distribution ---\n")

ggplot(df, aes(x = weight)) +
  geom_histogram(binwidth = 3, fill = ACCENT,
                 colour = DARK_BG, alpha = 0.9) +
  geom_vline(xintercept = median(df$weight),
             colour = "#F59E0B", linetype = "dashed", linewidth = 0.8) +
  annotate("text",
           x = median(df$weight) + 2, y = Inf,
           label = paste0("Median: ", median(df$weight), " kg"),
           colour = "#F59E0B", size = 3.5, hjust = 0, vjust = 1.5) +
  scale_x_continuous(labels = function(x) paste0(x, " kg")) +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "Weight Distribution",
    subtitle = paste0("Range: ", min(df$weight), "–", max(df$weight), " kg"),
    x        = "Weight (kg)",
    y        = "Count"
  ) +
  theme_dark_bi()

save_plot("02_weight_distribution")

# =============================================================================
# PLOT 3 — Height distribution
# =============================================================================
cat("--- Plot 3: Height distribution ---\n")

ggplot(df, aes(x = height)) +
  geom_histogram(binwidth = 2.54, fill = "#06B6D4",
                 colour = DARK_BG, alpha = 0.9) +
  geom_vline(xintercept = median(df$height),
             colour = "#F59E0B", linetype = "dashed", linewidth = 0.8) +
  annotate("text",
           x = median(df$height) + 1, y = Inf,
           label = paste0("Median: ", median(df$height), " cm"),
           colour = "#F59E0B", size = 3.5, hjust = 0, vjust = 1.5) +
  scale_x_continuous(labels = function(x) paste0(x, " cm")) +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "Height Distribution",
    subtitle = paste0("Range: ", min(df$height), "–", max(df$height),
                      " cm  |  Bin width = 2.54 cm (1 inch)"),
    x        = "Height (cm)",
    y        = "Count"
  ) +
  theme_dark_bi()

save_plot("03_height_distribution")

# =============================================================================
# PLOT 4 — Age distribution
# =============================================================================
cat("--- Plot 4: Age distribution ---\n")

ggplot(df, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "#10B981",
                 colour = DARK_BG, alpha = 0.9) +
  geom_vline(xintercept = median(df$age),
             colour = "#F59E0B", linetype = "dashed", linewidth = 0.8) +
  annotate("text",
           x = median(df$age) + 1, y = Inf,
           label = paste0("Median: ", median(df$age)),
           colour = "#F59E0B", size = 3.5, hjust = 0, vjust = 1.5) +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "Age Distribution",
    subtitle = paste0("Range: ", min(df$age), "–", max(df$age), " years"),
    x        = "Age (years)",
    y        = "Count"
  ) +
  theme_dark_bi()

save_plot("04_age_distribution")

# =============================================================================
# PLOT 5 — Weight by size (boxplot)
# =============================================================================
cat("--- Plot 5: Weight by size ---\n")

ggplot(df, aes(x = size, y = weight, fill = size)) +
  geom_boxplot(outlier.colour = TEXT_MUTED, outlier.size = 0.8,
               outlier.alpha = 0.5, show.legend = FALSE) +
  scale_fill_manual(values = SIZE_COLOURS) +
  scale_y_continuous(labels = function(x) paste0(x, " kg")) +
  labs(
    title    = "Weight by Clothing Size",
    subtitle = "Clear upward trend — heavier customers tend toward larger sizes",
    x        = "Clothing Size",
    y        = "Weight (kg)"
  ) +
  theme_dark_bi()

save_plot("05_weight_by_size")

# =============================================================================
# PLOT 6 — Height by size (boxplot)
# =============================================================================
cat("--- Plot 6: Height by size ---\n")

ggplot(df, aes(x = size, y = height, fill = size)) +
  geom_boxplot(outlier.colour = TEXT_MUTED, outlier.size = 0.8,
               outlier.alpha = 0.5, show.legend = FALSE) +
  scale_fill_manual(values = SIZE_COLOURS) +
  scale_y_continuous(labels = function(x) paste0(x, " cm")) +
  labs(
    title    = "Height by Clothing Size",
    subtitle = "Taller customers tend toward larger sizes, though overlap is significant",
    x        = "Clothing Size",
    y        = "Height (cm)"
  ) +
  theme_dark_bi()

save_plot("06_height_by_size")

# =============================================================================
# PLOT 7 — Age by size (boxplot)
# =============================================================================
cat("--- Plot 7: Age by size ---\n")

ggplot(df, aes(x = size, y = age, fill = size)) +
  geom_boxplot(outlier.colour = TEXT_MUTED, outlier.size = 0.8,
               outlier.alpha = 0.5, show.legend = FALSE) +
  scale_fill_manual(values = SIZE_COLOURS) +
  labs(
    title    = "Age by Clothing Size",
    subtitle = "Age shows weak relationship with size — wide overlap across all classes",
    x        = "Clothing Size",
    y        = "Age (years)"
  ) +
  theme_dark_bi()

save_plot("07_age_by_size")

# =============================================================================
# PLOT 8 — Weight vs Height scatter coloured by size
# =============================================================================
cat("--- Plot 8: Weight vs Height scatter ---\n")

# Sample to keep plot readable
set.seed(42)
df_sample <- df %>% slice_sample(n = 5000)

ggplot(df_sample, aes(x = height, y = weight, colour = size)) +
  geom_point(alpha = 0.45, size = 1.2) +
  scale_colour_manual(values = SIZE_COLOURS, name = "Size") +
  scale_x_continuous(labels = function(x) paste0(x, " cm")) +
  scale_y_continuous(labels = function(x) paste0(x, " kg")) +
  labs(
    title    = "Weight vs Height by Size",
    subtitle = "Sample of 5,000 records — size bands visible but overlapping",
    x        = "Height (cm)",
    y        = "Weight (kg)",
    caption  = "Overlap confirms why a model is needed over a simple rule"
  ) +
  theme_dark_bi() +
  guides(colour = guide_legend(override.aes = list(size = 3, alpha = 1)))

save_plot("08_weight_vs_height_scatter", width = 11, height = 7)

# =============================================================================
# PLOT 9 — Correlation heatmap (weight, height, age)
# =============================================================================
cat("--- Plot 9: Correlation heatmap ---\n")

cor_matrix <- df %>%
  select(weight, height, age) %>%
  cor(use = "complete.obs") %>%
  as.data.frame() %>%
  rownames_to_column("var1") %>%
  pivot_longer(-var1, names_to = "var2", values_to = "correlation")

ggplot(cor_matrix, aes(x = var1, y = var2, fill = correlation)) +
  geom_tile(colour = DARK_BG, linewidth = 0.5) +
  geom_text(aes(label = round(correlation, 2)),
            colour = TEXT_MAIN, size = 5, fontface = "bold") +
  scale_fill_gradient2(
    low      = "#F43F5E",
    mid      = DARK_PANEL,
    high     = "#3B82F6",
    midpoint = 0,
    limits   = c(-1, 1),
    name     = "Correlation"
  ) +
  scale_x_discrete(labels = c(age = "Age", height = "Height", weight = "Weight")) +
  scale_y_discrete(labels = c(age = "Age", height = "Height", weight = "Weight")) +
  labs(
    title    = "Predictor Correlation Matrix",
    subtitle = "Weight and height show moderate positive correlation"
  ) +
  theme_dark_bi() +
  theme(
    axis.title  = element_blank(),
    panel.grid  = element_blank()
  )

save_plot("09_correlation_heatmap", width = 7, height = 6)

# =============================================================================
# PLOT 10 — Class imbalance bar (log scale)
# =============================================================================
cat("--- Plot 10: Class imbalance (log scale) ---\n")

ggplot(size_counts, aes(x = size, y = n, fill = size)) +
  geom_col(width = 0.7, show.legend = FALSE) +
  geom_text(aes(label = comma(n)),
            vjust = -0.4, colour = TEXT_MUTED, size = 3.5) +
  scale_fill_manual(values = SIZE_COLOURS) +
  scale_y_log10(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Class Imbalance — Log Scale",
    subtitle = "XXL has only 67 records vs XXXL with 6,766 — 101:1 ratio",
    x        = "Clothing Size",
    y        = "Count (log scale)",
    caption  = "Class weights will be applied in ranger to compensate"
  ) +
  theme_dark_bi()

save_plot("10_class_imbalance_log")

# =============================================================================
# Summary
# =============================================================================
cat("\n========== PHASE 3 COMPLETE ==========\n")
plots <- list.files(FIGURES_DIR, pattern = "\\.png$")
cat("Plots saved:", length(plots), "\n")
for (p in plots) cat(" ", p, "\n")
cat("\nNext step: Run R/04_train_models.R\n")
