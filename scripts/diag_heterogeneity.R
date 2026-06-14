# ============================================================
# diag_heterogeneity.R  —  Trade Capstone (exploratory)
# Characterizes the sign-flipping heterogeneity in US-China:
#   - quadrant map of sectors (tariff level x import outcome)
#   - names which sectors sit where
#   - weighted vs unweighted models side by side
#
# NOTE: this is EXPLORATORY description, not hypothesis testing. We are
# describing structure in data we've already inspected. Treat p-values
# as descriptive, not confirmatory.
# ============================================================

library(dplyr)

pt <- read.csv("data_processed/panel_with_tariffs.csv")

# Focus: US-China, 2019 (peak escalation), IMPORT side (what 301 actually taxed)
uc <- pt %>%
  filter(pair == "us_china", year == 2019) %>%
  mutate(import_change = (imports - base_imports) / base_imports,
         export_change = (exports - base_exports) / base_exports) %>%
  filter(is.finite(import_change))

# HS2 chapter labels for the sectors that matter (for readability)
chap_label <- c(
  "01"="live animals","02"="meat","03"="fish","08"="fruit/nuts","10"="cereals",
  "12"="oilseeds/soybeans","27"="mineral fuels","28"="inorg chem","29"="org chem",
  "39"="plastics","40"="rubber","44"="wood","48"="paper","52"="cotton",
  "61"="apparel knit","62"="apparel woven","64"="footwear","68"="stone",
  "72"="iron/steel","73"="steel articles","74"="copper","76"="aluminum",
  "84"="machinery","85"="electronics","87"="vehicles","88"="aircraft",
  "90"="instruments","94"="furniture","95"="toys")
uc$label <- ifelse(uc$sector %in% as.integer(names(chap_label)),
                   chap_label[sprintf("%02d", uc$sector)], paste0("HS", uc$sector))

# ---- QUADRANT MAP ----------------------------------------------------------
# High tariff = init_rate >= 25 ; outcome split at median import_change
med_change <- median(uc$import_change, na.rm = TRUE)
uc <- uc %>%
  mutate(tariff_hi = init_rate >= 25,
         fell_hard = import_change < med_change,
         quadrant = case_when(
            tariff_hi & fell_hard  ~ "Q1: high tariff + big drop (expected)",
            tariff_hi & !fell_hard ~ "Q2: high tariff + resilient (puzzle)",
           !tariff_hi & fell_hard  ~ "Q3: low tariff + big drop (puzzle)",
            TRUE                   ~ "Q4: low tariff + resilient (expected)"))

cat("=== QUADRANT COUNTS ===\n")
print(table(uc$quadrant))

cat("\n=== Q2: HIGH TARIFF BUT RESILIENT (the 'inelastic dependence' sectors) ===\n")
uc %>% filter(grepl("Q2", quadrant)) %>%
  arrange(desc(base_imports)) %>%
  select(sector, label, init_rate, import_change, base_imports) %>%
  head(12) %>% print()

cat("\n=== Q3: LOW TARIFF BUT COLLAPSED ===\n")
uc %>% filter(grepl("Q3", quadrant)) %>%
  arrange(import_change) %>%
  select(sector, label, init_rate, import_change, base_imports) %>%
  head(12) %>% print()

# ---- WEIGHTED vs UNWEIGHTED MODELS side by side ----------------------------
cat("\n=== MODELS: import_change ~ init_rate ===\n")
m_unw <- lm(import_change ~ init_rate, data = uc)
m_wtd <- lm(import_change ~ init_rate, data = uc, weights = base_imports)
cat(sprintf("Unweighted slope: %+.5f  (p=%.3f)\n",
            coef(m_unw)[2], summary(m_unw)$coefficients[2,4]))
cat(sprintf("Dollar-weighted slope: %+.5f  (p=%.3f)\n",
            coef(m_wtd)[2], summary(m_wtd)$coefficients[2,4]))
cat("If signs differ, the unweighted vs weighted disagreement IS the finding.\n")

# ---- Does size interact with tariff? (formal test of the heterogeneity) ----
cat("\n=== INTERACTION: does tariff effect depend on sector size? ===\n")
uc$log_size <- log(uc$base_imports)
m_int <- lm(import_change ~ init_rate * log_size, data = uc)
print(round(summary(m_int)$coefficients, 4))
cat("\nThe init_rate:log_size interaction term is the key row.\n")
cat("Significant interaction => tariff effect genuinely differs by sector size.\n")
