# ============================================================
# 21_appendix_methods.R  —  Trade Capstone
# Generates four appendix methodology figures:
#   figA1_hs_hierarchy.png      — HS2 vs HS6 structure
#   figA2_tariff_distribution.png — tariff rate distributions T1 + T2
#   figA3_merge_flow.png        — data merge / match rate flow
#   figA4_tariff_timeline.png   — tariff escalation timeline
# ============================================================

library(dplyr); library(readr); library(ggplot2); library(tidyr)
fig <- "figures"

NAVY  <- "#1E2761"; BLUE  <- "#1F5C8A"; ICE   <- "#CADCFC"
RED   <- "#C0473B"; MID   <- "#5A7FA8"; MUTED <- "#8899AA"
LTGRAY<- "#EEF1F6"; DKGRAY<- "#444C5A"; WHITE <- "#FFFFFF"
INK   <- "#222222"

theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15, color=NAVY),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0),
        plot.background=element_rect(fill=WHITE, color=NA))

# ============================================================
# A1 — HS CLASSIFICATION HIERARCHY
# Shows HS2 → HS4 → HS6 structure with a concrete example
# ============================================================
cat("Building figA1_hs_hierarchy.png...\n")

# Build as a ggplot with annotated boxes
fA1 <- ggplot() +
  xlim(0, 10) + ylim(0, 10) +

  # Title band
  annotate("rect", xmin=0, xmax=10, ymin=9.3, ymax=10, fill=NAVY) +
  annotate("text", x=5, y=9.65, label="How the Harmonized System (HS) works",
           color=WHITE, size=5.5, fontface="bold") +

  # Level labels (left margin)
  annotate("text", x=0.15, y=8.2, label="HS2\nChapter\n(97 total)",
           color=BLUE, size=3.5, fontface="bold", hjust=0.5, lineheight=0.95) +
  annotate("text", x=0.15, y=6.0, label="HS4\nHeading\n(~1,200)",
           color=MID,  size=3.5, fontface="bold", hjust=0.5, lineheight=0.95) +
  annotate("text", x=0.15, y=3.5, label="HS6\nSubheading\n(~5,000+)",
           color=RED,  size=3.5, fontface="bold", hjust=0.5, lineheight=0.95) +

  # ── EXAMPLE 1: HS84 Machinery ──
  # HS2 box
  annotate("rect", xmin=1.0, xmax=4.5, ymin=7.7, ymax=8.7, fill=BLUE, color=BLUE) +
  annotate("text", x=2.75, y=8.35, label="84", color=WHITE, size=6, fontface="bold") +
  annotate("text", x=2.75, y=7.95, label="Machinery & mechanical appliances",
           color=ICE, size=3.2) +

  # HS4 box
  annotate("rect", xmin=1.0, xmax=4.5, ymin=5.5, ymax=6.5, fill=MID, color=MID) +
  annotate("text", x=2.75, y=6.15, label="8471", color=WHITE, size=5.5, fontface="bold") +
  annotate("text", x=2.75, y=5.72, label="Automatic data processing machines",
           color=ICE, size=3.2) +

  # HS6 boxes
  annotate("rect", xmin=1.0, xmax=2.6, ymin=3.0, ymax=4.0, fill=RED, color=RED) +
  annotate("text", x=1.8, y=3.65, label="847130", color=WHITE, size=4, fontface="bold") +
  annotate("text", x=1.8, y=3.2, label="Laptops\n(25% tariff)",
           color=WHITE, size=3.0, lineheight=0.9) +

  annotate("rect", xmin=2.9, xmax=4.5, ymin=3.0, ymax=4.0, fill=RED, color=RED) +
  annotate("text", x=3.7, y=3.65, label="847141", color=WHITE, size=4, fontface="bold") +
  annotate("text", x=3.7, y=3.2, label="Other PDAs\n(25% tariff)",
           color=WHITE, size=3.0, lineheight=0.9) +

  # Connector lines example 1
  annotate("segment", x=2.75, xend=2.75, y=7.7, yend=6.5, color="grey60", linewidth=0.6) +
  annotate("segment", x=2.75, xend=1.8,  y=5.5, yend=4.0, color="grey60", linewidth=0.6) +
  annotate("segment", x=2.75, xend=3.7,  y=5.5, yend=4.0, color="grey60", linewidth=0.6) +

  # ── EXAMPLE 2: HS01 Agriculture ──
  annotate("rect", xmin=5.5, xmax=9.0, ymin=7.7, ymax=8.7, fill=BLUE, color=BLUE) +
  annotate("text", x=7.25, y=8.35, label="01", color=WHITE, size=6, fontface="bold") +
  annotate("text", x=7.25, y=7.95, label="Live animals",
           color=ICE, size=3.2) +

  annotate("rect", xmin=5.5, xmax=9.0, ymin=5.5, ymax=6.5, fill=MID, color=MID) +
  annotate("text", x=7.25, y=6.15, label="0101", color=WHITE, size=5.5, fontface="bold") +
  annotate("text", x=7.25, y=5.72, label="Live horses, asses, mules",
           color=ICE, size=3.2) +

  annotate("rect", xmin=5.5, xmax=7.15, ymin=3.0, ymax=4.0, fill="#2D8A4E", color="#2D8A4E") +
  annotate("text", x=6.32, y=3.65, label="010121", color=WHITE, size=4, fontface="bold") +
  annotate("text", x=6.32, y=3.2, label="Pure-bred\nhorses (0%)",
           color=WHITE, size=3.0, lineheight=0.9) +

  annotate("rect", xmin=7.4, xmax=9.0, ymin=3.0, ymax=4.0, fill=RED, color=RED) +
  annotate("text", x=8.2, y=3.65, label="010129", color=WHITE, size=4, fontface="bold") +
  annotate("text", x=8.2, y=3.2, label="Other horses\n(25% tariff)",
           color=WHITE, size=3.0, lineheight=0.9) +

  annotate("segment", x=7.25, xend=7.25, y=7.7, yend=6.5, color="grey60", linewidth=0.6) +
  annotate("segment", x=7.25, xend=6.32, y=5.5, yend=4.0, color="grey60", linewidth=0.6) +
  annotate("segment", x=7.25, xend=8.2,  y=5.5, yend=4.0, color="grey60", linewidth=0.6) +

  # Key insight box
  annotate("rect", xmin=0.5, xmax=9.5, ymin=0.3, ymax=2.4, fill=LTGRAY, color=LTGRAY) +
  annotate("text", x=5, y=2.05,
           label="Why HS6 matters: tariffs are applied at HS6, not HS2.",
           color=NAVY, size=4.2, fontface="bold") +
  annotate("text", x=5, y=1.55,
           label="Chapter 84 (Machinery) contains products at 0%, 7.5%, 15%, AND 25% tariff.",
           color=DKGRAY, size=3.8) +
  annotate("text", x=5, y=1.1,
           label="Averaging them into one HS2 data point cancels the effect.",
           color=DKGRAY, size=3.8) +
  annotate("text", x=5, y=0.62,
           label="Our analysis uses 3,201 HS6 subheadings — the resolution where the policy lives.",
           color=RED, size=3.8, fontface="bold.italic") +

  theme_void() +
  theme(plot.background=element_rect(fill=WHITE, color=NA),
        plot.margin=ggplot2::margin(5,5,5,5))

ggsave(file.path(fig,"figA1_hs_hierarchy.png"), fA1, width=12, height=9, dpi=200)
cat("  saved figA1_hs_hierarchy.png\n\n")

# ============================================================
# A2 — TARIFF RATE DISTRIBUTIONS: TRUMP 1 vs TRUMP 2
# ============================================================
cat("Building figA2_tariff_distribution.png...\n")

t1_tar <- read_csv("data_processed/us_tariff_hs6.csv", show_col_types=FALSE) %>%
  mutate(hs6=gsub(" ","0",sprintf("%06s",as.character(hs06))),
         episode="Trump 1 (2019)\nBown Section 301 rates",
         rate=us_tariff_2019) %>%
  select(hs6, episode, rate)

t2_tar <- read_csv("data_processed/us_tariff_2025_hs6.csv", show_col_types=FALSE) %>%
  mutate(hs6=sprintf("%06d",as.integer(hs_code)),
         episode="Trump 2 (2025)\nWTO Nov-2025 snapshot",
         rate=best_avlbl) %>%
  select(hs6, episode, rate) %>%
  filter(rate <= 100)  # exclude extreme outliers (EVs, solar) for distribution view

both_tar <- bind_rows(t1_tar, t2_tar)

# Summary stats for annotation
stats <- both_tar %>%
  group_by(episode) %>%
  summarise(med=round(median(rate,na.rm=TRUE),1),
            mn=round(mean(rate,na.rm=TRUE),1),
            n=n(), .groups="drop")
cat("  Tariff distribution stats:\n"); print(stats)

fA2 <- ggplot(both_tar, aes(rate, fill=episode, color=episode)) +
  geom_histogram(binwidth=2.5, alpha=0.65, position="identity") +
  geom_vline(data=stats, aes(xintercept=med, color=episode),
             linetype="dashed", linewidth=1.0) +
  geom_text(data=stats,
            aes(x=med+1.5, y=Inf,
                label=paste0("Median: ",med,"%"),
                color=episode),
            vjust=1.5, hjust=0, size=3.5, fontface="bold",
            inherit.aes=FALSE) +
  scale_fill_manual(values=c(BLUE, RED), name=NULL) +
  scale_color_manual(values=c(BLUE, RED), name=NULL) +
  facet_wrap(~episode, scales="free_y") +
  labs(title="Tariff rate distributions: Trump 1 (2019) vs Trump 2 (2025)",
       subtitle=paste0("Trump 1: ", stats$n[1], " HS6 products from Bown (2021) Section 301 rates.\n",
                       "Trump 2: ", stats$n[2], " HS6 products from WTO Tariff Actions (Nov-2025 snapshot, capped at 100%)."),
       x="US tariff rate on Chinese imports (%)",
       y="Number of HS6 products",
       caption="Trump 2 products with rates >100% (EVs, solar panels) excluded from chart for readability; included in all regressions.") +
  theme_cap +
  theme(legend.position="none", strip.text=element_text(size=11, face="bold"))

ggsave(file.path(fig,"figA2_tariff_distribution.png"), fA2, width=11, height=6, dpi=200)
cat("  saved figA2_tariff_distribution.png\n\n")

# ============================================================
# A3 — DATA MERGE FLOW: MATCH RATES
# ============================================================
cat("Building figA3_merge_flow.png...\n")

fA3 <- ggplot() + xlim(0,10) + ylim(0,10) +

  # Title
  annotate("rect", xmin=0, xmax=10, ymin=9.3, ymax=10, fill=NAVY) +
  annotate("text", x=5, y=9.65,
           label="How the three datasets were merged — and the match rates",
           color=WHITE, size=5, fontface="bold") +

  # ── SOURCE 1: Comtrade ──
  annotate("rect", xmin=0.3, xmax=3.2, ymin=7.8, ymax=9.1, fill=BLUE, color=BLUE, linewidth=0) +
  annotate("text", x=1.75, y=8.65, label="UN COMTRADE", color=WHITE, size=4.5, fontface="bold") +
  annotate("text", x=1.75, y=8.25, label="US-China 2015–2025\nHS6, annual bilateral flows\n~78K rows total",
           color=ICE, size=3.2, lineheight=1.1) +

  # ── SOURCE 2: Bown ──
  annotate("rect", xmin=3.9, xmax=6.1, ymin=7.8, ymax=9.1, fill=BLUE, color=BLUE, linewidth=0) +
  annotate("text", x=5.0, y=8.65, label="BOWN (2021)", color=WHITE, size=4.5, fontface="bold") +
  annotate("text", x=5.0, y=8.25, label="Section 301 tariff rates\n5,309 HS6 codes\nUS tariff on China",
           color=ICE, size=3.2, lineheight=1.1) +

  # ── SOURCE 3: WTO ──
  annotate("rect", xmin=6.8, xmax=9.7, ymin=7.8, ymax=9.1, fill=BLUE, color=BLUE, linewidth=0) +
  annotate("text", x=8.25, y=8.65, label="WTO (2025)", color=WHITE, size=4.5, fontface="bold") +
  annotate("text", x=8.25, y=8.25, label="Tariff Actions Nov-2025\n5,612 HS6 codes\nUS→China & China→US",
           color=ICE, size=3.2, lineheight=1.1) +

  # Step 1 arrows down
  annotate("segment", x=1.75, xend=1.75, y=7.8, yend=6.9, color="grey50", linewidth=1,
           arrow=arrow(length=unit(0.1,"in"))) +
  annotate("segment", x=5.0,  xend=5.0,  y=7.8, yend=6.9, color="grey50", linewidth=1,
           arrow=arrow(length=unit(0.1,"in"))) +

  # Step 1: filter to HS6 panel
  annotate("rect", xmin=0.3, xmax=3.2, ymin=5.8, ymax=6.8, fill=LTGRAY, color="#DDE3EC", linewidth=0.5) +
  annotate("text", x=1.75, y=6.45, label="Filter: aggr_level == 6", color=NAVY, size=3.5, fontface="bold") +
  annotate("text", x=1.75, y=6.05, label="8,601–8,861 HS6 products/year\n(Trump 1 + Trump 2 pulls)",
           color=DKGRAY, size=3.1, lineheight=1.0) +

  # Step 2 arrow
  annotate("rect", xmin=3.5, xmax=6.5, ymin=5.8, ymax=6.8, fill=LTGRAY, color="#DDE3EC", linewidth=0.5) +
  annotate("text", x=5.0, y=6.45, label="Standardize HS code format", color=NAVY, size=3.5, fontface="bold") +
  annotate("text", x=5.0, y=6.05, label="sprintf(\"%06s\", hs_code)\nEnsures 6-character zero-padded strings",
           color=DKGRAY, size=3.1, lineheight=1.0) +

  # Merge arrows — clean verticals only, no crossing diagonals
  annotate("segment", x=1.75, xend=2.5, y=5.8, yend=5.0, color="grey50", linewidth=1,
           arrow=arrow(length=unit(0.1,"in"))) +
  annotate("segment", x=5.0,  xend=2.5, y=5.8, yend=5.0, color="grey50", linewidth=1,
           arrow=arrow(length=unit(0.1,"in"))) +

  # Trump 1 merge result
  annotate("rect", xmin=0.3, xmax=4.7, ymin=3.8, ymax=4.9, fill=NAVY, color=NAVY, linewidth=0) +
  annotate("text", x=2.5, y=4.55, label="TRUMP 1 ANALYSIS DATASET",
           color=WHITE, size=4, fontface="bold") +
  annotate("text", x=2.5, y=4.15,
           label="3,201 / 3,202 products matched  →  100% match rate",
           color=ICE, size=3.5) +

  # Trump 2: WTO arrow straight down, no crossing
  annotate("segment", x=8.25, xend=8.25, y=7.8, yend=5.0, color="grey50", linewidth=1,
           arrow=arrow(length=unit(0.1,"in"))) +

  annotate("rect", xmin=5.3, xmax=9.7, ymin=3.8, ymax=4.9, fill=RED, color=RED, linewidth=0) +
  annotate("text", x=7.5, y=4.55, label="TRUMP 2 ANALYSIS DATASET",
           color=WHITE, size=4, fontface="bold") +
  annotate("text", x=7.5, y=4.15,
           label="3,164 / 3,165 products matched  →  100% match rate",
           color="#FFCCCC", size=3.5) +

  # Bottom note
  annotate("rect", xmin=0.3, xmax=9.7, ymin=0.3, ymax=3.5, fill=LTGRAY, color=LTGRAY) +
  annotate("text", x=5, y=3.15, label="Retaliation merges (China→US)",
           color=NAVY, size=4, fontface="bold") +
  annotate("text", x=5, y=2.7,
           label="Trump 1: 1,986 / 2,105 products matched  →  94.3%  (HS8→HS6 collapse by simple mean)",
           color=DKGRAY, size=3.3) +
  annotate("text", x=5, y=2.3,
           label="Trump 2: 1,590 products matched from WTO China→US file (Nov-2025 snapshot)",
           color=DKGRAY, size=3.3) +
  annotate("text", x=5, y=1.75,
           label="Why 94.3% for Trump 1 retaliation?",
           color=NAVY, size=3.5, fontface="bold") +
  annotate("text", x=5, y=1.3,
           label="The Bown retaliation file is at HS8 (8-digit). We collapse to HS6 by simple mean.",
           color=DKGRAY, size=3.2) +
  annotate("text", x=5, y=0.85,
           label="Some HS6 headings had no HS8 match in the retaliation schedule (untargeted products).",
           color=DKGRAY, size=3.2) +

  theme_void() +
  theme(plot.background=element_rect(fill=WHITE, color=NA),
        plot.margin=ggplot2::margin(5,5,5,5))

ggsave(file.path(fig,"figA3_merge_flow.png"), fA3, width=12, height=9, dpi=200)
cat("  saved figA3_merge_flow.png\n\n")

# ============================================================
# A4 — TARIFF ESCALATION TIMELINE
# ============================================================
cat("Building figA4_tariff_timeline.png...\n")

events <- data.frame(
  date  = as.Date(c(
    "2018-07-06","2018-08-23","2018-09-24","2019-05-10",
    "2020-02-14",
    "2025-02-04","2025-04-02","2025-05-14","2025-06-01","2026-02-18")),
  label = c(
    "List 1: 25%\n(HS84,85,88,90)\n$34B goods",
    "List 2: 25%\n(HS28,39,86)\n$16B goods",
    "List 3: 10%\n(broad coverage)\n$200B goods",
    "List 3 → 25%\n(escalation)",
    "Phase One\nList 4A → 7.5%\n(de-escalation)",
    "IEEPA +10%\nFeb 2025",
    "Liberation Day\n+34% IEEPA\nall Chinese goods",
    "Geneva talks\npartial rollback\n~50% avg",
    "Current regime\n~35–50%\nSection 301\n+ IEEPA",
    "SCOTUS\nIEEPA struck down\n(post-sample)"),
  # Stagger Trump 1 on 3 levels, Trump 2 on 4 levels to avoid overlap
  y_pos = c(3.8, 2.6, 4.6, 2.6,   # T1 events
            1.8,                     # Phase One low
            3.8, 2.4, 4.4, 3.0, 1.6), # T2 events staggered
  col   = c(BLUE,BLUE,BLUE,BLUE,MID,RED,RED,RED,RED,"#888888"),
  has_rate = c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE)
)

windows <- data.frame(
  xmin = as.Date(c("2018-01-01","2022-01-01")),
  xmax = as.Date(c("2019-12-31","2025-12-31")),
  fill = c(BLUE, RED)
)

fA4 <- ggplot() +
  # Study window shading
  geom_rect(data=windows,
            aes(xmin=xmin, xmax=xmax, ymin=0.3, ymax=5.5, fill=fill),
            alpha=0.07, inherit.aes=FALSE) +
  scale_fill_identity() +
  # Timeline baseline
  geom_hline(yintercept=0.7, color="grey50", linewidth=0.7) +
  # Stems
  geom_segment(data=events[events$has_rate,],
               aes(x=date, xend=date, y=0.7, yend=y_pos-0.35, color=col),
               linewidth=0.6) +
  scale_color_identity() +
  # Event labels — main events
  geom_label(data=events[events$has_rate,],
             aes(x=date, y=y_pos, label=label, fill=col),
             color=WHITE, size=2.6, fontface="bold",
             lineheight=0.9, label.size=0,
             label.padding=unit(0.22,"lines")) +
  # SCOTUS (post-sample, grey)
  geom_label(data=events[!events$has_rate,],
             aes(x=date, y=y_pos, label=label),
             fill="grey65", color=WHITE, size=2.6, fontface="bold",
             lineheight=0.9, label.size=0,
             label.padding=unit(0.22,"lines")) +
  # Study window labels
  annotate("text", x=as.Date("2018-07-01"), y=5.2,
           label="Trump 1 analysis\n(2019 cross-section)",
           color=BLUE, size=3.8, fontface="bold", lineheight=0.9, hjust=0) +
  annotate("text", x=as.Date("2023-06-01"), y=5.2,
           label="Trump 2 analysis\n(2025 cross-section)",
           color=RED, size=3.8, fontface="bold", lineheight=0.9, hjust=0) +
  scale_x_date(date_breaks="1 year", date_labels="%Y",
               limits=as.Date(c("2017-09-01","2026-09-01"))) +
  scale_y_continuous(limits=c(0.2, 5.7)) +
  labs(title="US-China tariff escalation timeline, 2018–2026",
       subtitle="Key tariff actions on US imports from China. Shaded windows = cross-sections used in this analysis.",
       x=NULL, y=NULL,
       caption="Sources: Bown (2021) for Trump 1 episode; WTO Tariff Actions for Trump 2. SCOTUS ruling (Feb 2026) is post-sample.") +
  theme_cap +
  theme(axis.text.y=element_blank(),
        panel.grid.major.y=element_blank(),
        panel.grid.major.x=element_line(color="grey90"),
        plot.title=element_text(size=16))

ggsave(file.path(fig,"figA4_tariff_timeline.png"), fA4, width=16, height=7, dpi=200)
cat("  saved figA4_tariff_timeline.png\n\n")

cat("=== ALL FOUR APPENDIX FIGURES SAVED ===\n")
cat("  figA1_hs_hierarchy.png\n")
cat("  figA2_tariff_distribution.png\n")
cat("  figA3_merge_flow.png\n")
cat("  figA4_tariff_timeline.png\n")
