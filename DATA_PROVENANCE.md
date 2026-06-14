# Data Provenance & Methods Record
### Structural Predictors of Trade-Conflict Disruption — complete pipeline

---

## 1. Trade-flow data

**Source:** UN Comtrade, via `comtradr` R package (v1.0.5),
API endpoint `comtradeapi.un.org/data/v1/get`.
Auth: free-tier key in `.Renviron` as `COMTRADE_PRIMARY` (gitignored).

**Pulls:**

| Pair | Reporter | Partner | Years | Script |
|------|----------|---------|-------|--------|
| US-China (T1) | USA | CHN | 2015–2021 | 01_pull.R |
| US-EU (Germany) | USA | DEU | 2015–2021 | 01_pull.R |
| US-Canada | USA | CAN | 2015–2021 | 01_pull.R |
| China-Australia | CHN | AUS | 2015–2022 | 01_pull.R |
| US-China (T2 baseline) | USA | CHN | 2022–2024 | 12_trump2_build.R |
| US-China (T2 conflict) | USA | CHN | 2025 | 12_trump2_build.R |

Confirmed: 8,601–8,861 HS6 products per year across all pulls.

**HS2 aggregation:** `aggr_level == 2` (API flag — not string-slicing).
**HS6 aggregation:** `aggr_level == 6`.
**Baselines:** T1 = mean(2015–17); T2 = mean(2022–24). Flat mean chosen
over trend-projection: 3-point extrapolation unstable for majority of
products (1,243 import / 1,890 export fallbacks to flat mean).

---

## 2. Tariff data — Trump 1

**Source:** Bown (2021) replication archive "Bown-Feb-2021".
**Built by:** `scripts/03b_build_tariff_csvs.R` (added to close
reproducibility gap — CSVs were originally built interactively).

**US tariffs on China (HS6):**
Source file: `data_raw/bown/TrumpTariffs-CHN-hs6.dta`
Structure: tariff *changes* at each action date.
Conversion: `us_tariff_2019` = sum of all change columns except
`TT301_f` (Feb-2020 Phase-One cut). Verified: mean 21.2%, mass at 25%.
Output: `data_processed/us_tariff_hs6.csv`

**China retaliation on US (HS6):**
Source file: `data_raw/bown/301Retaliation-hts8-2018&2019-best.dta`
Structure: cumulative levels by date.
Conversion: `chn_reta_2019` = `reta_2019Jun01`.
Collapsed HS8→HS6 by simple mean rate (stated limitation).
Output: `data_processed/chn_reta_hs6.csv`

---

## 3. Tariff data — Trump 2

**Source:** WTO Tariff & Trade Data portal (ttd.wto.org),
"Tariff Actions / HS 6-digit datasets".
Downloaded: US→China (`data_raw/wto/C840_C156.csv`, 16MB) and
China→US (`data_raw/wto/C156_C840.csv`, 4MB).
**Built by:** `scripts/03b_build_tariff_csvs.R`

**Snapshot chosen:** 2025-11-10 (US→China) and 2025-11-10 (China→US)
— last event date before 2026, representing the settled second-half
2025 regime post-Geneva talks. Column `best_avlbl` = cumulative
effective rate (all tariff layers: MFN + Section 301 + IEEPA).

**US tariffs on China 2025:**
5,612 products; median 41.2%; min 10% (IEEPA floor); max 370% (EVs/solar).
Zero-padded to 6 digits via `sprintf("%06d", hs_code)`.
Output: `data_processed/us_tariff_2025_hs6.csv`

**China retaliation on US 2025:**
5,612 products; median 34.4%; min 10%; max 100%.
Note: China's median rate (34.4%) lower than US (41.2%) — asymmetric
capacity visible in the rate levels themselves.
Output: `data_processed/chn_reta_2025_hs6.csv`

**Limitation:** T2 intra-year rate volatility. Tariffs escalated from
20% (Feb) to 145% (April) then settled ~50% post-Geneva (May), then
reduced to ~35% post-SCOTUS (Feb 2026). Nov-2025 snapshot captures
the settled H2-2025 regime. Annual Comtrade data reflects this full
path; the snapshot is an approximation of the effective rate products
faced for most of 2025.

---

## 4. Merges and match rates

All HS6 codes zero-padded to 6 characters before merging.

| Merge | Left | Right | Match |
|-------|------|-------|-------|
| T1 import (07) | 3,202 | us_tariff_hs6 | 3,201 / 100% |
| T1 retaliation (08) | 2,105 | chn_reta_hs6 | 1,986 / 94.3% |
| T2 import (14) | 3,165 | us_tariff_2025_hs6 | 3,164 / 100% |
| T2 retaliation (15) | ~2,000 | chn_reta_2025_hs6 | 1,590 |
| T2 group panel (12) | 3,165 | us_tariff_hs6 (T1 proxy) | 3,165 / 100% |
| Payoff phase (10/11) | both sides | both tariff files | 459–471 (>$10M floor) |

---

## 5. Models

All cross-sectional OLS. Outcomes winsorized 1/99%.

| Script | Model | Slope | t | p |
|--------|-------|-------|---|---|
| 07 | T1: import_change ~ us_tariff_2019 | −0.019 | −16.4 | <1e-50 |
| 08 | T1: export_change ~ chn_reta_2019 | −0.012 | −4.3 | 2e-5 |
| 12 | T2 group: Group B tail logistic | −0.432 | −3.7 | 2e-4 |
| 14 | T2: import_change25 ~ us_tariff_2025 | −0.00017 | −0.3 | 0.76 |
| 15 | T2: export_change25 ~ chn_reta_2025 | +0.0017 | +1.3 | ns |

---

## 6. Payoff phase diagrams

CIFEr eqs (4)–(5) observable terms. Calibration params omitted.
US payoff: τM − ½τ(M₀−M)₊ − (X₀−X)₊
China payoff: (X−X₀) − ½ρ(X₀−X)₊
Two versions: normalized (÷ baseline) and dollar (raw USD).
Data hygiene: $10M floor, 1% symmetric tail trim, 20 products dropped.

---

## 7. Software

R 4.6.0 (aarch64-darwin). renv v1.2.3 (lockfile committed).
Packages: comtradr 1.0.5, dplyr 1.2.1, tidyr 1.3.2, readr 2.2.0,
ggplot2 4.0.3, fixest 0.14.1, pROC 1.19.0.1.
Python 3 (pandas) used for file inspection only (not in pipeline).
Scripts 01–15 plus diag_heterogeneity.R run in order from project root.

---

## 8. References

1. Amiti, Redding, Weinstein (2019). JEP 33(4):187–210.
2. Bown (2021). Journal of Policy Modeling 43(4):805–843.
3. Bown (2026). "The Trump-China trade wars: Five takeaways from US
   imports in 2025." PIIE RealTime Economics, March 16, 2026.
4. Fajgelbaum & Khandelwal (2026). "Tariffs in 2025: Short-Run Impacts
   on the U.S. Economy." BPEA Spring 2026 / NBER WP 35064.
5. WTO Tariff & Trade Data (ttd.wto.org). Tariff Actions HS6 dataset,
   downloaded June 2026.
6. Kee, Nicita, Olarreaga (2008). REStat 90(4):666–682.
   [planned for elasticity interaction extension]
