# ============================================================
# 00_setup.R  —  Trade Capstone
# Run this ONCE first. Confirms packages, key, and live API.
# ============================================================

# ---- 1. Install packages (only first time; comment out after) ----
install.packages(c(
  "comtradr",  # UN Comtrade API
  "dplyr",     # wrangling
  "tidyr",     # reshaping
  "readr",     # CSV I/O
  "ggplot2",   # plots
  "fixest",    # panel fixed-effects regression
  "pROC"       # ROC / AUC
))

# ---- 2. Register your Comtrade key ----
# In your Comtrade account (comtradeplus.un.org) you must have subscribed
# to the FREE product called "comtrade - v1". Copy that key below.
#
# Option A (interactive, saves to your .Renviron so you only do it once):
#   comtradr::set_primary_comtrade_key()   # paste key when prompted
#
# Option B (this session only):
Sys.setenv(COMTRADE_PRIMARY = "PASTE-YOUR-KEY-HERE")

# Verify the key is visible to the package:
stopifnot(nchar(comtradr::get_primary_comtrade_key()) > 0)
message("Key detected OK.")

# ---- 3. Connection test: one tiny known-good pull ----
# China -> Argentina+Germany, 2010-2012. If this returns rows, you're live.
test <- comtradr::ct_get_data(
  reporter   = "CHN",
  partner    = c("ARG", "DEU"),
  start_date = 2010,
  end_date   = 2012,
  verbose    = TRUE
)

message("Connection test returned ", nrow(test), " rows.")
str(test)

# If you see rows above, setup is complete. Move to 01_pull.R
# Common failures:
#   - "401 / unauthorized"  -> wrong key, or didn't subscribe to comtrade-v1
#   - 0 rows / NULL         -> key fine but query empty (not your case here)
#   - cannot resolve host   -> network/firewall; try a different connection
