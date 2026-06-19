# ============================================================
# 26_diversion_build.R  —  Trade Capstone
# Build the trade diversion panel — Vietnam + Mexico only.
# Taiwan excluded (UN Comtrade does not publish US-Taiwan
# bilateral HS6 data due to Taiwan's political status).
#
# Requires: 25_diversion_pull.R to have run first.
# Skips if data_processed/diversion_panel.rds already exists.
# Delete that file to force a rebuild.
# ============================================================

library(dplyr); library(tidyr); library(readr)

raw_dir  <- "data_raw"
proc_dir <- "data_processed"
out_path <- file.path(proc_dir, "diversion_panel.rds")

if (file.exists(out_path)) {
  message("Already have ", out_path, " — skipping. Delete it to rebuild.")
  d <- readRDS(out_path)
  cat("Existing panel:", nrow(d), "products\n")
  cat("Columns:", paste(names(d), collapse=", "), "\n")
  stop("Done.", call.=FALSE)
}

# ── Check required files ─────────────────────────────────────
needed <- c("us_vietnam_1521.rds","us_vietnam_2225.rds",
            "us_mexico_1521.rds", "us_mexico_2225.rds",
            "us_taiwan_1521.rds", "us_taiwan_2225.rds")
for (f in needed) {
  if (!file.exists(file.path(raw_dir, f)))
    stop("Required file missing: ", f,
         ". Run scripts/25_diversion_pull.R first.", call.=FALSE)
}
message("All required files present.")

# ── Helper: standardise to (hs6, year, country, imports) ─────
to_hs6 <- function(raw, country_label) {
  raw %>%
    filter(aggr_level == 6,
           grepl("import", tolower(flow_desc))) %>%
    transmute(
      hs6     = gsub(" ", "0", sprintf("%06s", as.character(cmd_code))),
      year    = as.integer(ref_year),
      country = country_label,
      imports = as.numeric(primary_value)
    ) %>%
    filter(!is.na(imports), imports >= 0)
}

# ── Load ─────────────────────────────────────────────────────
message("Loading raw files...")
vn_1521 <- readRDS(file.path(raw_dir, "us_vietnam_1521.rds"))
vn_2225 <- readRDS(file.path(raw_dir, "us_vietnam_2225.rds"))
mx_1521 <- readRDS(file.path(raw_dir, "us_mexico_1521.rds"))
mx_2225 <- readRDS(file.path(raw_dir, "us_mexico_2225.rds"))
tw_1521 <- readRDS(file.path(raw_dir, "us_taiwan_1521.rds"))
tw_2225 <- readRDS(file.path(raw_dir, "us_taiwan_2225.rds"))

cat("Vietnam 2015-21:", nrow(vn_1521), "rows\n")
cat("Vietnam 2022-25:", nrow(vn_2225), "rows\n")
cat("Mexico  2015-21:", nrow(mx_1521), "rows\n")
cat("Mexico  2022-25:", nrow(mx_2225), "rows\n")
cat("Taiwan  2015-21:", nrow(tw_1521), "rows (USITC)\n")
cat("Taiwan  2022-25:", nrow(tw_2225), "rows (USITC)\n")

# ── Standardise ──────────────────────────────────────────────
all_third <- bind_rows(
  to_hs6(vn_1521, "vietnam"), to_hs6(vn_2225, "vietnam"),
  to_hs6(mx_1521, "mexico"),  to_hs6(mx_2225, "mexico"),
  to_hs6(tw_1521, "taiwan"),  to_hs6(tw_2225, "taiwan")
)
cat("Third-country HS6 rows:", nrow(all_third), "\n")

# ── Load China panels ─────────────────────────────────────────
t1_china <- readRDS(file.path(proc_dir, "hs6_merged_2019.rds")) %>%
  select(hs6, china_t1_base=base_imports, china_t1_conf=imports,
         china_decline_t1=import_change) %>%
  filter(!is.na(china_decline_t1))

t2_china <- readRDS(file.path(proc_dir, "hs6_trump2_direct.rds")) %>%
  select(hs6, china_t2_base=base_imports, china_t2_conf=v25_imports,
         china_decline_t2=import_change25) %>%
  filter(!is.na(china_decline_t2))

cat("China T1 products:", nrow(t1_china), "\n")
cat("China T2 products:", nrow(t2_china), "\n")

# ── T1 episode: baseline 2015-17, conflict 2019 ──────────────
base_t1 <- all_third %>%
  filter(year %in% 2015:2017) %>%
  group_by(hs6, country) %>%
  summarise(base_val = mean(imports, na.rm=TRUE), .groups="drop")

conf_t1 <- all_third %>%
  filter(year == 2019) %>%
  group_by(hs6, country) %>%
  summarise(conf_val = sum(imports, na.rm=TRUE), .groups="drop")

third_t1 <- base_t1 %>%
  full_join(conf_t1, by=c("hs6","country")) %>%
  mutate(
    base_val = replace_na(base_val, 0),
    conf_val = replace_na(conf_val, 0),
    import_change_t1 = case_when(
      base_val >= 500000 ~ (conf_val - base_val) / base_val,
      base_val < 500000 & conf_val >= 500000 ~ 1.0,
      TRUE ~ NA_real_
    )
  ) %>%
  filter(!is.na(import_change_t1)) %>%
  select(hs6, country, import_change_t1) %>%
  pivot_wider(names_from=country, values_from=import_change_t1,
              names_prefix="t1_")

# ── T2 episode: baseline 2022-24, conflict 2025 ──────────────
base_t2 <- all_third %>%
  filter(year %in% 2022:2024) %>%
  group_by(hs6, country) %>%
  summarise(base_val = mean(imports, na.rm=TRUE), .groups="drop")

conf_t2 <- all_third %>%
  filter(year == 2025) %>%
  group_by(hs6, country) %>%
  summarise(conf_val = sum(imports, na.rm=TRUE), .groups="drop")

third_t2 <- base_t2 %>%
  full_join(conf_t2, by=c("hs6","country")) %>%
  mutate(
    base_val = replace_na(base_val, 0),
    conf_val = replace_na(conf_val, 0),
    import_change_t2 = case_when(
      base_val >= 500000 ~ (conf_val - base_val) / base_val,
      base_val < 500000 & conf_val >= 500000 ~ 1.0,
      TRUE ~ NA_real_
    )
  ) %>%
  filter(!is.na(import_change_t2)) %>%
  select(hs6, country, import_change_t2) %>%
  pivot_wider(names_from=country, values_from=import_change_t2,
              names_prefix="t2_")

# ── Merge ─────────────────────────────────────────────────────
diversion <- t1_china %>%
  inner_join(t2_china, by="hs6") %>%
  left_join(third_t1, by="hs6") %>%
  left_join(third_t2, by="hs6") %>%
  mutate(
    any_third_rose_t2 = pmax(t2_vietnam, t2_mexico, t2_taiwan, na.rm=TRUE) > 0,
    third_mean_t2     = rowMeans(cbind(t2_vietnam, t2_mexico, t2_taiwan), na.rm=TRUE)
  )

cat("\n=== DIVERSION PANEL BUILT ===\n")
cat("Products:", nrow(diversion), "\n")
cat("With Vietnam T2:", sum(!is.na(diversion$t2_vietnam)), "\n")
cat("With Mexico T2: ", sum(!is.na(diversion$t2_mexico)),  "\n")
cat("With Taiwan T2: ", sum(!is.na(diversion$t2_taiwan)),  "(USITC source)\n")

saveRDS(diversion, out_path)
write_csv(diversion, file.path(proc_dir, "diversion_panel.csv"))
cat("\nsaved diversion_panel.rds/.csv\n")
cat("Next: source('scripts/27_diversion_test.R')\n")
