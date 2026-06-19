# Trade Capstone: When Tariffs Stop Moving Trade
## Product-Level Evidence from US-China Trade Conflict, 2019–2025
**Wharton Data Science Academy Capstone — Nikhil M.**

---

## Five findings (with exact numbers)

**Finding 1 — Resolution:** HS2: slope ≈ 0, t = −0.8, ns. HS6: slope = −0.019,
t = −16.4, p < 1e-50. Untariffed +18%, >25% tariff −23%. Signal lives where
policy is applied.

**Finding 2 — Predictive failure:** T1 model applied out-of-sample to 3,164 T2
products. Predicted −84% for >50% tariff; actual −26%; gap = 58pp. Direct T2
regression: slope = −0.0002, t = −0.3, ns. Every tariff tier fell ~27–30%.

**Finding 3 — Within-range robustness:** In-range (≤45%, 64% of T2): gap = 9.8pp.
Out-of-range (>45%): gap = 47.9pp. In-range T2 slope = +0.0007, t = 0.76, ns.
Dose-response absent even within training range.

**Finding 4 — Compositional selection:** CEPII ProTEE elasticities.
Exited σ = −11.6 vs surviving σ = −8.7, t = −6.33, p < 0.001. Even
high-elasticity survivors show T2 slope ≈ 0. Selection explains who exited,
not why survivors stopped responding.

**Finding 5 — Trade diversion:** Vietnam (t=3.08, p=0.002), Mexico (t=2.41,
p=0.016), Taiwan (t=5.58, p<0.001, USITC DataWeb). Combined t=4.69, p<0.001.
~14.5 cents on the dollar captured. ~85.5 cents unaccounted.

**Finding 6 — Linear structure:** Logistic AUC=0.677 > RF 0.657 > XGBoost 0.630.

---

## Repository structure

```
trade_capstone/
├── scripts/                  27 R scripts + build_deck.js
├── data_raw/
│   ├── bown/                 Bown (2021) .dta files — not tracked
│   ├── wto/                  WTO tariff CSVs — not tracked
│   ├── ProTEE_0_1.csv        CEPII elasticities — tracked (200KB)
│   └── us_taiwan_usitc.csv   USITC DataWeb Taiwan — tracked
├── data_processed/           Built RDS + CSV files
├── figures/                  All output PNGs
├── outputs/                  Documentation (FINDINGS, PROVENANCE, etc.)
├── build_deck.js             pptxgenjs deck builder (Node.js)
├── renv.lock                 Package lockfile
└── README.md                 This file
```

---

## Requirements

- R 4.6.0+ with renv (auto-activates on project open)
- Node.js (for deck builder)
- UN Comtrade API key (free tier, 250 calls/day)

```r
renv::restore()
comtradr::set_primary_comtrade_key()  # one-time
```

---

## External files required before running 03b

```
data_raw/bown/TrumpTariffs-CHN-hs6.dta
data_raw/bown/301Retaliation-hts8-2018&2019-best.dta
data_raw/wto/C840_C156.csv           (US→China, 16MB)
data_raw/wto/C156_C840.csv           (China→US, 4MB)
data_raw/ProTEE_0_1.csv              ← tracked in git
```

**Taiwan data (USITC DataWeb):**
Go to dataweb.usitc.gov → Imports for Consumption → Taiwan → All HTS →
Customs Value (Actual) → Annual → years 2015/16/17/2022/23/24/25 → Download CSV.
Save as `data_raw/us_taiwan_usitc.csv`, then run `25b_taiwan_usitc_parse.R`.

---

## Script run order

```
00_setup.R                  packages + API test
01_pull.R                   Comtrade US-China 2015–2021
03b_build_tariff_csvs.R     all 4 tariff CSVs (requires bown/ + wto/ files)
06_hs6_build.R              HS6 panel
07_hs6_merge_test.R         Finding 1+2: HS6 regression (t=−16.4)
08_retaliation_test.R       Trump 1 retaliation
09_final_figures.R          Figs 1–4
12_trump2_build.R           Comtrade 2022–25 pull + T2 panel
13_trump_comparison.R       Slope comparison fig7
14_trump2_direct.R          Direct T2 regression
15_four_bar_chart.R         Four-bar chart
16_fig1_enhanced.R          Enhanced fig1 (two-panel)
17_predictive_validation.R  T1 model on T2 data fig10
18_logistic_hs6.R           Logistic + coefficient plot fig11b/c
19_random_forest.R          RF comparison
20_model_comparison.R       Three-model ROC fig12
21_appendix_methods.R       Appendix figs A1–A4
22_bucket_comparison.R      Appendix fig A5 (bucket table)
23_elasticity_extension.R   ProTEE merge + 3 tests + fig A6
24_inrange_validation.R     Within-range robustness check fig13*
25_diversion_pull.R         Comtrade VN+MX pulls (cached per file)
25b_taiwan_usitc_parse.R    Parse USITC Taiwan CSV → RDS
26_diversion_build.R        Diversion panel VN+MX+TW
27_diversion_test.R         4 tests + fig14 + fig15
```

*fig13: script 24 saves as `fig_inrange_validation.png`; rename to
`fig13_inrange_validation.png` before running `node build_deck.js`.

Scripts 02–05 archived on branch `archive/full-exploration`.

---

## Match rates

| Merge | Matched | Rate |
|-------|---------|------|
| T1 import (Bown) | 3,201 / 3,202 | 100% |
| T1 retaliation (Bown HS8→HS6) | 1,986 / 2,105 | 94.3% |
| T2 import (WTO) | 3,164 / 3,165 | 100% |
| ProTEE elasticity | 2,730 / 3,201 | 85.3% |
| Diversion panel (VN+MX+TW) | 2,746 products | — |

---

## Building the deck

```bash
# One rename needed first:
cp figures/fig_inrange_validation.png figures/fig13_inrange_validation.png

node build_deck.js
# Output: when_tariffs_stop_moving_trade.pptx (21 slides)
```

21 slides: 14 main + appendix divider + A1–A7 (7 appendix slides).
figA2 optional — shows placeholder if missing (run 21_appendix_methods.R).

---

## Key figures

| Figure | Script | Slide |
|--------|--------|-------|
| fig1_resolution_contrast_v2 | 16 | 3 |
| fig2_hs6_import_effect | 09 | 4 |
| fig10_predictive_validation | 17 | 5 |
| fig13_inrange_validation* | 24 | 6 |
| fig7_trump1_vs_trump2 | 13 | 7 |
| figA5_bucket_comparison | 22 | 8 |
| fig15_diversion_by_country | 27 | 9 |
| fig11b_disruption_prob | 18 | 10 |
| fig11c_logistic_coefficients | 18 | 11 |
| fig12_model_comparison | 20 | 12 |
| figA1–A4 | 21 | A1–A4 |
| figA5 | 22 | A5 |
| figA6_elasticity_dose_response | 23 | A6 |
| fig14_diversion_scatter | 27 | A7 |
| fig15_diversion_by_country | 27 | A7 |

*rename from fig_inrange_validation.png

---

## References

1. Amiti, Redding, Weinstein (2019). JEP 33(4):187–210.
2. Bown (2021). Journal of Policy Modeling 43(4):805–843.
3. Bown (2026). PIIE RealTime Economics, March 16, 2026.
4. Fajgelbaum & Khandelwal (2026). BPEA Spring 2026 / NBER WP 35064.
5. WTO Tariff & Trade Data (ttd.wto.org). Downloaded June 2026.
6. Kee, Nicita, Olarreaga (2008). REStat 90(4):666–682.
7. CEPII ProTEE. cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=35
8. USITC DataWeb. dataweb.usitc.gov (Taiwan bilateral data).
