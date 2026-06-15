# Data Provenance & Methods Record
### When Tariffs Stop Moving Trade — complete pipeline
### Wharton Data Science Academy Capstone — Nikhil M.

---

## 1. Trade-flow data

**Source:** UN Comtrade, via `comtradr` R package (v1.0.5).
Auth: free-tier key in `.Renviron` as `COMTRADE_PRIMARY` (gitignored).

**Pulls:**

| Pair | Reporter | Partner | Years | Script |
|------|----------|---------|-------|--------|
| US-China (T1) | USA | CHN | 2015–2021 | 01_pull.R |
| US-China (T2 baseline) | USA | CHN | 2022–2024 | 12_trump2_build.R |
| US-China (T2 conflict) | USA | CHN | 2025 | 12_trump2_build.R |

Confirmed: 8,601–8,861 HS6 products per year.
HS6 filter: `aggr_level == 6` (API flag, not string-slicing).
Baselines: T1 = mean(2015–17); T2 = mean(2022–24).
Flat mean chosen over trend-projection (3-point extrapolation unstable).

---

## 2. Tariff data — Trump 1

**Built by:** `scripts/03b_build_tariff_csvs.R`

**US tariffs on China (HS6):**
Source: `data_raw/bown/TrumpTariffs-CHN-hs6.dta` (Bown 2021)
Variable: sum of tariff change columns excluding Phase One cut (Feb 2020).
Output: `data_processed/us_tariff_hs6.csv`
Mean rate: 21.2%; mass at 25%.

**China retaliation on US (HS6):**
Source: `data_raw/bown/301Retaliation-hts8-2018&2019-best.dta` (Bown 2021)
Variable: `chn_reta_2019` = `reta_2019Jun01`
Collapsed HS8→HS6 by simple mean (stated limitation).
Output: `data_processed/chn_reta_hs6.csv`

---

## 3. Tariff data — Trump 2

**Source:** WTO Tariff & Trade Data portal (ttd.wto.org)
Files: `data_raw/wto/C840_C156.csv` (US→China, 16MB)
       `data_raw/wto/C156_C840.csv` (China→US, 4MB)
**Built by:** `scripts/03b_build_tariff_csvs.R`

**Snapshot:** 2025-11-10 — settled post-Geneva regime.
Column `best_avlbl` = cumulative effective rate (MFN + Section 301 + IEEPA).

US→China 2025: 5,612 products; median 41.2%; max 370% (EVs/solar).
China→US 2025: 5,612 products; median 34.4%; max 100%.

Zero-padded via `sprintf("%06d", hs_code)`.
Outputs: `data_processed/us_tariff_2025_hs6.csv`
         `data_processed/chn_reta_2025_hs6.csv`

**T2 rate volatility caveat:** rates moved 20%→145%→50% through 2025.
Nov-2025 snapshot approximates the settled H2-2025 regime.

---

## 4. Elasticity data — CEPII ProTEE

**Source:** CEPII Product-Level Trade Elasticities (ProTEE)
File: `data_raw/ProTEE_0_1.csv` (200KB, tracked in git)
Reference: Fontagné, Guimbard & Orefice (2022) / Kee, Nicita & Olarreaga (2008)
Portal: cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=35

**Structure:** 5,050 HS6 products, 4 columns:
- `HS6`: product code (integer, requires zero-padding to 6 digits)
- `sigma`: own-price import demand elasticity (negative; more negative = more elastic)
- `zero`: 1 if elasticity constrained to zero (484 products → NaN sigma)
- `positive`: 1 if raw estimate had wrong sign (122 products, excluded)

After filtering (NaN and positive==1 excluded): 4,479 valid elasticities.
Sigma range: −131.8 to −0.1; median −7.9; mean −10.9.

**HS revision note:** ProTEE uses HS2007-era codes. Our Comtrade data uses
HS2017/2022 vintage. Match rate: 4,772 / 5,309 = 89.9% of T1 tariff codes.
~537 unmatched codes reflect HS revision changes (products split/merged/renumbered).

**Script:** `scripts/23_elasticity_extension.R`

---

## 5. Merges and match rates

All HS6 codes standardized via `sprintf("%06s", hs_code)` before merging
(ensures 6-character zero-padded strings; not left-pad to "000084").

| Merge | n left | n right | Matched | Rate |
|-------|--------|---------|---------|------|
| T1 import (07) | 3,202 | 5,309 | 3,201 | 100% |
| T1 retaliation (08) | 2,105 | 1,986 HS6 collapsed | 1,986 | 94.3% |
| T2 import (14) | 3,165 | 5,612 | 3,164 | 100% |
| T2 retaliation (15) | ~2,000 | 5,612 | 1,590 | — |
| T1 + ProTEE elasticity (23) | 3,201 | 4,479 | 2,730 | 85.3% |

T1 retaliation 94.3%: Bown file is HS8; collapsed to HS6 by simple mean.
Some HS6 headings had no HS8 match (untargeted products).

---

## 6. Models

All regressions cross-sectional OLS. Outcomes winsorized 1/99%.

| Script | Model | Slope | t | p |
|--------|-------|-------|---|---|
| 07 | T1: import_change ~ us_tariff_2019 | −0.019 | −16.4 | <1e-50 |
| 08 | T1: export_change ~ chn_reta_2019 | −0.012 | −4.3 | 2e-5 |
| 14 | T2: import_change25 ~ us_tariff_2025 | −0.0002 | −0.3 | ns |
| 17 | T1 model OOS on T2 data | predicted −84%, actual −26% | gap=58pp | — |
| 18 | Logistic: disruption ~ tariff + log_vol + asymmetry | AUC=0.689 | — | — |
| 19 | Random Forest: same features | AUC=0.657 | — | — |
| 20 | XGBoost: same features | AUC=0.630 | — | — |
| 23 | T1: import_change ~ tariff × sigma | interaction t=0.65 | ns | 0.51 |
| 23 | T.test: sigma ~ still_trading_2025 | Δ=2.92 | −6.33 | <0.001 |

---

## 7. Script run order

```
00_setup.R               packages, API key, connection test
01_pull.R                UN Comtrade pull (US-China 2015–2021)
03b_build_tariff_csvs.R  builds all 4 tariff CSVs (T1 + T2, US + China)
06_hs6_build.R           HS6 panel construction
07_hs6_merge_test.R      Finding 1+2: HS6 import regression
08_retaliation_test.R    Trump 1 retaliation regression
09_final_figures.R       Figures 1–4
12_trump2_build.R        pull 2022–25, build T2 panel
13_trump_comparison.R    slope comparison fig7
14_trump2_direct.R       Finding 3: direct T2 regression
15_four_bar_chart.R      four-bar elasticity fig9
16_fig1_enhanced.R       enhanced fig1 (two-panel)
17_predictive_validation.R  Finding 3: T1 model on T2 data fig10
18_logistic_hs6.R        Finding 4: logistic + coefficient plot
19_random_forest.R       RF comparison
20_model_comparison.R    three-model ROC fig12
21_appendix_methods.R    Appendix figs A1–A4
22_bucket_comparison.R   Appendix fig A5 (bucket comparison)
23_elasticity_extension.R  Elasticity merge + 3 tests + fig A6
```

External files required before running 03b:
- `data_raw/bown/TrumpTariffs-CHN-hs6.dta`
- `data_raw/bown/301Retaliation-hts8-2018&2019-best.dta`
- `data_raw/wto/C840_C156.csv`
- `data_raw/wto/C156_C840.csv`
- `data_raw/ProTEE_0_1.csv`  ← tracked in git (200KB)

---

## 8. Software

R 4.6.0 (aarch64-darwin). renv v1.2.3 (lockfile committed).
Key packages: comtradr 1.0.5, dplyr, tidyr, readr, ggplot2 4.0.3,
patchwork, pROC 1.19.0.1, randomForest, xgboost.

---

## 9. References

1. Amiti, Redding, Weinstein (2019). JEP 33(4):187–210.
2. Bown (2021). Journal of Policy Modeling 43(4):805–843.
3. Bown (2026). PIIE RealTime Economics, March 16, 2026.
4. Fajgelbaum & Khandelwal (2026). BPEA Spring 2026 / NBER WP 35064.
5. WTO Tariff & Trade Data (ttd.wto.org). Downloaded June 2026.
6. Kee, Nicita, Olarreaga (2008). REStat 90(4):666–682.
7. CEPII ProTEE Product-Level Trade Elasticities dataset.
   cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=35
