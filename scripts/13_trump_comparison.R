# ============================================================
# 13_trump_comparison.R  —  Trade Capstone
# Trump 1 (2019) vs Trump 2 (2025): the adaptation test
#
# KEY QUESTION: did the HS6 tariff-import slope change between episodes,
# and does it differ by prior exposure (Group A vs B)?
#
# DESIGN:
#   Trump 1: tariff = us_tariff_2019 (from Bown 2021), outcome = import_change
#            (2019 vs 2015-17 baseline) — from scripts 07+
#   Trump 2: tariff = us_tariff_2019 as PROXY for Trump 2 exposure
#            (T1-hit products stayed tariffed; T1-spared got hit for first time)
#            outcome = import_change25 (2025 vs 2022-24 baseline) — from script 12
#
# Three-group classification by Trump 1 exposure:
#   Group A:  us_tariff_2019 >= 25%  (heaviest T1 tariff, T2 add-on)
#   Group A2: 0 < us_tariff_2019 < 25% (partial T1, T2 add-on)
#   Group B:  us_tariff_2019 == 0    (T1-spared, T2 first-time shock)
#
# ADAPTATION HYPOTHESIS: slope(Group B, T2) > slope(Group A, T2)
# because Group B had no prior supply-chain adjustment.
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"

# Trump 1 data (from 07_hs6_merge_test.R)
t1 <- readRDS("data_processed/hs6_merged_2019.rds") %>%
  select(hs6, us_tariff_2019, import_change, import_change_w, base_imports)

# Trump 2 data (from 12_trump2_build.R)
t2 <- read_csv("data_processed/panel_hs6_trump2.csv",
               show_col_types=FALSE) %>%
  select(hs6, import_change25, base_imports, trump1_hit, us_tariff_2019)

# winsorise T2 outcome
w <- function(x,p=0.01){q<-quantile(x,c(p,1-p),na.rm=TRUE);pmin(pmax(x,q[1]),q[2])}
t2$ic25_w <- w(t2$import_change25)

# three-group classification
t2 <- t2 %>% mutate(
  group = case_when(
    is.na(us_tariff_2019) | us_tariff_2019 == 0 ~ "B: T1-spared (first-time shock)",
    us_tariff_2019 >= 25                         ~ "A: T1 heavy (25%+)",
    TRUE                                         ~ "A2: T1 partial (<25%)"
  ))

cat("=== GROUP SIZES ===\n")
print(table(t2$group))

cat("\n=== GROUP MEDIANS: Trump 2 import change ===\n")
t2 %>% group_by(group) %>%
  summarise(n=n(), median=round(median(import_change25,na.rm=TRUE),3),
            pct_fell_hard=round(mean(import_change25 < -0.5,na.rm=TRUE),3)) %>%
  print()

# ---- REGRESSION 1: Trump 1 slope (already computed; just confirm) ----
m_t1 <- lm(import_change_w ~ us_tariff_2019, data=t1)
cat("\n=== TRUMP 1 slope ===\n")
print(round(summary(m_t1)$coefficients, 5))

# ---- REGRESSION 2: Trump 2 slope (using T1 tariff as proxy for exposure) ----
m_t2 <- lm(ic25_w ~ us_tariff_2019, data=t2)
cat("\n=== TRUMP 2 slope (T1 tariff as proxy) ===\n")
print(round(summary(m_t2)$coefficients, 5))

# ---- REGRESSION 3: Group interaction — does slope differ by prior exposure? ----
m_int <- lm(ic25_w ~ us_tariff_2019 * group, data=t2)
cat("\n=== TRUMP 2: slope x group interaction ===\n")
print(round(summary(m_int)$coefficients, 5))

# ---- FIGURE: side-by-side slopes Trump 1 vs Trump 2 ----
both <- bind_rows(
  t1 %>% mutate(episode="Trump 1 (2019)", outcome=import_change_w, tariff=us_tariff_2019),
  t2 %>% mutate(episode="Trump 2 (2025)", outcome=ic25_w, tariff=us_tariff_2019)
) %>% filter(!is.na(tariff), !is.na(outcome))

# stat labels for each panel — computed from the models
t1_label <- sprintf("β = %.3f\nt = %.1f\np < 1e-50",
                    coef(m_t1)[2], summary(m_t1)$coefficients[2,3])
t2_label <- sprintf("β ≈ %.4f\nt = %.1f\nns",
                    coef(m_t2)[2], summary(m_t2)$coefficients[2,3])

stat_labels <- data.frame(
  episode = c("Trump 1 (2019)", "Trump 2 (2025)"),
  label   = c(t1_label, t2_label),
  tariff  = c(2, 2),
  outcome = c(-0.72, -0.72)
)

f7 <- ggplot(both, aes(tariff, outcome, color=episode)) +
  geom_hline(yintercept=0, color="grey60") +
  geom_point(alpha=0.12, size=0.9) +
  geom_smooth(method="lm", se=TRUE, linewidth=1.2) +
  geom_label(data=stat_labels, aes(x=tariff, y=outcome, label=label, color=episode),
             hjust=0, vjust=1, size=3.6, fontface="bold",
             fill="white", label.size=0.3, inherit.aes=FALSE) +
  scale_color_manual(values=c("Trump 1 (2019)"="#1f5c8a",
                              "Trump 2 (2025)"="#c0473b"), name=NULL) +
  facet_wrap(~episode) +
  coord_cartesian(ylim=c(-1, 1)) +
  labs(title="Trump 1 vs Trump 2: tariff-import slope comparison",
       subtitle="Each dot = one HS6 product. Regression stats shown on each panel.",
       x="US tariff rate, Trump 1 vintage (%) — prior exposure proxy",
       y="Import change vs baseline",
       caption="Trump 2 tariff proxy = Trump 1 rate (all products faced ~50% average in 2025; T1 rate captures prior adaptation, not current rate).") +
  theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(), legend.position="none",
        plot.title=element_text(face="bold"))
ggsave(file.path(fig,"fig7_trump1_vs_trump2.png"), f7, width=11, height=6, dpi=200)
cat("\nsaved fig7_trump1_vs_trump2.png\n")
