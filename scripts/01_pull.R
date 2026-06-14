# ============================================================
# 01_pull.R  —  Trade Capstone
# Pulls US-China bilateral trade flows 2015-2021.
# Run AFTER 00_setup.R succeeds.
#
# Budget: 1 API call. Free tier = 250/day.
# Saves to data_raw/us_china.rds — skips if already present.
#
# Note: US as reporter (US-reported imports from China).
# US-reported and China-reported figures differ materially;
# US-reporter is used consistently throughout this analysis.
# ============================================================

library(comtradr)
library(dplyr)
library(readr)

raw_dir <- "data_raw"
out_path <- file.path(raw_dir, "us_china.rds")

if (file.exists(out_path)) {
  message("Already have ", out_path, " — skipping. Delete it to re-pull.")
} else {
  message("Pulling USA <-> CHN (2015-2021)...")
  d <- ct_get_data(
    reporter                 = "USA",
    partner                  = "CHN",
    commodity_classification = "HS",
    commodity_code           = "everything",
    flow_direction           = c("Import", "Export"),
    frequency                = "A",
    start_date               = 2015,
    end_date                 = 2021,
    verbose                  = TRUE
  )
  # keep only Import/Export (drop re-import/re-export)
  d <- d[d$flow_desc %in% c("Import", "Export"), ]
  saveRDS(d, out_path)
  message("  saved ", nrow(d), " rows -> ", out_path)
}

message("Done. Next: 02_clean.R")
