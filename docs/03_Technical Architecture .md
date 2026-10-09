# Clothing Size Prediction System
## Technical Architecture & Implementation Specification

**Project:** Business Intelligence — Predictive Model  
**Application:** R Shiny  
**Problem Type:** Supervised Multiclass Classification  
**Prediction Target:** Clothing `size`

---

# 1. System Objective

Build an interactive R Shiny application that uses a trained machine learning model to predict a customer's clothing size from:

- Weight
- Height
- Age

The user does **not** provide their size when making a prediction.

The trained model receives:

```text
weight
height
age
```

and returns:

```text
predicted size
```

plus prediction probabilities where supported.

The system should also provide optional user feedback so that future labelled observations can be collected for model evaluation and possible retraining.

---

# 2. Core Prediction Concept

The dataset contains:

```text
weight | age | height | size
```

`size` is the target variable.

During model training:

```text
weight + age + height
          ↓
       ML Model
          ↑
        size
```

The model learns the relationship between the input features and the known target.

During real prediction:

```text
weight + age + height
          ↓
       ML Model
          ↓
   Predicted clothing size
```

The `size` column is **not supplied to the model during prediction**.

---

# 3. Example Prediction

Suppose a new user enters:

```text
Weight: 62 kg
Height: 172 cm
Age: 28
```

The application sends:

```r
new_customer <- data.frame(
  weight = 62,
  age = 28,
  height = 172
)
```

to the trained model.

The model might return:

```text
Predicted size: XL
```

The actual prediction will depend entirely on the model trained from the dataset.

We must never hard-code a result such as `XL`.

---

# 4. Overall Architecture

```text
                         ┌─────────────────────┐
                         │   Original CSV      │
                         │   clothing data     │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Data Preparation    │
                         │ & Cleaning           │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Exploratory Data    │
                         │ Analysis             │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Feature Preparation│
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Model Training      │
                         │                     │
                         │ Logistic Regression │
                         │ Decision Tree       │
                         │ Random Forest       │
                         │ Gradient Boosting   │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Model Evaluation    │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Select Best Model   │
                         └──────────┬──────────┘
                                    │
                                    ▼
                    ┌──────────────────────────────┐
                    │          R SHINY             │
                    │                              │
                    │  User Input                  │
                    │       ↓                      │
                    │  Prediction                  │
                    │       ↓                      │
                    │  Result + Probability        │
                    │       ↓                      │
                    │  Optional Feedback            │
                    └──────────────────────────────┘
```

---

# 5. Technology Stack

## Core

- R
- RStudio
- R Shiny
- `tidyverse`
- `dplyr`
- `ggplot2`
- `caret` and/or `tidymodels`
- Random Forest implementation
- Decision Tree implementation
- Logistic Regression
- Optional Gradient Boosting

## Application

- Shiny
- `shinydashboard` or modern Shiny UI components if appropriate
- `DT` for interactive tables
- `plotly` if interactive visualisations are useful

## Data

Initial development:

```text
CSV files
```

Optional future production architecture:

```text
AWS S3
DynamoDB
API Gateway
Lambda
```

AWS is **not required for the core assignment**.

---

# 6. Project Directory

The project should use a structure similar to:

```text
clothing-size-prediction/
│
├── app.R
│
├── data/
│   ├── clothing_raw.csv
│   ├── clothing_clean.csv
│   └── prediction_feedback.csv
│
├── models/
│   ├── logistic_model.rds
│   ├── decision_tree_model.rds
│   ├── random_forest_model.rds
│   └── best_model.rds
│
├── R/
│   ├── data_prep.R
│   ├── train_models.R
│   ├── evaluate_models.R
│   └── prediction.R
│
├── www/
│   ├── styles.css
│   └── logo/
│
├── reports/
│   └── model_results.csv
│
└── README.md
```

The exact structure can be simplified depending on how we implement the final project.

---

# 7. Data Pipeline

The original CSV should remain untouched.

```text
data/clothing_raw.csv
          │
          ▼
     Data cleaning
          │
          ▼
data/clothing_clean.csv
```

The cleaning process should handle:

1. Missing values
2. Exact duplicates
3. Data types
4. Target encoding
5. Unusual values
6. Class imbalance
7. Train/test separation

---

# 8. Important Dataset Issues

Initial inspection of the supplied CSV identified:

- 119,734 total records
- 92,330 exact duplicate rows
- missing `age` values
- missing `height` values
- significant class imbalance
- very small `XXL` class
- multiple identical combinations of `weight`, `age`, and `height` associated with different sizes

These issues must be investigated before model training.

---

# 9. Train/Test Split

The dataset must be cleaned **before** the train/test split.

Recommended workflow:

```text
Raw Data
   ↓
Remove exact duplicates
   ↓
Handle missing values
   ↓
Investigate unusual values
   ↓
Prepare target
   ↓
Train/Test Split
   ↓
Training Data       Testing Data
      ↓                  ↓
   Train Models       Evaluate
```

The test set must remain unseen during model training.

---

# 10. Candidate Machine Learning Models

We will initially test:

## Model 1 — Logistic Regression

Purpose:

- baseline model
- simple benchmark
- provides a comparison against more complex models

---

## Model 2 — Decision Tree

Purpose:

- interpretable model
- easy to visualise
- useful for explaining decision logic

---

## Model 3 — Random Forest

Purpose:

- ensemble classification
- potentially stronger predictive performance
- feature importance analysis

This is currently the leading candidate, but it is **not automatically the final model**.

---

## Model 4 — Gradient Boosting

Optional additional model.

It will only be included if it provides useful comparison and does not unnecessarily complicate the project.

---

# 11. Model Evaluation

Each model will be evaluated on unseen test data.

Primary metrics:

```text
Accuracy
Precision
Recall
F1-score
```

We will also use:

```text
Confusion Matrix
```

to determine how well each model predicts individual size classes.

Because the dataset is imbalanced, accuracy alone must not determine the winning model.

---

# 12. Model Selection

The final model will be selected after comparing actual results.

Example:

```text
                  Accuracy    F1
Logistic           72%       0.68
Decision Tree      76%       0.73
Random Forest      82%       0.80
Gradient Boosting  81%       0.79
```

These numbers are only an example.

**We will use actual results from our experiments.**

If Random Forest performs best and provides acceptable performance across classes, it may become the final model.

---

# 13. Model Persistence

Once the best model is selected, save it using R's model serialization:

```r
saveRDS(best_model, "models/best_model.rds")
```

The Shiny application loads this model:

```r
model <- readRDS("models/best_model.rds")
```

This means the application does not retrain the model every time a user opens the app.

---

# 14. R Shiny Application Architecture

The application will have two major parts:

```text
UI
│
├── Input controls
├── Prediction button
├── Prediction result
├── Probability chart
└── Feedback controls

Server
│
├── Load model
├── Receive input
├── Validate input
├── Generate prediction
├── Calculate probabilities
└── Store feedback
```

Conceptually:

```text
                 app.R
                   │
          ┌────────┴────────┐
          │                 │
          ▼                 ▼
       ui.R logic       server.R logic
          │                 │
          │                 ▼
          │             Load model
          │                 │
          │                 ▼
          │            Receive inputs
          │                 │
          │                 ▼
          │             Prediction
          │                 │
          └──────────┬──────┘
                     ▼
                  UI Result
```

For a smaller project, everything can remain inside `app.R`.

---

# 15. R Shiny UI

The UI should look like a professional business application rather than a basic R form.

## Main Layout

```text
┌─────────────────────────────────────────────────────┐
│                                                     │
│        CLOTHING SIZE PREDICTION                     │
│        Machine Learning Decision Support            │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  CUSTOMER INFORMATION                               │
│                                                     │
│  Weight                                             │
│  ┌──────────────────────┐                           │
│  │ 62                   │ kg                       │
│  └──────────────────────┘                           │
│                                                     │
│  Height                                             │
│  ┌──────────────────────┐                           │
│  │ 172                  │ cm                       │
│  └──────────────────────┘                           │
│                                                     │
│  Age                                                │
│  ┌──────────────────────┐                           │
│  │ 28                   │                           │
│  └──────────────────────┘                           │
│                                                     │
│             [ PREDICT SIZE ]                       │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│              PREDICTION RESULT                     │
│                                                     │
│                  SIZE: XL                           │
│                                                     │
│              Confidence: 61%                        │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│             SIZE PROBABILITIES                     │
│                                                     │
│  XXS     ███ 1%                                    │
│  S       █████ 4%                                  │
│  M       ████████ 9%                               │
│  L       ███████████████ 20%                      │
│  XL      █████████████████████████ 61%            │
│  XXL     █ 4%                                      │
│  XXXL    █ 1%                                      │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  WAS THIS RECOMMENDATION CORRECT?                  │
│                                                     │
│       [ YES ]          [ NO ]                      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

The exact styling will be implemented later.

---

# 16. Input Validation

The application must validate user inputs before making predictions.

For example:

```text
Weight > 0
Height > 0
Age > 0
```

The application should reject invalid inputs such as:

```text
Weight = -20
Height = 0
Age = -5
```

Instead of allowing them to reach the model.

Example:

```r
validate(
  need(input$weight > 0, "Weight must be greater than 0"),
  need(input$height > 0, "Height must be greater than 0"),
  need(input$age > 0, "Age must be greater than 0")
)
```

---

# 17. Prediction Logic

When the user clicks:

```text
Predict Size
```

the server creates a new observation.

Example:

```r
new_customer <- data.frame(
  weight = input$weight,
  age = input$age,
  height = input$height
)
```

Then:

```r
prediction <- predict(
  model,
  newdata = new_customer
)
```

The result is displayed in the UI.

---

# 18. Probability Prediction

Where supported by the final model, obtain class probabilities.

Conceptually:

```r
probabilities <- predict(
  model,
  newdata = new_customer,
  type = "prob"
)
```

The application can then identify the highest probability:

```text
XXS  1%
S    4%
M    9%
L   20%
XL  61%
XXL  4%
XXXL 1%
```

The highest probability becomes the recommended class.

---

# 19. Prediction Result Card

The main result should be visually prominent.

Example:

```text
┌──────────────────────────────┐
│     RECOMMENDED SIZE         │
│                              │
│             XL               │
│                              │
│       Confidence: 61%        │
└──────────────────────────────┘
```

Below it:

```text
Based on the information provided,
the model predicts XL as the most
likely clothing size.
```

---

# 20. Prediction Feedback

After prediction, display:

```text
Was this recommendation correct?

[ YES ]     [ NO ]
```

If the user selects `NO`:

```text
What was the actual size?

[ Select size ▼ ]
```

Options:

```text
XXS
S
M
L
XL
XXL
XXXL
```

---

# 21. Feedback Data Structure

Store feedback separately from the original dataset.

Example:

```text
prediction_feedback.csv
```

Columns:

```text
timestamp
weight
age
height
predicted_size
actual_size
```

Example:

```text
2026-10-08 10:15:32,62,28,172,XL,L
```

This creates labelled observations that can potentially be used for future model improvement.

---

# 22. Feedback Must Not Automatically Retrain the Model

The application should **not** immediately change the production model after one user response.

Correct architecture:

```text
User prediction
      ↓
User feedback
      ↓
Store feedback
      ↓
Quality checking
      ↓
Add to future training dataset
      ↓
Retrain model offline
      ↓
Evaluate new model
      ↓
Compare with existing model
      ↓
Deploy only if better
```

This prevents poor or erroneous user feedback from immediately damaging the model.

---

# 23. Model Improvement Cycle

Future versions can use accumulated feedback:

```text
Original Training Data
        +
Validated Feedback
        ↓
New Training Dataset
        ↓
Retrain Models
        ↓
Evaluate
        ↓
Compare Against Current Model
        ↓
Deploy Improved Model
```

This is **machine-learning model retraining**, not LLM training.

---

# 24. LLM / Amazon Bedrock

Amazon Bedrock is **not required** for the core system.

The main prediction model will be traditional machine learning.

```text
Weight
Height
Age
  ↓
Random Forest / selected model
  ↓
Clothing Size
```

An LLM could be added later for natural-language explanations, but it should not replace the classification model.

Optional future architecture:

```text
             Prediction Model
                    │
                    ▼
             Predicted Size
                    │
                    ▼
             Optional LLM
                    │
                    ▼
        Natural Language Explanation
```

This is an optional enhancement and should not be added unless it provides a clear benefit.

---

# 25. Application Pages

The initial Shiny application should contain the following sections.

## Dashboard

Purpose:

Provide an overview of the predictive system.

Display:

- Project title
- Short business description
- Model currently deployed
- Prediction interface

---

## Predict Size

Main application page.

Inputs:

```text
Weight
Height
Age
```

Action:

```text
Predict Size
```

Outputs:

```text
Predicted Size
Confidence
Class probabilities
```

---

## Model Information

Display:

- Selected model
- Model accuracy
- F1-score
- Training information
- Brief explanation of the model

This makes the application transparent.

---

## Feedback

Allow the user to confirm or correct the prediction.

```text
Was this prediction correct?

YES / NO
```

If `NO`, capture the actual size.

---

# 26. Suggested Shiny Navigation

```text
┌───────────────────────────────────────────────┐
│ CLOTHING SIZE PREDICTOR                       │
├───────────────────────────────────────────────┤
│                                               │
│ [Dashboard] [Predict Size] [Model] [About]   │
│                                               │
└───────────────────────────────────────────────┘
```

### Dashboard

Business overview.

### Predict Size

Main prediction interface.

### Model

Model performance and evaluation.

### About

Dataset and project information.

---

# 27. Model Page

The model page should display the actual evaluation results.

Example:

```text
MODEL PERFORMANCE

Model              Accuracy      F1
-------------------------------------
Logistic Regression    XX%       XX
Decision Tree          XX%       XX
Random Forest          XX%       XX
Gradient Boosting      XX%       XX
```

Then:

```text
Selected Model:

Random Forest
```

Only the actual experimental results should be shown.

---

# 28. Visualisations in the Application

The Shiny app does not need to reproduce every analysis from the report.

Useful application visualisations include:

### Prediction probabilities

Bar chart showing:

```text
XXS
S
M
L
XL
XXL
XXXL
```

### Model comparison

Bar chart comparing model performance.

### Confusion matrix

Display the final model's classification performance.

---

# 29. Model Training vs Application

The application should **not train models every time it starts**.

Correct approach:

```text
                 DEVELOPMENT
                     │
                     ▼
              Train Models
                     │
                     ▼
              Evaluate Models
                     │
                     ▼
               Best Model
                     │
                     ▼
              Save .rds file
                     │
                     │
              DEPLOYMENT
                     │
                     ▼
                 R Shiny
                     │
                     ▼
              Load .rds model
                     │
                     ▼
                Predict
```

This makes the application faster and separates model development from model serving.

---

# 30. Development Workflow

We will build the project in this order.

## Phase 1 — Dataset Analysis

1. Load CSV.
2. Inspect dimensions.
3. Inspect column types.
4. Analyse missing values.
5. Analyse duplicates.
6. Analyse target distribution.
7. Investigate unusual values.

---

## Phase 2 — Data Preparation

1. Remove exact duplicates.
2. Handle missing values.
3. Investigate unusual observations.
4. Prepare target variable.
5. Investigate class imbalance.
6. Create clean dataset.
7. Split into training/testing data.

---

## Phase 3 — Exploratory Data Analysis

Create:

- size distribution;
- weight distribution;
- height distribution;
- age distribution;
- weight vs size;
- height vs size;
- age vs size;
- correlation/relationship analysis.

---

## Phase 4 — Model Development

Train:

```text
Logistic Regression
Decision Tree
Random Forest
Optional Gradient Boosting
```

---

## Phase 5 — Model Evaluation

Calculate:

```text
Accuracy
Precision
Recall
F1
Confusion Matrix
```

Compare models.

Select the best model.

---

## Phase 6 — Model Persistence

Save:

```text
models/best_model.rds
```

Also save evaluation results.

---

## Phase 7 — R Shiny Development

Build:

```text
Dashboard
Prediction
Model information
Feedback
```

---

## Phase 8 — Testing

Test:

- valid inputs;
- invalid inputs;
- missing inputs;
- extreme inputs;
- predictions;
- probability display;
- feedback;
- application restart;
- model loading.

---

# 31. Final User Journey

The final user experience should be:

```text
1. Open application
          ↓
2. Go to Predict Size
          ↓
3. Enter weight
          ↓
4. Enter height
          ↓
5. Enter age
          ↓
6. Click Predict Size
          ↓
7. Model processes input
          ↓
8. Recommended size displayed
          ↓
9. Probability distribution displayed
          ↓
10. User can confirm/correct prediction
          ↓
11. Feedback stored for future analysis
```

---

# 32. Final Technical Architecture

```text
                         ┌──────────────────────┐
                         │   clothing_raw.csv   │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │  Data Preparation    │
                         │                      │
                         │ Missing values       │
                         │ Duplicates           │
                         │ Class imbalance      │
                         │ Validation           │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ clothing_clean.csv   │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Model Development    │
                         │                      │
                         │ Logistic Regression │
                         │ Decision Tree        │
                         │ Random Forest        │
                         │ Gradient Boosting    │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Model Evaluation     │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │   best_model.rds     │
                         └──────────┬───────────┘
                                    │
                                    ▼
              ┌────────────────────────────────────────┐
              │                R SHINY                 │
              │                                        │
              │  ┌──────────────────────────────────┐  │
              │  │          USER INTERFACE          │  │
              │  │                                  │  │
              │  │ Weight   [________]              │  │
              │  │ Height   [________]              │  │
              │  │ Age      [________]              │  │
              │  │                                  │  │
              │  │       [ PREDICT SIZE ]           │  │
              │  └────────────────┬─────────────────┘  │
              │                   │                    │
              │                   ▼                    │
              │        ┌─────────────────────┐         │
              │        │   BEST ML MODEL     │         │
              │        │                     │         │
              │        │   Predict Size      │         │
              │        │   Calculate Prob.   │         │
              │        └──────────┬──────────┘         │
              │                   │                    │
              │                   ▼                    │
              │        ┌─────────────────────┐         │
              │        │   PREDICTION        │         │
              │        │                     │         │
              │        │   Size: XL          │         │
              │        │   Confidence: XX%   │         │
              │        └──────────┬──────────┘         │
              │                   │                    │
              │                   ▼                    │
              │        ┌─────────────────────┐         │
              │        │     FEEDBACK        │         │
              │        │                     │         │
              │        │  Correct? YES / NO  │         │
              │        └──────────┬──────────┘         │
              └───────────────────┼────────────────────┘
                                  │
                                  ▼
                     prediction_feedback.csv
                                  │
                                  ▼
                        Future Model Updates
```

---

# 33. Important Implementation Principle

We will **not build the UI first and then try to make the model fit it**.

The correct order is:

```text
Dataset
   ↓
Understand data
   ↓
Clean data
   ↓
Train models
   ↓
Evaluate models
   ↓
Choose final model
   ↓
Save final model
   ↓
Build R Shiny UI around the model
```

This ensures the application is driven by a genuine predictive model rather than a simulated prediction.

---

# 34. Definition of Done

The project will be considered technically complete when:

- [ ] Original dataset is preserved.
- [ ] Data cleaning is implemented.
- [ ] Duplicate handling is documented.
- [ ] Missing values are handled.
- [ ] Class imbalance is investigated.
- [ ] Exploratory analysis is completed.
- [ ] Multiple ML models are trained.
- [ ] Models are evaluated on unseen data.
- [ ] Best model is selected using evidence.
- [ ] Best model is saved as `.rds`.
- [ ] R Shiny loads the saved model.
- [ ] User can enter weight, height and age.
- [ ] User can request a prediction.
- [ ] Application returns predicted size.
- [ ] Prediction probabilities are displayed where supported.
- [ ] Model performance is visible in the application.
- [ ] User feedback can optionally be recorded.
- [ ] Application handles invalid input.
- [ ] Final application screenshots can be included in the assignment.
- [ ] AI-assisted development is appropriately acknowledged in the submission.

---

# 35. Final Concept

The project is **not**:

```text
User → ChatGPT/LLM → Clothing Size
```

It is:

```text
Historical Clothing Data
          ↓
Supervised Machine Learning
          ↓
Best Classification Model
          ↓
Saved Model
          ↓
R Shiny Application
          ↓
New Customer Inputs
          ↓
Predicted Clothing Size
          ↓
Business Decision Support
```

The core AI/ML component is the **predictive classification model**.

R Shiny is the **interactive application used to deploy and demonstrate that model**.

User feedback is an **optional mechanism for collecting future labelled data**, which can later support controlled model retraining.