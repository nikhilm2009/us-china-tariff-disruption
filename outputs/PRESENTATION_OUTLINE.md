# Presentation Outline
## When Tariffs Stop Moving Trade
### Wharton Data Science Academy Capstone — Nikhil M.
### 18-slide deck (12 main + 6 appendix)

---

## Narrative arc

```
Setup (slides 1–4)
  → The 2019 model is real and strong. Here's what we're about to test.

Climax (slide 5)
  → We applied it to 2025. Spectacular failure. −84% predicted, −26% actual.

Explanation (slides 6–7)
  → Why Part 1: the slope collapsed entirely.
  → Why Part 2: the dose-response vanished across every tariff level.

Evidence (slides 8–10)
  → Logistic model confirms tariff rate dominates in Trump 1.
  → Simpler model wins. Structure is linear.

Close (slides 11–12)
  → Honest limitations. Four lessons. Research frontier.
```

---

## Main deck

| # | Tag | Title | Figure | Takeaway bar |
|---|-----|-------|--------|--------------|
| 1 | — | When Tariffs Stop Moving Trade | — | — |
| 2 | DATA & PIPELINE | This took serious engineering | Stats grid | Every number is reproducible |
| 3 | RESOLUTION | The signal was hiding in plain sight | fig1_v2 (two-panel) | Aggregation destroyed detectability |
| 4 | TRUMP 1 · 2019 | In 2019, tariffs strongly predicted trade collapse | fig2 + t=−16.4 callout | t=16 is not a noisy student result |
| 5 | PREDICTIVE VALIDATION | Can a Trump 1 model predict 2025? Spectacular failure. | fig10 + 3 stat cards | The model learned Trump 1. The world changed. |
| 6 | EXPLANATION · PART 1 | Why did it fail? The tariff-response relationship disappeared. | fig7 | Slope −0.019→0. Core assumption broke. |
| 7 | EXPLANATION · PART 2 | Why? The dose-response vanished across every tariff level. | figA5 (bucket comparison) | Compositional selection |
| 8 | CLASSIFICATION | What predicts whether a product gets disrupted? | fig11b (S-curve) | Coin-flip at 30%. AUC=0.689 |
| 9 | CLASSIFICATION | What matters most? Tariff rate — by a wide margin. | fig11c (coef plot) | Size protects. Asymmetry adds nothing. |
| 10 | MODEL COMPARISON | More complexity did not improve prediction | fig12 (ROC) | Complexity adds noise |
| 11 | LIMITATIONS | What we do not claim | Text cards | — |
| 12 | — | Four lessons / When Tariffs Stop Moving Trade | — | Trade adapted faster than predicted |

---

## Appendix

| # | Tag | Title | Figure |
|---|-----|-------|--------|
| A1 | APPENDIX A1 | How the Harmonized System works — HS2 vs HS6 | figA1 |
| A2 | APPENDIX A2 | Tariff rate distributions: Trump 1 vs Trump 2 | figA2 |
| A3 | APPENDIX A3 | Data merge flow and match rates | figA3 |
| A4 | APPENDIX A4 | US-China tariff escalation timeline, 2018–2026 | figA4 |
| A5 | APPENDIX A5 | Trump 1 vs Trump 2: dose-response by tariff bucket | figA5 |
| A6 | APPENDIX A6 | Elasticity extension: CEPII ProTEE × dose-response | figA6 |

---

## Slide 12 detail — Four lessons

1. Policy effects live at policy resolution.
   HS6 t=−16.4 invisible at HS2. Signal lives where tariffs applied.

2. Trump 1 tariffs strongly predicted disruption.
   +18% untariffed, −46% heavily tariffed. Logistic AUC=0.689.

3. Those relationships largely disappeared by 2025.
   Elastic products exited disproportionately (t=−6.33, p<0.001).
   But even high-elasticity survivors showed no dose-response.
   Selection explains part, not all, of the attenuation.

4. Simple models explain more than complex ones.
   Logistic (0.677) > RF (0.657) > XGBoost (0.630). Mechanism is linear.

Final sentence: Trade adapted faster than the original tariff model predicted.

---

## Appendix A6 detail — Elasticity extension

Figure: dose-response lines by elasticity tercile, T1 vs T2 panels.
- T1 panel: fan shape — high elasticity steeper than low elasticity
- T2 panel: all lines flat and clustered — uniform attenuation

Stat cards below figure:
- Exited products: σ = −11.6 (more elastic)
- Surviving products: σ = −8.7 (less elastic)
- Difference: t = −6.33, p < 0.001

Punchline: "Selection explains who exited. It does not explain why survivors stopped responding."

---

## Verbal delivery notes

**Slide 4 (t=−16.4):** "A t-statistic of 16 is not a noisy student result.
This is one of the strongest associations in the empirical trade literature
for a cross-sectional regression of this type."

**Slide 5 (failure):** Let the numbers land before explaining.
"The model predicted −84%. The actual was −26%. That's a 58 percentage
point failure. The model learned Trump 1. The world changed. The model broke."

**Slide 7 (buckets):** "No regression. No p-values. Just: did higher tariffs
correspond to bigger declines? In 2019, yes — clear staircase. In 2025, no —
every bucket fell roughly the same amount."

**Slide 12 (lesson 3):** "We now have evidence for the mechanism.
Products that disappeared between 2019 and 2025 were significantly more
elastic. But here's the twist — even among the high-elasticity survivors,
the tariff response was absent. Selection explains part of the story.
Not all of it. That's where the next paper begins."

---

## Build instructions

```bash
# Ensure all figures are in /home/claude/ (or adjust paths in build_deck.js)
# Required figures:
#   fig1.png    ← fig1_resolution_contrast_v2.png
#   fig2.png    ← fig2_hs6_import_effect.png
#   fig7.png    ← fig7_trump1_vs_trump2.png
#   fig10.png   ← fig10_predictive_validation.png
#   fig11b.png  ← fig11b_disruption_prob.png
#   fig11c.png  ← fig11c_logistic_coefficients.png
#   fig12.png   ← fig12_model_comparison.png
#   figA1.png   ← figA1_hs_hierarchy.png
#   figA2.png   ← figA2_tariff_distribution.png (optional)
#   figA3.png   ← figA3_merge_flow.png
#   figA4.png   ← figA4_tariff_timeline.png
#   figA5.png   ← figA5_bucket_comparison.png
#   figA6.png   ← figA6_elasticity_dose_response.png

node build_deck.js
# Output: when_tariffs_stop_moving_trade.pptx
```
