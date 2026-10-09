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

## Phase 1 — Data Inspection
**File:** `R/01_inspect_data.R`  
**Output:** Console summary (no files written)

- [ ] Load `data/clothing_raw.csv`
- [ ] Inspect dimensions, column types, head/tail
- [ ] Count missing values per column (`age`, `height`)
- [ ] Count exact duplicate rows
- [ ] Analyse size class distribution
- [ ] Investigate height decimal precision (possible inch → cm conversion)
- [ ] Identify ambiguous observations (same weight/age/height → different sizes)
- [ ] Document findings for report Data Prep section

---

## Phase 2 — Data Cleaning
**File:** `R/02_clean_data.R`  
**Output:** `data/clothing_clean.csv`

- [ ] Preserve `data/clothing_raw.csv` — never overwrite
- [ ] Remove exact duplicate rows (expected ~92,330)
- [ ] Handle missing `age` values — impute median or remove, justify decision
- [ ] Handle missing `height` values — impute median or remove, justify decision
- [ ] Investigate unusual age values before deleting
- [ ] Investigate ambiguous observations after deduplication
- [ ] Encode `size` as ordered factor: `XXS < S < M < L < XL < XXL < XXXL`
- [ ] Document class imbalance — XXL (69 records) vs M (29,712 records)
- [ ] Write `data/clothing_clean.csv`
- [ ] Initialise `data/prediction_feedback.csv` with headers only

---

## Phase 3 — Exploratory Data Analysis
**File:** `R/03_exploratory_analysis.R`  
**Output:** `outputs/figures/*.png`

- [ ] Size class frequency bar chart
- [ ] Weight distribution histogram
- [ ] Height distribution histogram
- [ ] Age distribution histogram
- [ ] Weight by size boxplot
- [ ] Height by size boxplot
- [ ] Age by size boxplot
- [ ] Correlation matrix / pairs plot (weight, height, age)
- [ ] Save all plots to `outputs/figures/`
- [ ] Note patterns relevant to report Visualisation section

---

## Phase 4 — Model Training
**File:** `R/04_train_models.R`  
**Output:** `models/logistic_model.rds`, `models/decision_tree_model.rds`, `models/random_forest_model.rds`

- [ ] Load `data/clothing_clean.csv`
- [ ] Set seed (42) for reproducibility
- [ ] 80/20 stratified train/test split via `caret::createDataPartition`
- [ ] Save `data/final_test.csv` — held-out test set, never touched during training
- [ ] Apply class weights to address XXL imbalance (use `ranger` class.weights)
- [ ] Train Model 1: Multinomial Logistic Regression (baseline)
- [ ] Train Model 2: Decision Tree (`rpart`)
- [ ] Train Model 3: Random Forest (`ranger`, 500 trees, probability = TRUE)
- [ ] Save each model as `.rds`

---

## Phase 5 — Model Evaluation
**File:** `R/05_evaluate_models.R`  
**Output:** `outputs/model_metrics.csv`, `outputs/confusion_matrix.csv`

- [ ] Load all three models and `data/final_test.csv`
- [ ] Generate predictions on unseen test data
- [ ] Calculate per-model: Accuracy, Precision, Recall, F1-score (macro)
- [ ] Generate confusion matrix for each model
- [ ] Save comparison table to `outputs/model_metrics.csv`
- [ ] Save best model confusion matrix to `outputs/confusion_matrix.csv`
- [ ] Select best model based on macro F1 (not accuracy alone — due to imbalance)
- [ ] Save best model as `models/best_model.rds`
- [ ] Document selection rationale for report

---

## Phase 6 — Helper Utilities
**File:** `R/helpers.R`  
**File:** `R/prediction.R`

- [ ] `helpers.R` — size level order constant, seed constant, input validation function, probability formatting function
- [ ] `prediction.R` — load model function, predict from new inputs function, format result for UI

---

## Phase 7 — R Shiny Application
**File:** `app.R`  
**Supporting:** `www/styles.css`

- [ ] Load `models/best_model.rds` on startup (not per-request)
- [ ] Source `R/helpers.R` and `R/prediction.R`
- [ ] Build UI with `bslib` theme (see colour palette below)
- [ ] **Tab 1 — Dashboard:** project title, business description, model deployed, quick stats
- [ ] **Tab 2 — Predict Size:** weight/height/age inputs, Predict button, result card, probability bar chart, feedback YES/NO
- [ ] **Tab 3 — Model Performance:** model comparison table, confusion matrix, selected model info
- [ ] **Tab 4 — Data Insights:** size frequency chart, feature distribution charts
- [ ] **Tab 5 — About:** dataset info, limitations note, AI acknowledgement
- [ ] Input validation (weight > 0, height > 0, age > 0, sensible upper bounds)
- [ ] Feedback writes row to `data/prediction_feedback.csv`
- [ ] Test all tabs, valid inputs, invalid inputs, edge cases

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

## Key Decisions Locked

| Decision | Choice | Reason |
|---|---|---|
| ML framework | `caret` + `ranger` | Established, well-documented |
| Primary model candidate | Random Forest | Handles multiclass, supports probability output |
| Baseline model | Logistic Regression | Simple benchmark for comparison |
| Class imbalance strategy | Class weights in `ranger` | No synthetic data risk, simple to implement |
| Model selection metric | Macro F1 | Accounts for XXL imbalance better than accuracy |
| Shiny UI package | `bslib` | Modern theming, actively maintained |
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
├── final_test.csv          ← Phase 4 output, held-out set
└── prediction_feedback.csv ← Phase 7 output, app feedback

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

| Phase | Status |
|---|---|
| Phase 1 — Data Inspection | ⬜ Not started |
| Phase 2 — Data Cleaning | ⬜ Not started |
| Phase 3 — EDA | ⬜ Not started |
| Phase 4 — Model Training | ⬜ Not started |
| Phase 5 — Model Evaluation | ⬜ Not started |
| Phase 6 — Helper Utilities | ⬜ Not started |
| Phase 7 — R Shiny App | ⬜ Not started |
| Phase 8 — EC2 Deployment | ⬜ Not started |
| Phase 9 — Report | ⬜ Not started |
