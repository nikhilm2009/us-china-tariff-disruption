# ============================================================
# 20_model_comparison.R  —  Trade Capstone
# THREE-MODEL ROC COMPARISON: Logistic vs RF vs XGBoost
#
# Same features, same outcome, same train/test split across all three.
# We report whatever the data shows — no result is suppressed.
# If XGBoost outperforms, Finding 4 changes from "structure is linear"
# to "modest nonlinear structure exists; XGBoost captures it."
#
# Design:
#   - 80/20 train/test split (stratified on outcome)
#   - All three models fitted on TRAIN, evaluated on TEST
#   - AUC computed on TEST set (out-of-sample)
#   - XGBoost: minimal tuning (50 rounds, default depth=6, eta=0.3)
#     We note in caption that no extensive tuning was performed.
# ============================================================

library(dplyr); library(readr); library(ggplot2)
library(randomForest); library(xgboost); library(pROC)
fig <- "figures"

BLUE <- "#1f5c8a"; RED <- "#c0473b"; GREEN <- "#2d8a4e"; INK <- "#222222"
theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0))

# ---- prep ----
t1 <- readRDS("data_processed/hs6_merged_2019.rds") %>%
  mutate(
    disruption      = as.integer(import_change < -0.30),
    log_base_imp    = log(base_imports),
    trade_asymmetry = ifelse(base_imports > 0, exports/base_imports, NA_real_)
  ) %>%
  filter(!is.na(disruption), !is.na(trade_asymmetry), is.finite(log_base_imp))

# ---- stratified 80/20 split ----
set.seed(42)
idx_pos <- which(t1$disruption == 1)
idx_neg <- which(t1$disruption == 0)
train_idx <- c(sample(idx_pos, floor(0.8*length(idx_pos))),
               sample(idx_neg, floor(0.8*length(idx_neg))))
train <- t1[ train_idx, ]
test  <- t1[-train_idx, ]
cat("Train:", nrow(train), " Test:", nrow(test),
    " Disruption rate train:", round(mean(train$disruption),3),
    " test:", round(mean(test$disruption),3), "\n\n")

features <- c("us_tariff_2019","log_base_imp","trade_asymmetry")

# ---- Logistic ----
m_log <- glm(disruption ~ us_tariff_2019 + log_base_imp + trade_asymmetry,
             data=train, family=binomial)
prob_log <- predict(m_log, newdata=test, type="response")
roc_log  <- pROC::roc(test$disruption, prob_log, quiet=TRUE)
auc_log  <- round(as.numeric(roc_log$auc), 3)

# ---- Random Forest ----
cat("Fitting RF...\n")
rf <- randomForest(
  factor(disruption) ~ us_tariff_2019 + log_base_imp + trade_asymmetry,
  data=train, ntree=500, importance=FALSE
)
prob_rf <- predict(rf, newdata=test, type="prob")[,"1"]
roc_rf  <- pROC::roc(test$disruption, prob_rf, quiet=TRUE)
auc_rf  <- round(as.numeric(roc_rf$auc), 3)

# ---- XGBoost ----
cat("Fitting XGBoost...\n")
dtrain <- xgb.DMatrix(
  data  = as.matrix(train[, features]),
  label = train$disruption
)
dtest <- xgb.DMatrix(
  data  = as.matrix(test[, features]),
  label = test$disruption
)
xgb_params <- list(
  objective  = "binary:logistic",
  eval_metric= "auc",
  eta        = 0.3,
  max_depth  = 6,
  subsample  = 0.8
)
set.seed(42)
m_xgb <- xgb.train(
  params  = xgb_params,
  data    = dtrain,
  nrounds = 50,
  verbose = 0
)
prob_xgb <- predict(m_xgb, dtest)
roc_xgb  <- pROC::roc(test$disruption, prob_xgb, quiet=TRUE)
auc_xgb  <- round(as.numeric(roc_xgb$auc), 3)

# ---- Results ----
cat("\n=== THREE-MODEL AUC COMPARISON (TEST SET) ===\n")
cat("Logistic regression: AUC =", auc_log, "\n")
cat("Random Forest:       AUC =", auc_rf,  "\n")
cat("XGBoost (50 rounds): AUC =", auc_xgb, "\n")
cat("\nBest model:", c("Logistic","RF","XGBoost")[which.max(c(auc_log,auc_rf,auc_xgb))], "\n")
cat("XGBoost vs Logistic:", round(auc_xgb-auc_log,3), "\n")

# ---- Interpret the result ----
best_auc <- max(c(auc_log, auc_rf, auc_xgb))
if (auc_xgb > auc_log + 0.02) {
  cat("\nINTERPRETATION: XGBoost meaningfully outperforms logistic (>2pp).\n")
  cat("Finding 4 revision: modest nonlinear structure exists.\n")
} else if (auc_xgb > auc_log) {
  cat("\nINTERPRETATION: XGBoost marginally outperforms logistic (<2pp gap).\n")
  cat("Finding 4 holds: structure is predominantly linear.\n")
} else {
  cat("\nINTERPRETATION: Logistic matches or beats both ML models.\n")
  cat("Finding 4 confirmed: structure is linear.\n")
}

# ---- FIGURE: three-model ROC ----
roc_log_df <- data.frame(fpr=1-roc_log$specificities, tpr=roc_log$sensitivities,
                         model=paste0("Logistic (AUC=",auc_log,")"))
roc_rf_df  <- data.frame(fpr=1-roc_rf$specificities,  tpr=roc_rf$sensitivities,
                         model=paste0("Random Forest (AUC=",auc_rf,")"))
roc_xgb_df <- data.frame(fpr=1-roc_xgb$specificities, tpr=roc_xgb$sensitivities,
                         model=paste0("XGBoost (AUC=",auc_xgb,")"))
roc_all <- bind_rows(roc_log_df, roc_rf_df, roc_xgb_df)
roc_all$model <- factor(roc_all$model,
  levels=c(paste0("Logistic (AUC=",auc_log,")"),
           paste0("Random Forest (AUC=",auc_rf,")"),
           paste0("XGBoost (AUC=",auc_xgb,")")))

# verdict annotation
verdict <- ifelse(auc_xgb > auc_log + 0.02,
  "XGBoost reveals nonlinear structure.",
  ifelse(auc_xgb > auc_log,
    "Marginal XGBoost gain: structure\nis predominantly linear.",
    "Logistic matches/beats ML models:\nstructure is linear."))

f12_v2 <- ggplot(roc_all, aes(fpr, tpr, color=model, linetype=model)) +
  geom_abline(slope=1, intercept=0, color="grey70", linetype="dotted") +
  geom_line(linewidth=1.1) +
  annotate("text", x=0.42, y=0.08, hjust=0, size=3.4, color="grey35",
           label=verdict) +
  scale_color_manual(values=c(BLUE, GREEN, "#e67e22"), name=NULL) +
  scale_linetype_manual(values=c("solid","dashed","longdash"), name=NULL) +
  labs(title="Model comparison: Logistic vs Random Forest vs XGBoost",
       subtitle="80/20 stratified train/test split. AUC evaluated on held-out test set.\nSame three features across all models: tariff rate, log product size, trade asymmetry.",
       x="False positive rate", y="True positive rate",
       caption="XGBoost: 50 rounds, eta=0.3, max_depth=6, subsample=0.8. No extensive tuning.\nWe report the result regardless of direction — narrative follows the data.") +
  theme_cap + theme(legend.position=c(0.72, 0.28))
ggsave(file.path(fig,"fig12_model_comparison.png"), f12_v2, width=9, height=6.5, dpi=200)
cat("\nsaved fig12_model_comparison.png\n")
