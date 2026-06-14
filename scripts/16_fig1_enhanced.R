# ============================================================
# 16_fig1_enhanced.R  —  Trade Capstone
# Enhanced Fig 1: HS2 vs HS6 resolution contrast, incorporating
# reviewer feedback:
#   - regression stats on figure (improvement #1)
#   - HS84 machinery annotation showing within-chapter mix (#2)
#   - intentional tariff-bucket shading (#3)
#   - updated caption (#4)
#   - waterfall panel B showing aggregation loss (#bonus)
# ============================================================

library(dplyr); library(readr); library(ggplot2); library(patchwork)
fig <- "figures"

imp <- readRDS("data_processed/hs6_merged_2019.rds")

BLUE <- "#1f5c8a"; RED <- "#c0473b"; INK <- "#222222"
theme_cap <- theme_minimal(base_size = 13) +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey88"),
        plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(color = "grey35", size = 10.5, lineheight = 1.05),
        plot.caption = element_text(color = "grey45", size = 9, hjust = 0),
        legend.position = "top")

# ---- build HS2 aggregates ----
hs2 <- imp %>%
  mutate(hs2 = substr(hs6, 1, 2)) %>%
  group_by(hs2) %>%
  summarise(tariff  = weighted.mean(us_tariff_2019, base_imports, na.rm = TRUE),
            imp_chg = weighted.mean(import_change,  base_imports, na.rm = TRUE),
            n_prod  = n(),
            .groups = "drop")

# HS84 (machinery) label coords for annotation
hs84 <- hs2 %>% filter(hs2 == "84")

# tariff bucket shading bands
buckets <- data.frame(
  xmin = c(-1, 7, 14, 24, 39),
  xmax = c( 1,  9, 16, 26, 43),
  label = c("0%", "7.5%", "15%", "25%", "40%+")
)

# ---- PANEL A: the overlay plot ----
pA <- ggplot() +
  # tariff bucket shading (improvement #3)
  geom_rect(data=buckets, aes(xmin=xmin, xmax=xmax, ymin=-Inf, ymax=Inf),
            fill="grey92", alpha=0.6, inherit.aes=FALSE) +
  geom_text(data=buckets, aes(x=(xmin+xmax)/2, y=1.45, label=label),
            size=2.8, color="grey55", inherit.aes=FALSE) +
  geom_hline(yintercept=0, color="grey55", linewidth=0.4) +
  # HS6 cloud
  geom_point(data=imp, aes(us_tariff_2019, import_change_w,
             color="HS6 products (n=3,201)"), alpha=0.16, size=0.9) +
  # HS2 dots
  geom_point(data=hs2, aes(tariff, imp_chg,
             color="HS2 chapters (n=97)"), size=3.2, alpha=0.9) +
  # regression lines
  geom_smooth(data=imp, aes(us_tariff_2019, import_change_w,
              color="HS6 products (n=3,201)"),
              method="lm", se=FALSE, linewidth=1.2) +
  geom_smooth(data=hs2, aes(tariff, imp_chg,
              color="HS2 chapters (n=97)"),
              method="lm", se=FALSE, linewidth=1.2) +
  # improvement #1: regression stats in upper right
  annotate("label", x=41, y=1.38, hjust=1, vjust=1,
           label="HS6: β = -0.019, t = -16.4, p < 1e-50",
           color=BLUE, fill="white", size=3.4, fontface="bold") +
  annotate("label", x=41, y=1.18, hjust=1, vjust=1,
           label="HS2: β ≈ 0, t = -0.8, ns",
           color=RED, fill="white", size=3.4, fontface="bold") +
  # improvement #2: HS84 annotation — moved to left white space
  annotate("segment", x=hs84$tariff-1, xend=5,
           y=hs84$imp_chg, yend=-0.48,
           color=INK, linewidth=0.5,
           arrow=arrow(length=unit(0.08,"inches"), ends="first")) +
  annotate("label", x=1, y=-0.55, hjust=0, vjust=1,
           label="HS84: Machinery\nContains: 0%, 7.5%, 15%,\n25% tariff products\naveraged together",
           color=INK, fill="#fffef5", size=2.8, lineheight=1) +
  coord_cartesian(ylim=c(-1, 1.55)) +
  scale_color_manual(values=c("HS6 products (n=3,201)"=BLUE,
                               "HS2 chapters (n=97)"=RED), name=NULL) +
  guides(color=guide_legend(override.aes=list(alpha=1, size=3))) +
  labs(title="A.  Why the signal was invisible at the chapter (HS2) level",
       subtitle="Same trade war, same products, different resolution.\nThe relationship exists at the level where policy is applied.",
       x="US tariff 2019 (%)", y="Import change vs 2015-17 baseline",
       caption="Aggregation hides the relationship because tariffs are applied to products, not chapters.") +
  theme_cap +
  theme(plot.margin = margin(t=5, r=5, b=5, l=20))

# ---- PANEL B: pipeline diagram (text + arrows, no illustrative bars) ----
# Using ggplot with annotate so it stays in the same framework.
# Two REAL numbers (|t|=16.4 and |t|≈0.8); logical steps in between.
pB <- ggplot() +
  xlim(0, 10) + ylim(0, 10) +
  # top box: HS6
  annotate("rect", xmin=2, xmax=8, ymin=8.2, ymax=9.8,
           fill="#ddeeff", color=BLUE, linewidth=0.8) +
  annotate("text", x=5, y=9.4, label="3,201 HS6 products",
           size=3.8, fontface="bold", color=BLUE) +
  annotate("text", x=5, y=8.8, label="|t| = 16.4  (p < 1e-50)",
           size=3.4, color=BLUE) +
  # arrow 1
  annotate("segment", x=5, xend=5, y=8.2, yend=7.3,
           arrow=arrow(length=unit(0.12,"inches")), color="grey40", linewidth=0.7) +
  annotate("text", x=5, y=7.65, label="aggregate to chapters",
           size=3, color="grey40", fontface="italic") +
  # middle box: HS2 chapters
  annotate("rect", xmin=2, xmax=8, ymin=5.8, ymax=7.2,
           fill="#f5f5f5", color="grey60", linewidth=0.8) +
  annotate("text", x=5, y=6.7, label="97 HS2 chapters",
           size=3.8, fontface="bold", color="grey40") +
  annotate("text", x=5, y=6.1,
           label="Each chapter mixes tariffed\n& untariffed products",
           size=3, color="grey50", lineheight=0.95) +
  # arrow 2
  annotate("segment", x=5, xend=5, y=5.8, yend=4.9,
           arrow=arrow(length=unit(0.12,"inches")), color="grey40", linewidth=0.7) +
  annotate("text", x=5, y=5.35, label="run same regression",
           size=3, color="grey40", fontface="italic") +
  # bottom box: result
  annotate("rect", xmin=2, xmax=8, ymin=3.3, ymax=4.8,
           fill="#ffdddd", color=RED, linewidth=0.8) +
  annotate("text", x=5, y=4.3, label="Signal disappears",
           size=3.8, fontface="bold", color=RED) +
  annotate("text", x=5, y=3.7, label="|t| ≈ 0.8  (ns)",
           size=3.4, color=RED) +
  # key lesson at bottom
  annotate("text", x=5, y=1.8,
           label="The effect exists. The resolution was wrong.",
           size=3.5, fontface="bold.italic", color=INK) +
  theme_void() +
  labs(title="B.  The aggregation path",
       subtitle="Both endpoints are estimated. Steps show the logical path.") +
  theme(plot.title=element_text(face="bold", size=14),
        plot.subtitle=element_text(color="grey35", size=10.5),
        plot.margin=margin(t=5, r=15, b=5, l=5))

# ---- COMBINE with patchwork ----
combined <- pA + pB + plot_layout(widths=c(2, 1))
ggsave(file.path(fig,"fig1_resolution_contrast_v2.png"),
       combined, width=15.5, height=6.5, dpi=200)
cat("saved fig1_resolution_contrast_v2.png\n")
