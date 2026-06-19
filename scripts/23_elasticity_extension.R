# ============================================================
# 23_elasticity_extension.R  —  Trade Capstone
# ELASTICITY EXTENSION: Kee-Nicita-Olarreaga via CEPII ProTEE
#
# Data: ProTEE_0_1.csv — import demand elasticities at HS6
#   sigma = own-price import demand elasticity (all negative)
#   more negative = more elastic = more tariff-responsive
#   Source: CEPII Product-Level Trade Elasticities (2019)
#   Based on Kee, Nicita & Olarreaga (2008) REStat methodology
#
# THREE TESTS:
#   Test 1: Does the Trump 1 dose-response differ by elasticity?
#           import_change ~ tariff * sigma (interaction)
#           Prediction: stronger slope for high-elasticity products
#
#   Test 2: Did high-elasticity products exit the T1→T2 sample?
#           t.test(sigma ~ still_trading_2025)
#           Prediction: surviving T2 products have lower |sigma|
#
#   Test 3: Does elasticity explain the T2 dose-response collapse?
#           T2 regression: import_change25 ~ tariff * sigma
#           Prediction: even among high-elasticity products,
#           the T2 slope is near zero (full attenuation)
#
# LIMITATION: ProTEE uses HS2007-era codes; not all match our HS2017
# Comtrade data. Unmatched codes are excluded. The exact match rate and
# count are computed and printed at runtime (see "Match rate vs full T1").
# ============================================================

library(dplyr); library(readr); library(ggplot2); library(tidyr)
fig <- "figures"

NAVY <- "#1E2761"; BLUE <- "#1F5C8A"; RED <- "#C0473B"
MID  <- "#5A7FA8"; LTGRAY <- "#EEF1F6"; DKGRAY <- "#444C5A"
theme_cap <- theme_minimal(base_size=13) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_line(color="grey88"),
        plot.title=element_text(face="bold", size=15, color=NAVY),
        plot.subtitle=element_text(color="grey35", size=11, lineheight=1.05),
        plot.caption=element_text(color="grey45", size=9, hjust=0))

w <- function(x,p=0.01){q<-quantile(x,c(p,1-p),na.rm=TRUE);pmin(pmax(x,q[1]),q[2])}

# ---- Load elasticity data ----
elast <- read_csv("data_raw/ProTEE_0_1.csv",
                  show_col_types=FALSE) %>%
  mutate(hs6 = sprintf("%06d", as.integer(HS6))) %>%
  filter(!is.na(sigma), positive == 0) %>%   # exclude NaN + wrong-sign estimates
  select(hs6, sigma)

cat("ProTEE elasticities loaded:", nrow(elast), "products\n")
cat("sigma range:", round(min(elast$sigma),2), "to", round(max(elast$sigma),2), "\n\n")

# ---- Load Trump 1 data + merge ----
t1 <- readRDS("data_processed/hs6_merged_2019.rds") %>%
  left_join(elast, by="hs6") %>%
  filter(!is.na(sigma)) %>%
  mutate(ic_w = w(import_change))

cat("=== TRUMP 1 + ELASTICITY MERGED ===\n")
cat("Products with elasticity:", nrow(t1), "\n")
cat("Match rate vs full T1 (3,201):", round(100*nrow(t1)/3201,1), "%\n\n")

# Compute tercile breaks from T1 — used by both T1 and T2 labels
t1_breaks  <- quantile(-t1$sigma, probs=c(1/3, 2/3), na.rm=TRUE)
label_low  <- paste0("Low elasticity\n(|σ| < ",  round(t1_breaks[1],1),")")
label_mid  <- paste0("Medium elasticity\n(|σ| ", round(t1_breaks[1],1),"–",round(t1_breaks[2],1),")")
label_high <- paste0("High elasticity\n(|σ| ≥ ", round(t1_breaks[2],1),")")
elast_levels <- c(label_low, label_mid, label_high)

t1 <- t1 %>%
  mutate(elast_group = ntile(-sigma, 3),
         elast_label = factor(
           case_when(elast_group==1 ~ label_low,
                     elast_group==2 ~ label_mid,
                     TRUE           ~ label_high),
           levels=elast_levels))

# ============================================================
# TEST 1: Does dose-response differ by elasticity?
# ============================================================
cat("=== TEST 1: INTERACTION MODEL (T1) ===\n")
m_interact <- lm(ic_w ~ us_tariff_2019 * sigma, data=t1)
cat("import_change ~ tariff * sigma\n\n")
print(round(summary(m_interact)$coefficients, 5))

# Slope per elasticity group for intuition
slopes <- t1 %>%
  group_by(elast_label) %>%
  group_modify(~{
    m <- lm(w(import_change) ~ us_tariff_2019, data=.x)
    tibble(slope=round(coef(m)[2],4), t=round(summary(m)$coef[2,3],2), n=nrow(.x))
  })
cat("\n--- Slope by elasticity tercile ---\n")
print(slopes)

# ============================================================
# TEST 2: Did elastic products exit? (Compositional selection test)
# ============================================================
cat("\n=== TEST 2: COMPOSITIONAL SELECTION ===\n")
t2_panel <- read_csv("data_processed/panel_hs6_trump2.csv",
                     show_col_types=FALSE) %>%
  mutate(hs6=gsub(" ","0",sprintf("%06s",as.character(hs6))))

t1_with_survival <- t1 %>%
  mutate(still_trading = hs6 %in% t2_panel$hs6[!is.na(t2_panel$import_change25)])

cat("Still trading in 2025:", sum(t1_with_survival$still_trading), "\n")
cat("Exited by 2025:", sum(!t1_with_survival$still_trading), "\n\n")

tt <- t.test(sigma ~ still_trading, data=t1_with_survival)
cat("t.test: sigma by still_trading_2025\n")
cat("  Mean sigma (exited):        ", round(tt$estimate[1],3), "\n")
cat("  Mean sigma (still trading): ", round(tt$estimate[2],3), "\n")
cat("  Difference:                 ", round(diff(tt$estimate),3), "\n")
cat("  t =", round(tt$statistic,2), "  p =", round(tt$p.value,4), "\n\n")
cat("Interpretation: more negative sigma = more elastic\n")
cat("If exited products have more negative sigma → elastic products left first\n\n")

# ============================================================
# TEST 3: T2 slope by elasticity group
# ============================================================
cat("=== TEST 3: T2 SLOPE BY ELASTICITY GROUP ===\n")
t2_merged <- readRDS("data_processed/hs6_trump2_direct.rds") %>%
  left_join(elast, by="hs6") %>%
  filter(!is.na(sigma), !is.na(import_change25)) %>%
  mutate(ic25_w = w(import_change25),
         elast_group = ntile(-sigma, 3),
         elast_label = factor(
           case_when(elast_group==1 ~ label_low,
                     elast_group==2 ~ label_mid,
                     TRUE           ~ label_high),
           levels=elast_levels))

slopes_t2 <- t2_merged %>%
  group_by(elast_label) %>%
  group_modify(~{
    m <- lm(ic25_w ~ us_tariff_2025, data=.x)
    tibble(slope=round(coef(m)[2],5), t=round(summary(m)$coef[2,3],2), n=nrow(.x))
  })
cat("T2 import_change25 ~ us_tariff_2025, by elasticity group:\n")
print(slopes_t2)

# ============================================================
# FIGURE: Dose-response by elasticity tercile, T1 vs T2
# ============================================================
t1_plot <- t1 %>%
  select(hs6, tariff=us_tariff_2019, outcome=ic_w, elast_label) %>%
  mutate(episode="Trump 1 (2019)")

t2_plot <- t2_merged %>%
  select(hs6, tariff=us_tariff_2025, outcome=ic25_w, elast_label) %>%
  mutate(episode="Trump 2 (2025)")

both_elast <- bind_rows(t1_plot, t2_plot) %>%
  mutate(episode=factor(episode, levels=c("Trump 1 (2019)","Trump 2 (2025)")))

fA6 <- ggplot(both_elast, aes(tariff, outcome, color=elast_label)) +
  geom_hline(yintercept=0, color="grey60", linewidth=0.4) +
  geom_smooth(method="lm", se=FALSE, linewidth=1.2, aes(group=elast_label)) +
  scale_color_manual(values=c(BLUE, MID, RED), name="Elasticity group") +
  facet_wrap(~episode, scales="free_x") +
  coord_cartesian(ylim=c(-0.8, 0.6)) +
  labs(title="Does elasticity explain the dose-response? Trump 1 vs Trump 2",
       subtitle=paste0(
         "Trump 1: dose-response is steeper for high-elasticity products (as predicted).\n",
         "Trump 2: slopes converge near zero for ALL elasticity groups — uniform attenuation."),
       x="US tariff rate (%)",
       y="Import change vs baseline",
       caption=paste0(
         "Elasticity: CEPII ProTEE sigma (own-price import demand elasticity).\n",
         "High elasticity = more negative sigma = more responsive to price/tariff changes.\n",
         "n=", nrow(t1), " products (T1) matched to elasticity data (",
         round(100*nrow(t1)/3201,1), "% coverage).")) +
  theme_cap +
  theme(legend.position="top",
        strip.text=element_text(size=12, face="bold", color=NAVY))

ggsave(file.path(fig,"figA6_elasticity_dose_response.png"),
       fA6, width=12, height=6.5, dpi=200)
cat("\nsaved figA6_elasticity_dose_response.png\n")
