#!/usr/bin/env bash
# =============================================================================
# scripts/run_local.sh
# Run the Shiny app locally
# Usage: bash scripts/run_local.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo " SizePredict ML — Run Locally"
echo "============================================"
echo "Project root : $PROJECT_ROOT"
echo ""

cd "$PROJECT_ROOT"

# ---- Pre-flight checks ----
if ! command -v Rscript &>/dev/null; then
  echo "ERROR: Rscript not found. Install R first."
  exit 1
fi

if [ ! -f "app.R" ]; then
  echo "ERROR: app.R not found. Run from project root or use this script."
  exit 1
fi

if [ ! -f "models/best_model.rds" ]; then
  echo "WARNING: models/best_model.rds not found — app will run in demo mode."
  echo "         Run the full pipeline first to get real predictions:"
  echo "           source('R/02_clean_data.R')"
  echo "           source('R/03_exploratory_analysis.R')"
  echo "           source('R/04_train_models.R')"
  echo "           source('R/05_evaluate_models.R')"
  echo ""
fi

echo "Starting app at http://127.0.0.1:3838"
echo "Press Ctrl+C to stop."
echo ""

Rscript -e "shiny::runApp('.', port=3838, launch.browser=TRUE)"
