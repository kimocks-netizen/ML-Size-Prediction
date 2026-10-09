# Project Roadmap
## Machine Learning-Based Clothing Size Prediction and Decision Support System
**Module:** Business Intelligence (6029CMD)  
**Deadline:** 19/10/2026, 18:00 UK time

---

## Overview

```text
Data Pipeline → EDA → Model Training → Evaluation → Shiny App → EC2 Deploy → Report
```

---

## Phase 1 — Data Inspection ✅
**File:** `R/01_inspect_data.R`  
**Output:** Console summary (no files written)

- [x] Load `data/clothing_raw.csv`
- [x] Inspect dimensions, column types, head/tail
- [x] Count missing values per column (`age`, `height`)
- [x] Count exact duplicate rows
- [x] Analyse size class distribution
- [x] Investigate height decimal precision (possible inch → cm conversion)
- [x] Identify ambiguous observations (same weight/age/height → different sizes)
- [x] Document findings for report Data Prep section

---

## Phase 2 — Data Cleaning ✅
**File:** `R/02_clean_data.R`  
**Output:** `data/clothing_clean.csv`

- [x] Preserve `data/clothing_raw.csv` — never overwrite
- [x] Remove exact duplicate rows (92,330 removed)
- [x] Handle missing `age` values — imputed median (34)
- [x] Handle missing `height` values — imputed median (165.1 cm)
- [x] Investigate unusual age values — 13 age=0 rows removed
- [x] Investigate ambiguous observations — 6,805 retained, disclosed as limitation
- [x] Encode `size` as ordered factor: `XXS < S < M < L < XL < XXL < XXXL`
- [x] Document class imbalance — XXL (67 records) vs XXXL (6,766 records), 101:1 ratio
- [x] Write `data/clothing_clean.csv` (27,391 rows)
- [x] Initialise `data/prediction_feedback.csv` with headers only

---

## Phase 3 — Exploratory Data Analysis ✅
**File:** `R/03_exploratory_analysis.R`  
**Output:** `outputs/figures/*.png` (10 plots)

- [x] Size class frequency bar chart — XXXL (24.7%) and M (17.9%) dominate
- [x] Weight distribution histogram — median 63 kg, right-skewed
- [x] Height distribution histogram — bin=2.54 cm confirms inch conversion
- [x] Age distribution histogram — median 34, broad spread
- [x] Weight by size boxplot — strong upward trend, most predictive feature
- [x] Height by size boxplot — moderate trend, significant overlap
- [x] Age by size boxplot — weak relationship
- [x] Weight vs height scatter (5k sample) — size bands visible but overlapping
- [x] Correlation heatmap — weight/height moderately correlated (r≈0.5)
- [x] Class imbalance log scale — XXL severity clearly visible
- [x] All 10 plots saved to `outputs/figures/`

---

## Phase 4 — Model Training ✅
**File:** `R/04_train_models.R`  
**Output:** `models/logistic_model.rds`, `models/decision_tree_model.rds`, `models/random_forest_model.rds`, `models/test_df.rds`

- [x] Load `data/clothing_clean.csv`
- [x] Set seed (42) for reproducibility
- [x] 80/20 stratified train/test split — 21,916 train / 5,475 test
- [x] Save `models/test_df.rds` — held-out test set
- [x] Compute inverse-frequency class weights for XXL imbalance
- [x] Train Model 1: Multinomial Logistic Regression — train acc 42.75%
- [x] Train Model 2: Decision Tree (`rpart`, pruned to best cp) — train acc 42.11%
- [x] Train Model 3: Random Forest (`ranger`, 500 trees, probability=TRUE) — OOB acc 39.99%
- [x] Variable importance: weight (1.25) > age (1.02) > height (0.59)
- [x] All three models saved as `.rds`

---

## Phase 5 — Model Evaluation ✅
**File:** `R/05_evaluate_models.R`  
**Output:** `outputs/model_metrics.csv`, `outputs/confusion_matrix.csv`, `models/best_model.rds`

- [x] Load all three models and `models/test_df.rds`
- [x] Generate predictions on unseen test data (5,475 rows)
- [x] Calculate per-model: Accuracy, Kappa, Macro F1
- [x] Results: Logistic (43.21%, F1=0.3763) > Tree (41.75%, F1=0.3599) > RF (22.41%, F1=0.1835)
- [x] Save comparison table to `outputs/model_metrics.csv`
- [x] Save best model confusion matrix to `outputs/confusion_matrix.csv`
- [x] Best model selected: **Logistic Regression** (highest macro F1)
- [x] Per-class F1: XXXL=0.74, XXS=0.41, S=0.38, M=0.35, XL=0.31, L=0.08, XXL=NA
- [x] Save best model as `models/best_model.rds`
- [x] App now serves live predictions (no longer in demo mode)

---

## Phase 6 — Helper Utilities ✅
**File:** `R/helpers.R`  
**File:** `R/prediction.R`

- [x] `helpers.R` — SIZE_LEVELS, SEED, confidence thresholds, input bounds, `confidence_level()`, `confidence_colour()`, `validate_input()`
- [x] `prediction.R` — `load_model()`, `predict_size()` using ranger probability output, `save_feedback()` appending to CSV

---

## Phase 7 — R Shiny Application 🔄
**File:** `app.R`  
**Supporting:** `www/styles.css`, `www/logo/logo.png`

- [x] Load `models/best_model.rds` on startup (not per-request)
- [x] Source `R/helpers.R` and `R/prediction.R`
- [x] Build UI with `bslib` Bootstrap 5 dark theme
- [x] **Tab 1 — Dashboard:** hero, stat boxes, workflow, business context
- [x] **Tab 2 — Predict Size:** inputs, Predict button, result card, probability bar chart, feedback YES/NO
- [x] **Tab 3 — Model Performance:** metrics table, confusion matrix, selected model info
- [x] **Tab 4 — Data Insights:** size distribution, weight/height/age histograms, download all plots button
- [x] **Tab 5 — About:** dataset info, limitations, AI acknowledgement
- [x] Input validation with sensible bounds
- [x] Feedback writes row to `data/prediction_feedback.csv`
- [x] Logo in navbar and dashboard hero
- [x] Demo mode fallback when model not present
- [ ] Full end-to-end test with live model
- [ ] Screenshots for report

---

## Phase 8 — AWS EC2 Deployment
**Target:** Single EC2 instance (Linux, 2 GiB RAM minimum)

- [ ] Launch EC2 instance (Amazon Linux 2 or Ubuntu)
- [ ] Configure security group: port 80/443 inbound, SSH restricted
- [ ] Install R and Shiny Server
- [ ] Upload `app.R`, `models/best_model.rds`, `data/clothing_clean.csv`, `www/`
- [ ] Test hosted URL
- [ ] Configure HTTPS (recommended)
- [ ] Capture screenshots for report
- [ ] Keep source code + model backup separate from EC2

---

## Phase 9 — Report & Submission
**Output:** PDF submitted to Aula

- [ ] Introduction (5%) — business problem, dataset overview, report structure
- [ ] Data Prep & Cleaning (10%) — steps taken, justifications, screenshots
- [ ] Visualisation & Descriptive Analysis (15%) — plots from Phase 3, patterns noted
- [ ] Build Model, Prediction & Evaluation (40%) — model comparison table, confusion matrix, selected model justification, business value
- [ ] Deploy App (20%) — screenshots of all Shiny tabs, EC2 URL
- [ ] Critical Reflection & Conclusion (10%) — limitations (XXL imbalance, ambiguous observations), future improvements
- [ ] AI use acknowledgement table
- [ ] Word count stated at end
- [ ] Export as PDF
- [ ] Submit before 18:00 on 19/10/2026

---

## R Packages

### Installed & Verified (R 4.6.1)

| Package | Version | Role | Phase Used |
|---|---|---|---|
| `tidyverse` | 2.x | Data wrangling, `dplyr`, `ggplot2`, `readr` | 1–5 |
| `caret` | 7.x | Stratified train/test split, confusion matrix | 4–5 |
| `ranger` | latest | Random Forest with probability output + class weights | 4–5 |
| `rpart` | built-in | Decision Tree classifier | 4–5 |
| `rpart.plot` | latest | Decision Tree visualisation | 3, 7 |
| `nnet` | built-in | Multinomial Logistic Regression baseline | 4–5 |
| `bslib` | latest | Shiny Bootstrap 5 theming (dark mode) | 7 |
| `shiny` | 1.14+ | Web application framework | 7 |
| `DT` | latest | Interactive data tables in app | 7 |
| `plotly` | latest | Interactive probability bar charts | 7 |
| `scales` | latest | Axis and percentage formatting in plots | 3, 7 |
| `viridis` | latest | Accessible colour scales for EDA plots | 3 |

### Installation Command

```r
install.packages(c(
  'tidyverse', 'caret', 'ranger', 'rpart', 'rpart.plot',
  'nnet', 'bslib', 'shiny', 'DT', 'plotly', 'scales', 'viridis'
), repos = 'https://cloud.r-project.org')
```

> System dependency note: `tidyverse` requires `harfbuzz` and `fribidi` on macOS.
> Install via: `brew install harfbuzz fribidi` before installing `tidyverse`.

---

## Shiny Theme

**Selected theme: Dark Professional (`bslib` Bootstrap 5)**

### Colour Palette

| Role | Name | Hex |
|---|---|---|
| Page background | Deep navy | `#0F172A` |
| Card / surface | Slate dark | `#1E293B` |
| Primary accent | Electric blue | `#3B82F6` |
| Secondary accent | Cyan | `#06B6D4` |
| Success / high confidence | Emerald | `#10B981` |
| Warning / medium confidence | Amber | `#F59E0B` |
| Danger / error / low confidence | Rose | `#F43F5E` |
| Primary text | Off-white | `#F8FAFC` |
| Muted text / labels | Slate grey | `#94A3B8` |

### Theme Definition (used in `app.R`)

```r
library(bslib)

app_theme <- bs_theme(
  version    = 5,
  bg         = "#0F172A",
  fg         = "#F8FAFC",
  primary    = "#3B82F6",
  secondary  = "#06B6D4",
  success    = "#10B981",
  warning    = "#F59E0B",
  danger     = "#F43F5E",
  base_font  = font_google("Inter"),
  heading_font = font_google("Inter")
)
```

### Why this theme

- Dark backgrounds make probability bar charts and result cards visually prominent
- Blue/cyan accent pair is standard in professional BI tools
- The success/warning/danger trio maps directly onto prediction confidence levels:
  - High confidence (≥ 60%) → Emerald green
  - Medium confidence (30–59%) → Amber
  - Low confidence (< 30%) → Rose red
- Inter font is clean, readable, and professional at all sizes
- All colours pass WCAG AA contrast ratio on the dark background

---

## Key Decisions Locked

| Decision | Choice | Reason |
|---|---|---|
| ML framework | `caret` + `ranger` | Established, well-documented |
| Primary model candidate | Random Forest | Handles multiclass, supports probability output |
| Best model (actual result) | Logistic Regression | Highest macro F1 (0.3763) on test set — RF underperformed due to class weight over-correction with probability=TRUE |
| Baseline model | Logistic Regression | Simple benchmark for comparison |
| Class imbalance strategy | Class weights in `ranger` | No synthetic data risk, simple to implement |
| Model selection metric | Macro F1 | Accounts for XXL imbalance better than accuracy |
| Shiny UI package | `bslib` | Modern theming, actively maintained |
| Shiny theme | Dark Professional | Visually prominent, BI-appropriate |
| Confidence colour coding | Emerald / Amber / Rose | Maps naturally to high / medium / low confidence |
| Gradient Boosting | Excluded | Adds complexity for marginal gain given word count |
| LLM / Bedrock | Excluded | Not appropriate for tabular classification |
| AWS services | EC2 only | Simplest viable hosting for prototype |
| Feedback retraining | Manual / offline only | Prevents bad feedback corrupting model |

---

## File Outputs Summary

```text
data/
├── clothing_raw.csv        ← never modified
├── clothing_clean.csv      ← Phase 2 output
└── prediction_feedback.csv ← Phase 7 output, app feedback

models/
└── test_df.rds             ← Phase 4 output, held-out test set (replaces final_test.csv)

models/
├── logistic_model.rds      ← Phase 4
├── decision_tree_model.rds ← Phase 4
├── random_forest_model.rds ← Phase 4
└── best_model.rds          ← Phase 5, used by app

outputs/
├── figures/                ← Phase 3 plots
├── model_metrics.csv       ← Phase 5
└── confusion_matrix.csv    ← Phase 5
```

---

## Current Status

| Phase | Status | Commit |
|---|---|---|
| Phase 1 — Data Inspection | ✅ Complete | `FEAT: Phase 2` (46e6f7a) |
| Phase 2 — Data Cleaning | ✅ Complete | `FEAT: Phase 2` (46e6f7a) |
| Phase 3 — EDA | ✅ Complete | `FEAT: Phase 3` |
| Phase 4 — Model Training | ✅ Complete | `FEAT: Phase 4 & 5` (3a216ca) |
| Phase 5 — Model Evaluation | ✅ Complete | `FEAT: Phase 4 & 5` (3a216ca) |
| Phase 6 — Helper Utilities | ✅ Complete | `FEAT: Phase 2` (46e6f7a) |
| Phase 7 — R Shiny App | 🔄 In progress (live predictions) | `FEAT: Phase 4 & 5` (3a216ca) |
| Phase 8 — EC2 Deployment | ⬜ Not started | — |
| Phase 9 — Report | ⬜ Not started | — |
