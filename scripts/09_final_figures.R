# ============================================================
# 09_final_figures.R  —  Trade Capstone (consolidation, v2)
# Improved palette, fuller legends/annotations, + phase diagram.
#
# Palette: darker readable blue (#1f5c8a), muted brick red (#c0473b),
# neutral grids. Colorblind-safe diverging scale for the phase map.
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"

imp <- readRDS("data_processed/hs6_merged_2019.rds")        # 07: import side + us_tariff_2019
ret <- readRDS("data_processed/hs6_retaliation_2019.rds")    # 08: export side + chn_reta_2019

BLUE <- "#1f5c8a"; RED <- "#c0473b"; INK <- "#222222"
theme_cap <- theme_minimal(base_size = 13) +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey88"),
        plot.title = element_text(face = "bold", size = 15),
        plot.subtitle = element_text(color = "grey35", size = 11, lineheight = 1.05),
        plot.caption = element_text(color = "grey45", size = 9, hjust = 0),
        legend.position = "top")

# ---- FIG 2: clean HS6 import effect ----------------------------------------
f2 <- ggplot(imp, aes(us_tariff_2019, import_change_w)) +
  geom_hline(yintercept = 0, color = "grey55", linewidth = 0.4) +
  geom_point(alpha = 0.22, size = 1.1, color = BLUE) +
  geom_smooth(method = "lm", color = RED, fill = "#e8b4ae", linewidth = 1.1) +
  annotate("text", x = 2, y = 1.35, hjust = 0, color = INK, size = 4,
           label = "Untariffed products\ngrew ~18%") +
  annotate("text", x = 43, y = -0.75, hjust = 1, color = INK, size = 4,
           label = "Products >25% tariff\nfell ~46%") +
  coord_cartesian(ylim = c(-1, 1.5)) +
  labs(title = "US tariffs predict 2019 import declines at the product (HS6) level",
       subtitle = "Each dot = one HS6 product (n = 3,201). Red line = OLS fit; band = 95% CI.\nSlope = -0.019 per tariff-point  (t = -16.4, p < 1e-50).",
       x = "US Section 301 tariff in effect, 2019 (%)",
       y = "Change in US imports from China vs 2015-17 baseline",
       caption = "Source: UN Comtrade (trade) + Bown (2021) Section 301 tariffs at HS6. Outcome winsorized 1/99%.") +
  theme_cap
ggsave(file.path(fig,"fig2_hs6_import_effect.png"), f2, width=9.5, height=6.3, dpi=200)

# ---- FIG 1: resolution contrast --------------------------------------------
hs2 <- imp %>% mutate(hs2 = substr(hs6,1,2)) %>%
  group_by(hs2) %>%
  summarise(tariff = weighted.mean(us_tariff_2019, base_imports, na.rm=TRUE),
            imp_chg = weighted.mean(import_change, base_imports, na.rm=TRUE),
            .groups="drop")
f1 <- ggplot() +
  geom_hline(yintercept=0, color="grey55", linewidth=0.4) +
  geom_point(data=imp, aes(us_tariff_2019, import_change_w, color="HS6 products (n=3,201)"),
             alpha=0.16, size=1) +
  geom_point(data=hs2, aes(tariff, imp_chg, color="HS2 chapters (n=97)"),
             size=3.2, alpha=0.9) +
  geom_smooth(data=imp, aes(us_tariff_2019, import_change_w, color="HS6 products (n=3,201)"),
              method="lm", se=FALSE, linewidth=1.2) +
  geom_smooth(data=hs2, aes(tariff, imp_chg, color="HS2 chapters (n=97)"),
              method="lm", se=FALSE, linewidth=1.2) +
  coord_cartesian(ylim=c(-1,1.5)) +
  scale_color_manual(values=c("HS6 products (n=3,201)"=BLUE,
                              "HS2 chapters (n=97)"=RED), name=NULL) +
  guides(color = guide_legend(override.aes = list(alpha=1, size=3))) +
  labs(title="Why the signal was invisible at the chapter (HS2) level",
       subtitle="Same data, two resolutions. HS2 chapters (red) average tariffed + untariffed products\ntogether, collapsing into a narrow band with no power. The HS6 relationship (blue) is strong.",
       x="US tariff 2019 (%)", y="Import change vs baseline",
       caption="Red dots are HS6 products aggregated to 97 chapters (trade-weighted). The averaging destroys detectability, not the effect.") +
  theme_cap
ggsave(file.path(fig,"fig1_resolution_contrast.png"), f1, width=9.5, height=6.3, dpi=200)

# ---- FIG 3: asymmetry bars (legend order + values on bars) -----------------
imp_b <- imp %>% mutate(side="US tariff -> imports (clean, t=-16)",
                        bucket=cut(us_tariff_2019,c(-1,0,10,20,100),
                                   labels=c("0","1-10","11-20","21+"))) %>%
  group_by(side,bucket) %>% summarise(chg=median(import_change,na.rm=TRUE),.groups="drop")
ret_b <- ret %>% mutate(side="China retaliation -> exports (muted, t=-4)",
                        bucket=cut(chn_reta_2019,c(-1,0,10,20,100),
                                   labels=c("0","1-10","11-20","21+"))) %>%
  group_by(side,bucket) %>% summarise(chg=median(export_change,na.rm=TRUE),.groups="drop")
f3 <- bind_rows(imp_b, ret_b) %>%
  mutate(side=factor(side, levels=c("US tariff -> imports (clean, t=-16)",
                                    "China retaliation -> exports (muted, t=-4)"))) %>%
  ggplot(aes(bucket, chg, fill=side)) +
  geom_col(position=position_dodge(0.8), width=0.72) +
  geom_text(aes(label=sprintf("%+.0f%%", chg*100)),
            position=position_dodge(0.8), vjust=ifelse(bind_rows(imp_b,ret_b)$chg>=0,-0.4,1.2),
            size=3.2, color=INK) +
  geom_hline(yintercept=0, color="grey40") +
  scale_fill_manual(values=c("US tariff -> imports (clean, t=-16)"=BLUE,
                             "China retaliation -> exports (muted, t=-4)"=RED), name=NULL) +
  labs(title="Asymmetric disruption: import effect is clean, retaliation is muted",
       subtitle="Median trade change by tariff bucket. US tariffs bite monotonically (staircase);\nChina's retaliation is weaker and non-monotonic, confounded by commodity volatility.",
       x="Tariff rate bucket (%)", y="Median trade change vs baseline",
       caption="Buckets differ in product composition across sides; compare pattern shape, not exact bar heights.") +
  theme_cap
ggsave(file.path(fig,"fig3_retaliation_asymmetry.png"), f3, width=9.5, height=6.3, dpi=200)

# ---- FIG 4: PHASE DIAGRAM (honest empirical echo of the MARL grid) ---------
# AXES MATCH THE MARL CIFEr GRID:
#   x = China retaliation (follower retaliation ceiling, rho)
#   y = US tariff          (leader tariff ceiling, tau)
# COLOR = continuous US import change (NOT binned into deter/transition/escalate;
#   real data is shown as-is, not forced into the model's three regimes).
# Each point is an HS6 product appearing on BOTH tariff lists.
phase <- imp %>%
  inner_join(ret %>% select(hs6, chn_reta_2019), by="hs6")
cat("phase-diagram products (on both tariff lists):", nrow(phase), "\n")

# MARL reference points from the CIFEr grid (rho_max, tau_max), scaled to %:
# LF (0.20,0.35), CENTER (0.27,0.28), FF (0.35,0.25) -> x100 to match tariff %
marl_pts <- data.frame(
  x = c(20, 27, 35), y = c(35, 28, 25),
  lab = c("LF", "CENTER", "FF"))

f4 <- ggplot(phase, aes(chn_reta_2019, us_tariff_2019, z = import_change_w)) +
  stat_summary_2d(bins = 10, fun = mean) +
  scale_fill_gradient2(low=RED, mid="grey90", high=BLUE,
                       midpoint=0, name="Mean US\nimport change",
                       breaks=c(-0.4,0,0.4), labels=c("-40%","no change","+40%")) +
  geom_point(data=marl_pts, aes(x,y), inherit.aes=FALSE,
             shape=23, size=4, fill="white", color=INK, stroke=1.2) +
  geom_text(data=marl_pts, aes(x,y,label=lab), inherit.aes=FALSE,
            vjust=-1.2, size=3.8, color=INK, fontface="bold") +
  labs(title="Empirical phase diagram (honest echo of the MARL structural grid)",
       subtitle="Axes match the CIFEr grid: x = follower retaliation, y = leader tariff.\nEach cell = mean REAL import change of products in that region (not a regime label).\nWhite diamonds = MARL grid's LF / CENTER / FF reference points.",
       x="China retaliation on US, 2019 (%)   (follower retaliation ceiling)",
       y="US tariff on China, 2019 (%)   (leader tariff ceiling)",
       caption="Cells colored by mean import-side outcome. Red = trade fell, blue = trade grew. Empty cells = no products in that tariff combination.") +
  theme_cap + theme(legend.position="right")
ggsave(file.path(fig,"fig4_phase_diagram.png"), f4, width=9.8, height=6.8, dpi=200)

cat("Saved fig1-fig4 to figures/\n")
