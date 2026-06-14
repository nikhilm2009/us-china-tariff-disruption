# ============================================================
# 07_hs6_merge_test.R  —  Trade Capstone
# THE DIRECT TEST: do higher-tariffed HS6 products show larger
# US-import declines in 2019? (ARW / Census-aligned, HS6 resolution)
#
# Inputs:
#   data_processed/panel_hs6.csv      (built by 06_hs6_build.R)
#   data_processed/us_tariff_hs6.csv  (US Section 301 tariff in effect 2019, by HS6;
#                                       derived from Bown-Feb-2021 TrumpTariffs-CHN-hs6)
# ============================================================

library(dplyr)
library(readr)

panel <- read_csv("data_processed/panel_hs6.csv", show_col_types = FALSE)
tar   <- read_csv("data_processed/us_tariff_hs6.csv", show_col_types = FALSE,
                  col_types = cols(hs06 = col_character()))

# --- CRITICAL: make HS6 codes match. Comtrade may drop leading zeros / store as int.
panel <- panel %>%
  mutate(hs6 = sprintf("%06s", as.character(hs6)),          # zero-pad to 6
         hs6 = gsub(" ", "0", hs6))
tar <- tar %>% mutate(hs06 = sprintf("%06s", as.character(hs06)),
                      hs06 = gsub(" ", "0", hs06))

# 2019 import-side slice with usable baseline
p19 <- panel %>%
  filter(year == 2019, !is.na(import_change), base_imports > 1e6)

merged <- p19 %>% inner_join(tar, by = c("hs6" = "hs06"))

cat("=== MERGE DIAGNOSTICS ===\n")
cat("2019 usable products:", nrow(p19), "\n")
cat("matched to tariff file:", nrow(merged),
    sprintf(" (%.1f%%)\n", 100*nrow(merged)/nrow(p19)))
cat("unmatched:", nrow(p19) - nrow(merged), "\n\n")

# --- THE TEST -------------------------------------------------------------
# winsorize the import_change tail (a few products explode); log1p alternative too
w <- function(x, p=0.01) { q <- quantile(x, c(p,1-p), na.rm=TRUE); pmin(pmax(x,q[1]),q[2]) }
merged <- merged %>% mutate(import_change_w = w(import_change))

cat("=== DIRECT EFFECT: import_change ~ us_tariff_2019 ===\n")
m1 <- lm(import_change_w ~ us_tariff_2019, data = merged)
print(summary(m1)$coefficients)
cat("\nslope sign: a NEGATIVE coefficient = higher tariff -> bigger import drop (expected)\n\n")

# tariff buckets, dollar-weighted and not
merged %>%
  mutate(tb = cut(us_tariff_2019, c(-1,0,7.5,15,25,100),
                  labels=c("0","(0-7.5]","(7.5-15]","(15-25]",">25"))) %>%
  group_by(tb) %>%
  summarise(n=n(),
            median_imp_chg = round(median(import_change, na.rm=TRUE),3),
            mean_imp_chg   = round(mean(import_change_w, na.rm=TRUE),3),
            dollar_wtd     = round(weighted.mean(import_change, base_imports, na.rm=TRUE),3)) %>%
  print()

cat("\nSpearman (rank) corr tariff vs import_change:",
    round(cor(merged$us_tariff_2019, merged$import_change, method="spearman", use="complete.obs"),3), "\n")

saveRDS(merged, "data_processed/hs6_merged_2019.rds")
cat("\nsaved data_processed/hs6_merged_2019.rds\n")
