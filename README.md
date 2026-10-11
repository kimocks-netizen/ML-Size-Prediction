# ML-Size-Prediction

Machine Learning-Based Clothing Size Prediction and Decision Support System
**Module:** Business Intelligence (6029CMD) — Coventry University
**Deadline:** 19/10/2026

---

## Live URL

**https://sizepredictionml.shinyapps.io/ML-Size-Prediction/**

Deployed via shinyapps.io (free tier).

---

## What This Project Does

Trains a supervised machine learning model on historical clothing data to predict
a customer's clothing size (XXS → XXXL) from their weight, height and age.
The trained model is deployed as an R Shiny web application that returns a
predicted size (US and EU simultaneously) and probability distribution for each
new customer. User feedback is collected and tracked toward model retraining.

---

## Project Structure

```text
ML-Size-Prediction/
├── app.R                          ← Entry point — sources modules, wires UI + server
├── .gitignore
├── README.md
├── tree.txt
│
├── R/
│   ├── modules/
│   │   ├── mod_dashboard.R        ← Tab 1: Dashboard
│   │   ├── mod_predict.R          ← Tab 2: Predict Size + BMI insight
│   │   ├── mod_model.R            ← Tab 3: Model Performance
│   │   ├── mod_insights.R         ← Tab 4: Data Insights
│   │   ├── mod_feedback.R         ← Tab 5: Feedback & Retraining
│   │   └── mod_about.R            ← Tab 6: About (static)
│   ├── 01_inspect_data.R          ← Phase 1: data profiling
│   ├── 02_clean_data.R            ← Phase 2: cleaning → clothing_clean.csv
│   ├── 03_exploratory_analysis.R  ← Phase 3: EDA plots → outputs/figures/
│   ├── 04_train_models.R          ← Phase 4: train Logistic, Tree, RF
│   ├── 05_evaluate_models.R       ← Phase 5: metrics, select best model
│   ├── helpers.R                  ← Constants, size mappings, utility functions
│   └── prediction.R               ← Model loading and prediction logic
│
├── data/
│   ├── clothing_raw.csv           ← Original dataset (git-ignored)
│   ├── clothing_clean.csv         ← Cleaned dataset (Phase 2 output)
│   └── prediction_feedback.csv    ← App feedback log (git-ignored)
│
├── models/
│   ├── best_model.rds             ← Phase 5 output, loaded by app (git-tracked)
│   ├── logistic_model.rds         ← Phase 4 output (git-ignored)
│   ├── decision_tree_model.rds    ← Phase 4 output (git-ignored)
│   ├── random_forest_model.rds    ← Phase 4 output (git-ignored)
│   └── test_df.rds                ← Held-out test set (git-ignored)
│
├── outputs/
│   ├── figures/                   ← EDA plots (git-ignored)
│   ├── model_metrics.csv          ← Model comparison table
│   └── confusion_matrix.csv       ← Best model confusion matrix
│
├── scripts/
│   ├── deploy.sh                  ← Deploy to shinyapps.io
│   └── run_local.sh               ← Run app locally
│
├── www/
│   ├── styles.css                 ← Dark theme CSS with animations
│   └── logo/logo.png              ← App logo
│
├── docs/                          ← Local only (git-ignored)
├── reports/                       ← Report drafts (git-ignored)
└── screenshots/                   ← App screenshots (git-ignored)
```

---

## Requirements

- R 4.6.1+
- macOS: install system dependencies first

```bash
brew install harfbuzz fribidi
```

Install all R packages:

```r
install.packages(c(
  "tidyverse", "caret", "ranger", "rpart", "rpart.plot",
  "nnet", "bslib", "shiny", "DT", "plotly", "scales", "viridis", "rsconnect"
), repos = "https://cloud.r-project.org")
```

---

## How to Run

### Local app

```bash
bash scripts/run_local.sh
```

Opens at `http://127.0.0.1:3838`

### Deploy to shinyapps.io

```bash
bash scripts/deploy.sh
```

### Full pipeline (from scratch)

```r
source("R/02_clean_data.R")
source("R/03_exploratory_analysis.R")
source("R/04_train_models.R")
source("R/05_evaluate_models.R")
shiny::runApp(".")
```

---

## Model Results

| Model | Accuracy | Macro F1 |
|---|---|---|
| Logistic Regression ✅ | 43.21% | 0.3763 |
| Decision Tree | 41.75% | 0.3599 |
| Random Forest | 22.41% | 0.1835 |

**Best model: Logistic Regression** — selected by highest macro F1.

Per-class F1: XXXL=0.74, XXS=0.41, S=0.38, M=0.35, XL=0.31, L=0.08, XXL=NA

---

## Size Conversion

The dataset reflects women's sizing. Both US and EU sizes are shown simultaneously.

| US | EU |
|---|---|
| XXS | 32 |
| S | 36 |
| M | 38 |
| L | 40 |
| XL | 42 |
| XXL | 44 |
| XXXL | 46 |

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
| Phase 7 — R Shiny App | ✅ Complete |
| Phase 8 — Deployment | ✅ Complete (shinyapps.io) |
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

| Tool | How used |
|---|---|
| Copilot | Code generation, debugging, project planning |
| ChatGPT | Data analysis and identifying suitable model algorithms and equations |
| Claude | Guidance on integrating ML model equations with the dataset |
| YouTube | Learning R Shiny — https://www.youtube.com/watch?v=jxsKUxkiaLI |
