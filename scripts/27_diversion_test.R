# ============================================================
# 27_diversion_test.R  —  Trade Capstone
# TRADE DIVERSION TEST — Vietnam + Mexico only
# Taiwan excluded (UN Comtrade data unavailable).
# Requires: 26_diversion_build.R to have run first.
# ============================================================

library(dplyr); library(readr); library(ggplot2); library(tidyr)
fig  <- "figures"
proc <- "data_processed"

NAVY    <- "#1E2761"; BLUE   <- "#1F5C8A"; STEEL  <- "#4A6FA5"
RED     <- "#B03A2E"; MIDGRAY<- "#666666"; OFFWHT <- "#F7F9FC"
CHARCOAL<- "#333333"; WHITE  <- "#FFFFFF"; MIST   <- "#E8EEF4"

theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15, color=NAVY),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color=MIDGRAY, size=9, hjust=0),
        plot.background=element_rect(fill=WHITE, color=NA))

w <- function(x, p=0.01) {
  q <- quantile(x, c(p, 1-p), na.rm=TRUE)
  pmin(pmax(x, q[1]), q[2])
}

# ── Load panel ───────────────────────────────────────────────
d <- readRDS(file.path(proc, "diversion_panel.rds"))
cat("=== DIVERSION PANEL ===\n")
cat("n products:", nrow(d), "\n\n")

# ── TEST 1: China T1 decline vs third-country T2 rise ────────
cat("=== TEST 1: DOES CHINA'S T1 DECLINE PREDICT THIRD-COUNTRY T2 RISE? ===\n")

d_vn <- d %>% filter(!is.na(china_decline_t1), !is.na(t2_vietnam))
m_vn <- lm(w(t2_vietnam) ~ w(china_decline_t1), data=d_vn)
cat(sprintf("Vietnam  (n=%d): slope=%.4f, t=%.2f, p=%.4f\n",
    nrow(d_vn), coef(m_vn)[2],
    summary(m_vn)$coef[2,3], summary(m_vn)$coef[2,4]))

d_mx <- d %>% filter(!is.na(china_decline_t1), !is.na(t2_mexico))
m_mx <- lm(w(t2_mexico) ~ w(china_decline_t1), data=d_mx)
cat(sprintf("Mexico   (n=%d): slope=%.4f, t=%.2f, p=%.4f\n",
    nrow(d_mx), coef(m_mx)[2],
    summary(m_mx)$coef[2,3], summary(m_mx)$coef[2,4]))

d_tw <- d %>% filter(!is.na(china_decline_t1), !is.na(t2_taiwan))
m_tw <- lm(w(t2_taiwan) ~ w(china_decline_t1), data=d_tw)
cat(sprintf("Taiwan   (n=%d): slope=%.4f, t=%.2f, p=%.4f  (USITC source)\n",
    nrow(d_tw), coef(m_tw)[2],
    summary(m_tw)$coef[2,3], summary(m_tw)$coef[2,4]))

d_all <- d %>% filter(!is.na(china_decline_t1), !is.na(third_mean_t2))
m_all <- lm(w(third_mean_t2) ~ w(china_decline_t1), data=d_all)
cat(sprintf("Combined (n=%d): slope=%.4f, t=%.2f, p=%.4f\n",
    nrow(d_all), coef(m_all)[2],
    summary(m_all)$coef[2,3], summary(m_all)$coef[2,4]))

cat("\nInterpretation:\n")
cat("  Positive slope = products where China fell saw third-country RISE\n")
cat("  (china_decline is negative; positive slope = inverse relationship)\n")
cat("  Significant positive slope = DIVERSION PATTERN\n\n")

# ── TEST 2: Quadrant classification ──────────────────────────
cat("=== TEST 2: PRODUCT CLASSIFICATION BY T2 OUTCOME ===\n")
total_test <- d %>%
  filter(!is.na(china_decline_t2), !is.na(third_mean_t2)) %>%
  mutate(quadrant = case_when(
    china_decline_t2 < -0.1 & third_mean_t2 >  0.1 ~ "Diversion (China↓, 3rd↑)",
    china_decline_t2 < -0.1 & third_mean_t2 <= 0.1 ~ "Destruction (China↓, 3rd flat)",
    china_decline_t2 >= -0.1 & third_mean_t2 >  0.1 ~ "3rd growth only",
    TRUE ~ "Stable (both flat)"
  ))
print(total_test %>% count(quadrant) %>% arrange(desc(n)))

divert_n <- sum(total_test$quadrant == "Diversion (China↓, 3rd↑)", na.rm=TRUE)
total_n  <- nrow(total_test)
cat(sprintf("\nDiversion pattern: %d / %d products (%.1f%%)\n",
    divert_n, total_n, 100*divert_n/total_n))

# ── FIGURE 1: Combined scatter ────────────────────────────────
fig_df <- d %>%
  filter(!is.na(china_decline_t1), !is.na(third_mean_t2)) %>%
  mutate(china_w = w(china_decline_t1),
         third_w = w(third_mean_t2))

# Regression stats for annotation
m_ann  <- lm(third_w ~ china_w, data=fig_df)
slope  <- round(coef(m_ann)[2], 3)
tstat  <- round(summary(m_ann)$coef[2,3], 2)
pval   <- summary(m_ann)$coef[2,4]
plab   <- ifelse(pval < 0.001, "p < 0.001", paste0("p = ", round(pval,3)))
ann_label <- paste0("slope = ", slope, "\nt = ", tstat, ", ", plab)

fig1 <- ggplot(fig_df, aes(china_w, third_w)) +
  annotate("rect", xmin=-Inf, xmax=0, ymin=0, ymax=Inf,
           fill=RED, alpha=0.05) +
  geom_hline(yintercept=0, color="grey60", linewidth=0.4) +
  geom_vline(xintercept=0, color="grey60", linewidth=0.4) +
  geom_point(alpha=0.18, size=0.8, color=STEEL) +
  geom_smooth(method="lm", se=TRUE, color=NAVY,
              fill=NAVY, alpha=0.1, linewidth=1.1) +
  annotate("text", x=-0.55, y=0.75,
           label="Diversion zone\n(China↓, VN/MX/TW↑)",
           color=RED, size=3.5, fontface="bold", hjust=0) +
  annotate("text", x=-0.55, y=-0.55,
           label="Destruction zone\n(China↓, VN/MX/TW flat)",
           color=NAVY, size=3.5, fontface="bold", hjust=0) +
  annotate("text", x=0.35, y=0.75,
           label=ann_label,
           color=CHARCOAL, size=3.5, hjust=0) +
  labs(
    title="Trade diversion: China T1 decline vs Vietnam, Mexico + Taiwan T2 rise",
    subtitle=paste0(
      "Each dot = one HS6 product.\n",
      "x = How much did China lose in 2019? (Trump 1 shock, vs 2015-17 baseline)\n",
      "y = How much did Vietnam, Mexico + Taiwan gain by 2025? (vs 2022-24 baseline, 6 years later)\n",
      "Positive slope = products hit hardest in 2019 saw the largest third-country rises by 2025."),
    x="China import decline, Trump 1 — 2019 vs pre-tariff baseline (2015–17)",
    y="Vietnam, Mexico + Taiwan import rise — 2025 vs recent baseline (2022–24)",
    caption=paste0(
      "Vietnam n=", nrow(d_vn), "  Mexico n=", nrow(d_mx),
      "  Taiwan n=", nrow(d_tw), "  Combined n=", nrow(d_all), ".\n",
      "Minimum baseline threshold $500K. Winsorized 1/99%.\n",
      "Vietnam+Mexico: UN Comtrade. Taiwan: USITC DataWeb (US Census Bureau).\n",
      "6-year gap between x and y captures gradual supply-chain restructuring.")) +
  theme_cap

ggsave(file.path(fig, "fig14_diversion_scatter.png"),
       fig1, width=10, height=7, dpi=200)

# ── FIGURE 2: Side-by-side by country ────────────────────────
d_long <- d %>%
  filter(!is.na(china_decline_t1)) %>%
  select(hs6, china_decline_t1,
         Vietnam=t2_vietnam, Mexico=t2_mexico, Taiwan=t2_taiwan) %>%
  pivot_longer(c(Vietnam, Mexico, Taiwan),
               names_to="country", values_to="third_change") %>%
  filter(!is.na(third_change)) %>%
  mutate(china_w = w(china_decline_t1),
         third_w = w(third_change))

# Per-country stats for strip labels
strip_stats <- d_long %>%
  group_by(country) %>%
  group_modify(~{
    m <- lm(third_w ~ china_w, data=.x)
    tibble(
      slope = round(coef(m)[2], 3),
      tstat = round(summary(m)$coef[2,3], 2),
      pval  = summary(m)$coef[2,4],
      n     = nrow(.x)
    )
  }) %>%
  mutate(label = paste0(country, "\n(n=", n, ", slope=", slope,
                        ", t=", tstat,
                        ifelse(pval < 0.05, "*", ""), ")"))

d_long <- d_long %>%
  left_join(strip_stats %>% select(country, label), by="country") %>%
  mutate(label=factor(label))

fig2 <- ggplot(d_long, aes(china_w, third_w)) +
  geom_hline(yintercept=0, color="grey60", linewidth=0.4) +
  geom_vline(xintercept=0, color="grey60", linewidth=0.4) +
  geom_point(alpha=0.15, size=0.7, color=STEEL) +
  geom_smooth(method="lm", se=TRUE, color=RED,
              fill=RED, alpha=0.1, linewidth=1.0) +
  facet_wrap(~label) +
  labs(
    title="Trade diversion by country: China T1 decline vs third-country T2 rise",
    subtitle="Positive slope = products hit hardest in 2019 saw larger third-country rises by 2025.\n* = significant at p < 0.05.",
    x="China import decline, Trump 1 (2019 vs 2015–17 baseline)",
    y="Third-country import rise (2025 vs 2022–24 baseline)",
    caption="Winsorized 1/99%. Minimum baseline $500K.\nVietnam+Mexico: UN Comtrade. Taiwan: USITC DataWeb (US Census Bureau).\n6-year gap reflects gradual supply-chain restructuring.") +
  theme_cap +
  theme(strip.text=element_text(size=11, face="bold", color=NAVY))

ggsave(file.path(fig, "fig15_diversion_by_country.png"),
       fig2, width=10, height=5.5, dpi=200)

cat("\nsaved fig14_diversion_scatter.png\n")
cat("saved fig15_diversion_by_country.png\n")

cat("\n=== SUMMARY ===\n")
cat(sprintf("Vietnam: slope=%.4f, t=%.2f, p=%.4f\n",
    coef(m_vn)[2], summary(m_vn)$coef[2,3], summary(m_vn)$coef[2,4]))
cat(sprintf("Mexico:  slope=%.4f, t=%.2f, p=%.4f\n",
    coef(m_mx)[2], summary(m_mx)$coef[2,3], summary(m_mx)$coef[2,4]))
cat(sprintf("Taiwan:  slope=%.4f, t=%.2f, p=%.4f  (USITC source)\n",
    coef(m_tw)[2], summary(m_tw)$coef[2,3], summary(m_tw)$coef[2,4]))
cat(sprintf("Combined: slope=%.4f, t=%.2f, p=%.4f\n",
    coef(m_all)[2], summary(m_all)$coef[2,3], summary(m_all)$coef[2,4]))
cat("\nInterpretation guide:\n")
cat("Positive significant slope → diversion pattern confirmed\n")
cat("Neither significant → demand destruction more likely\n")
cat("Vietnam significant, Mexico not → Vietnam primary diversion channel\n")

# ── TEST 3: DOLLAR QUANTIFICATION — how many cents per dollar? ───
cat("\n=== TEST 3: DOLLAR QUANTIFICATION ===\n")
cat("How much of China's dollar-value decline was offset by VN+MX+TW?\n\n")

# Uses the combined regression slope (Vietnam + Mexico + Taiwan mean)
# slope = d(third_change) / d(china_change)
# slope = 0.145 means: for every 1pp China fell, VN+MX+TW rose 0.145pp
# = 14.5 cents on the dollar (in percentage point terms)
cents_per_dollar <- round(coef(m_all)[2] * 100, 1)
cat(sprintf("Combined regression slope: %.4f\n", coef(m_all)[2]))
cat(sprintf("Interpretation: for every $1.00 China lost,\n"))
cat(sprintf("  Vietnam+Mexico gained ~$%.2f (%.1f cents on the dollar)\n",
    coef(m_all)[2], cents_per_dollar))
cat(sprintf("  Unaccounted: ~$%.2f (%.1f cents) — destruction, reshoring,\n",
    1 - coef(m_all)[2], 100 - cents_per_dollar))
cat(sprintf("               other diversion (Korea, India, etc.)\n\n"))

# Cross-check with quadrant counts
cat("Cross-check via quadrant counts:\n")
cat(sprintf("  Diversion (China↓, 3rd↑):      %d products (%.1f%%)\n",
    divert_n, 100*divert_n/total_n))
dest_n <- sum(total_test$quadrant == "Destruction (China↓, 3rd flat)", na.rm=TRUE)
cat(sprintf("  Destruction (China↓, 3rd flat): %d products (%.1f%%)\n",
    dest_n, 100*dest_n/total_n))
cat(sprintf("  Note: product counts ≠ dollar amounts (large products skew totals)\n\n"))

# ── TEST 4: PLACEBO CHECK — untariffed products ───────────────
cat("=== TEST 4: PLACEBO CHECK — UNTARIFFED PRODUCTS ===\n")
cat("Do products with ZERO tariff show the same VN/MX/TW rise?\n")
cat("If yes → COVID/nearshoring explains VN/MX/TW rise, not tariffs.\n")
cat("If no  → tariff-exposed products drive the diversion signal.\n\n")

# Load T1 tariff rates to classify products
tar <- read_csv(file.path(proc_dir, "us_tariff_hs6.csv"),
                show_col_types=FALSE) %>%
  mutate(hs6 = gsub(" ","0", sprintf("%06s", as.character(hs06)))) %>%
  select(hs6, us_tariff_2019)

placebo_df <- d %>%
  left_join(tar, by="hs6") %>%
  filter(!is.na(t2_vietnam) | !is.na(t2_mexico)) %>%
  mutate(
    tariffed    = !is.na(us_tariff_2019) & us_tariff_2019 > 0,
    tariff_grp  = ifelse(tariffed, "Tariffed (>0%)", "Untariffed (0%)"),
    third_mean  = rowMeans(cbind(t2_vietnam, t2_mexico), na.rm=TRUE)
  ) %>%
  filter(!is.na(third_mean), !is.na(tariff_grp))

cat("Products by tariff status:\n")
print(placebo_df %>% count(tariff_grp))

# Compare mean third-country rise
means_by_group <- placebo_df %>%
  group_by(tariff_grp) %>%
  summarise(
    n          = n(),
    mean_third = round(mean(third_mean, na.rm=TRUE)*100, 2),
    .groups    = "drop"
  )
cat("\nMean Vietnam+Mexico rise by tariff status:\n")
print(means_by_group)

# t-test: are tariffed products showing more VN/MX rise?
tariffed_vals   <- placebo_df$third_mean[placebo_df$tariffed]
untariffed_vals <- placebo_df$third_mean[!placebo_df$tariffed]
tt <- t.test(tariffed_vals, untariffed_vals)
cat(sprintf("\nt.test: tariffed vs untariffed third-country rise\n"))
cat(sprintf("  Tariffed mean:   %.2f%%\n", mean(tariffed_vals, na.rm=TRUE)*100))
cat(sprintf("  Untariffed mean: %.2f%%\n", mean(untariffed_vals, na.rm=TRUE)*100))
cat(sprintf("  Difference:      %.2f pp\n", (mean(tariffed_vals,na.rm=TRUE) -
                                              mean(untariffed_vals,na.rm=TRUE))*100))
cat(sprintf("  t = %.2f, p = %.4f\n", tt$statistic, tt$p.value))
cat("\nInterpretation:\n")
cat("  Significant difference → tariff exposure drives VN/MX rise\n")
cat("    (diversion story, not just COVID/nearshoring)\n")
cat("  No significant difference → VN/MX rise is general trend,\n")
cat("    not specifically tariff-driven\n")
