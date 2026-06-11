# ============================================================
# 05_plots.R  —  Trade Capstone
# Plot A: trade-flow trajectories over time
# Plot B: retaliation_ratio vs trade_change scatter
# Plot C: the memorable figure — empirical phase map echoing the
#         MARL paper's structural grid
# ============================================================

library(dplyr)
library(readr)
library(ggplot2)

proc_dir <- "data_processed"
fig_dir  <- "figures"

panel <- read_csv(file.path(proc_dir, "panel_with_tariffs.csv"),
                  show_col_types = FALSE)

conflict <- panel %>%
  filter(
    (pair == "china_aus" & year %in% c(2020, 2021)) |
    (pair != "china_aus" & year %in% c(2018, 2019))
  ) %>%
  filter(!is.na(trade_change), !is.na(retaliation_ratio))

# A shared clean theme
theme_cap <- theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"))

# ---- Plot A: trajectories (total trade by sector, faceted by pair) ----
# Show the most-affected sectors to keep it readable.
top_sectors <- panel %>%
  group_by(pair, sector) %>%
  summarise(mx = max(total_trade, na.rm = TRUE), .groups = "drop") %>%
  group_by(pair) %>% slice_max(mx, n = 6) %>% ungroup() %>%
  select(pair, sector)

pA <- panel %>%
  inner_join(top_sectors, by = c("pair", "sector")) %>%
  ggplot(aes(year, total_trade / 1e9, group = sector, color = sector)) +
  geom_line(linewidth = 0.7) + geom_point(size = 1) +
  facet_wrap(~ pair, scales = "free_y") +
  labs(title = "Plot A — Trade-flow trajectories by sector",
       x = NULL, y = "Total trade (USD billions)", color = "HS2") +
  theme_cap
ggsave(file.path(fig_dir, "plotA_trajectories.png"), pA,
       width = 10, height = 6, dpi = 200)

# ---- Plot B: retaliation_ratio vs trade_change ----
pB <- ggplot(conflict, aes(retaliation_ratio, trade_change, color = pair)) +
  geom_hline(yintercept = 0, color = "grey60") +
  geom_point(alpha = 0.7, size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 0.6) +
  scale_x_log10() +
  labs(title = "Plot B — Retaliation ratio vs trade-flow change",
       subtitle = "Each point = (pair, sector). x on log scale.",
       x = "Retaliation ratio (log)", y = "Trade change vs 2015-17 baseline") +
  theme_cap
ggsave(file.path(fig_dir, "plotB_scatter.png"), pB,
       width = 9, height = 6, dpi = 200)

# ---- Plot C: the memorable phase map (echoes the MARL 8x8 grid) ----
# x = retaliation ratio (the MARL predictor's empirical analog)
# y = exposure (initiator tariff pressure, i.e. how hard the sector was hit)
# fill/color = observed disruption severity (trade_change)
pC <- ggplot(conflict, aes(x = retaliation_ratio, y = init_rate,
                           color = trade_change)) +
  geom_point(size = 4, alpha = 0.85) +
  scale_x_log10() +
  scale_color_gradient2(low = "#b2182b", mid = "#f7f7f7", high = "#2166ac",
                        midpoint = 0, name = "Trade\nchange") +
  labs(title = "Plot C — Empirical regime map",
       subtitle = "Structural position (retaliation ratio x tariff pressure) vs observed disruption\nDeliberate empirical echo of the MARL structural grid",
       x = "Retaliation ratio (log)  \u2192 follower capacity",
       y = "Initiator tariff pressure (%)") +
  facet_wrap(~ pair) +
  theme_cap
ggsave(file.path(fig_dir, "plotC_regime_map.png"), pC,
       width = 10, height = 7, dpi = 200)

message("Saved Plot A, B, C to ", normalizePath(fig_dir))
message("Plot C is the deliverable to polish for the presentation.")
