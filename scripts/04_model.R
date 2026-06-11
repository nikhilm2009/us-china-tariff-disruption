# ============================================================
# 04_model.R  —  Trade Capstone
# Implements the v2 blueprint modeling discipline:
#   - PRIMARY: continuous trade_change ~ retaliation_ratio (no arbitrary cutoff)
#   - ROBUSTNESS: logistic escalation flag at THREE thresholds (-25/-30/-35)
#   - Fixed effects kept MINIMAL (pair, then pair+year) to preserve the
#     cross-sector variation that identifies the retaliation_ratio coefficient
# ============================================================

library(dplyr)
library(readr)
library(fixest)
library(pROC)

proc_dir <- "data_processed"
out_dir  <- "outputs"

panel <- read_csv(file.path(proc_dir, "panel_with_tariffs.csv"),
                  show_col_types = FALSE)

# Use only conflict-period observations for the cross-section of disruption.
# (Baseline years already folded into trade_change.)
conflict <- panel %>%
  filter(
    (pair == "china_aus" & year %in% c(2020, 2021)) |
    (pair != "china_aus" & year %in% c(2018, 2019))
  ) %>%
  filter(!is.na(trade_change), !is.na(retaliation_ratio))

message("Conflict-period observations: ", nrow(conflict))

# ============================================================
# PRIMARY SPECIFICATION (continuous outcome)
# ============================================================

# (a) simplest: pooled
m_pooled <- feols(trade_change ~ retaliation_ratio, data = conflict)

# (b) minimal FE: pair fixed effects only (preserves cross-sector variation)
m_pairFE <- feols(trade_change ~ retaliation_ratio | pair, data = conflict)

# (c) pair + year FE
m_pairyrFE <- feols(trade_change ~ retaliation_ratio | pair + year, data = conflict)

# Add the secondary balance control to show it's not just asymmetry
m_ctrl <- feols(trade_change ~ retaliation_ratio + trade_asymmetry | pair,
                data = conflict)

primary_tbl <- etable(
  m_pooled, m_pairFE, m_pairyrFE, m_ctrl,
  headers = c("Pooled", "Pair FE", "Pair+Year FE", "Pair FE +ctrl"),
  fitstat = ~ n + r2
)
print(primary_tbl)
capture.output(print(primary_tbl),
               file = file.path(out_dir, "primary_continuous_models.txt"))

# ============================================================
# ROBUSTNESS: logistic at three thresholds
# ============================================================
thresholds <- c(-0.25, -0.30, -0.35)

logit_results <- lapply(thresholds, function(th) {
  d <- conflict %>% mutate(escalation = as.integer(trade_change < th))
  if (length(unique(d$escalation)) < 2) {
    return(data.frame(threshold = th, note = "no variation in flag",
                      coef = NA, auc = NA))
  }
  fit <- glm(escalation ~ retaliation_ratio, data = d, family = binomial)
  pr  <- predict(fit, type = "response")
  auc <- as.numeric(pROC::roc(d$escalation, pr, quiet = TRUE)$auc)
  data.frame(
    threshold = th,
    n_escalated = sum(d$escalation),
    coef_retaliation = coef(fit)[["retaliation_ratio"]],
    p_value = summary(fit)$coefficients["retaliation_ratio", "Pr(>|z|)"],
    auc = auc
  )
})
logit_tbl <- bind_rows(logit_results)
print(logit_tbl)
write_csv(logit_tbl, file.path(out_dir, "logistic_threshold_robustness.csv"))

message("\nInterpretation guide:")
message(" - If the continuous coef and the logistic coefs agree in SIGN across")
message("   all three thresholds, the story is robust to the cutoff choice.")
message(" - Per-pair or per-sector divergence -> that's the Finding C material;")
message("   characterize WHICH sectors diverge in 05_plots.R, don't just note it.")
message("Next: 05_plots.R")
