# Data Provenance & Methods Record
### When Tariffs Stop Moving Trade — complete pipeline
### Wharton Data Science Academy Capstone — Nikhil M.

---

## 1. Trade-flow data — US-China

**Source:** UN Comtrade via `comtradr` R package (v1.0.5).
Auth: free-tier key in `.Renviron` as `COMTRADE_PRIMARY` (gitignored).

| Pair | Reporter | Partner | Years | Script |
|------|----------|---------|-------|--------|
| US-China T1 | USA | CHN | 2015–2021 | 01_pull.R |
| US-China T2 baseline | USA | CHN | 2022–2024 | 12_trump2_build.R |
| US-China T2 conflict | USA | CHN | 2025 | 12_trump2_build.R |

Filter: `aggr_level == 6`. Baselines: T1 = mean(2015–17); T2 = mean(2022–24).

---

## 2. Trade-flow data — diversion countries

**Source:** UN Comtrade via `comtradr`. Script: 25_diversion_pull.R.
Skip logic: each RDS file checked for existence + validity before pulling.

| Pair | Years | File |
|------|-------|------|
| US-Vietnam | 2015–2021 | data_raw/us_vietnam_1521.rds |
| US-Vietnam | 2022–2025 | data_raw/us_vietnam_2225.rds |
| US-Mexico | 2015–2021 | data_raw/us_mexico_1521.rds |
| US-Mexico | 2022–2025 | data_raw/us_mexico_2225.rds |

**Taiwan:** UN Comtrade suppresses US-Taiwan bilateral HS6 data (political
status). Use USITC DataWeb instead — US Census Bureau official statistics,
US-reported imports by country of origin.

Source: dataweb.usitc.gov
Query: Imports for Consumption, Taiwan, All HTS, Customs Value (Actual),
Annual, years 2015/2016/2017/2022/2023/2024/2025.
File: data_raw/us_taiwan_usitc.csv (tracked in git, 22,616 rows).
Parser: 25b_taiwan_usitc_parse.R → data_raw/us_taiwan_1521.rds + us_taiwan_2225.rds.
Coverage: 4,365 unique HS6 codes; years 2015/16/17 + 2022–2025.
Note: Customs Value (FOB) vs Comtrade CIF — ~5% systematic difference,
acceptable for computing fractional import changes.

---

## 3. Tariff data — Trump 1

**Script:** 03b_build_tariff_csvs.R

**US tariffs on China (HS6):**
Source: data_raw/bown/TrumpTariffs-CHN-hs6.dta (Bown 2021)
Variable: sum of tariff change columns excluding Phase One cut (Feb 2020).
Output: data_processed/us_tariff_hs6.csv. Mean rate: 21.2%; mass at 25%.

**China retaliation on US (HS6):**
Source: data_raw/bown/301Retaliation-hts8-2018&2019-best.dta (Bown 2021)
Collapsed HS8→HS6 by simple mean (stated limitation).
Output: data_processed/chn_reta_hs6.csv

---

## 4. Tariff data — Trump 2

**Source:** WTO Tariff & Trade Data (ttd.wto.org), downloaded June 2026.
Files: data_raw/wto/C840_C156.csv (US→China, 16MB)
       data_raw/wto/C156_C840.csv (China→US, 4MB)
Script: 03b_build_tariff_csvs.R. Snapshot: 2025-11-10.
Column `best_avlbl` = cumulative effective rate (MFN + Section 301 + IEEPA).
US→China 2025: 5,612 products; median 41.2%.
T2 rate volatility caveat: rates moved 20%→145%→50% through 2025.
Nov-2025 snapshot approximates settled H2-2025 regime.

---

## 5. Elasticity data — CEPII ProTEE

**Source:** CEPII Product-Level Trade Elasticities (ProTEE)
File: data_raw/ProTEE_0_1.csv (200KB, tracked in git)
Reference: Fontagné, Guimbard & Orefice (2022); Kee, Nicita & Olarreaga (2008)
Portal: cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=35
Script: 23_elasticity_extension.R

Structure: 5,050 HS6 products.
- sigma: own-price import demand elasticity (negative; more negative = more elastic)
- zero: 1 if constrained to zero (484 → excluded)
- positive: 1 if wrong sign (122 → excluded)
After filtering: 4,479 valid elasticities. Sigma range: −131.8 to −0.1.

HS revision note: ProTEE uses HS2007-era codes. Our data uses HS2017/2022.
Match rate: 4,772 / 5,309 = 89.9% of T1 tariff codes matched.

---

## 6. Merges and match rates

All HS6 codes standardised: `sprintf("%06s", hs_code)` → 6-character strings.

| Merge | Left | Matched | Rate |
|-------|------|---------|------|
| T1 import (07) | 3,202 | 3,201 | 100% |
| T1 retaliation (08) | 2,105 | 1,986 | 94.3% |
| T2 import (14) | 3,165 | 3,164 | 100% |
| T1 + ProTEE (23) | 3,201 | 2,730 | 85.3% |
| Diversion panel VN | 3,201 | 1,491 | — |
| Diversion panel MX | 3,201 | 1,816 | — |
| Diversion panel TW | 3,201 | 1,522 | — |
| Diversion panel combined | 3,201 | 2,746 | — |

T1 retaliation 94.3%: Bown file is HS8; collapsed to HS6 by simple mean.

---

## 7. Key models

| Script | Model | Result |
|--------|-------|--------|
| 07 | T1: import_change ~ us_tariff_2019 | slope=−0.019, t=−16.4, p<1e-50 |
| 14 | T2: import_change25 ~ us_tariff_2025 | slope=−0.0002, t=−0.3, ns |
| 17 | T1 model OOS on T2 | predicted −84%, actual −26%, gap=58pp |
| 18 | Logistic: disruption ~ tariff+log_vol+asym | AUC=0.689 |
| 19 | Random Forest: same 3 features | AUC=0.657 |
| 20 | XGBoost: same 3 features | AUC=0.630 |
| 23 | T1: import_change ~ tariff × sigma | interaction t=0.65, ns |
| 23 | t.test: sigma ~ still_trading_2025 | Δ=2.92, t=−6.33, p<0.001 |
| 24 | In-range T2: slope=+0.0007, t=0.76, ns | gap=9.8pp in-range |
| 27 | Diversion: Vietnam | slope=0.262, t=3.08, p=0.002 |
| 27 | Diversion: Mexico | slope=0.075, t=2.41, p=0.016 |
| 27 | Diversion: Taiwan | slope=0.178, t=5.58, p<0.001 |
| 27 | Diversion: Combined | slope=0.145, t=4.69, p<0.001 |

---

## 8. Script run order

```
00_setup.R                  packages + API connection test
01_pull.R                   Comtrade US-China 2015–2021
03b_build_tariff_csvs.R     all 4 tariff CSVs
06_hs6_build.R              HS6 panel
07_hs6_merge_test.R         Finding 1+2: HS6 regression
08_retaliation_test.R       Trump 1 retaliation
09_final_figures.R          Figs 1–4
12_trump2_build.R           Comtrade 2022–25
13_trump_comparison.R       Slope comparison fig7
14_trump2_direct.R          Direct T2 regression
15_four_bar_chart.R         Four-bar chart
16_fig1_enhanced.R          Enhanced fig1 two-panel
17_predictive_validation.R  T1 model on T2 fig10
18_logistic_hs6.R           Logistic + coef plot fig11b/c
19_random_forest.R          RF comparison
20_model_comparison.R       Three-model ROC fig12
21_appendix_methods.R       Appendix figs A1–A4
22_bucket_comparison.R      Appendix fig A5
23_elasticity_extension.R   ProTEE merge + 3 tests + figA6
24_inrange_validation.R     Within-range robustness fig13*
25_diversion_pull.R         Comtrade VN+MX pulls
25b_taiwan_usitc_parse.R    Parse USITC Taiwan CSV → RDS
26_diversion_build.R        Diversion panel VN+MX+TW
27_diversion_test.R         4 tests + fig14 + fig15
```

*Script 24 saves as `fig_inrange_validation.png`.
Rename to `fig13_inrange_validation.png` before running `node build_deck.js`.

External files required before 03b:
- data_raw/bown/TrumpTariffs-CHN-hs6.dta
- data_raw/bown/301Retaliation-hts8-2018&2019-best.dta
- data_raw/wto/C840_C156.csv
- data_raw/wto/C156_C840.csv
- data_raw/ProTEE_0_1.csv  ← tracked in git
- data_raw/us_taiwan_usitc.csv  ← tracked in git (USITC download)

---

## 9. Software

R 4.6.0 (aarch64-darwin). renv v1.2.3 (lockfile committed).
Key packages: comtradr 1.0.5, dplyr, tidyr, readr, ggplot2, pROC, randomForest, xgboost.
Node.js: pptxgenjs for deck builder.

---

## 10. References

1. Amiti, Redding, Weinstein (2019). JEP 33(4):187–210.
2. Bown (2021). Journal of Policy Modeling 43(4):805–843.
3. Bown (2026). PIIE RealTime Economics, March 16, 2026.
4. Fajgelbaum & Khandelwal (2026). BPEA Spring 2026 / NBER WP 35064.
5. WTO Tariff & Trade Data (ttd.wto.org). Downloaded June 2026.
6. Kee, Nicita, Olarreaga (2008). REStat 90(4):666–682.
7. CEPII ProTEE. cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=35
8. USITC DataWeb. dataweb.usitc.gov (Taiwan bilateral data source).
