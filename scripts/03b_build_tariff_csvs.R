# ============================================================
# 03b_build_tariff_csvs.R  —  Trade Capstone
# Builds all four tariff CSV files from their source files.
# Run ONCE after placing the source files in the locations below.
#
# INPUT FILES REQUIRED (place before running):
#   Trump 1 (from Bown 2021 replication archive):
#     data_raw/bown/TrumpTariffs-CHN-hs6.dta
#     data_raw/bown/301Retaliation-hts8-2018&2019-best.dta
#
#   Trump 2 (from WTO ttd.wto.org → Download → Tariff Actions → HS 6-digit):
#     data_raw/wto/C840_C156.csv   (US→China, 16MB)
#     data_raw/wto/C156_C840.csv   (China→US, 4MB)
#
# OUTPUTS (written to data_processed/):
#   us_tariff_hs6.csv       — US Section 301 tariff in effect 2019, by HS6
#   chn_reta_hs6.csv        — China retaliation rate Jun-2019, by HS6
#   us_tariff_2025_hs6.csv  — US tariff in effect Nov-2025, by HS6
#   chn_reta_2025_hs6.csv   — China tariff in effect Nov-2025, by HS6
# ============================================================

library(haven); library(dplyr); library(readr)

proc <- "data_processed"

# ============================================================
# 1. US TARIFFS ON CHINA (Trump 1) — from Bown 2021 hs6 file
#    Structure: tariff CHANGES at each action date.
#    Sum all changes except TT301_f (Feb-2020 Phase-One cut)
#    to get cumulative rate in effect during 2019.
# ============================================================
cat("Building us_tariff_hs6.csv...\n")
t1_raw <- read_dta("data_raw/bown/TrumpTariffs-CHN-hs6.dta")

chg_cols <- c("TT201_1st","TT232_1","TT301_a","TT301_b","TT301_c",
              "TT201_2nd","TT301_d","TT301_e","TT201_3rd","TT232_2")
# TT301_f is the Feb-2020 Phase-One cut — excluded from 2019 rate
# TT301_f present in data but represents post-2019 change

t1_raw$us_tariff_2019 <- rowSums(
  t1_raw[, intersect(chg_cols, names(t1_raw))], na.rm=TRUE)
t1_raw$us_tariff_2020 <- t1_raw$us_tariff_2019 +
  ifelse(is.na(t1_raw$TT301_f), 0, t1_raw$TT301_f)

out1 <- t1_raw %>%
  transmute(hs06 = sprintf("%06s", as.character(hs06)),
            hs06 = gsub(" ","0", hs06),
            us_tariff_2019, us_tariff_2020)

write_csv(out1, file.path(proc, "us_tariff_hs6.csv"))
cat("  saved:", nrow(out1), "products, mean 2019 rate:",
    round(mean(out1$us_tariff_2019),1), "%\n\n")

# ============================================================
# 2. CHINA RETALIATION ON US (Trump 1) — from Bown 2021 hs8 file
#    Structure: cumulative LEVELS at each date (not changes).
#    Use reta_2019Jun01 as the 2019 retaliation rate.
#    Collapse HS8 → HS6 by simple mean within each heading.
# ============================================================
cat("Building chn_reta_hs6.csv...\n")
reta_raw <- read_dta("data_raw/bown/301Retaliation-hts8-2018&2019-best.dta")

reta_hs6 <- reta_raw %>%
  mutate(hs08 = sprintf("%08s", as.character(hs08)),
         hs08 = gsub(" ","0", hs08),
         hs6  = substr(hs08, 1, 6),
         chn_reta_2019 = as.numeric(reta_2019Jun01)) %>%
  group_by(hs6) %>%
  summarise(chn_reta_2019 = mean(chn_reta_2019, na.rm=TRUE),
            n_hs8 = n(), .groups="drop")

write_csv(reta_hs6, file.path(proc, "chn_reta_hs6.csv"))
cat("  saved:", nrow(reta_hs6), "HS6 codes, mean rate:",
    round(mean(reta_hs6$chn_reta_2019, na.rm=TRUE),1), "%\n",
    "  Note: HS8→HS6 collapsed by simple mean (stated limitation)\n\n")

# ============================================================
# 3. US TARIFFS ON CHINA (Trump 2) — WTO Tariff Actions
#    File: C840_C156.csv (US=C840 reporter, China=C156 partner)
#    Structure: event-driven rows, one per tariff change date.
#    Use last 2025 date as the settled second-half-2025 snapshot.
# ============================================================
cat("Building us_tariff_2025_hs6.csv...\n")
wto_us <- read_csv("data_raw/wto/C840_C156.csv", show_col_types=FALSE) %>%
  mutate(year_dt = as.Date(year_dt))

last_2025_us <- max(wto_us$year_dt[wto_us$year_dt < as.Date("2026-01-01")])
cat("  Snapshot date (US→China):", as.character(last_2025_us), "\n")

wto_us_snap <- wto_us %>%
  filter(year_dt == last_2025_us) %>%
  transmute(hs_code = hs_code,
            best_avlbl = best_avlbl)

write_csv(wto_us_snap, file.path(proc, "us_tariff_2025_hs6.csv"))
cat("  saved:", nrow(wto_us_snap), "products, median rate:",
    round(median(wto_us_snap$best_avlbl, na.rm=TRUE),1), "%\n\n")

# ============================================================
# 4. CHINA RETALIATION ON US (Trump 2) — WTO Tariff Actions
#    File: C156_C840.csv (China=C156 reporter, US=C840 partner)
# ============================================================
cat("Building chn_reta_2025_hs6.csv...\n")
wto_cn <- read_csv("data_raw/wto/C156_C840.csv", show_col_types=FALSE) %>%
  mutate(year_dt = as.Date(year_dt))

last_2025_cn <- max(wto_cn$year_dt[wto_cn$year_dt < as.Date("2026-01-01")])
cat("  Snapshot date (China→US):", as.character(last_2025_cn), "\n")

wto_cn_snap <- wto_cn %>%
  filter(year_dt == last_2025_cn) %>%
  transmute(hs6 = sprintf("%06d", as.integer(hs_code)),
            chn_reta_2025 = best_avlbl)

write_csv(wto_cn_snap, file.path(proc, "chn_reta_2025_hs6.csv"))
cat("  saved:", nrow(wto_cn_snap), "products, median rate:",
    round(median(wto_cn_snap$chn_reta_2025, na.rm=TRUE),1), "%\n\n")

cat("=== ALL FOUR TARIFF CSVS BUILT ===\n")
cat("Verify match rates by running scripts 07, 08, 14, 15.\n")
