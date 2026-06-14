# ============================================================
# 17_predictive_validation.R  —  Trade Capstone
# PREDICTIVE VALIDATION: train on Trump 1, predict Trump 2.
#
# Design:
#   1. Fit OLS on Trump 1 (2019): import_change ~ us_tariff_2019
#      (the slope -0.019 we already have)
#   2. Use that model to PREDICT 2025 import change for each product,
#      plugging in us_tariff_2025 as the new input
#   3. Compare predicted vs actual 2025 import change
#
# Expected result:
#   - Model predicts steep decline for high-2025-tariff products
#   - Actual 2025 data is flat (~-28%) regardless of tariff rate
#   - The gap IS the adaptation finding, made visual
#
# This directly supports the adaptive-systems interpretation:
#   "The model learned Trump 1. The world changed. The model broke."
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"

BLUE <- "#1f5c8a"; RED <- "#c0473b"; INK <- "#222222"
theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0))

# ---- Step 1: fit Trump 1 model ----
t1 <- readRDS("data_processed/hs6_merged_2019.rds")
w  <- function(x,p=0.01){q<-quantile(x,c(p,1-p),na.rm=TRUE);pmin(pmax(x,q[1]),q[2])}
t1$ic_w <- w(t1$import_change)

m_t1 <- lm(ic_w ~ us_tariff_2019, data=t1)
cat("=== TRUMP 1 MODEL (training) ===\n")
print(round(summary(m_t1)$coefficients, 5))
cat("Intercept:", round(coef(m_t1)[1], 4),
    "  Slope:", round(coef(m_t1)[2], 5), "\n\n")

# ---- Step 2: load Trump 2 data + predict ----
t2 <- readRDS("data_processed/hs6_trump2_direct.rds")  # from script 14

# predict 2025 outcome using Trump 1 model + Trump 2 tariff rates
t2$predicted_change <- predict(m_t1,
  newdata=data.frame(us_tariff_2019=t2$us_tariff_2025))
t2$actual_change    <- w(t2$import_change25)

cat("=== PREDICTION vs ACTUAL (Trump 2) ===\n")
cat("Mean PREDICTED 2025 change:", round(mean(t2$predicted_change, na.rm=TRUE), 3), "\n")
cat("Mean ACTUAL    2025 change:", round(mean(t2$actual_change,    na.rm=TRUE), 3), "\n")
cat("Mean prediction error:     ", round(mean(t2$actual_change - t2$predicted_change, na.rm=TRUE), 3), "\n\n")

# by tariff bucket — where does the model fail most?
cat("=== PREDICTION ERROR BY TARIFF BUCKET ===\n")
t2 %>%
  mutate(bucket=cut(us_tariff_2025, c(0,25,40,50,100),
                    labels=c("(0-25]","(25-40]","(40-50]","(50-100]"))) %>%
  group_by(bucket) %>%
  summarise(n=n(),
            mean_predicted = round(mean(predicted_change, na.rm=TRUE), 3),
            mean_actual    = round(mean(actual_change, na.rm=TRUE), 3),
            error          = round(mean(actual_change-predicted_change, na.rm=TRUE), 3)) %>%
  print()

# ---- Step 3: the figure ----
# Show predicted (from T1 model) vs actual (T2 data) against T2 tariff rate
# Predicted = steep downward line; Actual = flat cloud
# The gap between them IS the adaptation story

# smooth the predicted line cleanly
tariff_grid <- data.frame(
  us_tariff_2025 = seq(min(t2$us_tariff_2025, na.rm=TRUE),
                       max(t2$us_tariff_2025, na.rm=TRUE), length.out=200))
tariff_grid$predicted <- predict(m_t1,
  newdata=data.frame(us_tariff_2019=tariff_grid$us_tariff_2025))

f10 <- ggplot() +
  geom_hline(yintercept=0, color="grey60", linewidth=0.4) +
  # actual 2025 data points
  geom_point(data=t2, aes(us_tariff_2025, actual_change,
             color="Actual 2025 outcome"), alpha=0.15, size=0.9) +
  # actual 2025 smooth
  geom_smooth(data=t2, aes(us_tariff_2025, actual_change,
              color="Actual 2025 outcome"),
              method="lm", se=TRUE, linewidth=1.2) +
  # predicted line from T1 model
  geom_line(data=tariff_grid, aes(us_tariff_2025, predicted,
            color="Trump 1 model prediction"),
            linewidth=1.4, linetype="dashed") +
  # gap annotation
  annotate("segment", x=70, xend=70, y=-0.08, yend=-0.98,
           arrow=arrow(length=unit(0.1,"in"), ends="both"),
           color="grey30", linewidth=0.6) +
  annotate("text", x=72, y=-0.53, hjust=0, size=3.2, color="grey30",
           label="Prediction\ngap:\nadaptation") +
  scale_color_manual(
    values=c("Actual 2025 outcome"=RED,
             "Trump 1 model prediction"=BLUE),
    name=NULL) +
  coord_cartesian(ylim=c(-1.05, 0.6)) +
  labs(title="Predictive validation: Trump 1 model fails on Trump 2 data",
       subtitle=paste0("Dashed blue = what the Trump 1 OLS model predicts for 2025, using actual 2025 tariff rates.\n",
                       "Solid red = what actually happened. The model learned Trump 1. The world changed. The model broke."),
       x="US tariff on China, 2025 (%) — WTO Nov-2025 rate",
       y="Import change vs 2022-24 baseline",
       caption=paste0("Trump 1 model: import_change = ",
                      round(coef(m_t1)[1],3), " + ",
                      round(coef(m_t1)[2],4),
                      " × tariff (fitted on 3,201 products, 2019).\n",
                      "Applied out-of-sample to 3,164 products at 2025 tariff rates.")) +
  theme_cap + theme(legend.position="top")
ggsave(file.path(fig,"fig10_predictive_validation.png"), f10, width=10, height=6.5, dpi=200)
cat("\nsaved fig10_predictive_validation.png\n")
