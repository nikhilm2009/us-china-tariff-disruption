# ============================================================
# 25b_taiwan_usitc_parse.R  —  Trade Capstone
# Parse USITC DataWeb Taiwan import data into the same
# format as the Comtrade Vietnam/Mexico RDS files.
#
# Source: USITC DataWeb (dataweb.usitc.gov)
#   Trade flow: Imports for Consumption
#   Country: Taiwan
#   Measure: Customs Value (actual dollars)
#   Years: 2015, 2016, 2017, 2022, 2023, 2024, 2025
#   Classification: HTS (6-digit)
#
# Input:  data_raw/us_taiwan_usitc.csv
# Output: data_raw/us_taiwan_1521.rds  (2015-2021 period)
#         data_raw/us_taiwan_2225.rds  (2022-2025 period)
#
# Note: USITC reports HTS-10. We use first 6 digits only.
# Note: Customs Value ≈ FOB; Comtrade uses CIF. Small
#       systematic difference (~5%) — acceptable for
#       computing fractional import changes.
# ============================================================

library(dplyr); library(readr)

raw_dir <- "data_raw"
infile  <- file.path(raw_dir, "us_taiwan_usitc.csv")

if (!file.exists(infile))
  stop("File not found: ", infile,
       "\nDownload from dataweb.usitc.gov and save as data_raw/us_taiwan_usitc.csv",
       call.=FALSE)

# ── Read ─────────────────────────────────────────────────────
cat("Reading", infile, "...\n")
raw <- read_csv(infile, show_col_types=FALSE)
cat("Raw rows:", nrow(raw), "\n")
cat("Columns:", paste(names(raw), collapse=", "), "\n\n")

# ── Standardise column names ──────────────────────────────────
# DataWeb exports: "Data Type", "HTS Number", "Year",
#                  "Description", "Customs Value"
# Rename defensively in case column names vary slightly
names(raw) <- tolower(gsub(" ", "_", names(raw)))

# Find the value column (contains "customs" or "value")
val_col <- names(raw)[grepl("customs|value", names(raw))][1]
hts_col <- names(raw)[grepl("hts|number|commodity", names(raw))][1]
yr_col  <- names(raw)[grepl("year", names(raw))][1]
cat(sprintf("Using columns: hts='%s', year='%s', value='%s'\n\n",
    hts_col, yr_col, val_col))

# ── Clean and standardise ─────────────────────────────────────
d <- raw %>%
  rename(hts_raw = all_of(hts_col),
         year    = all_of(yr_col),
         value   = all_of(val_col)) %>%
  mutate(
    # Zero-pad to 6 digits, take first 6 chars
    hs6   = substr(sprintf("%06s", as.character(hts_raw)), 1, 6),
    year  = as.integer(year),
    value = as.numeric(value)
  ) %>%
  filter(!is.na(value), value > 0, !is.na(year)) %>%
  # Aggregate to HS6 (in case multiple HTS10 map to same HS6)
  group_by(hs6, year) %>%
  summarise(imports = sum(value, na.rm=TRUE), .groups="drop") %>%
  # Add columns to match Comtrade format expected by 26_diversion_build.R
  mutate(
    aggr_level  = 6L,
    flow_desc   = "Import",
    cmd_code    = hs6,
    ref_year    = year,
    primary_value = imports
  )

cat("Processed rows:", nrow(d), "\n")
cat("Unique HS6 codes:", n_distinct(d$hs6), "\n")
cat("Years present:", paste(sort(unique(d$year)), collapse=", "), "\n")
cat("Value range: $", format(min(d$imports), big.mark=","),
    "to $", format(max(d$imports), big.mark=","), "\n\n")

# ── Split into two period files ───────────────────────────────
# Period 1: 2015-2021 (T1 baseline + conflict)
# Note: USITC file only has 2015,2016,2017 from this period
# 2018-2021 not in the download — baseline uses 2015-17 only
d_1521 <- d %>% filter(year %in% 2015:2021)
cat("Period 2015-21: ", nrow(d_1521), "rows,",
    n_distinct(d_1521$hs6), "unique HS6\n")

# Period 2: 2022-2025 (T2 baseline + conflict)
d_2225 <- d %>% filter(year %in% 2022:2025)
cat("Period 2022-25: ", nrow(d_2225), "rows,",
    n_distinct(d_2225$hs6), "unique HS6\n")

# ── Save ─────────────────────────────────────────────────────
saveRDS(d_1521, file.path(raw_dir, "us_taiwan_1521.rds"))
saveRDS(d_2225, file.path(raw_dir, "us_taiwan_2225.rds"))
cat("\nSaved:\n")
cat("  data_raw/us_taiwan_1521.rds\n")
cat("  data_raw/us_taiwan_2225.rds\n")
cat("\nNext: delete data_processed/diversion_panel.rds,")
cat(" then source('scripts/26_diversion_build.R')\n")
