# ML-Size-Prediction

Machine Learning-Based Clothing Size Prediction and Decision Support System  
**Module:** Business Intelligence (6029CMD) — Coventry University  
**Deadline:** 19/10/2026

---

## What This Project Does

Trains a supervised machine learning model on historical clothing data to predict
a customer's clothing size (XXS → XXXL) from their weight, height and age.
The trained model is deployed as an R Shiny web application that returns a
predicted size and probability distribution for each new customer.

---

## Project Structure

```text
ML-Size-Prediction/
├── app.R                        ← Shiny application (entry point)
├── .gitignore
├── README.md
│
├── R/
│   ├── 01_inspect_data.R        ← Phase 1: data profiling (console only)
│   ├── 02_clean_data.R          ← Phase 2: cleaning → clothing_clean.csv
│   ├── 03_exploratory_analysis.R← Phase 3: EDA plots → outputs/figures/
│   ├── 04_train_models.R        ← Phase 4: train Logistic, Tree, RF
│   ├── 05_evaluate_models.R     ← Phase 5: metrics, select best model
│   ├── helpers.R                ← Shared constants and utility functions
│   └── prediction.R             ← Model loading and prediction logic
│
├── data/
│   ├── clothing_raw.csv         ← Original dataset (never modified, git-ignored)
│   ├── clothing_clean.csv       ← Cleaned dataset (Phase 2 output)
│   └── prediction_feedback.csv  ← App feedback log (git-ignored)
│
├── models/
│   ├── logistic_model.rds       ← Phase 4 output (git-ignored)
│   ├── decision_tree_model.rds  ← Phase 4 output (git-ignored)
│   ├── random_forest_model.rds  ← Phase 4 output (git-ignored)
│   └── best_model.rds           ← Phase 5 output, loaded by app (git-ignored)
│
├── outputs/
│   ├── figures/                 ← EDA plots (Phase 3 output, git-ignored)
│   ├── model_metrics.csv        ← Model comparison table (Phase 5 output)
│   └── confusion_matrix.csv     ← Best model confusion matrix (Phase 5 output)
│
├── www/
│   └── styles.css               ← Dark theme CSS
│
├── docs/
│   ├── 01_Spec.md               ← Assignment brief
│   ├── 02_Clothing_Size_Prediction_Project_Plan.md
│   ├── 03_Technical Architecture.md
│   ├── 04_clothing_size_project_supplement_.md
│   └── 05_Roadmap.md            ← Live project roadmap
│
└── screenshots/                 ← App screenshots for report
```

---

## Requirements

- R 4.6.1+
- macOS: install system dependencies first

```bash
brew install harfbuzz fribidi
```

Install all R packages in one command:

```r
install.packages(c(
  "tidyverse", "caret", "ranger", "rpart", "rpart.plot",
  "nnet", "bslib", "shiny", "DT", "plotly", "scales", "viridis"
), repos = "https://cloud.r-project.org")
```

---

## How to Run

All commands are run from the project root directory.

### Step 1 — Inspect the raw data (optional, console output only)

```r
source("R/01_inspect_data.R")
```

### Step 2 — Clean the data

Produces `data/clothing_clean.csv`.

```r
source("R/02_clean_data.R")
```

### Step 3 — Exploratory data analysis

Produces plots in `outputs/figures/`.

```r
source("R/03_exploratory_analysis.R")
```

### Step 4 — Train models

Produces `models/logistic_model.rds`, `models/decision_tree_model.rds`,
`models/random_forest_model.rds`.

```r
source("R/04_train_models.R")
```

### Step 5 — Evaluate and select best model

Produces `outputs/model_metrics.csv`, `outputs/confusion_matrix.csv`,
and `models/best_model.rds`.

```r
source("R/05_evaluate_models.R")
```

### Step 6 — Run the Shiny app

```r
shiny::runApp(".")
```

Or from the terminal:

```bash
Rscript -e "shiny::runApp('.', port=3838, launch.browser=TRUE)"
```

The app opens at `http://127.0.0.1:3838`

> The app runs in **demo mode** (random placeholder predictions) until
> `models/best_model.rds` exists. Run Steps 2–5 first for real predictions.

---

## Run the Full Pipeline in One Go

```r
source("R/02_clean_data.R")
source("R/03_exploratory_analysis.R")
source("R/04_train_models.R")
source("R/05_evaluate_models.R")
shiny::runApp(".")
```

---

## Current Progress

| Phase | Status |
|---|---|
| Phase 1 — Data Inspection | ✅ Complete |
| Phase 2 — Data Cleaning | ✅ Complete |
| Phase 3 — EDA | ✅ Complete |
| Phase 4 — Model Training | ✅ Complete |
| Phase 5 — Model Evaluation | ✅ Complete |
| Phase 6 — Helper Utilities | ✅ Complete |
| Phase 7 — R Shiny App | 🔄 In progress (live predictions) |
| Phase 8 — EC2 Deployment | ⬜ Not started |
| Phase 9 — Report | ⬜ Not started |

---

## Dataset Summary

| Property | Value |
|---|---|
| Raw records | 119,734 |
| After deduplication | 27,404 |
| After cleaning | 27,391 |
| Duplicates removed | 92,330 (77.1%) |
| Missing age imputed | 184 (median = 34) |
| Missing height imputed | 254 (median = 165.1 cm) |
| Age = 0 removed | 13 |
| Size classes | XXS, S, M, L, XL, XXL, XXXL |
| Imbalance ratio | 101:1 (XXXL vs XXL) |

---

## AI Use

Amazon Q Developer was used for code generation, debugging and project planning.
Full acknowledgement is included in the report and in the app About tab.
