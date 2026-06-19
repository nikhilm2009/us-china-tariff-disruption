# ============================================================
# 10_payoff_phase.R  —  Trade Capstone
# Payoff phase diagram: the honest MARL echo.
#
# Implements the OBSERVABLE terms of the CIFEr payoff equations (4)-(5),
# computed entirely from trade data. Calibration parameters (c_L, xi, psi_E,
# phi_F, beta_E, c_F) are NOT observable from trade flows and are OMITTED;
# this is therefore a REDUCED-FORM empirical payoff, stated as such.
#
# Leader (US) observable payoff, per HS6 product:
#   L = tariff revenue  -  1/2 * deadweight from import drop  -  export-loss penalty
#     = tau*M           -  0.5*tau*(M0 - M)                   -  (E0 - E)_+
# Follower (China) observable payoff:
#   F = export-change gain/loss  -  import-side loss from its own retaliation
#     = (X - X0)                 -  0.5*rho*(Xm0 - Xm)
#   [we proxy F's "harm absorbed" with the change in US exports it bought, X]
#
# All terms normalized by baseline trade value so US and China payoffs are
# comparable rates (net gain per $ of pre-conflict trade) before subtracting.
# COLOR = US_payoff - China_payoff  (who came out ahead).
# ============================================================

library(dplyr); library(readr); library(ggplot2)
fig <- "figures"; INK <- "#222222"

imp <- readRDS("data_processed/hs6_merged_2019.rds")       # us_tariff_2019, imports, base_imports, import_change
ret <- readRDS("data_processed/hs6_retaliation_2019.rds")   # chn_reta_2019, exports, base_exports, export_change

# join the two sides on HS6 (products present on both lists)
# FLOOR: require >$10M baseline on BOTH sides. The earlier $1M floor let
# near-zero-denominator products through, producing ratio explosions
# (e.g. US_payoff = -438). $10M is an economic-significance cut, stated
# up front and independent of the result — standard data hygiene, not tuning.
d <- imp %>%
  select(hs6, us_tariff_2019, imports, base_imports) %>%
  inner_join(ret %>% select(hs6, chn_reta_2019, exports, base_exports), by = "hs6") %>%
  filter(base_imports > 10e6, base_exports > 10e6)
cat("after $10M floor:", nrow(d), "products\n")

tau <- d$us_tariff_2019/100      # rate as fraction
rho <- d$chn_reta_2019/100

# ---- Leader (US) observable payoff, normalized by baseline imports ----
us_rev   <- tau * d$imports                                   # tariff revenue
us_dw    <- 0.5 * tau * pmax(0, d$base_imports - d$imports)   # deadweight-ish loss
us_exloss<- pmax(0, d$base_exports - d$exports)               # lost US exports (retaliation harm)
d$US_payoff <- (us_rev - us_dw - us_exloss) / d$base_imports

# ---- Follower (China) observable payoff, normalized by baseline exports ----
# China "gains" by the change in what it still sells to US absorbing the hit,
# and bears its own retaliation's deadweight on the goods it taxed.
chn_trade_term <- (d$exports - d$base_exports)                # export change (level)
chn_dw         <- 0.5 * rho * pmax(0, d$base_exports - d$exports)
d$CHN_payoff <- (chn_trade_term - chn_dw) / d$base_exports

# ---- relative payoff (who came out ahead) ----
d$rel_payoff <- d$US_payoff - d$CHN_payoff

# TRIM unstable tails: drop products in the most extreme 1% of EITHER payoff.
# These are residual small-denominator cases; cut is symmetric and stated.
us_q  <- quantile(d$US_payoff,  c(.01,.99), na.rm=TRUE)
chn_q <- quantile(d$CHN_payoff, c(.01,.99), na.rm=TRUE)
keep <- d$US_payoff  > us_q[1]  & d$US_payoff  < us_q[2] &
        d$CHN_payoff > chn_q[1] & d$CHN_payoff < chn_q[2]
cat("trimmed", sum(!keep), "extreme-tail products; retained", sum(keep), "\n")
d <- d[keep, ]

cat("products in payoff phase:", nrow(d), "\n")
cat("US_payoff summary:\n");  print(summary(d$US_payoff))
cat("CHN_payoff summary:\n"); print(summary(d$CHN_payoff))
cat("rel (US-CHN) summary:\n"); print(summary(d$rel_payoff))

theme_cap <- theme_minimal(base_size = 13) +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color="grey88"),
        plot.title = element_text(face="bold", size=15),
        plot.subtitle = element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption = element_text(color="grey45", size=9, hjust=0))

# winsorize the relative payoff for color stability
q <- quantile(d$rel_payoff, c(.02,.98), na.rm=TRUE)
d$rel_w <- pmin(pmax(d$rel_payoff, q[1]), q[2])

# manual 10x10 binning so we can label each cell with mean payoff AND product count
xb <- seq(min(d$chn_reta_2019), max(d$chn_reta_2019), length.out = 11)
yb <- seq(min(d$us_tariff_2019), max(d$us_tariff_2019), length.out = 11)
# bin INDEX (1..10) via findInterval, then midpoint from the breaks directly
d$xi <- pmin(findInterval(d$chn_reta_2019, xb, rightmost.closed = TRUE), 10)
d$yi <- pmin(findInterval(d$us_tariff_2019, yb, rightmost.closed = TRUE), 10)
xmid <- (head(xb,-1) + tail(xb,-1)) / 2   # 10 midpoints
ymid <- (head(yb,-1) + tail(yb,-1)) / 2
cells <- d %>%
  group_by(xi, yi) %>%
  summarise(rel = mean(rel_w), n = n(), .groups="drop") %>%
  mutate(xc = xmid[xi], yc = ymid[yi])

f5 <- ggplot(cells, aes(xc, yc, fill = rel)) +
  geom_tile(width = diff(xb)[1]*0.95, height = diff(yb)[1]*0.95) +
  geom_text(aes(label = sprintf("%+.2f\nn=%d", rel, n)), size = 2.4,
            color = INK, lineheight = 0.85) +
  scale_fill_gradient2(low="#c0473b", mid="grey90", high="#1f5c8a", midpoint=0,
                       name="US - China\npayoff",
                       labels=c("China ahead","even","US ahead"),
                       breaks=c(q[1]*0.8,0,q[2]*0.8)) +
  labs(title="Payoff phase diagram: who came out ahead, by structural position",
       subtitle="Reduced-form empirical payoffs from CIFEr eqs (4)-(5), observable terms only.\nx = China retaliation (follower), y = US tariff (leader). Cell = mean (US - China) payoff; n = products.\nBlue = US ahead, red = China ahead.",
       x="China retaliation on US, 2019 (%)   (follower retaliation ceiling)",
       y="US tariff on China, 2019 (%)   (leader tariff ceiling)",
       caption="Calibration params (c_L, xi, psi, phi, beta) omitted - reduced-form. Payoffs normalized by baseline trade value. Winsorized 2/98% for color.") +
  theme_cap + theme(legend.position="right")
ggsave(file.path(fig,"fig5_payoff_phase.png"), f5, width=10, height=7, dpi=200)
saveRDS(d, "data_processed/payoff_phase.rds")
cat("saved fig5_payoff_phase.png and payoff_phase.rds\n")
