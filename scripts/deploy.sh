#!/usr/bin/env bash
# =============================================================================
# scripts/deploy.sh
# Manual deployment script — deploys app to shinyapps.io
# Usage: bash scripts/deploy.sh
# =============================================================================

set -e  # exit on any error

# ---- Credentials (edit these or export as env vars before running) ----
SHINYAPPS_NAME="${SHINYAPPS_NAME:-sizepredictionml}"
SHINYAPPS_TOKEN="${SHINYAPPS_TOKEN:-F1DB1E6D69E6BE46CA901D2E8B846109}"
SHINYAPPS_SECRET="${SHINYAPPS_SECRET:-38JVqxNOOZrmhXBEAJ171HrS694dDFd6uTJWM8LP}"

# ---- Resolve project root (works from any directory) ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo " SizePredict ML — Deploy to shinyapps.io"
echo "============================================"
echo "Project root : $PROJECT_ROOT"
echo "Account      : $SHINYAPPS_NAME"
echo ""

cd "$PROJECT_ROOT"

# ---- Pre-flight checks ----
echo "--- Pre-flight checks ---"

if ! command -v Rscript &>/dev/null; then
  echo "ERROR: Rscript not found. Install R first."
  exit 1
fi

for f in app.R models/best_model.rds data/clothing_clean.csv; do
  if [ ! -f "$f" ]; then
    echo "ERROR: Required file missing: $f"
    echo "       Run the full pipeline first (Steps 2-5 in README)."
    exit 1
  fi
done

echo "All checks passed."
echo ""

# ---- Install rsconnect if missing ----
echo "--- Checking rsconnect ---"
Rscript -e "if (!requireNamespace('rsconnect', quietly=TRUE)) install.packages('rsconnect', repos='https://cloud.r-project.org')" 2>&1

echo ""
echo "--- Deploying ---"

Rscript -e "
  library(rsconnect)

  rsconnect::setAccountInfo(
    name   = '${SHINYAPPS_NAME}',
    token  = '${SHINYAPPS_TOKEN}',
    secret = '${SHINYAPPS_SECRET}'
  )

  rsconnect::deployApp(
    appDir      = '.',
    appName     = 'ML-Size-Prediction',
    account     = '${SHINYAPPS_NAME}',
    appFiles    = c(
      'app.R',
      'R/helpers.R',
      'R/prediction.R',
      'R/modules/mod_dashboard.R',
      'R/modules/mod_predict.R',
      'R/modules/mod_model.R',
      'R/modules/mod_insights.R',
      'R/modules/mod_feedback.R',
      'R/modules/mod_about.R',
      'models/best_model.rds',
      'data/clothing_clean.csv',
      'outputs/model_metrics.csv',
      'outputs/confusion_matrix.csv',
      'www/styles.css',
      'www/logo/logo.png'
    ),
    forceUpdate    = TRUE,
    launch.browser = FALSE
  )
"

echo ""
echo "============================================"
echo " Deployed: https://${SHINYAPPS_NAME}.shinyapps.io/ML-Size-Prediction/"
echo "============================================"
