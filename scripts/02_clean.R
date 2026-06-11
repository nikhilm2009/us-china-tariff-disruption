# ============================================================
# 02_clean.R  —  Trade Capstone
# Reads raw .rds files, aggregates to (pair, sector, year),
# builds trade_change vs 2015-17 baseline.
#
# Defensive design: comtradr column names vary by version, so we
# DETECT the right columns instead of hard-coding them. If detection
# fails, the script stops and prints the available names for you.
# ============================================================

library(dplyr)
library(tidyr)
library(readr)

raw_dir  <- "data_raw"
proc_dir <- "data_processed"

# ---- column auto-detection helper ----
pick_col <- function(df, candidates, label) {
  hit <- candidates[candidates %in% names(df)]
  if (length(hit) == 0) {
    stop("Could not find a '", label, "' column. Available columns:\n",
         paste(names(df), collapse = ", "))
  }
  hit[1]
}

load_and_standardize <- function(path, pair_name) {
  d <- readRDS(path)

  col_value  <- pick_col(d, c("primary_value", "trade_value_usd", "TradeValue",
                              "value", "Primary.Value"), "trade value (USD)")
  col_cmd    <- pick_col(d, c("cmd_code", "commodity_code", "CmdCode",
                              "cmdCode"), "commodity code")
  col_year   <- pick_col(d, c("ref_year", "period", "refYear", "year",
                              "Period"), "year")
  col_flow   <- pick_col(d, c("flow_desc", "flow_direction", "rgDesc",
                              "flowDesc", "flow"), "flow direction")

  out <- d %>%
    transmute(
      pair      = pair_name,
      cmd_raw   = as.character(.data[[col_cmd]]),
      year      = as.integer(.data[[col_year]]),
      flow      = tolower(as.character(.data[[col_flow]])),
      value     = as.numeric(.data[[col_value]])
    ) %>%
    # HS2 = first two digits of the commodity code. Drop aggregate "TOTAL".
    filter(cmd_raw != "TOTAL", !is.na(value)) %>%
    mutate(sector = substr(cmd_raw, 1, 2)) %>%
    filter(grepl("^[0-9]{2}$", sector)) %>%   # keep clean 2-digit chapters only
    mutate(flow = case_when(
      grepl("import", flow) ~ "imports",
      grepl("export", flow) ~ "exports",
      TRUE ~ NA_character_
    )) %>%
    filter(!is.na(flow))

  out
}

# ---- load all four pairs ----
raw_files <- list.files(raw_dir, pattern = "\\.rds$", full.names = TRUE)
stopifnot(length(raw_files) > 0)

all_long <- lapply(raw_files, function(f) {
  nm <- tools::file_path_sans_ext(basename(f))
  load_and_standardize(f, nm)
}) %>% bind_rows()

# ---- aggregate to (pair, sector, year, flow) then widen ----
agg <- all_long %>%
  group_by(pair, sector, year, flow) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = flow, values_from = value, values_fill = 0)

# Ensure both columns exist even if a pair lacks one direction in some year
if (!"imports" %in% names(agg)) agg$imports <- 0
if (!"exports" %in% names(agg)) agg$exports <- 0

# ---- baseline (2015-2017 mean) and trade_change ----
baseline <- agg %>%
  filter(year >= 2015, year <= 2017) %>%
  group_by(pair, sector) %>%
  summarise(
    base_imports = mean(imports, na.rm = TRUE),
    base_exports = mean(exports, na.rm = TRUE),
    base_total   = mean(imports + exports, na.rm = TRUE),
    .groups = "drop"
  )

panel <- agg %>%
  left_join(baseline, by = c("pair", "sector")) %>%
  mutate(
    total_trade  = imports + exports,
    trade_change = ifelse(base_total > 0,
                          (total_trade - base_total) / base_total, NA_real_),
    # secondary balance measure (kept separate from the MARL predictor)
    trade_asymmetry = ifelse(imports > 0, exports / imports, NA_real_)
  )

# Drop tiny sectors whose baseline is tradeless (noise / division blowups)
panel <- panel %>% filter(base_total > 0)

write_csv(panel, file.path(proc_dir, "panel_pre_tariff.csv"))
message("Wrote ", nrow(panel), " rows -> ",
        file.path(proc_dir, "panel_pre_tariff.csv"))
message("Next: 03_tariffs.R to attach retaliation_ratio from the PIIE timeline.")
