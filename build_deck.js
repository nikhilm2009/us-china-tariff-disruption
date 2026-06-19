const pptxgen = require("pptxgenjs");
const fs      = require("fs");
const path    = require("path");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.title  = "When Tariffs Stop Moving Trade";
pres.author = "Nikhil M. — Wharton DSA Capstone";

// ── Figure map ───────────────────────────────────────────────
const FIG_DIR = process.env.FIG_DIR || path.join(__dirname, "figures");
const FIGS = {
  fig1:   "fig1_resolution_contrast_v2.png",
  fig2:   "fig2_hs6_import_effect.png",
  fig10:  "fig10_predictive_validation.png",
  fig13:  "fig13_inrange_validation.png",
  figA5:  "figA5_bucket_comparison.png",       // slide 7 + A5
  figA6:  "figA6_elasticity_dose_response.png", // slide 8 + A6
  fig15:  "fig15_diversion_by_country.png",    // slide 9 + A7
  fig7:   "fig7_trump1_vs_trump2.png",          // A8 only
  fig11b: "fig11b_disruption_prob.png",         // A9 only
  fig11c: "fig11c_logistic_coefficients.png",   // A10 only
  fig12:  "fig12_model_comparison.png",         // A11 only
  figA1:  "figA1_hs_hierarchy.png",
  figA2:  "figA2_tariff_distribution.png",
  figA3:  "figA3_merge_flow.png",
  figA4:  "figA4_tariff_timeline.png",
};
const fp  = k => path.join(FIG_DIR, FIGS[k]);
const fex = k => fs.existsSync(fp(k));

(function check(){
  if(!fs.existsSync(FIG_DIR)){
    console.error("ERROR: figures/ not found: "+FIG_DIR); process.exit(1);
  }
  const optional = new Set(["figA2"]);
  const missing  = Object.keys(FIGS).filter(k=>!optional.has(k)&&!fex(k));
  if(missing.length){
    console.error("ERROR: missing figures:");
    missing.forEach(k=>console.error("  "+FIGS[k]+" ("+k+")"));
    process.exit(1);
  }
  if(!fex("figA2")) console.warn("NOTE: figA2 missing — appendix A2 will be a placeholder.");
})();

// ── Palette ──────────────────────────────────────────────────
const NAVY     = "1E2761";
const SLATE    = "2C3E6B";
const STEEL    = "4A6FA5";
const MIST     = "E8EEF4";
const OFFWHT   = "F7F9FC";
const WHITE    = "FFFFFF";
const CHARCOAL = "333333";
const MIDGRAY  = "666666";
const LTGRAY   = "EEEEEE";
const RED      = "B03A2E";
const TAUPE    = "F0F2F0";
const BLACK    = "111111";
const F        = "Calibri";

// ── Helpers ──────────────────────────────────────────────────
function bg(s)  { s.addShape(pres.ShapeType.rect,{x:0,y:0,w:"100%",h:"100%",fill:{color:OFFWHT}}); }
function wbg(s) { s.addShape(pres.ShapeType.rect,{x:0,y:0,w:"100%",h:"100%",fill:{color:WHITE}}); }

function tag(s,t,w=2.1){
  s.addShape(pres.ShapeType.rect,{x:0.4,y:0.22,w,h:0.27,fill:{color:MIST},line:{color:STEEL,width:0.75}});
  s.addText(t,{x:0.4,y:0.22,w,h:0.27,fontSize:8.5,color:SLATE,bold:true,
    align:"center",valign:"middle",fontFace:F,margin:0});
}
function ttl(s,t,sz=24){
  s.addText(t,{x:0.4,y:0.62,w:9.2,h:0.72,fontSize:sz,color:NAVY,bold:true,fontFace:F});
}
function bar(s,t){
  s.addShape(pres.ShapeType.rect,{x:0,y:5.05,w:"100%",h:0.575,fill:{color:TAUPE}});
  s.addShape(pres.ShapeType.line,{x:0,y:5.05,w:"100%",h:0,line:{color:STEEL,width:1}});
  s.addText(t,{x:0.4,y:5.05,w:9.2,h:0.575,fontSize:12,color:BLACK,
    bold:false,valign:"middle",fontFace:F,italic:true});
}
function appTag(s,n,title){
  s.addShape(pres.ShapeType.rect,{x:0,y:0,w:"100%",h:0.4,fill:{color:MIST}});
  s.addShape(pres.ShapeType.line,{x:0,y:0.4,w:"100%",h:0,line:{color:STEEL,width:0.5}});
  s.addText("APPENDIX "+n+"  ·  "+title,{x:0.4,y:0,w:9.2,h:0.4,
    fontSize:10.5,color:SLATE,bold:true,valign:"middle",fontFace:F});
}
function appBar(s,t){
  s.addShape(pres.ShapeType.rect,{x:0,y:5.28,w:"100%",h:0.32,fill:{color:MIST}});
  s.addText(t,{x:0.4,y:5.28,w:9.2,h:0.32,fontSize:10.5,color:SLATE,
    bold:true,italic:true,valign:"middle",fontFace:F});
}
function note(s,t){ s.addNotes(t); }

// ═══════════════════════════════════════════════════════════
// SLIDE 1 — TITLE
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); bg(s);
s.addShape(pres.ShapeType.rect,{x:0,y:0,w:0.12,h:"100%",fill:{color:STEEL}});
s.addShape(pres.ShapeType.line,{x:0.5,y:3.72,w:3.5,h:0,line:{color:STEEL,width:1.5}});
s.addText("WHARTON DATA SCIENCE ACADEMY  ·  CAPSTONE 2026",  // FIX: was 2025
  {x:0.5,y:0.48,w:9,h:0.28,fontSize:8.5,color:MIDGRAY,bold:true,charSpacing:2.5,fontFace:F});
s.addText("When Tariffs Stop\nMoving Trade",
  {x:0.5,y:0.88,w:9,h:1.95,fontSize:46,color:NAVY,bold:true,fontFace:F});
s.addText("A predictive test of tariff effectiveness across two US–China trade-war episodes",
  {x:0.5,y:2.9,w:8.2,h:0.55,fontSize:15,color:CHARCOAL,fontFace:F});
s.addText("Nikhil M.",{x:0.5,y:3.88,w:5,h:0.32,fontSize:13,color:NAVY,bold:true,fontFace:F});
s.addText("Data: UN Comtrade · Bown (2021) · WTO Tariff Actions · USITC DataWeb",
  {x:0.5,y:4.25,w:8,h:0.28,fontSize:10,color:MIDGRAY,fontFace:F});
note(s,"Good [morning/afternoon]. I want to start with a prediction — and a prediction failure. The 2019 US-China trade war produced one of the cleanest natural experiments in recent economic history. Tariffs were large, targeted, and applied at a granular product level. I trained a model on that episode. Then I asked: what would that model predict for 2025, when tariffs came back — broader and more severe? For the most heavily tariffed products, the model predicted an 84 percent import decline from China. The actual decline was 26 percent. That is a 58 percentage-point gap. Tonight I want to walk you through why the model failed — and why that failure is the most interesting finding in this project.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 2 — ENGINEERING
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); wbg(s);
tag(s,"DATA & PIPELINE");
ttl(s,"This took serious engineering");
const stats=[
  {n:"3",     unit:"data sources",    sub:"Comtrade · Bown\nWTO · USITC"},
  {n:"3,201", unit:"products (2019)", sub:"HS6 subheadings\nTrump 1 analysis"},
  {n:"3,164", unit:"products (2025)", sub:"HS6 subheadings\nTrump 2 analysis"},
  {n:"100%",  unit:"match rate",      sub:"tariff-to-product\nboth episodes"},
  {n:"27",    unit:"scripts",         sub:"fully reproducible\nrenv-locked"},
];
stats.forEach((st,i)=>{
  const x=0.35+i*1.9;
  s.addShape(pres.ShapeType.rect,{x,y:1.35,w:1.75,h:2.5,
    fill:{color:OFFWHT},line:{color:LTGRAY,width:0.75},rectRadius:0.05});
  s.addText(st.n,{x,y:1.45,w:1.75,h:0.85,fontSize:30,color:STEEL,bold:true,align:"center",fontFace:F});
  s.addText(st.unit,{x,y:2.28,w:1.75,h:0.32,fontSize:11,color:NAVY,bold:true,align:"center",fontFace:F});
  s.addText(st.sub,{x,y:2.62,w:1.75,h:0.65,fontSize:9.5,color:CHARCOAL,
    align:"center",lineSpacingMultiple:1.3,fontFace:F});
});
s.addText("Sources: UN Comtrade API  ·  Bown (2021) HS6 tariffs  ·  WTO Tariff Actions Nov-2025  ·  USITC DataWeb",
  {x:0.4,y:4.05,w:9.2,h:0.28,fontSize:9.5,color:MIDGRAY,align:"center",fontFace:F});
bar(s,"Three independent sources · 100% primary match rate · every number is reproducible.");
note(s,"Before the findings, a word on the data — because this kind of analysis stands or falls on the engineering behind it. Four independent sources: UN Comtrade for the actual trade flows, Chad Bown's Section 301 database for product-level tariff rates in 2019, WTO Tariff Actions for 2025 rates, and USITC DataWeb for Taiwan since UN Comtrade suppresses US-Taiwan bilateral data. The analysis covers 3,201 HS6 product subheadings in 2019 and 3,164 in 2025. Primary tariff-to-trade match rate: 100 percent for both episodes — every product has an exactly matched tariff rate, no imputation. Twenty-seven fully reproducible R scripts, locked with renv. Every number you see tonight can be regenerated from scratch from public data sources.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 3 — RESOLUTION
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); wbg(s);
tag(s,"RESOLUTION");
ttl(s,"Why did earlier studies miss the signal?");
s.addImage({path:fp("fig1"),x:0.3,y:1.22,w:7.2,h:3.75});
s.addShape(pres.ShapeType.rect,{x:7.65,y:1.5,w:2.0,h:1.6,
  fill:{color:MIST},line:{color:STEEL,width:0.75},rectRadius:0.05});
s.addText("Same trade war.\nSame tariffs.\nDifferent\nresolution.",
  {x:7.65,y:1.55,w:2.0,h:1.5,fontSize:13,color:NAVY,bold:true,
    align:"center",valign:"middle",fontFace:F,lineSpacingMultiple:1.35});
s.addShape(pres.ShapeType.rect,{x:7.65,y:3.3,w:2.0,h:1.55,
  fill:{color:OFFWHT},line:{color:LTGRAY,width:0.75},rectRadius:0.05});
s.addText("HS2 chapters (n=97)",
  {x:7.65,y:3.38,w:2.0,h:0.35,fontSize:10,color:RED,bold:true,align:"center",fontFace:F});
s.addText("signal invisible",
  {x:7.65,y:3.73,w:2.0,h:0.28,fontSize:10,color:MIDGRAY,align:"center",fontFace:F,italic:true});
s.addShape(pres.ShapeType.line,{x:7.85,y:4.05,w:1.6,h:0,line:{color:LTGRAY,width:0.5}});
s.addText("HS6 products (n=3,201)",
  {x:7.65,y:4.1,w:2.0,h:0.35,fontSize:10,color:STEEL,bold:true,align:"center",fontFace:F});
s.addText("signal strong",
  {x:7.65,y:4.48,w:2.0,h:0.28,fontSize:10,color:MIDGRAY,align:"center",fontFace:F,italic:true});
bar(s,"Much of the signal is lost when products are aggregated into broad chapters.");
note(s,"Here is a methodological finding that matters a great deal for the literature. Same trade war, same tariffs, same data — at two levels of granularity. The blue line is the HS6 relationship: 3,201 individual product subheadings, one dot per product. The negative slope is unmistakable — t-statistic of minus 16.4, p less than ten to the minus fifty. Now look at the red scatter: the same data aggregated to 97 HS2 chapters. The slope disappears entirely. t of minus 0.8, not significant. Why? Because each chapter mixes tariffed and untariffed products together. Chapter 84 — Machinery — contains products taxed at 0%, 7.5%, 15%, and 25% under Section 301 simultaneously. Averaging them into a single data point erases all variation. The signal lives exactly where the policy is applied: HS6. Earlier studies working at chapter-level were not finding a null effect. They were looking at the wrong resolution.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 4 — TRUMP 1
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); wbg(s);
tag(s,"TRUMP 1 · 2019");
ttl(s,"Was there really a tariff effect?");
s.addImage({path:fp("fig2"),x:0.3,y:1.22,w:6.5,h:3.75});
s.addShape(pres.ShapeType.rect,{x:7.0,y:1.22,w:2.6,h:1.6,
  fill:{color:MIST},line:{color:STEEL,width:1},rectRadius:0.05});
s.addText("t = −16.4",{x:7.0,y:1.3,w:2.6,h:0.78,
  fontSize:26,color:NAVY,bold:true,align:"center",fontFace:F});
s.addText("Strongest signal\nin the study",
  {x:7.0,y:2.08,w:2.6,h:0.65,fontSize:10.5,color:SLATE,align:"center",fontFace:F});
s.addShape(pres.ShapeType.rect,{x:7.0,y:3.0,w:2.6,h:1.97,
  fill:{color:OFFWHT},line:{color:LTGRAY,width:0.75},rectRadius:0.05});
s.addText("64pp spread",
  {x:7.0,y:3.08,w:2.6,h:0.55,fontSize:20,color:NAVY,bold:true,align:"center",fontFace:F});
s.addShape(pres.ShapeType.line,{x:7.15,y:3.68,w:2.3,h:0,line:{color:LTGRAY,width:0.5}});
s.addText("+18%  untariffed",
  {x:7.05,y:3.75,w:2.5,h:0.28,fontSize:10.5,color:STEEL,bold:true,fontFace:F});
s.addText("−46%  highest tariff",
  {x:7.05,y:4.05,w:2.5,h:0.28,fontSize:10.5,color:RED,bold:true,fontFace:F});
s.addText("across tariff distribution",
  {x:7.05,y:4.4,w:2.5,h:0.4,fontSize:9,color:MIDGRAY,fontFace:F,italic:true});
bar(s,"Yes. At the product level, the 2019 relationship is unmistakable.");
note(s,"At the product level, the 2019 relationship is unmistakable. The slope is minus 0.019 per tariff percentage point — meaning every additional percentage point of tariff was associated with a 1.9 percentage point reduction in imports relative to the pre-tariff baseline. Products with zero tariff actually grew about 18 percent above their 2015-to-2017 baseline — consistent with trade diversion into untariffed categories as buyers shifted sourcing. Products above the 25 percent threshold fell 46 percent on average. That is a 64 percentage-point spread from top to bottom of the tariff distribution. The confidence band around the regression line is tight. The t-statistic of minus 16.4 means this is not a marginal finding — it is among the strongest signals in cross-sectional trade economics. This is the relationship we will now test forward in time.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 5 — PREDICTIVE FAILURE
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); bg(s);
tag(s,"PREDICTIVE VALIDATION",2.6);
ttl(s,"Could the effect predict the future?");
s.addImage({path:fp("fig10"),x:0.3,y:1.22,w:7.0,h:3.75});
const cards=[
  {val:"−84%", lbl:"model predicted\n>50% tariff products", vc:NAVY, bc:NAVY},
  {val:"−26%", lbl:"actual decline\n(same products)",        vc:RED,  bc:RED},
  {val:"+58pp",lbl:"prediction gap\n= adaptation",           vc:STEEL,bc:STEEL},
];
cards.forEach((c,i)=>{
  const y=1.3+i*1.27;
  s.addShape(pres.ShapeType.rect,{x:7.45,y,w:2.2,h:1.15,
    fill:{color:WHITE},line:{color:c.bc,width:1.5},rectRadius:0.05});
  s.addText(c.val,{x:7.45,y:y+0.06,w:2.2,h:0.62,
    fontSize:34,color:c.vc,bold:true,align:"center",fontFace:F});
  s.addText(c.lbl,{x:7.45,y:y+0.67,w:2.2,h:0.42,
    fontSize:9.5,color:CHARCOAL,align:"center",lineSpacingMultiple:1.1,fontFace:F});
});
bar(s,"The model learned Trump 1. The world changed. The model broke.");
note(s,"Here is the prediction test. The dashed blue line is the Trump 1 model applied out-of-sample to 3,164 products at their actual 2025 tariff rates. It slopes steeply downward because 2025 tariffs average around 50 percent — far into the model's negative range. The solid red line is what actually happened: essentially flat at minus 26 percent regardless of tariff level. For products facing the highest tariffs, the model predicted minus 84 percent. The actual was minus 26 percent. A 58 percentage-point gap.\n\n[Pause.]\n\nNow — the natural objection is that we extrapolated the model far outside its training range. 2025 tariffs hit 50, 70, even 100 percent, while the Trump 1 model was trained on rates between 0 and 40 percent. Is the gap just a linear extrapolation artifact? That is exactly what we test on the next slide.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 6 — IN-RANGE VALIDATION
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); bg(s);
tag(s,"ROBUSTNESS CHECK",2.0);
ttl(s,"Is the gap just extrapolation? No.");
s.addImage({path:fp("fig13"),x:0.3,y:1.22,w:7.0,h:3.75});
const rcards=[
  {val:"9.8pp",  lbl:"gap for in-range\nproducts (≤45%)",   vc:NAVY, bc:NAVY},
  {val:"47.9pp", lbl:"gap for out-of-range\nproducts (>45%)",vc:RED,  bc:RED},
  {val:"t=0.76", lbl:"in-range T2 slope\nnot significant",   vc:STEEL,bc:STEEL},
];
rcards.forEach((c,i)=>{
  const y=1.3+i*1.27;
  s.addShape(pres.ShapeType.rect,{x:7.45,y,w:2.2,h:1.15,
    fill:{color:WHITE},line:{color:c.bc,width:1.5},rectRadius:0.05});
  s.addText(c.val,{x:7.45,y:y+0.06,w:2.2,h:0.62,
    fontSize:28,color:c.vc,bold:true,align:"center",fontFace:F});
  s.addText(c.lbl,{x:7.45,y:y+0.67,w:2.2,h:0.42,
    fontSize:9.5,color:CHARCOAL,align:"center",lineSpacingMultiple:1.1,fontFace:F});
});
bar(s,"Extrapolation inflates the gap. It does not create it. The dose-response is absent even within the trained range.");
note(s,"We test the extrapolation concern directly by splitting the 2025 sample into two groups. Left panel: the 2,019 products whose 2025 tariff rates fall inside the Trump 1 training window — 45 percent or below. Right panel: the 1,145 products above 45 percent. Look at the two red regression lines. Both are essentially flat. The in-range actual slope is 0.0007 — t of 0.76, not significant. The prediction gap for in-range products is 9.8 percentage points. For out-of-range products it is 47.9 points. So extrapolation explains the magnitude difference between the panels — the 38-point gap between 9.8 and 47.9 is attributable to out-of-distribution prediction — but it does not explain why the slope itself is zero. Even where the model had direct training experience, even where tariff rates fell inside its training window, the dose-response relationship was gone. The functional form itself broke. The world changed between 2019 and 2025.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 7 — BUCKET TABLE
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); wbg(s);
tag(s,"EXPLANATION",1.6);
ttl(s,"What changed?");
s.addImage({path:fp("figA5"),x:0.3,y:1.22,w:9.4,h:3.75});
bar(s,"No model. No p-values. The dose-response simply vanished.");
note(s,"I want to make this point without any model at all — no regression, no p-values, no distributional assumptions. Just a direct nonparametric question: do higher tariffs still correspond to bigger import declines? Left panel, 2019: yes — unambiguously. Untariffed products grew 18 percent above baseline. Partial tariff, 1 to 10 percent: plus 6 percent. Heavy tariff, 11 to 25 percent: minus 1 percent. Maximum tariff, above 25 percent: minus 23 percent. A clean monotonic staircase — every step down is larger than the one before. Right panel, 2025: every single tariff bucket falls between minus 27 and minus 30 percent. Low tariff: minus 30. Medium: minus 30. High: minus 27. Very high above 50 percent: minus 30. No staircase. No gradient. The variance across tariff buckets in 2025 is smaller than the measurement uncertainty within any single bucket in 2019. The dose-response simply vanished.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 8 — ELASTICITY (promoted from appendix)
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); wbg(s);
tag(s,"SELECTION",1.5);
ttl(s,"Who adapted? The most elastic products exited first.");
s.addImage({path:fp("figA6"),x:0.3,y:1.22,w:9.4,h:2.7});
[{lbl:"Exited products",    val:"σ = −11.6",sub:"more elastic"},
 {lbl:"Surviving products", val:"σ = −8.7", sub:"less elastic"},
 {lbl:"Difference",         val:"t = −6.33",sub:"p < 0.001"}].forEach((e,i)=>{
  const x=0.5+i*3.1;
  s.addShape(pres.ShapeType.rect,{x,y:4.0,w:2.85,h:0.92,
    fill:{color:OFFWHT},line:{color:LTGRAY,width:0.75},rectRadius:0.04});
  s.addText(e.lbl,{x,y:4.04,w:2.85,h:0.24,fontSize:9.5,color:MIDGRAY,align:"center",bold:true,fontFace:F});
  s.addText(e.val,{x,y:4.26,w:2.85,h:0.38,fontSize:17,color:NAVY,align:"center",bold:true,fontFace:F});
  s.addText(e.sub,{x,y:4.62,w:2.85,h:0.22,fontSize:9,color:CHARCOAL,align:"center",italic:true,fontFace:F});
});
bar(s,"Selection explains who exited. It does not explain why survivors stopped responding.");
note(s,"So why did the relationship disappear? Part of the answer lies in selection — in which products exited the market entirely. The CEPII ProTEE dataset provides own-price import demand elasticities for each product: sigma values that measure how responsive import volume is to price changes. A larger absolute sigma means the product's import demand is more price-sensitive. Products that completely exited US-China trade by 2025 had a mean elasticity of minus 11.6. Products still actively trading in 2025 had minus 8.7. The difference is highly significant: t of minus 6.33, p less than 0.001. The most price-sensitive products left first — firms found alternatives in Vietnam, Mexico, Taiwan, or domestic production and redirected their sourcing. This is exactly what selection theory predicts. But here is the critical part. Look at the right panel. Among the surviving products — even the high-elasticity survivors in the red line — the 2025 slope is essentially zero. All three elasticity groups converge near flat. Selection explains who exited. It does not explain why those who stayed stopped responding to tariff variation.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 9 — TRADE DIVERSION
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); wbg(s);
tag(s,"TRADE DIVERSION",2.0);
ttl(s,"Where did the trade go?");
s.addImage({path:fp("fig15"),x:0.3,y:1.22,w:9.4,h:2.9});
// 14.5¢ hero box
s.addShape(pres.ShapeType.rect,{x:0.3,y:4.2,w:9.4,h:0.75,
  fill:{color:MIST},line:{color:STEEL,width:0.75},rectRadius:0.05});
s.addText("~14.5 cents on the dollar",
  {x:0.3,y:4.22,w:4.8,h:0.72,fontSize:28,color:NAVY,bold:true,
    align:"center",valign:"middle",fontFace:F});
s.addShape(pres.ShapeType.line,{x:5.15,y:4.25,w:0,h:0.65,line:{color:STEEL,width:0.75}});
s.addText("captured by Vietnam, Mexico + Taiwan",
  {x:5.25,y:4.27,w:4.35,h:0.3,fontSize:12,color:CHARCOAL,fontFace:F});
s.addText("The remaining ~85.5 cents: demand destruction, reshoring, other diversion",
  {x:5.25,y:4.57,w:4.35,h:0.28,fontSize:10,color:MIDGRAY,fontFace:F,italic:true});
bar(s,"Diversion is real. It is also partial. Why did 85 cents disappear?");
note(s,"Where did the trade go? For each HS6 product, the x-axis shows how much China lost during the Trump 1 shock in 2019 relative to the 2015-to-2017 baseline. The y-axis shows how much imports from the third country rose by 2025 relative to the 2022-to-2024 baseline. The 6-year gap is intentional — supply-chain restructuring takes years, not months. A positive slope means products hurt most by Trump 1 tariffs are the same products that third countries gained most by 2025 — the signature of tariff-driven diversion.\n\nAll three destinations show statistically significant positive slopes. Vietnam: slope 0.236, t 3.27 — broad manufacturing relocation across categories. Taiwan: slope 0.211, t 5.55 — the tightest, most statistically reliable channel, consistent with Taiwan's role as the primary alternative source for semiconductor and electronics supply chains, the exact HS chapters 84 and 85 hit hardest by Trump 1 tariffs. Mexico: slope 0.077, t 2.10 — a weaker marginal effect, consistent with USMCA already providing preferential access before the tariffs.\n\nTogether, the three destinations captured approximately 14.5 cents of each dollar China lost. The remaining 85.5 cents is unaccounted — trade destruction, reshoring to US domestic production, or diversion to countries not in our sample. Diversion is real and statistically clear. It is also partial. The 85 cents is the next paper.");}

// ═══════════════════════════════════════════════════════════
// SLIDE 10 — FOUR LESSONS
// ═══════════════════════════════════════════════════════════
{const s=pres.addSlide(); bg(s);
s.addText("Four lessons",{x:0.5,y:0.28,w:9,h:0.3,
  fontSize:10,color:MIDGRAY,bold:true,charSpacing:3,fontFace:F});
s.addText("When Tariffs Stop Moving Trade",{x:0.5,y:0.6,w:9,h:0.65,
  fontSize:26,color:NAVY,bold:true,fontFace:F});
s.addShape(pres.ShapeType.line,{x:0.5,y:1.3,w:9,h:0,line:{color:STEEL,width:0.75}});
[{num:"1",head:"Resolution matters.",
  body:"The HS6 relationship (t = −16.4) was invisible at HS2. The signal lives where tariffs are applied."},
 {num:"2",head:"Tariffs predicted disruption in 2019.",
  body:"+18% untariffed, −46% heavily tariffed. A logistic model predicts disruption with AUC 0.677."},  // FIX: was 0.689
 {num:"3",head:"The relationship disappeared by 2025.",
  body:"Elastic products exited disproportionately (t = −6.33, p < 0.001). Even among survivors, dose-response was absent."},
 {num:"4",head:"The dose-response attenuated 6×.",
  body:"A 50pp tariff increase bought ~95pp of import reduction in 2019. In 2025, the same increase bought ~15pp."},
].forEach((l,i)=>{
  const y=1.42+i*0.78;
  s.addShape(pres.ShapeType.ellipse,{x:0.5,y:y+0.08,w:0.36,h:0.36,fill:{color:STEEL},line:{color:STEEL}});
  s.addText(l.num,{x:0.5,y:y+0.08,w:0.36,h:0.36,
    fontSize:12,color:WHITE,bold:true,align:"center",valign:"middle",fontFace:F,margin:0});
  s.addText(l.head,{x:1.02,y:y+0.04,w:8.5,h:0.28,fontSize:12.5,color:NAVY,bold:true,fontFace:F});
  s.addText(l.body,{x:1.02,y:y+0.32,w:8.5,h:0.36,fontSize:10.5,color:CHARCOAL,fontFace:F});
});
// Closing beat — open question
s.addShape(pres.ShapeType.rect,{x:0.5,y:4.56,w:9.1,h:0.42,
  fill:{color:MIST},line:{color:STEEL,width:0.75},rectRadius:0.04});
s.addText("Vietnam, Mexico + Taiwan captured ~14.5 cents of each dollar China lost.  Why did ~85 cents disappear?  That is the next paper.",
  {x:0.6,y:4.56,w:9.0,h:0.42,fontSize:11,color:SLATE,italic:true,valign:"middle",fontFace:F});
// Caveats in footer bar
bar(s,"Caveats: product-level outcomes only  ·  elasticity coverage ~85%  ·  cross-sectional, not causal");
note(s,"Four findings to take away. First: resolution matters. The HS6 tariff-trade relationship — t of minus 16.4 — was completely invisible at the HS2 chapter level. The signal lives exactly where policy is applied. Second: in 2019, tariffs worked. Products with no tariff grew 18 percent. Products at maximum tariff fell 46 percent. A logistic disruption model achieves an AUC of 0.677 on a held-out test set — real predictive signal, not a noise result. Third: by 2025, the mechanism had disappeared. Elastic products exited disproportionately — t of minus 6.33 — and even across every elasticity group of surviving products, tariff intensity no longer predicted outcomes. Fourth, and most precisely: the dose-response did not just weaken — it attenuated six-fold. A 50 percentage-point tariff increase bought roughly 95 percentage points of import reduction in 2019. In 2025, the same 50 points bought approximately 15 points.\n\n[Pause.]\n\nVietnam, Mexico, and Taiwan together captured 14.5 cents of each dollar China lost. The remaining 85 cents is unaccounted. The 14 cents tells us that supply chains do restructure, selectively, along the product lines where alternatives exist. The 85 cents tells us we do not yet fully understand what happened to the rest. That is the next paper.");}

// ══════════════════════════════════════════════════════════
// APPENDIX DIVIDER
// ══════════════════════════════════════════════════════════
{const s=pres.addSlide();
// Full NAVY background — mirrors title slide treatment
s.addShape(pres.ShapeType.rect,{x:0,y:0,w:"100%",h:"100%",fill:{color:NAVY}});
// Left accent bar — matches title slide
s.addShape(pres.ShapeType.rect,{x:0,y:0,w:0.12,h:"100%",fill:{color:STEEL}});
// Horizontal rule
s.addShape(pres.ShapeType.line,{x:0.5,y:3.05,w:9.0,h:0,line:{color:STEEL,width:1.5}});
// Main label
s.addText("APPENDIX",{x:0.5,y:1.5,w:9.0,h:1.2,
  fontSize:56,color:WHITE,bold:true,align:"center",valign:"middle",fontFace:F});
// Slide range
s.addText("Backup slides  ·  A1 – A11",{x:0.5,y:3.2,w:9.0,h:0.38,
  fontSize:14,color:MIST,align:"center",fontFace:F});
// Contents index
s.addText(
  "A1 HS system  ·  A2 Tariff distributions  ·  A3 Merge flow  ·  A4 Timeline  ·  A5 Bucket table  ·  A6 Elasticity  ·  A7 Diversion  ·  A8 Slope comparison  ·  A9–A10 Classification  ·  A11 ML comparison",
  {x:0.5,y:3.72,w:9.0,h:0.62,fontSize:9.5,color:STEEL,
    align:"center",lineSpacingMultiple:1.4,fontFace:F});
note(s,"This marks the end of the main presentation. The findings are complete. Appendix slides A1 through A11 are available for judge questions on data sources, methodology, and supporting analyses. Key backup slides to know: A5 is the nonparametric bucket table — no regression assumptions required. A7 is the full three-country diversion detail with per-country t-statistics. A8 is the side-by-side slope comparison showing the mechanism collapse directly. A9 and A10 cover the classification model if asked about prediction in 2019.");}

// ══════════════════════════════════════════════════════════
// APPENDIX — SLIDES A1–A11
// ══════════════════════════════════════════════════════════

// A1 — HS HIERARCHY
{const s=pres.addSlide();wbg(s);
appTag(s,"A1","How the Harmonized System works — HS2 vs HS6");
s.addImage({path:fp("figA1"),x:0.5,y:0.48,w:9.0,h:4.92});
note(s,"Background for anyone unfamiliar with the Harmonized System, the international product classification standard used by 200 countries. HS2 gives 97 broad chapters — Chapter 84 covers all machinery, Chapter 85 all electronics. HS4 gives roughly 1,200 headings. HS6 gives over 5,000 subheadings — laptops as a distinct product from tablets, pure-bred horses distinct from other horses. Tariffs under both Trump 1 and Trump 2 were applied at the HS6 level, not the chapter level. Chapter 84 contained products simultaneously taxed at 0%, 7.5%, 15%, and 25% under Section 301. Averaging all of them into a single HS2 data point destroys the variation entirely — which is why earlier chapter-level studies found no effect. Our entire analysis is built at HS6: 3,201 subheadings in 2019 and 3,164 in 2025, the granularity where the policy actually lives and where the signal is recoverable.");}

// A2 — TARIFF DISTRIBUTIONS
{const s=pres.addSlide();wbg(s);
appTag(s,"A2","Tariff rate distributions: Trump 1 vs Trump 2");
if(fex("figA2")){
  s.addImage({path:fp("figA2"),x:0.3,y:0.48,w:9.4,h:4.92});
} else {
  s.addShape(pres.ShapeType.rect,{x:0.5,y:1.0,w:9.0,h:3.5,fill:{color:OFFWHT},line:{color:LTGRAY}});
  s.addText("Run scripts/21_appendix_methods.R then re-run node build_deck.js",
    {x:0.5,y:2.4,w:9.0,h:0.6,fontSize:12,color:MIDGRAY,align:"center",italic:true,fontFace:F});
}
note(s,"The two distributions look architecturally different, which is itself substantively important. Trump 1 tariffs under Section 301 came in three discrete tranches — 0%, 7.5%, 15%, and 25% — producing the characteristic discrete spikes. Median rate: 25%. Trump 2 is a broad, near-continuous distribution reflecting the stacking of residual Section 301 carry-over rates on top of universal IEEPA tariffs applied across all Chinese goods. Median rate: 41.1%. Products above 100% — primarily electric vehicles and solar panels under separate targeted actions — are excluded from the chart for readability but included in all regressions. These are genuinely different policy architectures. Trump 1 was a targeted list-based escalation. Trump 2 layered a universal floor on top. That structural difference matters for how supply chains could realistically respond.");}

// A3 — MERGE FLOW
{const s=pres.addSlide();wbg(s);
appTag(s,"A3","Data merge flow and match rates");
s.addImage({path:fp("figA3"),x:0.5,y:0.48,w:9.0,h:4.92});
note(s,"The pipeline merges three independent sources, and the technical details matter for reproducibility. UN Comtrade provides annual bilateral HS6 trade flows for US-China from 2015 through 2025, approximately 78,000 rows after filtering to HS6 aggregation level. The Bown Section 301 database provides product-level tariff rates for Trump 1 at HS6, covering 5,309 codes. WTO Tariff Actions provides the November 2025 snapshot for Trump 2 rates, covering 5,612 codes for both US-on-China and China-on-US directions. The critical technical step is zero-padding all HS codes to exactly six characters before joining — a formatting inconsistency that would silently drop products without it. Both primary tariff-to-trade merges achieve 100 percent match rates. The retaliation merge for China-on-US tariffs achieves 94.3 percent for Trump 1 — the 5.7 percent gap consists of products in our trade sample that were never included in any Chinese retaliation schedule, not a data quality issue.");}

// A4 — TIMELINE
{const s=pres.addSlide();wbg(s);
appTag(s,"A4","US-China tariff escalation timeline, 2018–2026");
s.addImage({path:fp("figA4"),x:0.1,y:0.48,w:9.8,h:4.92});
note(s,"This timeline puts both episodes in comparative context. The blue window marks our Trump 1 analysis: trade outcomes measured in 2019 against a 2015-to-2017 pre-tariff baseline, capturing the first full year of Section 301 enforcement at scale. The red window marks Trump 2: outcomes measured in 2025 against a 2022-to-2024 baseline, deliberately chosen to exclude the COVID disruption years of 2020 and 2021. For Trump 2 tariff rates, we use the November 2025 WTO snapshot — after the Geneva talks partial rollback from the April Liberation Day peak and after the new IEEPA-plus-Section-301 rate structure had stabilized. Using an earlier snapshot during rapid escalation would capture transition dynamics rather than equilibrium responses. The SCOTUS IEEPA ruling in February 2026 is post-sample and not reflected in the analysis.");}

// A5 — BUCKET TABLE (full-page backup)
{const s=pres.addSlide();wbg(s);
appTag(s,"A5","Trump 1 vs Trump 2: dose-response by tariff bucket");
s.addImage({path:fp("figA5"),x:0.3,y:0.48,w:9.4,h:4.92});
note(s,"This is the full-resolution backup of the bucket table. No regression assumptions required — this is purely nonparametric. The 2019 staircase is unambiguous: 18 percent growth for untariffed products, declining monotonically through 6%, minus 1%, to minus 23% at the maximum tariff bucket. Each step is statistically and economically meaningful. The 2025 panel is equally unambiguous in the other direction: all four tariff buckets fall between minus 27 and minus 30 percent. The variance across tariff buckets in 2025 is smaller than the measurement uncertainty within any individual bucket in 2019. If a reviewer challenges the regression results for any reason — omitted variable bias, functional form assumptions, winsorization choices — this slide requires none of those assumptions. The dose-response collapse is visible to the naked eye.");}

// A6 — ELASTICITY (full detail)
{const s=pres.addSlide();wbg(s);
appTag(s,"A6","Elasticity extension: CEPII ProTEE × tariff dose-response");
s.addImage({path:fp("figA6"),x:0.3,y:0.48,w:9.4,h:3.6});
[{lbl:"Exited products",    val:"σ = −11.6",sub:"more elastic"},
 {lbl:"Surviving products", val:"σ = −8.7", sub:"less elastic"},
 {lbl:"Difference",         val:"t = −6.33",sub:"p < 0.001"}].forEach((e,i)=>{
  const x=0.5+i*3.1;
  s.addShape(pres.ShapeType.rect,{x,y:4.18,w:2.85,h:1.0,
    fill:{color:OFFWHT},line:{color:LTGRAY,width:0.75},rectRadius:0.04});
  s.addText(e.lbl,{x,y:4.22,w:2.85,h:0.28,fontSize:9.5,color:MIDGRAY,align:"center",bold:true,fontFace:F});
  s.addText(e.val,{x,y:4.48,w:2.85,h:0.38,fontSize:17,color:NAVY,align:"center",bold:true,fontFace:F});
  s.addText(e.sub,{x,y:4.84,w:2.85,h:0.25,fontSize:9,color:CHARCOAL,align:"center",italic:true,fontFace:F});
});
appBar(s,"Selection explains who exited.  It does not explain why survivors stopped responding.");
note(s,"This is the full elasticity extension using CEPII ProTEE own-price demand elasticities. The two panels break the dose-response by elasticity group: low, medium, and high sigma. In Trump 1 on the left, the dose-response is steeper for high-elasticity products — exactly as theory predicts. Price-sensitive products respond more to a tariff-driven price increase. In Trump 2 on the right, all three groups converge near zero slope — uniform attenuation across all responsiveness levels. This is the key null result within the elasticity analysis: it is not that elastic products adapted more while inelastic products continued responding. Every group stopped responding. The stat table shows the selection finding: exited products had mean sigma of minus 11.6 versus minus 8.7 for survivors, t of minus 6.33, covering 85.3 percent of products matched to elasticity data. Selection explains the composition change. It does not explain the behavioral change among those who stayed.");}

// A7 — DIVERSION (three-country detail)
// Stats match fig15_diversion_by_country.png (figures are canonical)
{const s=pres.addSlide();wbg(s);
appTag(s,"A7","Trade diversion: Vietnam, Mexico + Taiwan");
s.addImage({path:fp("fig15"),x:0.3,y:0.48,w:9.4,h:3.55});
[{lbl:"Vietnam",  val:"t = 3.27", sub:"slope = 0.236"},
 {lbl:"Taiwan",   val:"t = 5.55", sub:"slope = 0.211  ★"},
 {lbl:"Mexico",   val:"t = 2.10", sub:"slope = 0.077"},
 {lbl:"Combined", val:"t = 4.69", sub:"14.5¢ per $1.00"}].forEach((e,i)=>{
  const x=0.3+i*2.38;
  s.addShape(pres.ShapeType.rect,{x,y:4.1,w:2.2,h:1.05,
    fill:{color:OFFWHT},line:{color:LTGRAY,width:0.75},rectRadius:0.04});
  s.addText(e.lbl,{x,y:4.14,w:2.2,h:0.25,fontSize:9.5,color:MIDGRAY,align:"center",bold:true,fontFace:F});
  s.addText(e.val,{x,y:4.37,w:2.2,h:0.38,fontSize:16,color:NAVY,align:"center",bold:true,fontFace:F});
  s.addText(e.sub,{x,y:4.73,w:2.2,h:0.3, fontSize:9,color:CHARCOAL,align:"center",italic:true,fontFace:F});
});
appBar(s,"All three channels significant. Taiwan strongest (t=5.55). Together: ~14.5 cents on the dollar.");
note(s,"The full three-country diversion detail. Each dot is one HS6 product. X-axis: how much China lost in the Trump 1 shock, as import change relative to the 2015-to-2017 baseline — further right means China lost more. Y-axis: how much the third country gained by 2025 relative to the 2022-to-2024 baseline. The 6-year gap captures gradual restructuring — sourcing relationships take time to establish. A positive slope is the diversion signature: products China lost most in 2019 are the ones Vietnam, Taiwan, and Mexico gained most by 2025.\n\nVietnam slope 0.236, t 3.27: broad manufacturing relocation across categories. Taiwan slope 0.211, t 5.55 — the tightest signal with the highest t-statistic: semiconductor and electronics supply chains shifted to Taiwan with a speed and consistency no other destination matched, consistent with Taiwan's deep existing capacity in HS chapters 84 and 85. Mexico slope 0.077, t 2.10: weaker marginal effect consistent with USMCA already providing preferential access before the tariffs, making tariff-driven diversion harder to isolate. Combined slope 0.145, t 4.69: approximately 14.5 cents per dollar. Taiwan data comes from USITC DataWeb since UN Comtrade suppresses US-Taiwan bilateral flows; both datasets use proportional changes so the FOB versus CIF basis difference does not affect slope comparisons.");}

// A8 — SLOPE COMPARISON (was main deck slide 7)
{const s=pres.addSlide();wbg(s);
appTag(s,"A8","Trump 1 vs Trump 2: tariff-import slope comparison");
s.addImage({path:fp("fig7"),x:0.3,y:0.48,w:9.4,h:4.75});
appBar(s,"The simplest explanation is that the underlying relationship changed.");
note(s,"The side-by-side regression that most directly diagnoses the prediction failure. Left panel, Trump 1: beta of minus 0.019 per tariff percentage point, t of minus 16.4, p less than ten to the minus fifty. The slope is steep, precise, and statistically overwhelming. Right panel, Trump 2 data: the x-axis uses Trump 1 vintage tariff rates as a prior-exposure proxy — we use the old rates because by 2025 nearly all products faced high tariffs, leaving insufficient variation to estimate a 2025 slope cleanly with current rates. Beta approximately minus 0.0001, t of minus 0.1, not significant. The regression line is horizontal. Products with high prior tariff exposure under Trump 1 show no additional sensitivity in 2025 relative to products with lower prior exposure. The robustness check on slide 6 already established this is not just an out-of-distribution problem. The mechanism itself changed between episodes.");}

// A9 — CLASSIFICATION: LOGISTIC CURVE (was main deck slide 10)
{const s=pres.addSlide();wbg(s);
appTag(s,"A9","Classification: predicted disruption probability, 2019");
s.addImage({path:fp("fig11b"),x:1.2,y:0.48,w:7.6,h:4.75});
appBar(s,"At 30% tariff — a coin flip. Useful signal, but not a precise instrument.");
note(s,"This slide shows the predictive performance of the logistic disruption classifier on 2019 data. The outcome is binary: did this product experience an import decline of more than 30 percent below baseline? The S-curve shows predicted probability as a function of tariff rate, evaluated at median values for the other two features — baseline import volume and trade asymmetry. At zero tariff, predicted probability is approximately 10 percent, close to the unconditional base rate. At 15 percent tariff, roughly 30 percent. At 30 percent — the modal Trump 1 tariff rate — approximately 50 percent, essentially a coin flip. At 40 percent, roughly 65 percent. AUC on the held-out 20 percent test set: 0.677. The model has real predictive signal — substantially above the 0.5 random baseline — but not precise enough for reliable product-level prediction. The shaded band shows plus or minus 15 percent of the point estimate, reflecting meaningful uncertainty throughout. This is an honest result: useful directional signal, not a precision instrument.");}

// A10 — CLASSIFICATION: COEFFICIENTS (was main deck slide 11)
{const s=pres.addSlide();wbg(s);
appTag(s,"A10","Classification: logistic regression coefficients");
s.addImage({path:fp("fig11c"),x:0.8,y:0.48,w:6.8,h:4.0});
s.addShape(pres.ShapeType.rect,{x:7.8,y:0.6,w:1.85,h:2.7,
  fill:{color:OFFWHT},line:{color:LTGRAY,width:0.75},rectRadius:0.05});
[{label:"Tariff rate",      ans:"yes",col:STEEL},
 {label:"Product size",     ans:"yes",col:STEEL},
 {label:"Trade asymmetry",  ans:"no", col:RED}].forEach((item,i)=>{
  const y=0.7+i*0.85;
  s.addText(item.label,{x:7.85,y,w:1.75,h:0.28,fontSize:9.5,color:CHARCOAL,fontFace:F,bold:true});
  s.addText(item.ans,{x:7.85,y:y+0.3,w:1.75,h:0.38,fontSize:18,color:item.col,fontFace:F,bold:true});
});
appBar(s,"Tariff rate dominates. Larger products appear more resilient after controlling for tariff rate.");
note(s,"The logistic model uses three features. Tariff rate is the dominant predictor by a large margin — the coefficient is far to the right of zero with a tight confidence interval. Higher tariffs strongly increase the probability of large import decline, confirming the core 2019 finding. Product size, measured as log baseline import volume, shows a significant negative coefficient — larger trade flows appear more resilient after controlling for tariff rate. This could reflect that larger bilateral relationships have more established supply chains with greater flexibility, or that firms with larger exposure have stronger incentives to invest in tariff exclusion requests and compliance infrastructure. Trade asymmetry — the ratio of Chinese exports to the US divided by US exports to China — is essentially zero and non-significant at z of 0.10. The bilateral trade balance in a product does not predict which products face disruption once tariff level is controlled for.");}

// A11 — MODEL COMPARISON (was main deck slide 12)  FIX: RF 0.657→0.658, XGBoost 0.630→0.640
{const s=pres.addSlide();wbg(s);
appTag(s,"A11","Model comparison: Logistic vs Random Forest vs XGBoost");
s.addImage({path:fp("fig12"),x:0.3,y:0.48,w:6.6,h:4.0});
s.addText("No.",{x:7.05,y:0.65,w:2.55,h:1.1,
  fontSize:52,color:NAVY,bold:true,align:"center",fontFace:F});
[{name:"Logistic",      auc:"0.677",col:STEEL,  winner:true},
 {name:"Random Forest", auc:"0.658",col:MIDGRAY,winner:false},  // FIX: was 0.657
 {name:"XGBoost",       auc:"0.640",col:MIDGRAY,winner:false}   // FIX: was 0.630
].forEach((m,i)=>{
  const y=1.97+i*0.85;
  s.addShape(pres.ShapeType.rect,{x:7.05,y,w:2.55,h:0.75,
    fill:{color:m.winner?MIST:OFFWHT},line:{color:m.winner?STEEL:LTGRAY,width:0.75},rectRadius:0.04});
  s.addText(m.name,{x:7.05,y:y+0.06,w:2.55,h:0.24,
    fontSize:10,color:CHARCOAL,bold:m.winner,align:"center",fontFace:F});
  s.addText("AUC = "+m.auc,{x:7.05,y:y+0.3,w:2.55,h:0.36,
    fontSize:18,color:m.col,bold:true,align:"center",fontFace:F});
});
appBar(s,"At least with these features, additional complexity did not improve predictive performance.");
note(s,"We compared the logistic model against Random Forest and XGBoost using the same three features — tariff rate, log baseline product size, and trade asymmetry — with an 80/20 stratified train-test split. Logistic AUC on held-out test: 0.677. Random Forest: 0.658. XGBoost: 0.640. The simpler model outperforms both ensemble methods. This is not surprising given the main analysis finding: the tariff-disruption relationship in 2019 is substantially linear. When the true signal is linear, logistic regression captures it efficiently, and the additional flexibility of decision-tree ensembles causes them to fit noise in the training set rather than generalizable signal. We report this result regardless of direction — if XGBoost had beaten logistic, we would have investigated why. The message is consistent with the interpretable linear mechanism identified throughout the project: more complexity did not help here.");}

pres.writeFile({fileName:path.join(__dirname,"when_tariffs_stop_moving_trade.pptx")})
  .then(()=>console.log("saved: when_tariffs_stop_moving_trade.pptx ("+(10+1+11)+" slides — 10 main + divider + 11 appendix)"))
  .catch(e=>console.error(e));
