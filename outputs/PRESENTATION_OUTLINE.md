# Presentation Outline (v2)
## When Tariffs Stop Moving Trade: Product-Level Evidence from US-China Trade Conflict

**Wharton DSA Capstone — Nikhil M.**
**Suggested length: 12–15 minutes**

---

### Slide 1 — Title + one-sentence contribution

**Title:** When Tariffs Stop Moving Trade

**One sentence:**
> Trade-policy effects are highly resolution-dependent, and repeated conflict
> appears to change the composition of trade in ways that attenuate later
> tariff responsiveness.

---

### Slide 2 — Data + pipeline

- UN Comtrade: 3,200+ HS6 products, US-China 2015–2025
- Tariff sources: Bown (2021) for Trump 1; WTO Tariff Actions for Trump 2
- Fully reproducible: 19 scripts, renv-locked, match rates documented
- **The data engineering is part of the finding** — resolution analysis required product-level joins that most studies don't attempt

---

### Slide 3 — Finding 1: Resolution matters

**Show Fig 1 (enhanced, two-panel)**

HS2: β ≈ 0, ns. HS6: β = −0.019, t = −16.4, p < 1e-50.

> The signal lives at the level where policy is applied.
> Aggregation hides the relationship because tariffs are applied to products, not chapters.

---

### Slide 4 — Finding 2: The Trump 1 dose-response

**Show Fig 2 — HS6 import effect**

Clean monotonic staircase from +18% (untariffed) to −46% (>25% tariff).
t = −16.4. Not a noisy result — this is screaming signal.

---

### Slide 5 — Finding 3: The relationship collapsed by 2025

**Show Fig 7 — Trump 1 vs Trump 2 slope (with in-panel stats)**

Left: steep blue line, β = −0.019, t = −16.4.
Right: flat red line, β ≈ 0, t = −0.3, ns.

> The model learned Trump 1. The world changed. The model broke.

---

### Slide 6 — The predictive validation

**Show Fig 10 — predictive validation**

Train on Trump 1. Predict 2025 using actual 2025 tariff rates.
Predicted: steep decline at high tariffs.
Actual: flat at −28% regardless of tariff rate.

> Products facing 50–100% tariffs were predicted to fall 84%.
> They actually fell 26%.
> The gap is adaptation.

---

### Slide 7 — What predicts disruption? (logistic)

**Show Fig 11b — disruption probability curve**

At 30% tariff: ~50% probability of large disruption.
AUC = 0.689 with three features.

**Show Fig 11c — coefficient plot**

Tariff rate: strong positive (z = 11.98) ***
Product size: moderate negative (z = −9.38) ***
Trade asymmetry: near zero (z = 0.10) ns

> Larger products are more resilient — consistent with structural inelasticity.

---

### Slide 8 — Is the structure linear? (RF vs logistic)

**Show Fig 12a — ROC comparison**

Logistic AUC = 0.689. Random Forest AUC = 0.649.
RF underperforms despite greater complexity.

> We tested whether additional model complexity helped. It didn't.
> The disruption signal is mostly linear and interpretable.
> Trade disruption appears driven by simple structural relationships,
> not complex nonlinear interactions.

---

### Slide 9 — What we do not claim

- Not causality — cross-sectional associations at annual frequency
- Not exogeneity — tariff placement was strategic
- Not full MARL validation — two structural predictions consistent; regime structure not reproduced
- "Largely absent" not "99% collapse" — magnitude depends on snapshot choice

---

### Slide 10 — Conclusion: four findings

| # | Finding | Figure |
|---|---------|--------|
| 1 | Resolution matters: HS2 hides, HS6 reveals | Fig 1 |
| 2 | Trump 1 shows strong linear dose-response | Fig 2, 11b |
| 3 | Trump 2 relationship collapsed; model fails out-of-sample | Fig 7, 10 |
| 4 | Disruption signal is linear; complexity adds noise | Fig 12a |

> The biggest surprise: we expected more complex models to help.
> They didn't. The structure of trade disruption appears simple —
> and that simplicity is itself a finding.

---

### Appendix

- A1: Retaliation asymmetry (Fig 3, Fig 9)
- A2: Payoff phase diagrams (Fig 5, 6)
- A3: RF feature importance + Gini vs logistic explanation (Fig 12b)
- A4: Full data provenance (DATA_PROVENANCE.md)
- A5: Pipeline diagram (scripts 01–19)
- A6: HS2 null — all eight specifications
- A7: Group A vs B adaptation test
