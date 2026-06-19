# ============================================================
# 22_bucket_comparison.R  —  Trade Capstone
# APPENDIX: Trump 1 vs Trump 2 tariff bucket comparison
# The single strongest backup slide for the adaptation argument.
#
# Trump 1: higher tariff bucket → bigger decline (monotonic)
# Trump 2: all buckets ≈ same decline (flat)
#
# This is the heart of the compositional selection finding,
# shown in the simplest possible visual.
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"

NAVY  <- "#1E2761"; BLUE  <- "#1F5C8A"; ICE  <- "#CADCFC"
RED   <- "#C0473B"; LTGRAY<- "#EEF1F6"; WHITE <- "#FFFFFF"
DKGRAY<- "#444C5A"; MID   <- "#5A7FA8"

theme_cap <- theme_minimal(base_size=14) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major.x=element_blank(),
        panel.grid.major.y=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=16, color=NAVY),
        plot.subtitle=element_text(color="grey35", size=12, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0),
        plot.background=element_rect(fill=WHITE, color=NA),
        strip.text=element_text(size=13, face="bold", color=NAVY),
        legend.position="none")

# ---- Trump 1 bucket table ----
t1 <- readRDS("data_processed/hs6_merged_2019.rds")
w  <- function(x,p=0.01){q<-quantile(x,c(p,1-p),na.rm=TRUE);pmin(pmax(x,q[1]),q[2])}

t1_buckets <- t1 %>%
  mutate(bucket = cut(us_tariff_2019,
                      breaks=c(-1, 0, 10, 20, 45),
                      labels=c("0%\n(untariffed)",
                               "1–10%\n(partial)",
                               "11–25%\n(heavy)",
                               ">25%\n(max)"))) %>%
  filter(!is.na(bucket)) %>%
  group_by(bucket) %>%
  summarise(median_chg = median(w(import_change), na.rm=TRUE) * 100,
            n = n(), .groups="drop") %>%
  mutate(episode = "Trump 1 (2019)")

# ---- Trump 2 bucket table ----
t2 <- readRDS("data_processed/hs6_trump2_direct.rds")

t2_buckets <- t2 %>%
  mutate(bucket = cut(us_tariff_2025,
                      breaks=c(0, 25, 40, 50, 500),
                      labels=c("10–25%\n(low)",
                               "25–40%\n(medium)",
                               "40–50%\n(high)",
                               ">50%\n(very high)"))) %>%
  filter(!is.na(bucket)) %>%
  group_by(bucket) %>%
  summarise(median_chg = median(w(import_change25), na.rm=TRUE) * 100,
            n = n(), .groups="drop") %>%
  mutate(episode = "Trump 2 (2025)")

cat("=== TRUMP 1 BUCKETS ===\n"); print(t1_buckets)
cat("\n=== TRUMP 2 BUCKETS ===\n"); print(t2_buckets)

# ---- Combined bar chart ----
# Two panels, same y-axis scale so comparison is honest

both <- bind_rows(t1_buckets, t2_buckets) %>%
  mutate(episode = factor(episode,
                          levels=c("Trump 1 (2019)","Trump 2 (2025)")),
         fill_col = ifelse(episode=="Trump 1 (2019)", BLUE, RED))

# Y axis range — shared
ylim_lo <- min(both$median_chg) * 1.15
ylim_hi <- max(both$median_chg, 0) * 1.1 + 3

fA5 <- ggplot(both, aes(bucket, median_chg, fill=fill_col)) +
  geom_col(width=0.65, show.legend=FALSE) +
  geom_hline(yintercept=0, color="grey40", linewidth=0.4) +
  # value labels — inside bar at midpoint, but only if bar tall enough
  geom_text(aes(label=paste0(round(median_chg,0),"%"),
                y=ifelse(abs(median_chg) > 5, median_chg * 0.5, median_chg - sign(median_chg)*2)),
            size=4.2, fontface="bold", color=WHITE) +
  # n= labels — above bars for positive, below bar top for negative
  geom_text(aes(label=paste0("n=",n),
                y=ifelse(median_chg >= 0, median_chg + 1.5, 1.5)),
            vjust=0, size=3.0, color="grey50") +
  scale_fill_identity() +
  scale_y_continuous(limits=c(ylim_lo * 1.25, ylim_hi),
                     labels=function(x) paste0(x,"%")) +
  facet_wrap(~episode, scales="free_x") +
  labs(title="The bucket table: why the model failed",
       subtitle=paste0(
         "Trump 1: higher tariff bucket → bigger import decline. Clear dose-response.\n",
         "Trump 2: all buckets fell ~27–30%, regardless of tariff level. The dose-response vanished."),
       x="US tariff bucket",
       y="Median import change vs baseline",
       caption=paste0(
         "Trump 1 outcome: import change vs 2015-17 mean. Winsorized 1/99%.\n",
         "Trump 2 outcome: import change vs 2022-24 mean. WTO Nov-2025 tariff rates.")) +
  theme_cap +
  geom_hline(data=data.frame(episode=factor("Trump 2 (2025)",
             levels=c("Trump 1 (2019)","Trump 2 (2025)")),
             y=mean(t2_buckets$median_chg)),
             aes(yintercept=y), color=RED, linetype="dashed",
             linewidth=0.8, alpha=0.7)

# Panel-specific annotations — placed BELOW the bars in clear white space
ann_t1 <- data.frame(
  episode = factor("Trump 1 (2019)", levels=c("Trump 1 (2019)","Trump 2 (2025)")),
  x = 2.5, y = ylim_lo * 1.15,
  label = "Monotonic:\nhigher tariff → bigger decline"
)
ann_t2 <- data.frame(
  episode = factor("Trump 2 (2025)", levels=c("Trump 1 (2019)","Trump 2 (2025)")),
  x = 2.5, y = ylim_lo * 1.15,
  label = "Flat:\nevery bucket ≈ same decline"
)
fA5 <- fA5 +
  geom_text(data=ann_t1, aes(x=x, y=y, label=label),
            size=3.8, color=BLUE, fontface="bold.italic",
            lineheight=1.0, hjust=0.5, inherit.aes=FALSE) +
  geom_text(data=ann_t2, aes(x=x, y=y, label=label),
            size=3.8, color=RED, fontface="bold.italic",
            lineheight=1.0, hjust=0.5, inherit.aes=FALSE)

ggsave(file.path(fig,"figA5_bucket_comparison.png"), fA5,
       width=11, height=6.5, dpi=200)
cat("\nsaved figA5_bucket_comparison.png\n")
