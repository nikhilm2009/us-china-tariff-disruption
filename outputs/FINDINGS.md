# Findings: When Tariffs Stop Moving Trade
### US-China Product-Level Evidence, 2019–2025
### Wharton Data Science Academy Capstone — Nikhil M.

---

## Core contribution

Trade-policy effects are highly resolution-dependent. A strong product-level
dose-response in 2019 failed to generalize to 2025. Elasticity analysis
confirms elastic products exited disproportionately, but selection alone
does not explain the attenuation. Trade diversion to Vietnam, Mexico, and
Taiwan is confirmed but partial — three countries captured ~14.5 cents of
each dollar China lost.

---

## Finding 1: Resolution dependence

At HS2 (97 chapters): slope ≈ 0, t = −0.8, ns.
At HS6 (3,201 products): slope = −0.019, **t = −16.4**, p < 1e-50.

Same data, same tariffs, two resolutions. The HS2 null result is a
measurement artifact: each chapter averages tariffed and untariffed
products together, cancelling the signal. The relationship lives at the
resolution where the policy instrument is applied.

**Bucket evidence (Trump 1):**
- Untariffed products (0%): +18% vs baseline
- Products 1–10% tariff: +6%
- Products 11–25%: −1%
- Products >25%: −23%
Clear monotonic staircase.

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

**Within-range robustness check (script 24):**
Trump 1 model trained on 0–45% tariff range. T2 products split:
- In-range (≤45%): 2,019 products (64%), gap = **9.8pp**
- Out-of-range (>45%): 1,145 products (36%), gap = **47.9pp**

Extrapolation explains the out-of-range gap. But the in-range T2 slope
is +0.0007, t=0.76, ns — the dose-response collapsed even within the
trained range. Both mechanisms operate.

**Direct Trump 2 regression (WTO rates):**
slope = −0.0002, t = −0.3, ns. Dose-response absent.

**Trump 2 bucket table:**

| Tariff bucket | n | Median decline |
|--------------|---|---------------|
| Low (0–25%) | 345 | −30% |
| Medium (25–40%) | 956 | −30% |
| High (40–50%) | 1,329 | −27% |
| Very High (50–100%) | 534 | −30% |

Every bucket fell ~28–30% regardless of tariff level.

---

## Finding 4: Compositional selection (elasticity extension)

**Data:** CEPII ProTEE, sigma = own-price import demand elasticity.
File: data_raw/ProTEE_0_1.csv (tracked in git).
T1 merge: 2,730 / 3,201 products = 85.3% coverage.

### Test 1: Elasticity × Trump 1 dose-response
Interaction model: import_change ~ tariff × sigma
- Interaction: β = 0.00010, t = 0.65, p = 0.51 (ns)
- But tercile slopes: low −0.0185, medium −0.0164, high −0.0243
- Direction correct; linear interaction too weak to reach significance

### Test 2: Compositional selection (key result)
| Group | Mean sigma |
|-------|-----------|
| Exited products | −11.58 |
| Still trading 2025 | −8.66 |
| Difference | 2.92 |
| t = −6.33, p ≈ 0 | |

Products that disappeared from US-China trade by 2025 were significantly
more elastic. Compositional selection confirmed empirically.

### Test 3: T2 slope by elasticity group
| Group | T2 slope | t |
|-------|---------|---|
| Low elasticity | −0.00104 | −1.12 |
| Medium elasticity | +0.00017 | +0.18 |
| High elasticity | +0.00150 | +1.43 |

All ≈ zero, all ns. Even high-elasticity survivors show no dose-response.
Selection explains who exited. It does not explain why survivors stopped
responding.

---

## Finding 5: Trade diversion (Vietnam, Mexico, Taiwan)

**Scripts:** 25_diversion_pull.R, 25b_taiwan_usitc_parse.R,
26_diversion_build.R, 27_diversion_test.R

**Data sources:**
- Vietnam, Mexico: UN Comtrade (pulled via comtradr)
- Taiwan: USITC DataWeb / US Census Bureau (dataweb.usitc.gov)
  — UN Comtrade suppresses US-Taiwan bilateral data; USITC publishes
  it as US-reported imports by country of origin

**Panel:** 2,746 products with China T1 + T2 data and at least one
third-country match.

### Test 1: Does China's T1 decline predict third-country T2 rise?

| Country | n | Slope | t | p |
|---------|---|-------|---|---|
| Vietnam | 1,491 | +0.262 | 3.08 | 0.002 |
| Mexico | 1,816 | +0.075 | 2.41 | 0.016 |
| Taiwan | 1,522 | +0.178 | 5.58 | <0.001 |
| Combined | 2,313 | +0.145 | 4.69 | <0.001 |

All three significant. Positive slope = products where China fell most
saw the largest third-country rises 6 years later. Taiwan has the
strongest t-statistic — consistent with its role as primary alternative
source for semiconductor and electronics categories (HS84/85/90).

### Test 2: Product classification by T2 outcome

| Quadrant | n | % |
|----------|---|---|
| Destruction (China↓, 3rd flat) | 965 | 41.7% |
| Diversion (China↓, 3rd↑) | 824 | 35.6% |
| 3rd growth only | 277 | 12.0% |
| Stable | 247 | 10.7% |

Two mechanisms operate on different product categories in roughly equal
proportions.

### Test 3: Dollar quantification
Combined slope = 0.145.
**For every $1.00 China lost, Vietnam+Mexico+Taiwan gained ~$0.14
(14.5 cents on the dollar).**
Unaccounted: ~$0.86 — demand destruction, reshoring, diversion to
Korea/India not captured, limits of three-country baseline.

### Test 4: Placebo check (inconclusive)
Untariffed products showed larger VN/MX rises than tariffed (71% vs 36%,
t=−2.80, p=0.006). This is the opposite of the diversion prediction.
Interpretation: the untariffed group contains semiconductor categories
(strategically excluded from Section 301) where Taiwan specialises and
growth was driven by CHIPS Act and nearshoring trends independent of
tariffs. Not a clean control group — result is inconclusive.

---

## The three-stage mechanism

**Stage 1 — Trump 1:** Tariffs hit elastic products hardest.
Evidence: t = −16.4, bucket staircase, steeper slopes for high-elasticity
tercile.

**Stage 2 — Selection:** Elastic products exit disproportionately.
Evidence: exited σ = −11.6 vs surviving σ = −8.7, t = −6.33, p < 0.001.

**Stage 3 — Trump 2:** Remaining products show no tariff-response.
Evidence: slopes ≈ 0 across all elasticity groups. The flat T2
dose-response reflects a mixture of:
- Diversion (~36% of products): shifted to Vietnam/Mexico/Taiwan
- Destruction (~42% of products): trade genuinely reduced
- Residual (~22%): third-country growth or stable

---

## Robustness checks

**Within-range validation (script 24):**
Restricting to T2 products within T1 training range (≤45% tariff):
- In-range gap = 9.8pp (vs headline 58pp)
- In-range T2 slope = +0.0007, t=0.76, ns
- Dose-response absent even within training range
- Addresses Professor Zhao's out-of-distribution critique partially:
  extrapolation explains the out-of-range gap but not the in-range
  collapse

---

## Stated limitations

- Cross-sectional associations at annual frequency, not causal.
- Tariff placement was strategic (Made-in-China-2025 targeting).
- T2 slope magnitude depends on WTO snapshot date (Nov-2025), annual
  aggregation, and tariff-rate matching.
- ProTEE elasticities from HS2007-era data; 89.9% T1 match.
- ProTEE estimates global elasticities, not US-China bilateral.
- Diversion test uses 3 countries only; Korea, India, others excluded.
- Placebo check on untariffed products inconclusive — not a clean
  control group.
- T2 intra-year rate volatility: Nov-2025 is a snapshot approximation.

---

## Figure inventory

| Figure | Script | What it shows |
|--------|--------|---------------|
| fig1_resolution_contrast_v2 | 16 | HS2 vs HS6 two-panel |
| fig2_hs6_import_effect | 09 | Trump 1 dose-response (t=−16.4) |
| fig7_trump1_vs_trump2 | 13 | Slope comparison |
| fig10_predictive_validation | 17 | T1 model fails on T2 |
| fig11b_disruption_prob | 18 | Logistic S-curve |
| fig11c_logistic_coefficients | 18 | Coefficient forest plot |
| fig12_model_comparison | 20 | Three-model ROC |
| figA1_hs_hierarchy | 21 | HS classification tree |
| figA2_tariff_distribution | 21 | T1 vs T2 rate histograms |
| figA3_merge_flow | 21 | Data merge flow |
| figA4_tariff_timeline | 21 | Escalation timeline |
| figA5_bucket_comparison | 22 | T1 staircase vs T2 flat |
| figA6_elasticity_dose_response | 23 | Elasticity × dose-response |
| fig_inrange_validation | 24 | Within-range robustness check |
| fig14_diversion_scatter | 27 | China T1 vs VN+MX+TW T2 |
| fig15_diversion_by_country | 27 | Diversion by country (3 panels) |
