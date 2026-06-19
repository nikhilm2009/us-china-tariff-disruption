# ============================================================
# 12_trump2_build.R  —  Trade Capstone  (Trump 2 comparison)
# Builds the HS6 panel for Trump 2 episode:
#   baseline: 2022-2024 mean (post-COVID recovery, pre-Trump-2 tariffs)
#   conflict: 2025 annual
#
# Three-way product classification (the key heterogeneity):
#   Group A: hit in Trump 1 (us_tariff_2019 > 0) AND Trump 2
#   Group B: spared in Trump 1 (us_tariff_2019 == 0) BUT hit in Trump 2
#   Group C: spared in both (control group)
#
# Group B is the adaptation test: first-time shock, no prior supply-chain
# adjustment. Bown (2026) reports these fell sharpest — we test whether
# the tariff slope is larger for Group B than Group A.
# ============================================================

library(dplyr); library(tidyr); library(readr)

# ---- load the two new raw pulls ----
raw_22_24 <- readRDS("data_raw/us_china_2022_24.rds")
raw_2025  <- readRDS("data_raw/us_china_2025.rds")

# ---- helper: standardise to (hs6, year, flow, value) ----
to_long <- function(raw) {
  raw %>%
    filter(aggr_level == 6) %>%
    transmute(
      hs6  = gsub(" ","0", sprintf("%06s", as.character(cmd_code))),
      year = as.integer(ref_year),
      flow = case_when(grepl("import", tolower(flow_desc)) ~ "imports",
                       grepl("export", tolower(flow_desc)) ~ "exports",
                       TRUE ~ NA_character_),
      value = as.numeric(primary_value)
    ) %>%
    filter(!is.na(flow), !is.na(value))
}

long_22_24 <- to_long(raw_22_24)
long_2025  <- to_long(raw_2025)

# ---- baseline: 2022-2024 mean per (hs6, flow) ----
base <- long_22_24 %>%
  group_by(hs6, flow) %>%
  summarise(base_val = mean(value, na.rm=TRUE), .groups="drop") %>%
  pivot_wider(names_from=flow, values_from=base_val,
              names_prefix="base_", values_fill=0)

# ---- 2025 conflict values ----
conf <- long_2025 %>%
  filter(year==2025) %>%
  group_by(hs6, flow) %>%
  summarise(val=sum(value, na.rm=TRUE), .groups="drop") %>%
  pivot_wider(names_from=flow, values_from=val,
              names_prefix="v25_", values_fill=0)

panel2 <- base %>%
  inner_join(conf, by="hs6") %>%
  mutate(
    import_change25 = ifelse(base_imports > 1e6,
                             (v25_imports - base_imports)/base_imports, NA_real_),
    export_change25 = ifelse(base_exports > 1e6,
                             (v25_exports - base_exports)/base_exports, NA_real_)
  ) %>%
  filter(!is.na(import_change25))

# ---- attach Trump 1 tariff (to classify A/B/C) ----
t1 <- read_csv("data_processed/us_tariff_hs6.csv", show_col_types=FALSE,
               col_types=cols(hs06=col_character())) %>%
  mutate(hs06=gsub(" ","0",sprintf("%06s",hs06)))
panel2 <- panel2 %>%
  left_join(t1, by=c("hs6"="hs06")) %>%
  mutate(trump1_hit = !is.na(us_tariff_2019) & us_tariff_2019 > 0)

write_csv(panel2, "data_processed/panel_hs6_trump2.csv")
cat("Trump 2 panel: ", nrow(panel2), "products\n")
cat("Trump 1 hit (Group A candidates):", sum(panel2$trump1_hit, na.rm=TRUE), "\n")
cat("Trump 1 spared (Group B candidates):", sum(!panel2$trump1_hit, na.rm=TRUE), "\n")
cat("\nimport_change25 summary:\n"); print(summary(panel2$import_change25))
cat("\nNext: upload Bown 2025 tariff file and run 13_trump2_tariffs.R\n")
