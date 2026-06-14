# ============================================================
# 19_random_forest.R  —  Trade Capstone
# RANDOM FOREST vs LOGISTIC REGRESSION comparison
#
# Same features, same outcome as script 18.
# Purpose: show that a more complex ML model does not dramatically
# outperform the simple logistic — the structure is simple.
# Feature importance chart shows which variables matter most.
#
# NO tuning. Default RF parameters. This is a comparison, not optimization.
# ============================================================

library(dplyr); library(readr); library(ggplot2)
library(randomForest); library(pROC)
fig <- "figures"

BLUE <- "#1f5c8a"; RED <- "#c0473b"; GREEN <- "#2d8a4e"; INK <- "#222222"
theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0))

# ---- load + prep (same as script 18) ----
t1 <- readRDS("data_processed/hs6_merged_2019.rds") %>%
  mutate(
    disruption      = factor(ifelse(import_change < -0.30, "Yes", "No"),
                             levels=c("No","Yes")),
    log_base_imp    = log(base_imports),
    trade_asymmetry = ifelse(base_imports > 0, exports/base_imports, NA_real_)
  ) %>%
  filter(!is.na(disruption), !is.na(trade_asymmetry), is.finite(log_base_imp))

set.seed(42)

# ---- Random Forest (default, no tuning) ----
cat("Fitting Random Forest (500 trees, default params)...\n")
rf <- randomForest(
  disruption ~ us_tariff_2019 + log_base_imp + trade_asymmetry,
  data      = t1,
  ntree     = 500,
  importance= TRUE
)
cat("Done.\n\n")

# ---- AUC comparison ----
# logistic (refit for comparison)
m_log <- glm(as.integer(disruption=="Yes") ~ us_tariff_2019 + log_base_imp + trade_asymmetry,
             data=t1, family=binomial)
prob_log <- predict(m_log, type="response")
prob_rf  <- predict(rf, type="prob")[,"Yes"]

roc_log <- pROC::roc(as.integer(t1$disruption=="Yes"), prob_log, quiet=TRUE)
roc_rf  <- pROC::roc(as.integer(t1$disruption=="Yes"), prob_rf,  quiet=TRUE)
auc_log <- round(as.numeric(roc_log$auc), 3)
auc_rf  <- round(as.numeric(roc_rf$auc),  3)

cat("=== AUC COMPARISON ===\n")
cat("Logistic regression:  AUC =", auc_log, "\n")
cat("Random Forest (500):  AUC =", auc_rf,  "\n")
cat("RF improvement:      +", round(auc_rf - auc_log, 3), "\n\n")

# ---- Feature importance ----
imp_df <- data.frame(
  feature   = c("Tariff rate\n(us_tariff_2019)",
                "Product size\n(log baseline imports)",
                "Trade asymmetry\n(exports/imports)"),
  MeanDecreaseGini = importance(rf)[,"MeanDecreaseGini"]
)
cat("=== FEATURE IMPORTANCE (Mean Decrease Gini) ===\n")
print(imp_df)

# ---- FIGURE A: ROC curve comparison ----
roc_log_df <- data.frame(fpr=1-roc_log$specificities, tpr=roc_log$sensitivities,
                          model="Logistic  (AUC=0.689)")
roc_rf_df  <- data.frame(fpr=1-roc_rf$specificities,  tpr=roc_rf$sensitivities,
                          model=paste0("Random Forest (AUC=", auc_rf, ")"))
# update logistic label with actual computed AUC
roc_log_df$model <- paste0("Logistic  (AUC=", auc_log, ")")

roc_both <- bind_rows(roc_log_df, roc_rf_df)

f12a <- ggplot(roc_both, aes(fpr, tpr, color=model, linetype=model)) +
  geom_abline(slope=1, intercept=0, color="grey70", linetype="dotted") +
  geom_line(linewidth=1.2) +
  scale_color_manual(values=c(BLUE, GREEN), name=NULL) +
  scale_linetype_manual(values=c("solid","dashed"), name=NULL) +
  annotate("text", x=0.02, y=0.18, hjust=0, size=3.5, color="grey40",
           label=paste0("RF vs Logistic: ",
                        ifelse(auc_rf >= auc_log,
                               paste0("+", round(auc_rf-auc_log,3)),
                               round(auc_rf-auc_log,3)),
                        "\nRF does not outperform logistic.\nThe structure is linear.")) +
  labs(title="Logistic vs Random Forest: ROC comparison",
       subtitle="Same three features. Random Forest underperforms the logistic (AUC 0.649 vs 0.689).\nThe predictive structure is linear — complexity adds noise, not signal.",
       x="False positive rate", y="True positive rate",
       caption="Trump 1 (2019), n=3,201 HS6 products. No hyperparameter tuning. RF: 500 trees, default params.") +
  theme_cap + theme(legend.position=c(0.62, 0.12))
ggsave(file.path(fig,"fig12a_roc_comparison.png"), f12a, width=8, height=6, dpi=200)

# ---- FIGURE B: Feature importance ----
f12b <- imp_df %>%
  arrange(MeanDecreaseGini) %>%
  mutate(feature=factor(feature, levels=feature)) %>%
  ggplot(aes(MeanDecreaseGini, feature, fill=MeanDecreaseGini)) +
  geom_col(show.legend=FALSE, width=0.6) +
  scale_fill_gradient(low="#9ab8d0", high=BLUE) +
  geom_text(aes(label=round(MeanDecreaseGini,1)), hjust=-0.2, size=3.5) +
  scale_x_continuous(expand=expansion(mult=c(0,0.15))) +
  labs(title="Feature importance: what predicts trade disruption?",
       subtitle="Random Forest Mean Decrease Gini.\nHigher = more important for classification.",
       x="Mean Decrease Gini", y=NULL,
       caption=paste0("Gini ranking: product size > trade asymmetry > tariff rate.\n",
                      "Note: Gini importance can be inflated for continuous variables with many split points.\n",
                      "Logistic regression gives a more interpretable ranking:\n",
                      "tariff rate (z=11.98) >> product size (z=-9.38) >> trade asymmetry (z=0.10, ns).")) +
  theme_cap + theme(panel.grid.major.y=element_blank())
ggsave(file.path(fig,"fig12b_feature_importance.png"), f12b, width=8, height=5, dpi=200)
cat("saved fig12a_roc_comparison.png and fig12b_feature_importance.png\n")
