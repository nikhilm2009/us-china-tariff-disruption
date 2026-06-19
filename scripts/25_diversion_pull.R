# ============================================================
# 25_diversion_pull.R  —  Trade Capstone
# Pull US imports from Vietnam, Mexico, Taiwan 2015–2025.
# Tests the trade diversion hypothesis from Professor Zhao.
#
# Budget: 6 API calls (3 countries × 2 periods).
#   Free tier = 250/day; run in one session.
#   Each call covers one reporter-partner-period.
#
# Saves:
#   data_raw/us_vietnam_1521.rds   (2015-2021)
#   data_raw/us_vietnam_2225.rds   (2022-2025)
#   data_raw/us_mexico_1521.rds
#   data_raw/us_mexico_2225.rds
#   data_raw/us_taiwan_1521.rds
#   data_raw/us_taiwan_2225.rds
#
# Note: US as reporter (US-reported imports), consistent with
# the main China analysis throughout this project.
# ============================================================

library(comtradr)
library(dplyr)

raw_dir <- "data_raw"

# ── Helper: pull one country-period with skip if cached ──────
pull_one <- function(partner, iso, start, end) {
  fname <- file.path(raw_dir,
    paste0("us_", tolower(iso), "_", start %% 100, substr(end,3,4), ".rds"))
  if (file.exists(fname)) {
    # Check the existing file is actually a data frame, not a corrupt pull
    existing <- readRDS(fname)
    if (is.data.frame(existing) && nrow(existing) > 0) {
      message("  Already have ", fname, " (", nrow(existing), " rows) — skipping.")
      return(invisible(NULL))
    } else {
      message("  ", fname, " exists but is corrupt (", class(existing)[1], ") — re-pulling.")
      file.remove(fname)
    }
  }
  message("Pulling USA <- ", partner, " (", start, "-", end, ")...")
  d <- ct_get_data(
    reporter                 = "USA",
    partner                  = partner,
    commodity_classification = "HS",
    commodity_code           = "everything",
    flow_direction           = "Import",
    frequency                = "A",
    start_date               = start,
    end_date                 = end,
    verbose                  = TRUE
  )
  if (!is.data.frame(d) || nrow(d) == 0) {
    message("  WARNING: pull returned no data for ", partner, " — not saving.")
    return(invisible(NULL))
  }
  d <- d[d$flow_desc %in% c("Import"), ]
  saveRDS(d, fname)
  message("  saved ", nrow(d), " rows -> ", fname)
  Sys.sleep(2)
}

# ── Pull all three countries, two periods each ───────────────
# Period 1: 2015-2021
pull_one("VNM", "vietnam", 2015, 2021)
pull_one("MEX", "mexico",  2015, 2021)
pull_one("TWN", "taiwan",  2015, 2021)

# Period 2: 2022-2025
pull_one("VNM", "vietnam", 2022, 2025)
pull_one("MEX", "mexico",  2022, 2025)
pull_one("TWN", "taiwan",  2022, 2025)

message("\nAll pulls complete. Next: source('scripts/26_diversion_build.R')")
