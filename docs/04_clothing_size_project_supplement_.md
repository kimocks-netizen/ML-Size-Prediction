# Supplementary Project Document 3: Random Forest Implementation and AWS Hosting

**Project:** Machine Learning-Based Clothing Size Prediction and
Decision Support System\
**Module:** Business Intelligence (6029CMD)\
**Date:** 9 October 2026

> **Scope:** This is a third supplementary document. The previous two
> project documents must remain unchanged. This document records the
> additional decisions and questions discussed today.

## 1. Project decision: no LLM

**We will not include an LLM (Large Language Model) in this project.**
This is a traditional supervised machine-learning project. We will train
and evaluate classification models in R using the supplied clothing-size
CSV. The trained model will be used by an R Shiny application to
estimate a clothing-size category from weight, height, and age.

No LLM, AWS Bedrock, paid AI prediction service, external prediction
API, or API keys are needed for the core implementation.

## 2. Project question

**Can a supervised multiclass classification model predict a
clothing-size category using weight, height, and age, and present that
prediction through a simple web application?**

-   **Inputs:** `weight`, `height`, `age`
-   **Target:** `size`
-   **Size categories identified in the dataset:** `XXS`, `S`, `M`, `L`,
    `XL`, `XXL`, `XXXL`

The app estimates the size label represented in the dataset. It cannot
guarantee that a garment will fit, because size standards can vary
across brands and garment types.

## 3. Example: training a Random Forest model in R

We will use an established Random Forest implementation rather than
writing the algorithm from scratch. Random Forest combines predictions
from many decision trees. With probability prediction enabled, it can
also return estimated probabilities for each size class.

The following is a starting example, not the final pipeline. Confirm
column names and data types after preparing the CSV, and address the
data-quality issues listed below before trusting evaluation results.

``` r
# Install once if needed
install.packages(c("tidyverse", "ranger", "caret"))

library(tidyverse)
library(ranger)
library(caret)

# Load prepared data
clothing <- read_csv("data/clothing_clean.csv")

clothing <- clothing %>%
  select(weight, height, age, size) %>%
  drop_na() %>%
  mutate(size = as.factor(size))

# Reproducible 80/20 train/test split
set.seed(42)
train_index <- createDataPartition(
  clothing$size, p = 0.80, list = FALSE
)

train_data <- clothing[train_index, ]
test_data  <- clothing[-train_index, ]

# Train Random Forest
set.seed(42)
rf_model <- ranger(
  size ~ weight + height + age,
  data = train_data,
  num.trees = 500,
  importance = "impurity",
  probability = TRUE
)

# Predict estimated probabilities on unseen test rows
probabilities <- predict(rf_model, data = test_data)$predictions
predicted_size <- colnames(probabilities)[
  max.col(probabilities, ties.method = "first")
]

# Evaluate against known test labels
confusionMatrix(
  factor(predicted_size, levels = levels(test_data$size)),
  test_data$size
)

# Save fitted model for use by the app
dir.create("models", showWarnings = FALSE)
saveRDS(rf_model, "models/random_forest.rds")
```

### Evaluation and data-quality safeguards

-   The example's `drop_na()` is only a placeholder; missing-value
    handling must be justified and documented.
-   The CSV contains many duplicate rows. Investigate and handle exact
    duplicates before splitting, so repeated copies do not artificially
    inflate test performance.
-   Some identical combinations of weight, height, and age have more
    than one size label. Investigate and disclose this ambiguity.
-   `XXL` has far fewer examples than some other classes. Do not rely on
    accuracy alone; assess per-class precision and recall, macro-F1, and
    the confusion matrix.
-   Investigate unusual ages rather than automatically deleting them
    without a defensible reason.
-   Do not report model scores until the code has been run and results
    have been recorded.
-   Compare Random Forest with a baseline model and, if useful, other
    classifiers. Random Forest is a candidate, not a predetermined
    winner.

## 4. How prediction will work

Training takes place before deployment. The trained model is saved as an
`.rds` file. When a user submits measurements, the Shiny app loads the
saved model and calls `predict()`; it does not retrain the forest for
each request.

1.  User enters weight, height, and age.
2.  The app validates the inputs.
3.  The app passes the values to the saved model.
4.  The model returns a predicted size and, if supported, estimated
    class probabilities.
5.  The app displays the result with a limitation note.

Do not call estimated class probabilities guaranteed or calibrated
confidence unless calibration has been assessed.

## 5. Proposed Shiny interface

The app may contain:

-   **Predict Size:** measurement inputs, a Predict button, predicted
    size, and estimated class probabilities.
-   **Model Evaluation:** actual test metrics and confusion matrix after
    evaluation.
-   **Data Insights:** charts of size frequencies and the
    distributions/relationships of age, height, and weight.
-   **About:** project purpose, data limitations, and a note that a
    prediction is not a guarantee of fit.

R Shiny combines the user interface and server-side logic in the same R
application. A separate backend service and database are not required
for the initial prototype.

## 6. Minimal AWS hosting architecture

The hosting preference is AWS with as few services and as little ongoing
cost as reasonably possible. The initial deployment will use **one EC2
instance** to run the application.

``` text
User's browser
      | HTTPS
      v
One AWS EC2 instance
  - Linux
  - R and Shiny Server
  - Shiny app (app.R)
  - Saved model (.rds)
  - Required local CSV and app files
```

The app can run predictions inside Shiny. No separate prediction API is
needed.

  -----------------------------------------------------------------------
  Service/component       Initial decision        Reason
  ----------------------- ----------------------- -----------------------
  EC2                     Use                     Runs R, Shiny, and the
                                                  model

  R and Shiny Server      Install on EC2          Executes and serves the
                                                  app

  RDS                     Do not use              No database needed for
                                                  the core app

  S3                      Do not use initially    Required files can live
                                                  on EC2

  Lambda                  Do not use              Shiny handles
                                                  prediction directly

  API Gateway             Do not use              No separate API is
                                                  required

  Load balancer           Do not use initially    One instance is
                                                  sufficient for a
                                                  prototype

  Domain/DNS              Optional                Only if using a custom
                                                  domain

  HTTPS                   Recommended             Protects traffic to the
                                                  public app
  -----------------------------------------------------------------------

A small burstable EC2 instance is a reasonable starting point, but test
memory and responsiveness before settling on an instance type. A 1 GiB
instance may be tight for R and Shiny; 2 GiB is a safer initial test
target, not a guarantee. Check current prices for the chosen region at
[AWS EC2 pricing](https://aws.amazon.com/ec2/pricing/). Costs may
include compute, attached storage, public IPv4, data transfer, and
domain costs.

Before making the app public, configure appropriate security-group rules
and HTTPS, restrict server access, and do not put secrets in source
code. Keep backups of the source code, dataset, and model in a safe
separate location; EC2 should not be the only copy.

### Simple server-side project structure

``` text
clothing-size-app/
├── app.R
├── models/
│   └── random_forest.rds
├── data/
│   └── clothing_clean.csv
└── README.md
```

Retain the raw CSV separately during development.

## 7. Implementation order

1.  Inspect and prepare the CSV while preserving the original.
2.  Explore data quality, size frequencies, and feature relationships.
3.  Train and compare a baseline model, Random Forest, and other
    suitable candidates.
4.  Evaluate models on unseen data using suitable metrics.
5.  Select the best-supported model and save it as `.rds`.
6.  Build and test the Shiny app locally.
7.  Deploy the app and saved model to one EC2 instance.
8.  Test the hosted URL, input validation, predictions, and
    responsiveness.
9.  Capture screenshots and report actual evaluation results for the
    assignment.

## 8. Decisions recorded on 9 October 2026

-   The project uses traditional supervised machine learning; **no LLM
    will be included**.
-   Random Forest is a candidate to implement, not a predetermined
    winner.
-   We will train and evaluate the model in R using the supplied CSV.
-   R Shiny will provide both the UI and prediction logic for the
    initial application.
-   The app will load a saved model rather than retraining for each
    prediction.
-   Initial AWS hosting will use one EC2 instance.
-   RDS, S3, Lambda, API Gateway, and a load balancer are excluded from
    the initial architecture.
-   Model performance and business value will only be claimed where
    supported by evaluation; dataset limitations must be disclosed.
