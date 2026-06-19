# ============================================================
# 15_four_bar_chart.R  —  Trade Capstone
# THE FOUR-BAR CHART: tariff effect vs retaliation effect,
# Trump 1 (2019) vs Trump 2 (2025).
#
# Four slopes, all from direct OLS:
#   T1 import:     import_change    ~ us_tariff_2019   (from script 07)
#   T1 retaliation: export_change   ~ chn_reta_2019    (from script 08)
#   T2 import:     import_change25  ~ us_tariff_2025   (from script 14)
#   T2 retaliation: export_change25 ~ chn_reta_2025    (new, this script)
#
# Tariff sources:
#   T1: Bown (2021) Section 301 rates at HS6
#   T2: WTO Tariff Actions, Nov-2025 snapshot (US→China and China→US)
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"

w <- function(x,p=0.01){q<-quantile(x,c(p,1-p),na.rm=TRUE);pmin(pmax(x,q[1]),q[2])}

# ---- Trump 1 data (already computed) ----
t1_imp <- readRDS("data_processed/hs6_merged_2019.rds")      # us_tariff_2019, import_change_w
t1_ret <- readRDS("data_processed/hs6_retaliation_2019.rds") # chn_reta_2019, export_change

# ---- Trump 2 data ----
t2_panel <- read_csv("data_processed/panel_hs6_trump2.csv", show_col_types=FALSE) %>%
  mutate(hs6 = gsub(" ","0", sprintf("%06s", as.character(hs6))))

tar25 <- read_csv("data_processed/us_tariff_2025_hs6.csv", show_col_types=FALSE) %>%
  mutate(hs6 = sprintf("%06d", as.integer(hs_code))) %>%
  select(hs6, us_tariff_2025=best_avlbl)

ret25 <- read_csv("data_processed/chn_reta_2025_hs6.csv", show_col_types=FALSE) %>%
  mutate(hs6 = gsub(" ","0", sprintf("%06s", as.character(hs6))))

t2_imp <- t2_panel %>%
  filter(!is.na(import_change25), base_imports > 1e6) %>%
  inner_join(tar25, by="hs6") %>%
  mutate(ic_w = w(import_change25))

t2_ret <- t2_panel %>%
  filter(!is.na(export_change25), base_exports > 1e6) %>%
  inner_join(ret25, by="hs6") %>%
  mutate(ec_w = w(export_change25))

cat("=== SAMPLE SIZES ===\n")
cat("T1 import:", nrow(t1_imp), " T1 retaliation:", nrow(t1_ret), "\n")
cat("T2 import:", nrow(t2_imp), " T2 retaliation:", nrow(t2_ret), "\n\n")

# ---- Run all four regressions ----
m_t1i <- lm(import_change_w  ~ us_tariff_2019, data=t1_imp)
m_t1r <- lm(w(export_change) ~ chn_reta_2019,  data=t1_ret)
m_t2i <- lm(ic_w             ~ us_tariff_2025, data=t2_imp)
m_t2r <- lm(ec_w             ~ chn_reta_2025,  data=t2_ret)

results <- data.frame(
  episode   = c("Trump 1 (2019)","Trump 1 (2019)","Trump 2 (2025)","Trump 2 (2025)"),
  side      = c("US tariff\n→ imports","China retaliation\n→ exports",
                "US tariff\n→ imports","China retaliation\n→ exports"),
  slope     = c(coef(m_t1i)[2], coef(m_t1r)[2], coef(m_t2i)[2], coef(m_t2r)[2]),
  tstat     = c(summary(m_t1i)$coef[2,3], summary(m_t1r)$coef[2,3],
                summary(m_t2i)$coef[2,3], summary(m_t2r)$coef[2,3]),
  n         = c(nrow(t1_imp), nrow(t1_ret), nrow(t2_imp), nrow(t2_ret))
)
results$sig <- ifelse(abs(results$tstat) > 3.3, "***",
               ifelse(abs(results$tstat) > 2.6, "**",
               ifelse(abs(results$tstat) > 1.96, "*", "ns")))

cat("=== ALL FOUR SLOPES ===\n")
print(results %>% mutate(slope=round(slope,5), tstat=round(tstat,2)))

# ---- THE FOUR-BAR CHART ----
results$label <- sprintf("%.4f\n(t=%.1f)%s", results$slope, results$tstat, results$sig)
results$side  <- factor(results$side,
                        levels=c("US tariff\n→ imports","China retaliation\n→ exports"))
results$episode <- factor(results$episode,
                          levels=c("Trump 1 (2019)","Trump 2 (2025)"))

f9 <- ggplot(results, aes(side, slope, fill=episode)) +
  geom_col(position=position_dodge(0.75), width=0.65) +
  geom_hline(yintercept=0, color="grey40") +
  geom_text(aes(label=label,
                y=ifelse(slope < 0, slope - 0.001, slope + 0.001),
                vjust=ifelse(slope < 0, 1.1, -0.2)),
            position=position_dodge(0.75), size=3, lineheight=0.85) +
  scale_fill_manual(values=c("Trump 1 (2019)"="#1f5c8a",
                             "Trump 2 (2025)"="#c0473b"), name=NULL) +
  scale_y_continuous(limits=c(-0.025, 0.003),
                     labels=scales::label_number(accuracy=0.001)) +
  labs(title="Tariff elasticity collapsed between Trump 1 and Trump 2",
       subtitle="OLS slope of import/export change on tariff rate, per percentage point.\nBoth US tariff effect and Chinese retaliation effect declined sharply by 2025.",
       x=NULL, y="Slope (trade change per tariff pp)",
       caption="Tariff sources: Bown (2021) for T1; WTO Tariff Actions Nov-2025 snapshot for T2.\n*** p<0.001, ** p<0.01, * p<0.05, ns = not significant.") +
  theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major.x=element_blank(),
        plot.title=element_text(face="bold", size=15),
        plot.subtitle=element_text(color="grey35", size=11),
        plot.caption=element_text(color="grey45", size=9, hjust=0),
        legend.position="top")
ggsave(file.path(fig,"fig9_four_bar_elasticity.png"), f9, width=9, height=6.5, dpi=200)
cat("\nsaved fig9_four_bar_elasticity.png\n")
