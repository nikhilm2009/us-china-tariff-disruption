# Trade Capstone: When Tariffs Stop Moving Trade
## Product-Level Evidence from US-China Trade Conflict, 2019–2025

**Wharton DSA Capstone — Nikhil M.**

---

## What this project shows

1. **Resolution dependence (Trump 1):** The tariff-import association is
   invisible at the HS2 chapter level and strong at the HS6 product level
   (slope −0.019, t = −16.4). The signal lives at the resolution of the
   policy instrument.

2. **Retaliation asymmetry (Trump 1):** Chinese retaliation shows a real
   but weaker association (slope −0.012, t = −4.3), concentrated in a
   handful of categories (top 20 products = 41% of US export value).

3. **Compositional selection (Trump 2):** The same product-level
   relationship is largely absent in 2025 (slope −0.0002, t = −0.3),
   consistent with seven years of trade restructuring selecting for
   structurally inelastic bilateral flows.

---

## Reproducibility

### Requirements
- R 4.6.0+
- renv (installed automatically on project open)
- UN Comtrade API key (free tier — see Step 1 below)
- ~500MB disk space for raw data

### Environment setup
```r
# After cloning, open trade_capstone.Rproj in RStudio
# renv will auto-activate; restore packages:
renv::restore()
```

### API key setup (one time)
```r
# Register at comtradeplus.un.org — free "comtrade v1" product
# Then run:
comtradr::set_primary_comtrade_key()   # paste key when prompted
# Restart R — key persists in .Renviron (gitignored)
```

### Run order
```
scripts/00_setup.R          # verify packages + API connection
scripts/01_pull.R           # pull US-China, US-EU, US-Canada, China-Australia (2015-2021)
scripts/02_clean.R          # aggregate to (pair, sector, year), build trade_change
scripts/03_tariffs.R        # attach Tier 1 Section 301 tariff lookup
scripts/04_model.R          # HS2 regressions (continuous + logistic robustness)
scripts/05_plots.R          # HS2 plots (Plots A, B, C)
scripts/06_hs6_build.R      # build HS6 panel from existing US-China raw file
scripts/07_hs6_merge_test.R # merge Bown T1 tariffs, run HS6 import regression
scripts/08_retaliation_test.R # merge Bown T1 retaliation, run export regression
scripts/09_final_figures.R  # Figs 1-4 (resolution contrast, HS6 effect, asymmetry)
scripts/10_payoff_phase.R   # normalized payoff phase diagram
scripts/11_payoff_phase_dollars.R  # dollar payoff phase diagram
scripts/12_trump2_build.R   # pull 2022-24 + 2025 Comtrade, build T2 panel
scripts/13_trump_comparison.R      # proxy slope comparison (T1 rate as T2 exposure proxy)
scripts/14_trump2_direct.R         # direct T2 regression (WTO 2025 rates)
scripts/15_four_bar_chart.R        # Fig 9: all four slopes, both episodes
```

### Required external source files
Place these before running `03b_build_tariff_csvs.R`:

```
data_raw/bown/TrumpTariffs-CHN-hs6.dta
data_raw/bown/301Retaliation-hts8-2018&2019-best.dta
data_raw/wto/C840_C156.csv
data_raw/wto/C156_C840.csv
```

**Bown files:** from the replication archive of Bown (2021), *Journal of
Policy Modeling* 43(4). Download the zip from the journal supplementary
materials; extract the two `.dta` files from `Input Data/` and
`Input Data/China tariff/`.

**WTO files:** from ttd.wto.org → Download → Tariff Actions → HS 6-digit
datasets. US reporter / China partner → `C840_C156.csv`. China reporter /
US partner → `C156_C840.csv`.

### Run order
```
scripts/00_setup.R              # verify packages + API connection
scripts/01_pull.R               # pull Comtrade (2015-2021, four pairs)
scripts/02_clean.R              # HS2 panel, baseline, trade_change
scripts/03_tariffs.R            # Tier 1 Section 301 lookup (HS2)
scripts/03b_build_tariff_csvs.R # builds all four tariff CSVs from source files
scripts/04_model.R              # HS2 regressions
scripts/05_plots.R              # HS2 plots
scripts/06_hs6_build.R          # HS6 panel from existing raw file
scripts/07_hs6_merge_test.R     # HS6 import regression (t=-16)
scripts/08_retaliation_test.R   # HS6 retaliation regression (t=-4)
scripts/09_final_figures.R      # Figs 1-4
scripts/10_payoff_phase.R       # normalized payoff phase
scripts/11_payoff_phase_dollars.R  # dollar payoff phase
scripts/12_trump2_build.R       # pull 2022-25, build T2 panel
scripts/13_trump_comparison.R   # proxy slope comparison
scripts/14_trump2_direct.R      # direct T2 regression (WTO rates)
scripts/15_four_bar_chart.R     # four-bar elasticity chart
scripts/16_fig1_enhanced.R      # enhanced Fig 1 (two-panel)
scripts/17_predictive_validation.R  # train T1, predict T2
scripts/18_logistic_hs6.R       # logistic regression + coefficient plot
scripts/19_random_forest.R      # RF comparison
scripts/20_model_comparison.R   # three-model ROC (Logistic/RF/XGBoost)
```
