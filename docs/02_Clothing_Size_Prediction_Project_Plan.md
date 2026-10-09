# Clothing Size Prediction – Business Intelligence Project

## 1. Project Overview

### Project Title

**Machine Learning-Based Clothing Size Prediction and Decision Support System**

### Objective

The objective of this project is to develop and deploy a supervised machine learning model that predicts a customer's clothing size using their **weight, height, and age**.

The resulting predictive model will be integrated into an **R Shiny application** that allows users to enter their characteristics and receive a predicted clothing size.

The project will demonstrate how data analytics and predictive modelling can support business decision-making in an e-commerce clothing environment.

The assignment requires the development of a predictive model, evaluation of its accuracy, usability and suitability for decision-making, and deployment of the model through an application.

---

# 2. Business Problem

Online clothing retailers need to help customers select an appropriate clothing size before purchasing.

A traditional size guide provides predefined information, but a machine learning system can use historical data to estimate the most likely size for a new customer based on their characteristics.

### Business Question

> **Can machine learning predict a customer's clothing size from their weight, height and age, and can this prediction be presented through an application to support size-selection decisions?**

### Potential Business Benefits

The system could:

- provide personalised size recommendations;
- support customers during online purchasing;
- provide a data-driven alternative to a generic size guide;
- improve the customer shopping experience;
- potentially reduce incorrect size selections.

The project will **not claim that the model directly reduces product returns**, because the dataset does not contain return information. Any reduction in returns will therefore be presented as a potential business benefit rather than a measured result.

---

# 3. Dataset

## Source

The project will use the provided clothing-size CSV dataset.

### Variables

The dataset contains four variables:

| Variable | Role | Description |
|---|---|---|
| `weight` | Predictor | Customer weight |
| `age` | Predictor | Customer age |
| `height` | Predictor | Customer height |
| `size` | Target | Clothing size |

The target variable is:

```text
size
```

The model will use:

```text
weight + age + height
```

to predict:

```text
size
```

---

# 4. What Exactly Is Being Predicted?

The historical dataset already contains the correct `size` for each existing record.

However, the machine learning model will **not receive the size when making a prediction**.

The historical data is used to teach the model relationships between the input variables and the known size.

### Training

```text
Weight
Age
Height
      +
Known Size
      ↓
Machine Learning Model
      ↓
Learns patterns
```

### Prediction

For a new customer:

```text
Weight = 67
Age = 25
Height = 175
Size = UNKNOWN
```

The trained model produces:

```text
Predicted Size = L
```

Therefore, the project is a **supervised multiclass classification problem**.

---

# 5. Why Machine Learning Is Required

The purpose is not to retrieve the `size` from an existing row.

The purpose is to learn patterns from historical observations and use those patterns to predict the target for **new observations where the target is unknown**.

The machine learning workflow is:

```text
Historical labelled data
          ↓
Data preparation
          ↓
Model training
          ↓
Model evaluation
          ↓
Best model
          ↓
New customer data
          ↓
Predicted clothing size
```

This is the predictive component required by the assignment.

---

# 6. AI / Machine Learning Approach

The project will use **traditional machine learning**, rather than a Large Language Model (LLM).

The assignment requires systematic exploration of machine learning algorithms and development of a predictive model. It does not require the use of an LLM or Amazon Bedrock.

## Candidate Models

### 6.1 Multinomial Logistic Regression

Used as the baseline classification model.

Purpose:

- establish a simple benchmark;
- provide a comparison against more complex models.

### 6.2 Decision Tree

Used because it provides an interpretable classification process.

A decision tree can demonstrate how combinations of variables lead toward different predicted sizes.

### 6.3 Random Forest

Used as an ensemble machine learning approach.

Multiple decision trees are trained and combined to produce the final prediction.

Random Forest is a strong candidate for the final model, but it will **not automatically be selected**. The actual evaluation results will determine which model performs best.

### 6.4 Gradient Boosting

May be evaluated as an additional advanced classification model if appropriate after the initial modelling stage.

---

# 7. Model Selection

The final model will be selected based on actual evaluation results.

Models will be compared using appropriate classification metrics, including:

- Accuracy
- Precision
- Recall
- F1-score
- Confusion matrix

Additional metrics may be considered depending on the final structure of the target classes.

The final choice will consider both predictive performance and suitability for business decision-making rather than selecting a model purely because it has the highest accuracy.

---

# 8. Data Preparation

The supplied dataset requires significant preparation.

Initial inspection identified:

- **119,734 total records**
- **92,330 exact duplicate rows**
- missing values in `age`
- missing values in `height`
- significant class imbalance
- `XXL` has substantially fewer observations than the other classes
- multiple identical combinations of `weight`, `age`, and `height` can correspond to different clothing sizes

## Data Preparation Process

```text
Original CSV
    ↓
Inspect structure
    ↓
Check missing values
    ↓
Check duplicates
    ↓
Investigate unusual values
    ↓
Analyse target distribution
    ↓
Handle class imbalance
    ↓
Prepare categorical target
    ↓
Train/test split
    ↓
Model training
```

The original dataset will be preserved separately from the cleaned dataset.

---

# 9. Duplicate Handling

The original dataset contains a very large number of exact duplicate records.

Exact duplicates will be investigated and removed before model training.

This is important because randomly splitting duplicated observations between the training and testing sets could cause the same observation to appear in both datasets.

That could produce an artificially high evaluation score.

Therefore:

```text
Original dataset
       ↓
Remove exact duplicates
       ↓
Clean dataset
       ↓
Train/test split
```

The duplicate-removal process will be documented in the report.

---

# 10. Class Imbalance

The target variable contains seven clothing-size categories.

The distribution is highly uneven, with `XXL` having only 69 observations compared with substantially larger classes such as `M`.

This creates a potential problem where a model may perform well on common classes while performing poorly on rare classes.

Therefore, model evaluation will not rely exclusively on overall accuracy.

The confusion matrix, precision, recall and F1-score will be used to investigate performance across individual classes.

Appropriate class-balancing techniques may also be investigated if required.

---

# 11. Exploratory Data Analysis

The visualisation and descriptive-analysis stage will investigate relationships between the predictors and clothing size.

Potential visualisations include:

- distribution of weight;
- distribution of height;
- distribution of age;
- clothing-size frequency;
- weight by clothing size;
- height by clothing size;
- age by clothing size;
- predictor relationships/correlation;
- class distribution.

The purpose is to identify patterns that may explain model behaviour.

The assignment allocates 15% to data visualisation and descriptive analysis.

---

# 12. R Shiny Application

## What Is R Shiny?

R Shiny is a framework for building interactive web applications using R.

For this project, R Shiny will provide the user interface through which the trained machine learning model can be used to make predictions.

The application will therefore be the **deployment layer for the predictive model**.

---

# 13. Proposed R Shiny Workflow

```text
User
 ↓
Enters weight
 ↓
Enters height
 ↓
Enters age
 ↓
Clicks "Predict Size"
 ↓
R Shiny
 ↓
Trained ML Model
 ↓
Prediction
 ↓
Recommended Clothing Size
```

Example:

```text
Weight: 62 kg
Height: 172 cm
Age: 28

        ↓

Machine Learning Model

        ↓

Predicted Size: XL
```

The application will not ask the user to enter their clothing size because **that is the variable being predicted**.

---

# 14. Prediction Probabilities

Where supported by the selected model, the application should display prediction probabilities rather than only the final class.

Example:

```text
Predicted Size: M

XXS     1%
S       7%
M      67%
L       19%
XL       5%
XXL      0%
XXXL     1%
```

This provides additional information about the model's confidence and makes the application more useful as a decision-support tool.

---

# 15. Business Decision Support

The application should not simply display a technical model output.

It should translate the prediction into a business-oriented recommendation.

Example:

```text
Recommended Size: M

The model predicts M as the most likely clothing size
based on the supplied characteristics.
```

This connects the machine learning model to the business problem.

The assignment specifically requires the application to make predictions that support decision-making.

---

# 16. Prediction Feedback

A possible extension is to allow users to provide feedback after receiving a prediction.

Example:

```text
Predicted Size: XL

Was this recommendation correct?

[ YES ]

[ NO ]

If NO:
What size did you actually use?

[ L ▼ ]
```

This creates a new labelled observation.

Example feedback record:

| weight | age | height | predicted_size | actual_size |
|---:|---:|---:|---|---|
| 62 | 28 | 172 | XL | L |

The feedback can eventually become additional training data.

---

# 17. Model Improvement Through Feedback

The feedback system should **not automatically retrain the model after every prediction**.

Instead:

```text
Prediction
    ↓
User feedback
    ↓
Validate feedback
    ↓
Store labelled observations
    ↓
Periodically analyse new data
    ↓
Retrain model
    ↓
Evaluate new model
    ↓
Deploy new model only if performance improves
```

This provides a realistic machine-learning improvement cycle.

For the assignment, this functionality can initially be treated as a proposed extension unless there is sufficient time to implement and evaluate it properly.

---

# 18. Data Storage

For the assignment prototype, the project can use local files:

```text
data/
├── clothing_raw.csv
├── clothing_clean.csv
└── prediction_feedback.csv
```

### `clothing_raw.csv`

The original supplied dataset.

### `clothing_clean.csv`

The processed dataset used for analysis and modelling.

### `prediction_feedback.csv`

Optional feedback collected from users of the application.

The original dataset should never be overwritten.

---

# 19. Possible Production Architecture

If the project were developed into a production system, cloud services could be introduced.

A possible architecture would be:

```text
                 R SHINY
                    │
                    ▼
              ML Prediction
                    │
                    ▼
              User Feedback
                    │
                    ▼
                API Layer
                    │
                    ▼
               Feedback DB
                    │
                    ▼
              Training Data
                    │
                    ▼
             Model Retraining
                    │
                    ▼
              New Model Version
```

AWS services such as S3, Lambda, API Gateway and DynamoDB could potentially be used.

However, these services are **not required for the core assignment** and should only be introduced if they add clear value.

---

# 20. Amazon Bedrock / LLM

Amazon Bedrock will **not be used as the primary prediction engine**.

The reason is that the project is a structured tabular classification problem.

The task is:

```text
Weight + Age + Height
        ↓
Predict Size
```

Traditional machine learning models are designed specifically for this type of predictive problem.

An LLM such as a model accessed through Amazon Bedrock would be more appropriate for tasks such as:

- natural-language generation;
- question answering;
- summarisation;
- conversational interfaces;
- generating explanations.

It is therefore unnecessary to introduce an LLM simply for the sake of calling the project "AI".

The Random Forest, Decision Tree, Logistic Regression or other selected machine-learning model is itself an AI/ML solution.

---

# 21. Possible Future LLM Extension

If an LLM were eventually introduced, it should be a **secondary component**, not the core prediction model.

For example:

```text
                 USER
                   │
                   ▼
              R SHINY APP
                   │
          ┌────────┴────────┐
          ▼                 ▼
     ML Prediction      Explanation
          │                 │
    Random Forest        LLM/Bedrock
          │                 │
          ▼                 ▼
     Size = XL       Natural-language
                     explanation
```

The machine learning model would remain responsible for predicting the clothing size.

An LLM could potentially explain the result in natural language.

This is an optional future enhancement and is not necessary for satisfying the assignment.

---

# 22. Complete Project Workflow

```text
                    CLOTHING CSV
                         │
                         ▼
                 DATA INSPECTION
                         │
                         ▼
                 DATA CLEANING
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
      Missing        Duplicates      Imbalance
       Values
          │              │              │
          └──────────────┼──────────────┘
                         ▼
                  CLEAN DATASET
                         │
                         ▼
              DESCRIPTIVE ANALYSIS
                         │
                         ▼
                  VISUALISATIONS
                         │
                         ▼
                 FEATURE PREPARATION
                         │
                         ▼
                  TRAIN / TEST SPLIT
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
       Logistic       Decision       Random
      Regression        Tree         Forest
          │              │              │
          └──────────────┼──────────────┘
                         ▼
                  MODEL EVALUATION
                         │
                         ▼
                   BEST MODEL
                         │
                         ▼
                    R SHINY
                         │
                         ▼
                 USER INPUTS
             Weight / Height / Age
                         │
                         ▼
                  PREDICTION
                         │
                         ▼
                RECOMMENDED SIZE
                         │
                         ▼
                BUSINESS DECISION
                         │
                         ▼
               OPTIONAL FEEDBACK
                         │
                         ▼
               FUTURE MODEL UPDATE
```

---

# 23. Assignment Alignment

| Assignment Requirement | Project Implementation |
|---|---|
| Introduction | E-commerce clothing-size prediction business problem |
| Data Preparation & Cleaning | Missing values, duplicates, unusual values and class imbalance |
| Visualisation & Descriptive Analysis | Distributions, size frequencies and predictor relationships |
| Predictive Model | Multiclass clothing-size classification |
| Algorithm Exploration | Logistic Regression, Decision Tree, Random Forest and potentially Gradient Boosting |
| Model Evaluation | Accuracy, Precision, Recall, F1, Confusion Matrix |
| Application | R Shiny |
| Business Decision Support | Predicted clothing size and probability |
| Critical Reflection | Model limitations, class imbalance, ambiguous observations and future improvements |
| AI Use | Machine-learning predictive model; any AI assistance used during development will be acknowledged |

The assignment structure explicitly covers these stages, including introduction, data preparation, visualisation, predictive modelling, application deployment, and critical reflection.

---

# 24. Final Project Goal

The final system will answer the following question:

> **Can a supervised machine learning model learn from historical clothing-size data and predict the most likely clothing size for a new customer using weight, height and age?**

The project will then demonstrate the complete process:

**Data → Cleaning → Analysis → Machine Learning → Evaluation → Deployment → Business Decision Support**

The R Shiny application will provide the practical demonstration of the final predictive model.

The feedback mechanism will be considered as a potential method for collecting new labelled observations and improving future model versions, rather than as automatic LLM training.