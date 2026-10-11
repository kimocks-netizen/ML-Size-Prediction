# =============================================================================
# helpers.R
# Shared constants and utility functions used across the project
# =============================================================================

SIZE_LEVELS <- c("XXS", "S", "M", "L", "XL", "XXL", "XXXL")
SEED        <- 42

# US to EU size conversion (women's clothing standard)
US_TO_EU <- c(
  XXS  = "32",
  S    = "36",
  M    = "38",
  L    = "40",
  XL   = "42",
  XXL  = "44",
  XXXL = "46"
)

# Convert a US size label to EU
to_eu_size <- function(us_size) {
  unname(US_TO_EU[us_size])
}

# Format size for display given system preference
format_size <- function(us_size, system = "US") {
  if (system == "EU") paste0(to_eu_size(us_size), " (EU)")
  else paste0(us_size, " (US)")
}

# Confidence thresholds for colour coding
CONF_HIGH   <- 0.60
CONF_MED    <- 0.30

# Input validation bounds
WEIGHT_MIN  <- 20;  WEIGHT_MAX  <- 200
HEIGHT_MIN  <- 100; HEIGHT_MAX  <- 220
AGE_MIN     <- 1;   AGE_MAX     <- 100

# Returns "high", "medium", or "low" based on top probability
confidence_level <- function(prob) {
  if (prob >= CONF_HIGH) "high"
  else if (prob >= CONF_MED) "medium"
  else "low"
}

# Maps confidence level to bslib colour class
confidence_colour <- function(level) {
  switch(level,
    high   = "success",
    medium = "warning",
    low    = "danger"
  )
}

# Validates numeric input — returns TRUE if valid
validate_input <- function(val, min_val, max_val) {
  !is.null(val) && !is.na(val) && is.numeric(val) &&
    val >= min_val && val <= max_val
}
