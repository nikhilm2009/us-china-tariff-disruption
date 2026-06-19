# ============================================================
# 18_logistic_hs6.R  —  Trade Capstone
# LOGISTIC REGRESSION at HS6 (Trump 1 episode)
#
# Question: can we predict whether a product experiences a large
# disruption (import decline > 30%)?
#
# Features:
#   - us_tariff_2019     (tariff exposure)
#   - log(base_imports)  (baseline trade volume / economic weight)
#   - trade_asymmetry    (export/import ratio — dependence direction)
#
# Threshold: disruption_flag = 1 if import_change < -0.30
# Reports: coefficients, AUC, confusion matrix, feature importance
# ============================================================

library(dplyr); library(readr); library(ggplot2); library(pROC)
fig <- "figures"

BLUE <- "#1f5c8a"; RED <- "#c0473b"; INK <- "#222222"
theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0))

# ---- load data ----
t1 <- readRDS("data_processed/hs6_merged_2019.rds") %>%
  mutate(
    disruption      = as.integer(import_change < -0.30),
    log_base_imp    = log(base_imports),
    trade_asymmetry = ifelse(base_imports > 0, exports/base_imports, NA_real_)
  ) %>%
  filter(!is.na(disruption), !is.na(trade_asymmetry),
         is.finite(log_base_imp), is.finite(trade_asymmetry))

cat("=== DATA ===\n")
cat("Products:", nrow(t1), "\n")
cat("Disrupted (>30% decline):", sum(t1$disruption),
    sprintf("(%.1f%%)\n\n", 100*mean(t1$disruption)))

# ---- fit logistic ----
m_log <- glm(disruption ~ us_tariff_2019 + log_base_imp + trade_asymmetry,
             data=t1, family=binomial)
cat("=== LOGISTIC REGRESSION COEFFICIENTS ===\n")
print(round(summary(m_log)$coefficients, 4))

# ---- AUC ----
probs <- predict(m_log, type="response")
roc_obj <- pROC::roc(t1$disruption, probs, quiet=TRUE)
auc_val <- as.numeric(roc_obj$auc)
cat("\nAUC:", round(auc_val, 3), "\n")

# threshold at 0.5 for confusion matrix
pred_class <- as.integer(probs >= 0.5)
cm <- table(Predicted=pred_class, Actual=t1$disruption)
cat("\nConfusion matrix (threshold = 0.5):\n")
print(cm)
cat("Accuracy:", round(mean(pred_class == t1$disruption), 3), "\n\n")

# ---- FIGURE: ROC curve ----
roc_df <- data.frame(
  fpr = 1 - roc_obj$specificities,
  tpr = roc_obj$sensitivities
)
f11 <- ggplot(roc_df, aes(fpr, tpr)) +
  geom_abline(slope=1, intercept=0, color="grey70", linetype="dashed") +
  geom_line(color=BLUE, linewidth=1.2) +
  annotate("text", x=0.6, y=0.3, hjust=0,
           label=sprintf("AUC = %.3f", auc_val),
           size=5, fontface="bold", color=BLUE) +
  annotate("text", x=0.6, y=0.22, hjust=0,
           label="Tariff rate + baseline volume\n+ trade asymmetry",
           size=3.5, color="grey40") +
  labs(title="Logistic regression: predicting trade disruption (>30% decline)",
       subtitle=paste0("Features: tariff rate, log baseline imports, trade asymmetry (exports/imports).\n",
                       "Outcome: disruption flag = 1 if 2019 import change < -30%.\n",
                       "n = ", nrow(t1), " HS6 products."),
       x="False positive rate", y="True positive rate (sensitivity)",
       caption="Trump 1 (2019) data. Logistic regression with three features.") +
  theme_cap
ggsave(file.path(fig,"fig11_logistic_roc.png"), f11, width=8, height=6, dpi=200)

# ---- marginal effects figure (what drives disruption probability?) ----
tariff_seq <- seq(0, 40, by=1)
med_log_imp <- median(t1$log_base_imp)
med_asym    <- median(t1$trade_asymmetry)

marg <- data.frame(
  us_tariff_2019  = tariff_seq,
  log_base_imp    = med_log_imp,
  trade_asymmetry = med_asym
)
marg$prob <- predict(m_log, newdata=marg, type="response")

f11b <- ggplot(marg, aes(us_tariff_2019, prob)) +
  geom_ribbon(aes(ymin=prob*0.85, ymax=pmin(prob*1.15,1)),
              fill=BLUE, alpha=0.15) +
  geom_line(color=BLUE, linewidth=1.3) +
  geom_hline(yintercept=0.5, color="grey50", linetype="dashed") +
  scale_y_continuous(labels=scales::percent_format(accuracy=1), limits=c(0,1)) +
  labs(title="Predicted probability of large disruption by tariff rate",
       subtitle="Logistic model evaluated at median baseline volume and trade asymmetry.\nDashed line = 50% probability threshold.",
       x="US Section 301 tariff rate, 2019 (%)",
       y="P(import decline > 30%)",
       caption="Other features held at median. Shaded band = ±15% of point estimate.") +
  theme_cap
ggsave(file.path(fig,"fig11b_disruption_prob.png"), f11b, width=8, height=5.5, dpi=200)
cat("saved fig11_logistic_roc.png and fig11b_disruption_prob.png\n")

# ---- FIGURE: coefficient plot (more interpretable than RF Gini) ----
# Shows the logistic regression coefficients with 95% CIs
# This is the "what drives disruption" figure for the main deck

coef_df <- data.frame(
  variable = c("Tariff rate\n(us_tariff_2019)",
               "Product size\n(log baseline imports)",
               "Trade asymmetry\n(exports/imports)"),
  estimate = coef(m_log)[c("us_tariff_2019","log_base_imp","trade_asymmetry")],
  se       = summary(m_log)$coefficients[
               c("us_tariff_2019","log_base_imp","trade_asymmetry"), "Std. Error"]
) %>%
  mutate(
    ci_lo = estimate - 1.96*se,
    ci_hi = estimate + 1.96*se,
    significant = ifelse(abs(estimate/se) > 1.96, "Significant", "Not significant"),
    variable = factor(variable, levels=rev(variable))
  )

f11c <- ggplot(coef_df, aes(estimate, variable, color=significant)) +
  geom_vline(xintercept=0, color="grey50", linetype="dashed") +
  geom_errorbarh(aes(xmin=ci_lo, xmax=ci_hi), height=0.15, linewidth=0.8) +
  geom_point(size=4) +
  scale_color_manual(values=c("Significant"="#1f5c8a", "Not significant"="#c0473b"),
                     name=NULL) +
  labs(title="What drives trade disruption? Logistic regression coefficients",
       subtitle="Log-odds coefficients with 95% CI. Points right of zero = increases disruption probability.\nTariff rate is the dominant predictor; product size adds protective effect; asymmetry adds nothing.",
       x="Log-odds coefficient (logistic regression)", y=NULL,
       caption=paste0("n=", nrow(t1), " HS6 products. Outcome: import decline >30%.\n",
                      "After controlling for tariff rate, product size still matters (large products more resilient).\n",
                      "Trade asymmetry is near-zero and non-significant (z=0.10).")) +
  theme_cap + theme(legend.position="top", panel.grid.major.y=element_blank())
ggsave(file.path(fig,"fig11c_logistic_coefficients.png"), f11c, width=9, height=5.5, dpi=200)
cat("saved fig11c_logistic_coefficients.png\n")
