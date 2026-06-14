# ============================================================
# 14_trump2_direct.R  —  Trade Capstone
# THE DIRECT TRUMP 2 TARIFF REGRESSION
# Parallel to 07_hs6_merge_test.R but for the 2025 episode.
#
# Tariff source: WTO Tariff Actions database, US→China,
#   snapshot 2025-11-14 (post-Geneva, settled second-half rate).
#   Column best_avlbl = cumulative effective rate (Section 301 + IEEPA).
#
# Outcome: import_change25 = (2025 imports - 2022-24 mean) / 2022-24 mean
#   from script 12.
#
# KEY COMPARISON:
#   Trump 1 (script 07): slope = -0.019 per tariff pp (t = -16.4)
#   Trump 2 (this):      slope = ?
#
# If Trump 2 slope is smaller in magnitude → elasticity declined
# under repeated tariff regimes (supply-chain adaptation).
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"

# load Trump 2 trade panel (script 12)
t2 <- read_csv("data_processed/panel_hs6_trump2.csv", show_col_types=FALSE) %>%
  mutate(hs6 = gsub(" ","0", sprintf("%06s", as.character(hs6))))

# load WTO 2025 tariff snapshot — zero-pad to 6 digits
tar25 <- read_csv("data_processed/us_tariff_2025_hs6.csv", show_col_types=FALSE) %>%
  mutate(hs6 = sprintf("%06d", as.integer(hs_code))) %>%
  select(hs6, us_tariff_2025 = best_avlbl)

# merge
merged <- t2 %>%
  filter(!is.na(import_change25), base_imports > 1e6) %>%
  inner_join(tar25, by="hs6")

cat("=== MERGE ===\n")
cat("T2 panel products:", nrow(t2 %>% filter(!is.na(import_change25), base_imports > 1e6)), "\n")
cat("Matched to 2025 tariffs:", nrow(merged),
    sprintf("(%.1f%%)\n\n", 100*nrow(merged)/(nrow(t2 %>% filter(!is.na(import_change25), base_imports > 1e6)))))

cat("=== 2025 TARIFF DISTRIBUTION ===\n")
print(summary(merged$us_tariff_2025))

# winsorise outcome
w <- function(x,p=0.01){q<-quantile(x,c(p,1-p),na.rm=TRUE);pmin(pmax(x,q[1]),q[2])}
merged$ic25_w <- w(merged$import_change25)

# THE DIRECT REGRESSION
m_t2 <- lm(ic25_w ~ us_tariff_2025, data=merged)
cat("\n=== TRUMP 2 DIRECT REGRESSION ===\n")
cat("import_change25 ~ us_tariff_2025 (WTO Nov-2025 rate)\n\n")
print(summary(m_t2)$coefficients)
cat("\n--- COMPARISON ---\n")
cat("Trump 1 slope: -0.01918  (t = -16.4, p < 1e-50)\n")
cat("Trump 2 slope:", round(coef(m_t2)[2], 5),
    " (t =", round(summary(m_t2)$coefficients[2,3], 2), ")\n")
cat("Elasticity change:", round(coef(m_t2)[2] / -0.01918, 2),
    "x Trump 1 (1.0 = same, <1 = dampened)\n\n")

# bucket table — same structure as Trump 1
merged %>%
  mutate(tb = cut(us_tariff_2025, c(0,25,40,50,100,500),
                  labels=c("(0-25]","(25-40]","(40-50]","(50-100]",">100"))) %>%
  group_by(tb) %>%
  summarise(n=n(),
            median_chg = round(median(import_change25, na.rm=TRUE), 3),
            dollar_wtd = round(weighted.mean(import_change25, base_imports, na.rm=TRUE), 3)) %>%
  print()

# save merged for plotting
saveRDS(merged, "data_processed/hs6_trump2_direct.rds")

# ---- FIGURE: Trump 1 vs Trump 2 direct comparison ----
# Load Trump 1
t1 <- readRDS("data_processed/hs6_merged_2019.rds") %>%
  rename(tariff=us_tariff_2019, outcome=import_change_w) %>%
  mutate(episode="Trump 1 (2019)\nslope = -0.019, t = -16.4")

t2_plot <- merged %>%
  rename(tariff=us_tariff_2025, outcome=ic25_w) %>%
  mutate(episode=paste0("Trump 2 (2025)\nslope = ",
                        round(coef(m_t2)[2],4),
                        ", t = ", round(summary(m_t2)$coefficients[2,3],1)))

both <- bind_rows(
  t1 %>% select(tariff, outcome, episode),
  t2_plot %>% select(tariff, outcome, episode)
)

f8 <- ggplot(both, aes(tariff, outcome)) +
  geom_hline(yintercept=0, color="grey60") +
  geom_point(aes(color=episode), alpha=0.12, size=0.9) +
  geom_smooth(aes(color=episode), method="lm", se=TRUE, linewidth=1.2) +
  scale_color_manual(values=c("#1f5c8a","#c0473b"), name=NULL) +
  facet_wrap(~episode, scales="free_x") +
  coord_cartesian(ylim=c(-1, 1)) +
  labs(title="Import demand elasticity: Trump 1 (2019) vs Trump 2 (2025)",
       subtitle="Direct tariff-import slope comparison using actual tariff rates.\nTrump 1 source: Bown (2021) Section 301 rates. Trump 2 source: WTO Tariff Actions, Nov-2025.",
       x="US tariff rate on Chinese imports (%)",
       y="Import change vs pre-conflict baseline",
       caption="Outcomes winsorized 1/99%. Trump 1 baseline = 2015-17 mean; Trump 2 baseline = 2022-24 mean.") +
  theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(), legend.position="none",
        plot.title=element_text(face="bold"),
        strip.text=element_text(size=11, face="bold"))
ggsave(file.path(fig,"fig8_elasticity_comparison.png"), f8, width=11, height=6, dpi=200)
cat("\nsaved fig8_elasticity_comparison.png\n")
