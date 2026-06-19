# Trade Capstone: When Tariffs Stop Moving Trade
## Product-Level Evidence from US-China Trade Conflict, 2019–2025

**Wharton Data Science Academy Capstone — Nikhil M.**

---

## What this project shows

**Finding 1 — Resolution dependence:** The tariff-import association is
invisible at the HS2 chapter level (t = −0.8, ns) and strong at the HS6
product level (slope = −0.019, t = −16.4, p < 1e-50). The signal lives
at the resolution where the policy instrument is applied.

**Finding 2 — Predictive failure:** Applying the Trump 1 OLS model
out-of-sample to 3,164 products at actual 2025 WTO tariff rates predicts
−84% for products facing >50% tariffs. The actual outcome was −26%.
Prediction gap = 58 percentage points. The dose-response that was strong
in 2019 is essentially zero in 2025 (slope = −0.0002, t = −0.3, ns).

**Finding 3 — Compositional selection:** CEPII ProTEE elasticity merge
reveals that products which exited the sample between Trump 1 and Trump 2
were significantly more elastic than survivors (mean σ = −11.6 vs −8.7,
t = −6.33, p < 0.001). Selection explains who exited. But even among
high-elasticity survivors, the Trump 2 dose-response is absent — selection
is part of the explanation, not all of it.

**Finding 4 — Structure is linear:** Logistic regression (AUC = 0.677)
outperforms Random Forest (0.657) and XGBoost (0.630) with the same three
features. More complexity adds noise, not signal.

---

## Repository structure

```
trade_capstone/
├── scripts/                  23 R scripts (run in order — see below)
├── data_raw/
│   ├── bown/                 Bown (2021) replication files (.dta) — not tracked
│   ├── wto/                  WTO tariff action files (.csv) — not tracked
│   └── ProTEE_0_1.csv        CEPII elasticities — tracked (200KB)
├── data_processed/           Built CSVs and RDS files — partially tracked
├── figures/                  All output figures (.png)
├── outputs/                  Documentation
│   ├── FINDINGS.md           Complete empirical record
│   ├── EXECUTIVE_SUMMARY.md  One-page summary
│   ├── DATA_PROVENANCE.md    Full data lineage and match rates
│   └── PRESENTATION_OUTLINE.md  18-slide deck structure
├── build_deck.js             pptxgenjs deck builder (Node.js)
├── renv.lock                 Package lockfile
└── README.md                 This file
```

---

## Reproducibility

### Requirements
- R 4.6.0+
- Node.js (for `build_deck.js` deck builder)
- renv (auto-activates on project open)
- UN Comtrade API key (free tier)
- ~500MB disk space

### Setup
```r
# Open trade_capstone.Rproj in RStudio
renv::restore()   # restore all packages from lockfile

# One-time API key setup:
comtradr::set_primary_comtrade_key()   # paste key when prompted
# Key persists in .Renviron (gitignored)
```

---

## External source files required

Place these before running `03b_build_tariff_csvs.R`:

```
data_raw/bown/TrumpTariffs-CHN-hs6.dta
data_raw/bown/301Retaliation-hts8-2018&2019-best.dta
data_raw/wto/C840_C156.csv      (US→China, 16MB)
data_raw/wto/C156_C840.csv      (China→US, 4MB)
data_raw/ProTEE_0_1.csv         (CEPII ProTEE — already tracked in git)
```

**Bown files:** Replication archive of Bown (2021), *Journal of Policy
Modeling* 43(4). Extract the two `.dta` files from the journal
supplementary zip.

**WTO files:** ttd.wto.org → Download → Tariff Actions → HS 6-digit.
US reporter / China partner → `C840_C156.csv`.
China reporter / US partner → `C156_C840.csv`.

**ProTEE:** CEPII Product-Level Trade Elasticities portal:
cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=35
Already in `data_raw/` and tracked in git.

---

## Script run order

```
00_setup.R                  verify packages + API connection
01_pull.R                   Comtrade pull — US-China 2015–2021
03b_build_tariff_csvs.R     build all 4 tariff CSVs from source files
                            (requires bown/ and wto/ files above)
06_hs6_build.R              HS6 panel from raw Comtrade file
07_hs6_merge_test.R         Finding 1+2: HS6 import regression (t=−16)
08_retaliation_test.R       Trump 1 retaliation regression
09_final_figures.R          Figures 1–4
12_trump2_build.R           Comtrade pull 2022–25, build T2 panel
13_trump_comparison.R       Slope comparison — Fig 7
14_trump2_direct.R          Finding 2: direct T2 regression (WTO rates)
15_four_bar_chart.R         Four-bar elasticity chart
16_fig1_enhanced.R          Enhanced Fig 1 (two-panel with aggregation path)
17_predictive_validation.R  Finding 2: T1 model on T2 data — Fig 10
18_logistic_hs6.R           Finding 4: logistic + coefficient plot
19_random_forest.R          Random Forest comparison
20_model_comparison.R       Three-model ROC — Fig 12
21_appendix_methods.R       Appendix figs A1–A4 (HS hierarchy, tariff
                            distributions, merge flow, timeline)
22_bucket_comparison.R      Appendix fig A5 (T1 vs T2 bucket comparison)
23_elasticity_extension.R   Finding 3: ProTEE merge + 3 tests + Fig A6
```

**Note:** Scripts 02–05 (HS2 multi-pair exploration) are archived on
branch `archive/full-exploration`. Main branch is the clean pipeline only.

---

## Match rates

| Merge | Matched | Rate |
|-------|---------|------|
| T1 import tariff (Bown) | 3,201 / 3,202 | 100% |
| T1 retaliation (Bown HS8→HS6) | 1,986 / 2,105 | 94.3% |
| T2 import tariff (WTO) | 3,164 / 3,165 | 100% |
| T2 retaliation (WTO) | 1,590 matched | — |
| ProTEE elasticity (T1) | 2,730 / 3,201 | 85.3% |

---

## Building the presentation

```bash
# Ensure figures are named correctly in the same directory as build_deck.js
# See outputs/PRESENTATION_OUTLINE.md for the full figure filename mapping

node build_deck.js
# Output: when_tariffs_stop_moving_trade.pptx  (18 slides)
```

Deck structure: 12 main slides + 6 appendix slides (A1–A6).
Built with pptxgenjs. Node.js required.

---

## Key figures

| Figure | Script | What it shows |
|--------|--------|---------------|
| fig1_resolution_contrast_v2 | 16 | HS2 vs HS6 — aggregation destroys signal |
| fig2_hs6_import_effect | 09 | Trump 1 dose-response (t = −16.4) |
| fig7_trump1_vs_trump2 | 13 | Steep T1 slope vs flat T2 slope |
| fig10_predictive_validation | 17 | T1 model fails on T2 — 58pp gap |
| fig11b_disruption_prob | 18 | Logistic S-curve |
| fig11c_logistic_coefficients | 18 | Coefficient forest plot |
| fig12_model_comparison | 20 | Three-model ROC |
| figA1_hs_hierarchy | 21 | HS2→HS4→HS6 classification tree |
| figA2_tariff_distribution | 21 | T1 vs T2 rate distributions |
| figA3_merge_flow | 21 | Data merge flow and match rates |
| figA4_tariff_timeline | 21 | Tariff escalation 2018–2026 |
| figA5_bucket_comparison | 22 | T1 staircase vs T2 flat (strongest backup) |
| figA6_elasticity_dose_response | 23 | Elasticity × dose-response: T1 fan, T2 flat |

---

## References

1. Amiti, Redding, Weinstein (2019). JEP 33(4):187–210.
2. Bown (2021). Journal of Policy Modeling 43(4):805–843.
3. Bown (2026). PIIE RealTime Economics, March 16, 2026.
4. Fajgelbaum & Khandelwal (2026). BPEA Spring 2026 / NBER WP 35064.
5. WTO Tariff & Trade Data (ttd.wto.org). Downloaded June 2026.
6. Kee, Nicita, Olarreaga (2008). REStat 90(4):666–682.
7. CEPII ProTEE Product-Level Trade Elasticities.
   cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=35
