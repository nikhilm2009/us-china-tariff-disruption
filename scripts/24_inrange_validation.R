# ============================================================
# 24_inrange_validation.R  —  Trade Capstone
# ROBUSTNESS CHECK: Within-range prediction test
#
# Professor Zhao's critique: the Trump 1 model was trained on
# tariff rates up to ~45%. Many Trump 2 rates are 70-100%+.
# The 58pp prediction gap may reflect out-of-distribution
# extrapolation rather than genuine economic adaptation.
#
# TEST: Restrict to T2 products where us_tariff_2025 is within
# the T1 training range (using the computed T1 max as the ceiling).
# If the prediction gap persists for in-range products, the
# out-of-distribution critique is substantially weakened.
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"

NAVY <- "#1E2761"; BLUE <- "#1F5C8A"; RED <- "#B03A2E"
STEEL <- "#4A6FA5"; CHARCOAL <- "#333333"; MIDGRAY <- "#666666"
OFFWHT <- "#F7F9FC"; MIST <- "#E8EEF4"; WHITE <- "#FFFFFF"

theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15, color=NAVY),
        plot.subtitle=element_text(color="grey35", size=11),
        plot.caption=element_text(color=MIDGRAY, size=9, hjust=0),
        plot.background=element_rect(fill=WHITE, color=NA))

w <- function(x, p=0.01) {
  q <- quantile(x, c(p, 1-p), na.rm=TRUE)
  pmin(pmax(x, q[1]), q[2])
}

# ── Load data ────────────────────────────────────────────────
t1 <- readRDS("data_processed/hs6_merged_2019.rds")
t2 <- readRDS("data_processed/hs6_trump2_direct.rds")

# T1 model — refit for reference
m_t1 <- lm(w(import_change) ~ us_tariff_2019, data=t1)
cat("=== TRUMP 1 MODEL (reference) ===\n")
cat(sprintf("  Intercept: %.4f\n", coef(m_t1)[1]))
cat(sprintf("  Slope:     %.4f\n", coef(m_t1)[2]))
cat(sprintf("  t:         %.2f\n", summary(m_t1)$coef[2,3]))

# T1 tariff range
t1_min <- min(t1$us_tariff_2019, na.rm=TRUE)
t1_max <- max(t1$us_tariff_2019, na.rm=TRUE)
cat(sprintf("\n=== T1 TRAINING RANGE: %.1f%% to %.1f%% ===\n", t1_min, t1_max))

# ── T2 full dataset stats ─────────────────────────────────────
cat("\n=== T2 TARIFF RATE DISTRIBUTION ===\n")
cat(sprintf("  n total:   %d\n", nrow(t2)))
cat(sprintf("  Min:       %.1f%%\n", min(t2$us_tariff_2025, na.rm=TRUE)))
cat(sprintf("  Median:    %.1f%%\n", median(t2$us_tariff_2025, na.rm=TRUE)))
cat(sprintf("  Max:       %.1f%%\n", max(t2$us_tariff_2025, na.rm=TRUE)))
cat(sprintf("  In T1 range (≤%.0f%%): %d products (%.1f%%)\n",
    t1_max,
    sum(t2$us_tariff_2025 <= t1_max, na.rm=TRUE),
    100*mean(t2$us_tariff_2025 <= t1_max, na.rm=TRUE)))
cat(sprintf("  Out of range (>%.0f%%): %d products (%.1f%%)\n",
    t1_max,
    sum(t2$us_tariff_2025 > t1_max, na.rm=TRUE),
    100*mean(t2$us_tariff_2025 > t1_max, na.rm=TRUE)))

# ── Apply T1 model to T2 ─────────────────────────────────────
t2 <- t2 %>%
  mutate(
    ic25_w = w(import_change25),
    predicted = coef(m_t1)[1] + coef(m_t1)[2] * us_tariff_2025,
    in_range = us_tariff_2025 <= t1_max,
    range_label = ifelse(in_range,
      paste0("In range (≤", round(t1_max), "%)"),
      paste0("Out of range (>", round(t1_max), "%)"))
  )

# ── Prediction gap by range group ────────────────────────────
cat("\n=== PREDICTION GAP: IN-RANGE vs OUT-OF-RANGE ===\n")
gap_tbl <- t2 %>%
  group_by(range_label) %>%
  summarise(
    n            = n(),
    mean_tariff  = round(mean(us_tariff_2025, na.rm=TRUE), 1),
    actual_mean  = round(mean(ic25_w, na.rm=TRUE)*100, 1),
    pred_mean    = round(mean(predicted, na.rm=TRUE)*100, 1),
    gap_pp       = round((mean(predicted, na.rm=TRUE) -
                           mean(ic25_w, na.rm=TRUE))*100, 1),
    .groups="drop"
  )
print(gap_tbl)

# ── Direct T2 regression: in-range only ──────────────────────
cat("\n=== DIRECT T2 REGRESSION: IN-RANGE PRODUCTS ONLY ===\n")
t2_in <- t2 %>% filter(in_range, !is.na(ic25_w))
m_t2_in <- lm(ic25_w ~ us_tariff_2025, data=t2_in)
cat(sprintf("  n:     %d\n", nrow(t2_in)))
cat(sprintf("  Slope: %.6f\n", coef(m_t2_in)[2]))
cat(sprintf("  t:     %.3f\n", summary(m_t2_in)$coef[2,3]))
cat(sprintf("  p:     %.4f\n", summary(m_t2_in)$coef[2,4]))

cat("\n=== DIRECT T2 REGRESSION: OUT-OF-RANGE PRODUCTS ONLY ===\n")
t2_out <- t2 %>% filter(!in_range, !is.na(ic25_w))
m_t2_out <- lm(ic25_w ~ us_tariff_2025, data=t2_out)
cat(sprintf("  n:     %d\n", nrow(t2_out)))
cat(sprintf("  Slope: %.6f\n", coef(m_t2_out)[2]))
cat(sprintf("  t:     %.3f\n", summary(m_t2_out)$coef[2,3]))
cat(sprintf("  p:     %.4f\n", summary(m_t2_out)$coef[2,4]))

cat("\n=== DIRECT T2 REGRESSION: ALL PRODUCTS ===\n")
m_t2_all <- lm(ic25_w ~ us_tariff_2025, data=t2)
cat(sprintf("  n:     %d\n", nrow(t2)))
cat(sprintf("  Slope: %.6f\n", coef(m_t2_all)[2]))
cat(sprintf("  t:     %.3f\n", summary(m_t2_all)$coef[2,3]))
cat(sprintf("  p:     %.4f\n", summary(m_t2_all)$coef[2,4]))

# ── FIGURE: Prediction vs actual, split by range ─────────────
plot_df <- t2 %>%
  filter(!is.na(ic25_w)) %>%
  mutate(range_label = factor(range_label,
    levels=c(paste0("In range (≤", round(t1_max), "%)"),
             paste0("Out of range (>", round(t1_max), "%)"))))

# Compute group means for annotation
means <- plot_df %>%
  group_by(range_label) %>%
  summarise(
    actual  = mean(ic25_w, na.rm=TRUE),
    pred    = mean(predicted, na.rm=TRUE),
    mid_x   = mean(us_tariff_2025, na.rm=TRUE),
    .groups="drop"
  )

# ── Per-panel annotation text, computed live from the models above ──
in_lab  <- paste0("In range (≤", round(t1_max), "%)")
out_lab <- paste0("Out of range (>", round(t1_max), "%)")

# slope + gap per panel (m_t2_in / m_t2_out fitted earlier in script)
slope_in   <- coef(m_t2_in)[2];  t_in   <- summary(m_t2_in)$coef[2,3]
slope_out  <- coef(m_t2_out)[2]; t_out  <- summary(m_t2_out)$coef[2,3]
gap_in  <- (mean(t2_in$predicted,  na.rm=TRUE) - mean(t2_in$ic25_w,  na.rm=TRUE))*100
gap_out <- (mean(t2_out$predicted, na.rm=TRUE) - mean(t2_out$ic25_w, na.rm=TRUE))*100
act_in  <- mean(t2_in$ic25_w,  na.rm=TRUE)*100
act_out <- mean(t2_out$ic25_w, na.rm=TRUE)*100

sig_tag <- function(tval) ifelse(abs(tval) > 1.96, sprintf("t = %.2f *", tval),
                                 sprintf("t = %.2f, ns", tval))

# stat boxes (upper-left of each panel): what the actual slope is
stat_box <- data.frame(
  range_label = factor(c(in_lab, out_lab), levels=c(in_lab, out_lab)),
  x = c(min(t2_in$us_tariff_2025, na.rm=TRUE), min(t2_out$us_tariff_2025, na.rm=TRUE)),
  y = c(0.55, 0.55),
  label = c(
    sprintf("Actual slope ≈ %.4f  (%s)\nNo dose-response inside the trained range.",
            slope_in, sig_tag(t_in)),
    sprintf("Actual slope = %.4f  (%s)\nEconomically tiny: ~%.0fpp over a 50pp tariff swing.",
            slope_out, sig_tag(t_out), abs(slope_out*50)*100))
)

# gap callouts (lower portion): prediction vs reality
gap_box <- data.frame(
  range_label = factor(c(in_lab, out_lab), levels=c(in_lab, out_lab)),
  x = c(mean(t2_in$us_tariff_2025, na.rm=TRUE), mean(t2_out$us_tariff_2025, na.rm=TRUE)),
  y = c(-0.70, -0.70),
  label = c(
    sprintf("Gap = %.0fpp\nActual %.0f%% vs predicted %.0f%%", gap_in, act_in, act_in - gap_in),
    sprintf("Gap = %.0fpp\nActual %.0f%% vs predicted %.0f%%", gap_out, act_out, act_out - gap_out))
)

fig_out <- ggplot(plot_df, aes(us_tariff_2025, ic25_w)) +
  geom_point(alpha=0.15, size=0.8, color=STEEL) +
  geom_hline(yintercept=0, color="grey60", linewidth=0.4) +
  # Actual smoothed line
  geom_smooth(method="lm", se=TRUE, color=RED,
              fill=RED, alpha=0.12, linewidth=1.1) +
  # T1 model prediction line
  geom_abline(intercept=coef(m_t1)[1], slope=coef(m_t1)[2],
              color=BLUE, linetype="dashed", linewidth=1.0) +
  # stat box: actual slope inside each panel
  geom_label(data=stat_box, aes(x=x, y=y, label=label),
             hjust=0, vjust=1, size=3.0, color=RED, fontface="bold",
             fill="white", label.size=0.3, lineheight=0.95, inherit.aes=FALSE) +
  # gap callout: prediction vs reality
  geom_label(data=gap_box, aes(x=x, y=y, label=label),
             hjust=0.5, vjust=1, size=3.0, color=NAVY, fontface="bold",
             fill="#EEF1F6", label.size=0, lineheight=0.95, inherit.aes=FALSE) +
  facet_wrap(~range_label, scales="free_x") +
  coord_cartesian(ylim=c(-0.8, 0.7)) +
  labs(
    title="Within-range robustness check: the dose-response is gone even where the model was trained",
    subtitle=paste0(
      "Dashed blue = Trump 1 model prediction.  Solid red = actual 2025 outcome.\n",
      "Left panel restricts to 2025 tariffs inside the Trump 1 training range — no extrapolation. ",
      "The actual slope is still flat,\nso the failure is not merely out-of-distribution extrapolation: the functional form itself broke."),
    x="US tariff rate, 2025 (%)",
    y="Import change vs 2022-24 baseline",
    caption=paste0(
      "T1 training range: ", round(t1_min), "–", round(t1_max), "%.  ",
      "In-range n = ", sum(t2$in_range, na.rm=TRUE), ".  ",
      "Out-of-range n = ", sum(!t2$in_range, na.rm=TRUE), ".  ",
      "Actual 2025 declines are ~flat (~", round(abs(act_in)), "%) regardless of tariff level.\n",
      "Prof. Zhao critique addressed: extrapolation inflates the gap magnitude but does not explain the slope collapse.")) +
  theme_cap +
  theme(strip.text=element_text(size=11, face="bold", color=NAVY))

ggsave(file.path(fig, "fig13_inrange_validation.png"),
       fig_out, width=11, height=6, dpi=200)
cat("\nsaved fig13_inrange_validation.png\n")

# ── Summary interpretation ────────────────────────────────────
cat("\n=== INTERPRETATION GUIDE ===\n")
cat("If in-range gap ≈ out-of-range gap:\n")
cat("  → Out-of-distribution extrapolation is NOT the primary explanation.\n")
cat("  → Adaptation story is strengthened.\n\n")
cat("If in-range gap << out-of-range gap:\n")
cat("  → Extrapolation explains a meaningful share of the failure.\n")
cat("  → Need to quantify and disclose as limitation.\n\n")
cat("If in-range T2 slope ≈ 0 (ns):\n")
cat("  → Dose-response collapsed even within the trained range.\n")
cat("  → Strongest possible evidence for structural change.\n")
