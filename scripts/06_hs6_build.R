# ============================================================
# 06_hs6_build.R  —  Trade Capstone (HS6 / variety-level analysis)
# Step 1 of the HS6 path: build product-level import_change from the
# raw us_china.rds we ALREADY have (no re-pull needed).
#
# Motivated by Amiti, Redding & Weinstein (2019): the 2018 tariff effect
# lives at the variety level and is masked by HS2 aggregation. We test at HS6.
# ============================================================

library(dplyr)
library(readr)

raw <- readRDS("data_raw/us_china.rds")

# Keep HS6 product lines only, imports + exports
hs6 <- raw %>%
  filter(aggr_level == 6) %>%
  transmute(
    hs6   = as.character(cmd_code),
    year  = as.integer(ref_year),
    flow  = tolower(flow_desc),
    value = as.numeric(primary_value)
  ) %>%
  filter(flow %in% c("import", "export"), !is.na(value)) %>%
  mutate(flow = if_else(flow == "import", "imports", "exports"))

# Aggregate (some HS6 may appear in multiple sub-rows) and widen
wide <- hs6 %>%
  group_by(hs6, year, flow) %>%
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = flow, values_from = value, values_fill = 0)
if (!"imports" %in% names(wide)) wide$imports <- 0
if (!"exports" %in% names(wide)) wide$exports <- 0

# Baseline 2015-2017 mean per product
base <- wide %>%
  filter(year >= 2015, year <= 2017) %>%
  group_by(hs6) %>%
  summarise(base_imports = mean(imports), base_exports = mean(exports),
            .groups = "drop")

panel_hs6 <- wide %>%
  left_join(base, by = "hs6") %>%
  mutate(
    import_change = if_else(base_imports > 0, (imports - base_imports)/base_imports, NA_real_),
    export_change = if_else(base_exports > 0, (exports - base_exports)/base_exports, NA_real_),
    hs2 = substr(hs6, 1, 2)
  )

write_csv(panel_hs6, "data_processed/panel_hs6.csv")

# diagnostics: how much usable product-level data do we have for 2019?
p19 <- panel_hs6 %>% filter(year == 2019, !is.na(import_change),
                            base_imports > 1e6)   # drop trivially tiny products
cat("HS6 products with usable 2019 import_change (>$1M baseline):", nrow(p19), "\n")
cat("import_change summary (2019):\n"); print(summary(p19$import_change))
cat("\nWrote data_processed/panel_hs6.csv (", nrow(panel_hs6), " rows)\n", sep="")
