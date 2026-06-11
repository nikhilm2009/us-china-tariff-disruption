# ============================================================
# 01_pull.R  —  Trade Capstone
# Pulls bilateral trade flows for all four conflict pairs.
# Run AFTER 00_setup.R succeeds.
#
# Budget: this script makes ~8 API calls. Free tier = 250/day. Fine.
# Saves one .rds per pair into data_raw/ so you never re-pull.
# ============================================================

library(comtradr)
library(dplyr)
library(readr)

# Resolve project root regardless of where R is launched from.
# Set this to your actual path if needed:
# setwd("~/path/to/trade_capstone")
raw_dir <- "data_raw"

# ---- Conflict pairs: reporter pulls IMPORTS from partner, and EXPORTS to partner ----
# We pull from the US/China side as the "reporter" for consistency, both flows.
pairs <- list(
  us_china     = list(reporter = "USA", partner = "CHN", years = c(2015, 2021)),
  us_eu        = list(reporter = "USA", partner = "DEU", years = c(2015, 2021)), # DEU as EU proxy; expand later
  us_canada    = list(reporter = "USA", partner = "CAN", years = c(2015, 2021)),
  china_aus    = list(reporter = "CHN", partner = "AUS", years = c(2015, 2022))  # AUS episode is 2020-21
)

# ---- Helper: pull both Import and Export, HS2, annual, all HS2 chapters ----
pull_pair <- function(reporter, partner, years) {
  message("Pulling ", reporter, " <-> ", partner, " (", years[1], "-", years[2], ") ...")
  d <- ct_get_data(
    reporter                = reporter,
    partner                 = partner,
    commodity_classification = "HS",
    commodity_code          = "everything",   # all HS chapters; we filter to HS2 after
    flow_direction          = c("Import", "Export"),
    frequency               = "A",
    start_date              = years[1],
    end_date                = years[2],
    verbose                 = TRUE
  )
  d
}

# ---- Run all four (throttled automatically by the package) ----
for (nm in names(pairs)) {
  p <- pairs[[nm]]
  out_path <- file.path(raw_dir, paste0(nm, ".rds"))
  if (file.exists(out_path)) {
    message("Already have ", out_path, " — skipping. Delete it to re-pull.")
    next
  }
  dat <- pull_pair(p$reporter, p$partner, p$years)
  saveRDS(dat, out_path)
  message("  saved ", nrow(dat), " rows -> ", out_path)
}

message("Pull complete. Raw files in ", normalizePath(raw_dir))

# NOTE ON REPORTER MISMATCH (state this in the writeup):
# US-reported imports from China and China-reported exports to the US
# differ materially. We use the US as reporter for the three US dyads,
# and China as reporter for the China-Australia dyad. Whose numbers are
# used is therefore explicit and consistent within each dyad.
