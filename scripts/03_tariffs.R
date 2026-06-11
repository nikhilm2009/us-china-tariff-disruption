# ============================================================
# 03_tariffs.R  —  Trade Capstone
# Attaches a COARSE sector-level tariff lookup and builds
# retaliation_ratio = retaliating-side rate / initiating-side rate.
#
# >>> THIS TABLE IS THE MVP'S WEAKEST LINK BY DESIGN. <<<
# It is a deliberately coarse, hand-coded approximation of the PIIE
# "Trade War Timeline" tranches, mapped to HS2 chapters. It exists so
# the pipeline runs END TO END today. The single highest-value upgrade
# later is to replace ONLY this table with the real PIIE tranche->HS2
# mapping. Nothing downstream changes.
#
# Sources to cite when you upgrade:
#   PIIE "US-China Trade War Tariffs: An Up-to-Date Chart" (Bown)
# ============================================================

library(dplyr)
library(readr)

proc_dir <- "data_processed"
panel <- read_csv(file.path(proc_dir, "panel_pre_tariff.csv"),
                  show_col_types = FALSE)

# ------------------------------------------------------------
# COARSE TARIFF TIERS (percent, approximate effective conflict-period rate)
# Two sides per pair: 'init' = side that initiated/raised first,
#                     'retal' = retaliating side.
# For the three US dyads the US is treated as initiator (Section 232 / 301).
# For China-Australia, China is the initiator (2020 coercive measures).
#
# HS2 buckets are grouped broadly. Anything not listed -> baseline low tier.
# These numbers are ROUND APPROXIMATIONS, not the real schedule.
# ------------------------------------------------------------

# Helper: assign a coarse tier to an HS2 chapter
coarse_init_rate <- function(pair, sector) {
  s <- as.integer(sector)
  dplyr::case_when(
    # US-China: List 3/4 hit broad manufactured/industrial goods hard
    pair == "us_china" & s %in% c(72:83) ~ 25,  # base metals, articles
    pair == "us_china" & s %in% c(84:85) ~ 25,  # machinery, electrical
    pair == "us_china" & s %in% c(86:89) ~ 25,  # vehicles, transport
    pair == "us_china" & s %in% c(39:40) ~ 10,  # plastics, rubber
    pair == "us_china" ~ 7.5,                    # broad List 4A-ish

    # US-EU and US-Canada: Section 232 steel(72)/aluminum(76)
    pair %in% c("us_eu", "us_canada") & s == 72 ~ 25,
    pair %in% c("us_eu", "us_canada") & s == 76 ~ 10,
    pair %in% c("us_eu", "us_canada") ~ 0,

    # China-Australia: targeted coercive tariffs (barley, wine, coal, beef...)
    pair == "china_aus" & s %in% c(22) ~ 200,    # wine
    pair == "china_aus" & s %in% c(10) ~ 80,     # barley/cereals
    pair == "china_aus" & s %in% c(27) ~ 20,     # coal/mineral fuels
    pair == "china_aus" & s %in% c(02) ~ 12,     # meat
    pair == "china_aus" ~ 0,

    TRUE ~ 0
  )
}

# Retaliating side responds roughly in kind on the goods it can hit
coarse_retal_rate <- function(pair, sector) {
  s <- as.integer(sector)
  dplyr::case_when(
    # China retaliated heavily on US agriculture / vehicles
    pair == "us_china" & s %in% c(01:24) ~ 25,   # ag & food
    pair == "us_china" & s %in% c(87) ~ 40,      # autos (peak)
    pair == "us_china" & s %in% c(27) ~ 10,      # energy
    pair == "us_china" ~ 7.5,

    # EU/Canada retaliated on iconic US goods (whiskey, bikes, ag)
    pair %in% c("us_eu", "us_canada") & s %in% c(22) ~ 25, # spirits
    pair %in% c("us_eu", "us_canada") & s %in% c(01:24) ~ 15,
    pair %in% c("us_eu", "us_canada") & s %in% c(87) ~ 10,
    pair %in% c("us_eu", "us_canada") ~ 0,

    # Australia's response was limited (mostly WTO action, little tariff)
    pair == "china_aus" ~ 0,

    TRUE ~ 0
  )
}

# A small floor so we never divide by zero; interpret with care.
EPS <- 1.0  # 1 percentage point floor

panel2 <- panel %>%
  mutate(
    init_rate  = mapply(coarse_init_rate,  pair, sector),
    retal_rate = mapply(coarse_retal_rate, pair, sector),
    # retaliation_ratio: retaliating-side capacity relative to initiator's pressure
    retaliation_ratio = (retal_rate + EPS) / (init_rate + EPS)
  )

write_csv(panel2, file.path(proc_dir, "panel_with_tariffs.csv"))
message("Wrote ", nrow(panel2), " rows -> ",
        file.path(proc_dir, "panel_with_tariffs.csv"))
message("retaliation_ratio range: ",
        round(min(panel2$retaliation_ratio, na.rm = TRUE), 2), " to ",
        round(max(panel2$retaliation_ratio, na.rm = TRUE), 2))
message("Next: 04_model.R")
