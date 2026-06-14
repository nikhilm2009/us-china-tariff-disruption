# ============================================================
# 03_tariffs.R  —  Trade Capstone
# Attaches Section 301 tariff rates to the US-China HS2 panel.
#
# These are CHAPTER-LEVEL approximations of statutory rates,
# derived from the Section 301 tranche compositions:
#   List 1  Jul 2018  25%  machinery/aerospace/tech  (HS 84,85,88,90)
#   List 2  Aug 2018  25%  chemicals/plastics/rail   (HS 28,29,38,39,86)
#   List 3  Sep 2018  10% -> 25% (May 2019)          (HS 73,87,94, many)
#   List 4A Sep 2019  15% -> 7.5% (Feb 2020)         (HS 61-64, etc.)
#
# China retaliation: heavy on agriculture (HS 01-24), autos (87),
#   energy (27). Aircraft (88) deliberately spared.
#
# NOTE: These are Tier 1 approximations used for the HS2 overview only.
# The main analysis uses the Bown (2021) product-level rates at HS6
# (built by 03b_build_tariff_csvs.R, used in scripts 07+).
# ============================================================

library(dplyr)
library(readr)

proc_dir <- "data_processed"
panel <- read_csv(file.path(proc_dir, "panel_pre_tariff.csv"),
                  show_col_types = FALSE)

# ---- US tariff on Chinese imports, by HS2 chapter and year ----
us_on_china_rate <- function(sector, year) {
  s <- as.integer(sector)
  list1  <- s %in% c(84, 85, 88, 89, 90)
  list2  <- s %in% c(28, 29, 38, 39, 40, 86)
  list3  <- s %in% c(72, 73, 74, 76, 83, 87, 44, 48, 94, 68, 69, 70)
  list4a <- s %in% c(42, 43, 61, 62, 63, 64, 65, 66, 67, 91, 92, 95)

  if (year <= 2017) return(0)
  if (list1 || list2) return(25)
  if (list3) { if (year == 2018) return(10); return(25) }
  if (list4a) { if (year <= 2018) return(0); if (year == 2019) return(15); return(7.5) }
  if (year >= 2019) return(5)
  return(0)
}

# ---- China retaliation on US exports, by HS2 chapter and year ----
china_on_us_rate <- function(sector, year) {
  s <- as.integer(sector)
  ag       <- s %in% c(1:24)
  autos    <- s %in% c(87)
  energy   <- s %in% c(27)
  chem_ind <- s %in% c(28, 29, 39)
  aircraft <- s %in% c(88)   # deliberately spared by China

  if (year <= 2017) return(0)
  if (aircraft) return(0)
  if (ag) return(25)
  if (autos) { if (year == 2018) return(40); return(25) }
  if (energy) { if (year <= 2018) return(10); return(25) }
  if (chem_ind) return(25)
  if (year >= 2019) return(10)
  return(5)
}

EPS <- 1.0  # 1pp floor to avoid divide-by-zero

panel2 <- panel %>%
  rowwise() %>%
  mutate(
    init_rate  = us_on_china_rate(sector, year),
    retal_rate = china_on_us_rate(sector, year)
  ) %>%
  ungroup() %>%
  mutate(retaliation_ratio = (retal_rate + EPS) / (init_rate + EPS))

write_csv(panel2, file.path(proc_dir, "panel_with_tariffs.csv"))
message("Wrote ", nrow(panel2), " rows -> panel_with_tariffs.csv")
message("retaliation_ratio range: ",
        round(min(panel2$retaliation_ratio), 2), " to ",
        round(max(panel2$retaliation_ratio), 2))
message("Next: 04_model.R")
