# Executive Summary
## When Tariffs Stop Moving Trade: Product-Level Evidence from US-China Trade Conflict

---

### The contribution in one sentence

Trade-policy effects are highly resolution-dependent, and repeated conflict
appears to change the composition of trade in ways that attenuate later
tariff responsiveness.

---

### What we did

Using UN Comtrade HS6 bilateral trade flows and product-level tariff
schedules from two independent sources (Bown 2021 for Trump 1; WTO Tariff
Actions database for Trump 2), we estimate the relationship between
statutory tariff rates and import changes at the product level for two
US-China trade-conflict episodes: 2018-19 (Trump 1) and 2025 (Trump 2).

The pipeline runs from raw API pull through cleaned panel construction,
tariff merges, OLS regressions, and figures — fully documented and
reproducible (scripts 01–15, renv-locked, match rates reported throughout).

---

### Finding 1: Resolution dependence (Trump 1)

At the HS2 chapter level (97 sectors), no detectable association exists
between tariff exposure and import change — in any specification tried.
At the HS6 product level (3,201 products), the association is strong:

> slope = −0.019 per tariff point  (t = −16.4,  p < 1e-50)

The signal is not absent at HS2. It is masked by aggregation: each chapter
averages tariffed and untariffed products together, cancelling the effect.
The empirical relationship lives at the resolution at which policy is applied.

*What this means:* coarse-sector analysis of tariff effects will routinely
find nothing, not because tariffs don't matter, but because the measurement
unit is wrong. This is consistent with Amiti, Redding & Weinstein (2019),
who find variety-level effects masked by aggregation.

---

### Finding 2: Retaliation asymmetry (Trump 1)

Chinese retaliation shows a real but weaker association with US export
changes (slope −0.012, t = −4.3). The top 20 HS6 products account for 41%
of all US export value to China — retaliatory capacity was structurally
concentrated, consistent with follower-capacity constraints in the CIFEr
MARL model.

*Two structural predictions from the MARL paper that are consistent with
the data:* (1) tariff pressure maps to disruption at the policy resolution;
(2) retaliatory capacity is asymmetric between leader and follower. We do
not claim the model is validated; we claim these two predictions are not
contradicted by the evidence.

---

### Finding 3: Compositional selection (Trump 2)

Using actual 2025 tariff rates from the WTO Tariff Actions database
(Nov-2025 snapshot, post-Geneva settlement), we run the parallel product-
level regression for 2025:

> Trump 1 (2019): slope = −0.019  (t = −16.4) ***
> Trump 2 (2025): slope = −0.0002 (t = −0.3)  ns

The product-level dose-response observed in 2019 is largely absent in 2025.
The same pattern holds for the retaliation side: China's 2025 retaliation
slope is +0.0017 (t = +1.3, ns) — both sides' relationships have
disappeared.

*The mechanism consistent with this pattern:* between 2018 and 2025,
elastic and substitutable products restructured away from China (via
Vietnam, Taiwan, Mexico). The products remaining in the bilateral
relationship by 2025 are those where substitution was structurally
hardest — an inelastic residual insensitive to further tariff variation.
This is compositional selection, not behavioral change: the slope did not
change because firms adapted their responses to tariffs; it changed because
the population of traded products changed. Economists would call this
survivor bias in the trade relationship.

---

### What we do not claim

- Causality. These are cross-sectional associations at annual frequency.
  A rigorous causal estimate requires monthly data and identification
  around implementation dates (cf. Census Bureau and ARW designs).
- That tariff placement is exogenous. Products were strategically targeted.
- That the MARL model is empirically validated. Two predictions are
  consistent with the data; the broader regime structure is not reproduced.
- That "elasticity fell 99%." The slope is largely absent in 2025.
  The magnitude of that absence depends on tariff-rate matching,
  the 2025 snapshot choice, and annual aggregation.

---

### The clean three-part story for presentation

> **Resolution matters in Trump 1.**
> The tariff effect is invisible at the chapter level and strong at the
> product level — the signal appears only where policy is applied.

> **Selection operates between Trump 1 and Trump 2.**
> The same product-level relationship is largely absent in 2025,
> consistent with seven years of compositional change in bilateral trade.

> **Retaliation was asymmetric throughout.**
> China's retaliatory capacity was structurally concentrated in both
> episodes, consistent with follower-capacity constraints.
