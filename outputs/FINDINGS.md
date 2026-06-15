# Findings: When Tariffs Stop Moving Trade
### US-China Product-Level Evidence, 2019–2025
### Wharton Data Science Academy Capstone — Nikhil M.

---

## Core contribution

Trade-policy effects are highly resolution-dependent. A strong product-level
dose-response in 2019 failed to generalize to 2025. Preliminary elasticity
analysis suggests compositional selection — elastic products exiting
disproportionately — partially explains the attenuation, but not fully.
Additional mechanisms (supply-chain restructuring, trade diversion) remain
to be identified.

---

## Finding 1: Resolution dependence

At HS2 (97 chapters): slope ≈ 0, t = −0.8, ns.
At HS6 (3,201 products): slope = −0.019, **t = −16.4**, p < 1e-50.

Same data, same tariffs, two resolutions. The HS2 null result is a
measurement artifact: each chapter averages tariffed and untariffed products
together, cancelling the signal. The relationship lives at the resolution
where the policy instrument is applied.

**Bucket evidence:**
- Untariffed products (0%): +18% vs baseline
- Products >25% tariff: −46% vs baseline
- Monotonic staircase across all four tariff tiers

---

## Finding 2: Trump 1 predictive model (OLS)

Trained on 3,201 HS6 products, 2019 cross-section:

> import_change = 0.317 − 0.0192 × us_tariff_2019

Logistic classification (outcome: import decline >30%):
- AUC = 0.689 (held-out test set, 80/20 stratified split)
- Tariff rate is the dominant predictor
- Product size (log baseline imports) adds a protective effect
- Trade asymmetry adds nothing (z = 0.10, ns)

Model comparison (same 3 features, same split):
- Logistic: AUC = 0.677
- Random Forest: AUC = 0.657
- XGBoost: AUC = 0.630

Simpler model wins. The disruption structure is linear.

---

## Finding 3: Predictive failure — Trump 2

Applied the Trump 1 OLS model out-of-sample to 3,164 products at actual
WTO Nov-2025 tariff rates:

| | Predicted | Actual | Gap |
|--|-----------|--------|-----|
| Products >50% tariff | −84% | −26% | +58pp |

The model broke. The world changed.

**Direct Trump 2 regression (WTO rates):**
> slope = −0.0002, t = −0.3, ns

The dose-response that was −0.019 in 2019 is essentially zero in 2025.

**Bucket table (Trump 2):**

| Tariff bucket | n products | Median decline |
|--------------|-----------|---------------|
| Low (0–25%) | 345 | −30% |
| Medium (25–40%) | 956 | −30% |
| High (40–50%) | 1,329 | −27% |
| Very High (50–100%) | 534 | −30% |

Every bucket fell ~28–30% regardless of tariff level. Dose-response vanished.
Compared to Trump 1, where the same bucket analysis showed a clear staircase.

---

## Finding 4: Compositional selection (elasticity extension)

**Data:** CEPII ProTEE product-level trade elasticities (sigma = own-price
import demand elasticity). 4,479 products after excluding NaN and
wrong-sign estimates. Merged to T1 dataset: 2,730 products (85.3% coverage).

### Test 1: Does elasticity moderate the Trump 1 dose-response?

Interaction model: import_change ~ tariff × sigma
- Interaction term: β = 0.00010, t = 0.65, p = 0.51 (not significant)

Slope by tercile:
| Elasticity group | Slope | t |
|-----------------|-------|---|
| Low (|σ| < 5.4) | −0.0185 | −11.5 |
| Medium (|σ| 5.4–9.2) | −0.0164 | −7.6 |
| High (|σ| ≥ 9.2) | −0.0243 | −8.5 |

Direction is correct (steeper for more elastic products) but the linear
interaction is too weak to reach significance. Tariff rate dominates.

### Test 2: Compositional selection test (the key result)

Did elastic products exit disproportionately between T1 and T2?

| Group | Mean sigma |
|-------|-----------|
| Exited products | −11.58 |
| Still trading 2025 | −8.66 |
| Difference | 2.92 |
| t = −6.33, p ≈ 0 | |

**Products that exited were significantly more elastic.**
This is direct empirical confirmation of compositional selection —
not inferred, measured.

### Test 3: T2 slope by elasticity group

| Elasticity group | T2 slope | t |
|-----------------|---------|---|
| Low | −0.00104 | −1.12 |
| Medium | +0.00017 | +0.18 |
| High | +0.00150 | +1.43 |

All essentially zero. All insignificant.

**The critical implication:** Even among products with historically high
elasticity, the tariff-response is absent in 2025. This means compositional
selection (elastic products exiting) is part of the explanation but not
the entire explanation. Something else also operates — possibly supply-chain
restructuring, tariff circumvention, or absorption of costs within supply
chains. This is where the research frontier currently sits.

---

## The three-stage mechanism

**Stage 1 — Trump 1:** Tariffs hit elastic products hardest.
Evidence: t = −16.4, staircase bucket table, steeper slopes for
high-elasticity tercile.

**Stage 2 — Selection:** Elastic products exit disproportionately.
Evidence: exited σ = −11.6 vs surviving σ = −8.7, t = −6.33, p < 0.001.

**Stage 3 — Trump 2:** Remaining products show no tariff-response.
Evidence: slopes ≈ 0 across all elasticity groups. Even high-elasticity
survivors are non-responsive — selection was thorough but not the
complete story.

---

## Stated limitations

- Cross-sectional associations at annual frequency, not causal identification.
- Tariff placement was strategic (Made-in-China-2025 targeting), not random.
- T2 slope magnitude depends on WTO snapshot date (Nov-2025), annual
  aggregation, and tariff-rate matching. "Largely absent" not "99% collapse."
- ProTEE elasticities from HS2007-era data; 89.9% match to our HS2017
  codes. ~537 unmatched codes excluded from elasticity analysis.
- ProTEE estimates global import demand elasticities, not US-China bilateral.
- T2 intra-year rate volatility: 20%→145%→50% through 2025.
  Nov-2025 snapshot approximates settled H2-2025 regime.
- Supply-chain restructuring mechanism not directly tested (requires
  bilateral data from Vietnam, Taiwan, Mexico — future work).

---

## Figure inventory

| Figure | Script | What it shows |
|--------|--------|---------------|
| fig1_resolution_contrast_v2 | 16 | HS2 vs HS6 two-panel with aggregation path |
| fig2_hs6_import_effect | 09 | Trump 1 dose-response (t = −16.4) |
| fig7_trump1_vs_trump2 | 13 | Slope comparison: steep T1, flat T2 |
| fig10_predictive_validation | 17 | T1 model applied to T2 — prediction gap |
| fig11b_disruption_prob | 18 | Logistic S-curve: P(disruption) by tariff rate |
| fig11c_logistic_coefficients | 18 | Coefficient forest plot |
| fig12_model_comparison | 20 | Three-model ROC: Logistic wins |
| figA1_hs_hierarchy | 21 | HS2→HS4→HS6 classification tree |
| figA2_tariff_distribution | 21 | T1 vs T2 tariff rate histograms |
| figA3_merge_flow | 21 | Data merge flow and match rates |
| figA4_tariff_timeline | 21 | Tariff escalation timeline 2018–2026 |
| figA5_bucket_comparison | 22 | T1 staircase vs T2 flat (strongest backup slide) |
| figA6_elasticity_dose_response | 23 | Elasticity × dose-response: T1 fan, T2 flat |
