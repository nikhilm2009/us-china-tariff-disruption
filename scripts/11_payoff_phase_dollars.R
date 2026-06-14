# ============================================================
# 11_payoff_phase_dollars.R  —  Trade Capstone
# DOLLAR payoff phase diagram with TREND-PROJECTED counterfactual baseline.
#
# CHANGE vs flat baseline: M0/X0 are no longer the 2015-17 MEAN. Instead we
# fit each product's 2015-2017 trajectory (OLS on 3 points) and EXTRAPOLATE
# to 2019 -> the "no-conflict" counterfactual level. Loss = counterfactual - actual.
#
# HONEST CAVEATS (a 3-point extrapolation is thin):
#   (1) projected counterfactual floored at 0 (trade can't be negative);
#   (2) if the trend projection diverges from the flat mean by >3x, we fall
#       back to the flat mean for that product (guards against noisy 3-pt fits
#       manufacturing fake giant losses). Count of fallbacks is reported.
#
# Payoffs (CIFEr eqs 4-5, observable terms, USD, no calibration params):
#   US:    tau*M  - 1/2*tau*(M0_cf - M)_+  - (X0_cf - X)_+
#   China: (X - X0_cf)  - 1/2*rho*(X0_cf - X)_+
# Cell color = SUM (US - China) dollar payoff.
# ============================================================

library(dplyr); library(tidyr); library(readr); library(ggplot2)
fig <- "figures"; INK <- "#222222"

panel <- read_csv("data_processed/panel_hs6.csv", show_col_types=FALSE) %>%
  mutate(hs6 = gsub(" ","0", sprintf("%06s", as.character(hs6))))

# --- trend-projected counterfactual to 2019, per product per flow ---
# Direct linear extrapolation from the 2015-17 points (no predict() name issues).
project_2019 <- function(years, vals) {
  keep <- years %in% 2015:2017 & is.finite(vals)
  if (sum(keep) < 2) return(NA_real_)
  yr <- years[keep]; v <- vals[keep]
  b  <- cov(yr, v) / var(yr)          # slope
  a  <- mean(v) - b * mean(yr)        # intercept
  a + b * 2019                        # extrapolate to 2019
}

cf <- panel %>%
  group_by(hs6) %>%
  group_modify(~{
    imp_cf <- project_2019(.x$year, .x$imports)
    exp_cf <- project_2019(.x$year, .x$exports)
    base_imp <- mean(.x$imports[.x$year %in% 2015:2017], na.rm=TRUE)
    base_exp <- mean(.x$exports[.x$year %in% 2015:2017], na.rm=TRUE)
    imp19 <- .x$imports[.x$year==2019]; exp19 <- .x$exports[.x$year==2019]
    tibble(M0_cf=imp_cf, X0_cf=exp_cf, base_imp, base_exp,
           M=ifelse(length(imp19)>0,imp19,NA), X=ifelse(length(exp19)>0,exp19,NA))
  }) %>% ungroup()

# guards: floor at 0; fall back to flat mean if projection > 3x or < 1/3x the mean
fb_imp <- with(cf, !is.na(M0_cf) & (M0_cf > 3*base_imp | M0_cf < base_imp/3 | M0_cf < 0))
fb_exp <- with(cf, !is.na(X0_cf) & (X0_cf > 3*base_exp | X0_cf < base_exp/3 | X0_cf < 0))
cf$M0_cf[fb_imp] <- cf$base_imp[fb_imp]
cf$X0_cf[fb_exp] <- cf$base_exp[fb_exp]
cf$M0_cf <- pmax(cf$M0_cf, 0); cf$X0_cf <- pmax(cf$X0_cf, 0)
cat("trend fallbacks to flat mean: imports", sum(fb_imp), " exports", sum(fb_exp), "\n")

# attach tariffs
ust <- read_csv("data_processed/us_tariff_hs6.csv", show_col_types=FALSE,
                col_types=cols(hs06=col_character())) %>%
  mutate(hs06=gsub(" ","0",sprintf("%06s",hs06)))
crt <- read_csv("data_processed/chn_reta_hs6.csv", show_col_types=FALSE,
                col_types=cols(hs6=col_character())) %>%
  mutate(hs6=gsub(" ","0",sprintf("%06s",hs6)))

d <- cf %>%
  inner_join(ust, by=c("hs6"="hs06")) %>%
  inner_join(crt, by="hs6") %>%
  filter(base_imp > 10e6, base_exp > 10e6, !is.na(M), !is.na(X))

tau <- d$us_tariff_2019/100; rho <- d$chn_reta_2019/100
d$US_payoff_usd <- tau*d$M - 0.5*tau*pmax(0, d$M0_cf - d$M) - pmax(0, d$X0_cf - d$X)
d$CHN_payoff_usd <- (d$X - d$X0_cf) - 0.5*rho*pmax(0, d$X0_cf - d$X)
d$rel_usd <- d$US_payoff_usd - d$CHN_payoff_usd

# drop any product whose payoff is NA (residual missing M/X or fallback NA)
nbefore <- nrow(d)
d <- d[is.finite(d$rel_usd) & is.finite(d$US_payoff_usd) & is.finite(d$CHN_payoff_usd), ]
cat("dropped", nbefore - nrow(d), "products with NA payoff;", nrow(d), "remain\n")

cat("\ndollar payoffs, trend-projected baseline ($M):\n")
cat("  US total:    ", round(sum(d$US_payoff_usd)/1e6,1), "\n")
cat("  China total: ", round(sum(d$CHN_payoff_usd)/1e6,1), "\n")
cat("  US - China:  ", round(sum(d$rel_usd)/1e6,1), "\n")
cat("  products:    ", nrow(d), "\n")
cat("  top 8 by |US-China| ($M):\n")
print(d %>% mutate(a=abs(rel_usd)) %>% arrange(desc(a)) %>%
        transmute(hs6, us_tariff_2019, chn_reta_2019, rel_M=round(rel_usd/1e6,1)) %>% head(8))

xb <- seq(min(d$chn_reta_2019), max(d$chn_reta_2019), length.out=11)
yb <- seq(min(d$us_tariff_2019), max(d$us_tariff_2019), length.out=11)
d$xi <- pmin(findInterval(d$chn_reta_2019, xb, rightmost.closed=TRUE),10)
d$yi <- pmin(findInterval(d$us_tariff_2019, yb, rightmost.closed=TRUE),10)
xmid <- (head(xb,-1)+tail(xb,-1))/2; ymid <- (head(yb,-1)+tail(yb,-1))/2
cells <- d %>% group_by(xi,yi) %>%
  summarise(rel_M=sum(rel_usd)/1e6, n=n(), .groups="drop") %>%
  mutate(xc=xmid[xi], yc=ymid[yi])
cap <- quantile(abs(cells$rel_M), .95); cells$rel_col <- pmin(pmax(cells$rel_M,-cap),cap)

theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(), panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0))

f6 <- ggplot(cells, aes(xc,yc,fill=rel_col)) +
  geom_tile(width=diff(xb)[1]*0.95, height=diff(yb)[1]*0.95) +
  geom_text(aes(label=sprintf("$%.0fM\nn=%d", rel_M, n)), size=2.4, color=INK, lineheight=0.85) +
  scale_fill_gradient2(low="#c0473b", mid="grey90", high="#1f5c8a", midpoint=0,
                       name="US - China\npayoff ($M)") +
  labs(title="Dollar payoff phase diagram (trend-projected counterfactual)",
       subtitle="Raw USD payoffs; M0/X0 = 2015-17 trend extrapolated to 2019 (not flat mean).\nCell = SUM of (US - China) payoff in $M; n = products. Blue = US ahead, red = China ahead.",
       x="China retaliation on US, 2019 (%)   (follower retaliation ceiling)",
       y="US tariff on China, 2019 (%)   (leader tariff ceiling)",
       caption="3-point trend fits floored at 0; >3x or <1/3x divergences fall back to flat mean (counts printed). Color winsorized 95%.") +
  theme_cap + theme(legend.position="right")
ggsave(file.path(fig,"fig6_payoff_phase_dollars.png"), f6, width=10, height=7, dpi=200)
saveRDS(d, "data_processed/payoff_phase_dollars.rds")
cat("\nsaved fig6_payoff_phase_dollars.png\n")
