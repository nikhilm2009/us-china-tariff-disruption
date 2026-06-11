# Trade Capstone — Pipeline

Empirical test of whether the MARL-derived structural predictor
(retaliation capacity / tariff ceiling) appears in real trade flows
across four conflict pairs.

## Run order (in RStudio, from the project root)

```
scripts/00_setup.R    # once: install pkgs, register Comtrade key, test connection
scripts/01_pull.R     # ~8 API calls; saves raw .rds per pair (won't re-pull)
scripts/02_clean.R    # aggregate to (pair, sector, year), build trade_change
scripts/03_tariffs.R  # attach COARSE tariff lookup -> retaliation_ratio
scripts/04_model.R    # continuous primary + logistic robustness at 3 thresholds
scripts/05_plots.R    # Plot A (trajectories), B (scatter), C (regime map)
```

## The two things to verify first (per the v2 blueprint)

1. **00_setup.R connection test must return rows.** If it 401s, your
   Comtrade account hasn't subscribed to the free "comtrade - v1" product.
2. **02_clean.R auto-detects column names.** If it stops and prints the
   available columns, paste them to me and I'll pin the mapping.

## Known weakest link (by design) — the upgrade path

`03_tariffs.R` uses a **coarse hand-coded** tariff table so the pipeline
runs end-to-end today. When you're ready to add rigor, replace ONLY that
table with the real PIIE "Trade War Timeline" tranche-to-HS2 mapping.
Nothing downstream changes. This is the single highest-value improvement.

## Caveats to state in the writeup

- Reporter mismatch: US- vs China-reported figures differ; reporter is
  consistent within each dyad (see note in 01_pull.R).
- Tariffs took effect in mid-2018 waves, not all at once; the 2018-19
  block smooths over that staging.
- DEU is used as an EU proxy in the MVP; broaden to EU aggregate later.
- retaliation_ratio is coarse until the PIIE upgrade above.

## Outputs

- `data_processed/panel_with_tariffs.csv` — the clean dataset (Deliverable 1)
- `outputs/primary_continuous_models.txt` — main regression table
- `outputs/logistic_threshold_robustness.csv` — robustness across cutoffs
- `figures/plotC_regime_map.png` — the memorable figure
```
