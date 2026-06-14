# Findings: Structural Predictors of Trade-Conflict Disruption
### US-China 2018-19 and 2025 — empirical companion to the MARL trade model

---

## The question

The MARL trade-conflict model identifies a compact structural predictor —
follower retaliation capacity relative to leader tariff pressure — that
governs whether a conflict escalates or deters in simulation. This project
asks two validation questions:
1. Does that structure appear in real trade flows during the 2018-19 US-China
   tariff war?
2. Does import demand elasticity change between Trump 1 (2018-19) and
   Trump 2 (2025) — and does this reflect adaptive-systems behavior?

---

## Part 1: Trump 1 (2018-19) — three empirical findings

### Finding 1: No signal at the chapter (HS2) level

At HS2, tariff measures showed no detectable relationship to trade
disruption in any specification. Every correlation sat near zero. This
is a resolution problem, not a null result.

### Finding 2: Strong, clean signal at the product (HS6) level

Regressing 2019 import change on the US Section 301 tariff (3,201 products,
Bown 2021 data):

> slope = −0.019 per tariff pp,  **t = −16.4**,  p < 1e-50

Monotonic across tariff buckets: untariffed products grew +18%;
products >25% tariff fell −46%.

**Why this matters more because of Finding 1:** HS2 aggregation averages
tariffed and untariffed products within the same chapter, cancelling the
effect. The relationship lives at the resolution of the policy instrument,
exactly as Amiti, Redding & Weinstein (2019) argue.

### Finding 3: Retaliation bit too — but weaker and asymmetric

China retaliation regression (1,986 products):

> slope = −0.012,  **t = −4.3**,  p ≈ 2e-5

Real but weaker — about 60% of the US import-side effect. Non-monotonic
across buckets due to commodity volatility. The top 20 HS6 products
account for **41%** of all US export value to China — China's retaliation
was structurally constrained, the empirical echo of follower-capacity
limitation in the CIFEr model.

---

## Part 2: Trump 2 (2025) — elasticity collapse

### Finding 4: Import demand elasticity fell 99% between episodes

Direct regression of 2025 import change on actual WTO Nov-2025 tariff
rates (3,164 products):

> Trump 1 slope: **−0.019** (t = −16.4, p < 1e-50)
> Trump 2 slope: **−0.00017** (t = −0.3, p = 0.76)
> Elasticity ratio: **0.01x** — 99% reduction

The dose-response that was strong and monotonic in 2019 had completely
vanished by 2025. Products remaining in the US-China trade relationship
by 2025 were those where substitution was structurally hardest, making
their import volumes insensitive to marginal tariff variation. Trump 2
tariffs hit a residual of structurally inelastic trade.

### Finding 5: Both sides' elasticities collapsed (four-bar summary)

| Episode | Side | Slope | t | Significance |
|---------|------|-------|---|---|
| Trump 1 | US tariff → imports | −0.0192 | −16.4 | *** |
| Trump 1 | China retaliation → exports | −0.0119 | −4.3 | *** |
| Trump 2 | US tariff → imports | −0.0002 | −0.3 | ns |
| Trump 2 | China retaliation → exports | +0.0017 | +1.3 | ns |

Both the US tariff effect and the Chinese retaliation effect collapsed
to statistical noise by 2025. The T2 retaliation sign-flip (positive
but ns) reflects that the US exports still flowing to China despite
high tariffs are structurally necessary — inelastic by selection, not
by tariff immunity.

### The adaptive-systems interpretation

> Repeated tariff pressure over seven years functioned as a selection
> mechanism: elastic, substitutable trade restructured away from China
> (supply chains moved to Vietnam, Taiwan, Mexico), leaving a residual
> that is structurally resistant to further disruption. By 2025, the
> tariff instrument had exhausted its marginal discriminating power —
> the remaining bilateral trade is the hardest-to-move fraction, where
> additional tariff escalation produces no differential product-level
> response.

This is the empirical analogue of the MARL model's adaptive-agent
behavior: repeated strategic pressure induces structural adjustment
that progressively reduces the responsiveness of remaining flows to
further pressure. The structural predictor that worked in Trump 1 had
been adapted away by Trump 2.

---

## The payoff phase diagrams

Observable payoff terms from CIFEr eqs (4)–(5), no calibration params:

**Normalized version:** dense cells cluster near zero to mildly
US-favorable everywhere. No regime structure. The simulation's clean
diagonal boundary does not reproduce in disaggregated real data.

**Dollar version (trend-projected, 471 products):** US +$7.2B,
China −$17.6B, US−China = +$24.7B. Weak directional consistency with
MARL prediction but dominated by a few giant categories (phones = $3.4B).
The pattern reflects concentration rather than a smooth structural geometry.

**Honest comparison to the MARL grid:** the simulation's compact regime
structure is an artifact of full calibration. What survives contact with
reality is the directional logic — leader pressure generates leader payoff
advantage — but not the sharp diagonal boundary.

---

## What this says about the MARL framing

The HS6 Trump 1 findings validate two core structural claims from the
CIFEr paper: tariff pressure maps to disruption at the right resolution,
and follower-capacity constrains retaliatory leverage. The Trump 2
comparison extends this: the adaptive behavior the MARL model encodes
in its agent learning rules appears in the real world as supply-chain
restructuring over a seven-year horizon. The model's within-episode
dynamics and the real world's cross-episode structural change are two
timescales of the same adaptive mechanism.

---

## Stated limitations

- Cross-sectional association at annual frequency, not causal
  identification (cf. Census/ARW monthly DiD designs).
- Tariff placement was strategic, not random.
- Retaliation rate: T1 collapsed HS8→HS6 by simple mean; T2 from WTO
  Tariff Actions Nov-2025 snapshot.
- CIF/FOB valuation asymmetry between import and export sides.
- Baseline = flat mean (2015-17 for T1; 2022-24 for T2). Trend-
  projection attempted but unstable for majority of products.
- Payoff calibration parameters omitted — reduced-form only.
- Three other conflict pairs (US-EU, US-Canada, China-Australia)
  remain on coarse Tier-0 tariff proxy.
- T2 intra-year rate volatility (10%→145%→50% through 2025); Nov-2025
  snapshot represents settled second-half regime.

---

## Figure inventory

| Figure | Script | Finding |
|--------|--------|---------|
| fig1_resolution_contrast | 09 | HS2 aggregation hides the signal |
| fig2_hs6_import_effect | 09 | Trump 1 HS6 dose-response (t=−16) |
| fig3_retaliation_asymmetry | 09 | Two-sided T1 comparison |
| fig4_phase_diagram | 09 | Binned import-change heatmap |
| fig5_payoff_phase | 10 | Normalized payoff phase (no regime structure) |
| fig6_payoff_phase_dollars | 11 | Dollar payoff phase (concentration) |
| fig7_trump1_vs_trump2 | 13 | Proxy slope comparison — flat T2 |
| fig8_elasticity_comparison | 14 | Direct elasticity comparison — 99% collapse |
| fig9_four_bar_elasticity | 15 | All four slopes, both episodes |
