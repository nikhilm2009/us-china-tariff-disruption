# Executive Summary
## When Tariffs Stop Moving Trade: Product-Level Evidence from US-China Trade Conflict
### Wharton Data Science Academy Capstone — Nikhil M.

---

## One sentence

A strong product-level tariff dose-response in 2019 failed to generalize
to 2025, and preliminary elasticity analysis suggests compositional
selection — elastic products exiting first — partially explains why.

---

## What we did

Using UN Comtrade HS6 bilateral trade flows and product-level tariff
schedules from two independent sources (Bown 2021 for Trump 1; WTO Tariff
Actions for Trump 2), we estimate the relationship between statutory tariff
rates and import changes for two US-China conflict episodes: 2019 (Trump 1)
and 2025 (Trump 2). We then apply CEPII ProTEE product-level elasticities
to test whether import demand elasticity explains the observed attenuation.

Pipeline: 18 scripts, raw API pull through cleaned panel, tariff merges,
OLS regressions, logistic + ML models, elasticity merge, figures — fully
reproducible (renv-locked, match rates documented throughout).

---

## The narrative arc

**Setup:** In 2019, tariffs strongly predicted import declines at the HS6
level. t = −16.4. Untariffed products grew +18%; heavily tariffed fell
−46%. The dose-response is unambiguous.

**Test:** We apply that Trump 1 model out-of-sample to 3,164 products at
actual 2025 tariff rates.

**Failure:** Predicted −84% for products facing >50% tariffs. Actual: −26%.
Prediction gap = 58 percentage points. The model broke.

**Explanation Part 1:** The tariff-response slope collapsed entirely by
2025 (−0.019 → ≈ 0). Even within tariff buckets, every tier fell ~28–30%
regardless of rate — the dose-response vanished.

**Explanation Part 2:** CEPII ProTEE elasticity merge reveals that products
which exited the sample between Trump 1 and Trump 2 were significantly more
elastic than survivors (mean σ = −11.6 vs −8.7, t = −6.33, p < 0.001).
Compositional selection is confirmed empirically.

**The twist:** Even among high-elasticity surviving products, the T2 slope
is ≈ 0. Selection explains who exited. It does not explain why survivors
stopped responding. Additional mechanisms remain.

---

## Four lessons

1. **Policy effects live at policy resolution.** The HS6 relationship
   (t = −16.4) was invisible at HS2. Aggregation destroys detectability.

2. **Trump 1 tariffs strongly predicted disruption.** Clear dose-response.
   A logistic model predicts disruption with AUC 0.689.

3. **Those relationships largely disappeared by 2025.** Elastic products
   exited disproportionately (t = −6.33, p < 0.001). But even among
   high-elasticity survivors, the dose-response was absent — selection
   explains part, not all, of the attenuation.

4. **Simple models explain more than complex ones.** Logistic (0.677)
   outperforms RF (0.657) and XGBoost (0.630). The mechanism is linear.

*Trade adapted faster than the original tariff model predicted.*

---

## What we do not claim

- Causality. Cross-sectional associations at annual frequency.
- Exogeneity. Tariff placement was strategic, not random.
- "99% elasticity collapse." The slope is largely absent; magnitude
  depends on snapshot date, annual aggregation, and rate matching.
- Complete mechanism. Selection explains part of the attenuation.
  Supply-chain restructuring (Vietnam, Taiwan, Mexico) is the
  hypothesized remainder — testable but not yet tested.

---

## Data sources

| Source | Use |
|--------|-----|
| UN Comtrade API | US-China bilateral HS6 trade flows, 2015–2025 |
| Bown (2021) | Section 301 tariff rates at HS6, Trump 1 |
| WTO Tariff Actions | 2025 effective tariff rates at HS6, Trump 2 |
| CEPII ProTEE | Product-level import demand elasticities (sigma) |

Match rates: 100% for T1 and T2 primary tariff merges.
89.9% for ProTEE elasticity merge (HS2007 vs HS2017 revision gap).
