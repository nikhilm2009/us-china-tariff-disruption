# ============================================================
# 02_clean.R  —  Trade Capstone
# Reads data_raw/us_china.rds, aggregates to (sector, year)
# at HS2, builds trade_change vs 2015-17 baseline.
#
# Key design decision: isolates HS2 chapters via aggr_level == 2
# (the API's authoritative flag). Do NOT string-slice: the pull
# contains HS2+HS4+HS6 simultaneously — slicing + summing would
# triple-count each chapter (verified against real data, 2026-06).
#
# Defensive column detection: comtradr column names vary by version.
# If detection fails, the script stops and prints available names.
# ============================================================

library(dplyr)
library(tidyr)
library(readr)

raw_dir  <- "data_raw"
proc_dir <- "data_processed"

# ---- column auto-detection helper ----
pick_col <- function(df, candidates, label) {
  hit <- candidates[candidates %in% names(df)]
  if (length(hit) == 0)
    stop("Could not find '", label, "' column. Available:\n",
         paste(names(df), collapse=", "))
  hit[1]
}

# ---- load US-China raw pull ----
d <- readRDS(file.path(raw_dir, "us_china.rds"))

col_value <- pick_col(d, c("primary_value","trade_value_usd","TradeValue","value"), "trade value")
col_cmd   <- pick_col(d, c("cmd_code","commodity_code","CmdCode","cmdCode"), "commodity code")
col_year  <- pick_col(d, c("ref_year","period","refYear","year","Period"), "year")
col_flow  <- pick_col(d, c("flow_desc","flow_direction","rgDesc","flowDesc","flow"), "flow direction")
col_aggr  <- pick_col(d, c("aggr_level","aggrLevel","aggregate_level"), "aggregation level")

long <- d %>%
  transmute(
    cmd_raw = as.character(.data[[col_cmd]]),
    year    = as.integer(.data[[col_year]]),
    flow    = tolower(as.character(.data[[col_flow]])),
    value   = as.numeric(.data[[col_value]]),
    aggr    = as.integer(.data[[col_aggr]])
  ) %>%
  filter(aggr == 2, !is.na(value), cmd_raw != "TOTAL") %>%
  mutate(sector = cmd_raw) %>%
  filter(grepl("^[0-9]{2}$", sector)) %>%
  mutate(flow = case_when(
    grepl("import", flow) ~ "imports",
    grepl("export", flow) ~ "exports",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(flow))

# ---- aggregate to (sector, year, flow) then widen ----
agg <- long %>%
  group_by(sector, year, flow) %>%
  summarise(value = sum(value, na.rm=TRUE), .groups="drop") %>%
  pivot_wider(names_from=flow, values_from=value, values_fill=0)

if (!"imports" %in% names(agg)) agg$imports <- 0
if (!"exports" %in% names(agg)) agg$exports <- 0

# ---- baseline (2015-2017 mean) and trade_change ----
baseline <- agg %>%
  filter(year >= 2015, year <= 2017) %>%
  group_by(sector) %>%
  summarise(
    base_imports = mean(imports, na.rm=TRUE),
    base_exports = mean(exports, na.rm=TRUE),
    base_total   = mean(imports + exports, na.rm=TRUE),
    .groups="drop"
  )

panel <- agg %>%
  left_join(baseline, by="sector") %>%
  mutate(
    total_trade     = imports + exports,
    trade_change    = ifelse(base_total > 0, (total_trade - base_total)/base_total, NA_real_),
    trade_asymmetry = ifelse(imports > 0, exports/imports, NA_real_)
  ) %>%
  filter(base_total > 0)

write_csv(panel, file.path(proc_dir, "panel_pre_tariff.csv"))
message("Wrote ", nrow(panel), " rows (", length(unique(panel$sector)),
        " sectors x ", length(unique(panel$year)), " years) -> panel_pre_tariff.csv")
message("Next: 03_tariffs.R")
