# ============================================================
# 08_retaliation_test.R  —  Trade Capstone
# THE MIRROR TEST: did China's retaliatory tariffs predict declines in
# US EXPORTS to China in 2019?  (the follower-capacity side of the story)
#
# Inputs:
#   data_processed/panel_hs6.csv     (06_hs6_build.R)
#   data_processed/chn_reta_hs6.csv  (China retaliation rate 2019 by HS6;
#                                      from Bown 301Retaliation-hts8, collapsed to HS6)
#
# EXPECT: smaller match (US exports to China are concentrated in fewer products)
# and a NOISIER result than the import side (commodity-driven volatility).
# That asymmetry is itself the finding.
# ============================================================

library(dplyr); library(readr)

panel <- read_csv("data_processed/panel_hs6.csv", show_col_types = FALSE) %>%
  mutate(hs6 = gsub(" ", "0", sprintf("%06s", as.character(hs6))))
reta  <- read_csv("data_processed/chn_reta_hs6.csv", show_col_types = FALSE,
                  col_types = cols(hs6 = col_character())) %>%
  mutate(hs6 = gsub(" ", "0", sprintf("%06s", as.character(hs6))))

# 2019 EXPORT-side slice (US exports to China) with usable baseline
e19 <- panel %>%
  filter(year == 2019, !is.na(export_change), base_exports > 1e6)

merged <- e19 %>% inner_join(reta, by = "hs6")

cat("=== MERGE DIAGNOSTICS (export side) ===\n")
cat("2019 usable export products:", nrow(e19), "\n")
cat("matched to retaliation file:", nrow(merged),
    sprintf(" (%.1f%%)\n\n", 100*nrow(merged)/nrow(e19)))

w <- function(x,p=0.01){q<-quantile(x,c(p,1-p),na.rm=TRUE);pmin(pmax(x,q[1]),q[2])}
merged <- merged %>% mutate(export_change_w = w(export_change))

cat("=== RETALIATION EFFECT: export_change ~ chn_reta_2019 ===\n")
m <- lm(export_change_w ~ chn_reta_2019, data = merged)
print(summary(m)$coefficients)
cat("\n(negative slope = higher retaliation -> bigger US export drop)\n\n")

merged %>%
  mutate(rb = cut(chn_reta_2019, c(-1,0,10,20,25),
                  labels=c("0","(0-10]","(10-20]","(20-25]"))) %>%
  group_by(rb) %>%
  summarise(n=n(),
            median_exp_chg = round(median(export_change,na.rm=TRUE),3),
            mean_exp_chg   = round(mean(export_change_w,na.rm=TRUE),3),
            dollar_wtd     = round(weighted.mean(export_change, base_exports, na.rm=TRUE),3)) %>%
  print()

cat("\nSpearman corr retaliation vs export_change:",
    round(cor(merged$chn_reta_2019, merged$export_change, method="spearman", use="complete.obs"),3), "\n")

# how concentrated are US exports? (the asymmetry point)
cat("\n=== ASYMMETRY CHECK: concentration of US exports to China ===\n")
top <- merged %>% arrange(desc(base_exports)) %>%
  mutate(cum_share = cumsum(base_exports)/sum(base_exports))
cat("Top 20 HS6 products =", round(100*top$cum_share[20],1), "% of US export value\n")
cat("vs import side which was far less concentrated.\n")

saveRDS(merged, "data_processed/hs6_retaliation_2019.rds")
cat("\nsaved data_processed/hs6_retaliation_2019.rds\n")
