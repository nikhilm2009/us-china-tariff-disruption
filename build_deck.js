const pptxgen = require("pptxgenjs");
const fs = require("fs");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.title = "When Tariffs Stop Moving Trade";
pres.author = "Nikhil M. — Wharton DSA Capstone";

const NAVY   = "1E2761"; const BLUE  = "1F5C8A"; const ICE   = "CADCFC";
const WHITE  = "FFFFFF"; const OFFWHT= "F4F6FA"; const LTGRAY= "EEF1F6";
const RED    = "C0473B"; const MID   = "5A7FA8"; const MUTED = "8899AA";
const DKGRAY = "444C5A";

function bg(s,c){s.addShape(pres.ShapeType.rect,{x:0,y:0,w:"100%",h:"100%",fill:{color:c}});}
function tag(s,t,w=2.0){
  s.addShape(pres.ShapeType.rect,{x:0.4,y:0.22,w,h:0.28,fill:{color:BLUE},line:{color:BLUE}});
  s.addText(t,{x:0.4,y:0.22,w,h:0.28,fontSize:9,color:WHITE,bold:true,align:"center",valign:"middle",margin:0});
}
function ttl(s,t,sz=26){s.addText(t,{x:0.4,y:0.62,w:9.2,h:0.65,fontSize:sz,color:NAVY,bold:true,fontFace:"Cambria"});}
function bar(s,t){
  s.addShape(pres.ShapeType.rect,{x:0,y:5.05,w:"100%",h:0.575,fill:{color:NAVY}});
  s.addText("↗  "+t,{x:0.4,y:5.05,w:9.2,h:0.575,fontSize:13,color:WHITE,bold:true,valign:"middle"});
}

// ── SLIDE 1: TITLE ──────────────────────────────────────────
{const s=pres.addSlide();bg(s,OFFWHT);
s.addShape(pres.ShapeType.rect,{x:0,y:0,w:0.18,h:"100%",fill:{color:NAVY}});
s.addText("WHARTON DATA SCIENCE ACADEMY  ·  CAPSTONE 2025",{x:0.5,y:0.5,w:9,h:0.3,fontSize:9,color:MUTED,bold:true,charSpacing:3});
s.addText("When Tariffs Stop\nMoving Trade",{x:0.5,y:0.95,w:9,h:2.1,fontSize:52,color:NAVY,bold:true,fontFace:"Cambria"});
s.addText("Product-Level Evidence from US-China Trade Conflict, 2019–2025",{x:0.5,y:3.1,w:8,h:0.5,fontSize:16,color:DKGRAY,fontFace:"Calibri"});
s.addShape(pres.ShapeType.line,{x:0.5,y:3.7,w:3.2,h:0,line:{color:RED,width:2.5}});
s.addText("Nikhil M.",{x:0.5,y:3.85,w:5,h:0.32,fontSize:14,color:NAVY,bold:true});
s.addText("Data: UN Comtrade · Bown (2021) · WTO Tariff Actions",{x:0.5,y:4.22,w:7,h:0.28,fontSize:10,color:MUTED});}

// ── SLIDE 2: PIPELINE (font cap 30) ─────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"DATA & PIPELINE");
ttl(s,"This took serious engineering");
const stats=[
  {n:"10",  unit:"years",        sub:"of bilateral\ntrade data"},
  {n:"3",   unit:"datasets",     sub:"Comtrade · Bown\nWTO Tariff Actions"},
  {n:"6,300+",unit:"product-years",sub:"HS6 observations\nTrump 1 + Trump 2"},
  {n:"100%",unit:"match rate",   sub:"tariff-to-product\nmerge, Trump 1"},
  {n:"18",  unit:"scripts",      sub:"fully reproducible\nrenv-locked"},
];
stats.forEach((st,i)=>{
  const x=0.35+i*1.9;
  s.addShape(pres.ShapeType.rect,{x,y:1.35,w:1.75,h:2.5,fill:{color:LTGRAY},line:{color:LTGRAY},rectRadius:0.06});
  s.addText(st.n,  {x,y:1.45,w:1.75,h:0.85,fontSize:30,color:BLUE,bold:true,align:"center",fontFace:"Cambria"});
  s.addText(st.unit,{x,y:2.25,w:1.75,h:0.35,fontSize:12,color:NAVY,bold:true,align:"center"});
  s.addText(st.sub, {x,y:2.6, w:1.75,h:0.65,fontSize:10,color:DKGRAY,align:"center",lineSpacingMultiple:1.3});
});
s.addText("Sources: UN Comtrade API  ·  Bown (2021) HS6 tariffs  ·  WTO Tariff Actions Nov-2025",{x:0.4,y:4.0,w:9.2,h:0.3,fontSize:10,color:MUTED,align:"center"});
bar(s,"The match rates and provenance are documented — every number in this deck is reproducible.");}

// ── SLIDE 3: RESOLUTION ──────────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"RESOLUTION");
ttl(s,"The signal was hiding in plain sight");
s.addImage({path:"/home/claude/fig1.png",x:0.3,y:1.22,w:9.4,h:3.75});
bar(s,"Aggregation destroyed detectability — not the effect. The signal lives where the policy is applied.");}

// ── SLIDE 4: TRUMP 1 (font cap 30) ───────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"TRUMP 1 · 2019");
ttl(s,"In 2019, tariffs strongly predicted trade collapse");
s.addImage({path:"/home/claude/fig2.png",x:0.3,y:1.22,w:6.5,h:3.75});
s.addShape(pres.ShapeType.rect,{x:7.0,y:1.22,w:2.6,h:2.2,fill:{color:NAVY},line:{color:NAVY},rectRadius:0.07});
s.addText("t =\n−16.4",{x:7.0,y:1.3,w:2.6,h:1.3,fontSize:30,color:WHITE,bold:true,align:"center",fontFace:"Cambria",lineSpacingMultiple:0.9});
s.addText("Strongest signal\nin the study",{x:7.0,y:2.62,w:2.6,h:0.65,fontSize:11,color:ICE,align:"center",lineSpacingMultiple:1.2});
s.addShape(pres.ShapeType.rect,{x:7.0,y:3.55,w:2.6,h:0.72,fill:{color:LTGRAY},line:{color:LTGRAY},rectRadius:0.05});
s.addText("−46%  products >25% tariff",{x:7.05,y:3.6,w:2.5,h:0.3,fontSize:11,color:RED,bold:true});
s.addText("+18%  untariffed products", {x:7.05,y:3.9,w:2.5,h:0.3,fontSize:11,color:BLUE,bold:true});
bar(s,"A t-statistic of 16 is not a noisy student result. This association is unambiguous.");}

// ── SLIDE 5: PREDICTIVE FAILURE ──────────────────────────────
{const s=pres.addSlide();bg(s,OFFWHT);
tag(s,"PREDICTIVE VALIDATION",2.6);
ttl(s,"Can a Trump 1 model predict 2025? Spectacular failure.",23);
s.addImage({path:"/home/claude/fig10.png",x:0.3,y:1.22,w:7.0,h:3.75});
const cards=[
  {val:"−84%",lbl:"model predicted\n>50% tariff products",col:NAVY,   tc:WHITE,sc:ICE},
  {val:"−26%",lbl:"actual decline\n(same products)",       col:RED,    tc:WHITE,sc:"FFCCBB"},
  {val:"+58pp",lbl:"prediction gap\n= adaptation",          col:BLUE,   tc:WHITE,sc:ICE},
];
cards.forEach((c,i)=>{
  const y=1.3+i*1.27;
  s.addShape(pres.ShapeType.rect,{x:7.45,y,w:2.2,h:1.15,fill:{color:c.col},line:{color:c.col},rectRadius:0.06});
  s.addText(c.val,{x:7.45,y:y+0.06,w:2.2,h:0.62,fontSize:34,color:c.tc,bold:true,align:"center",fontFace:"Cambria"});
  s.addText(c.lbl,{x:7.45,y:y+0.67,w:2.2,h:0.42,fontSize:10,color:c.sc,align:"center",lineSpacingMultiple:1.1});
});
bar(s,"The model learned Trump 1. The world changed. The model broke.");}

// ── SLIDE 6: WHY — SLOPE DISAPPEARED ─────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"EXPLANATION · PART 1",2.4);
ttl(s,"Why did it fail? The tariff-response relationship disappeared.",21);
s.addImage({path:"/home/claude/fig7.png",x:0.3,y:1.22,w:9.4,h:3.75});
bar(s,"The slope that was −0.019 in 2019 is essentially zero in 2025. The model's core assumption broke.");}

// ── SLIDE 7: WHY — BUCKET TABLE (replaces schematic) ─────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"EXPLANATION · PART 2",2.4);
ttl(s,"Why? The dose-response vanished across every tariff level.",21);
s.addImage({path:"/home/claude/figA5.png",x:0.3,y:1.22,w:9.4,h:3.75});
bar(s,"Compositional selection: the surviving trade relationship is uniformly resistant to tariff variation.");}

// ── SLIDE 8: LOGISTIC PROBABILITY ────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"CLASSIFICATION");
ttl(s,"What predicts whether a product gets disrupted?");
s.addImage({path:"/home/claude/fig11b.png",x:1.2,y:1.22,w:7.6,h:3.75});
bar(s,"At 30% tariff → coin-flip chance of large disruption. AUC = 0.689 with just three features.");}

// ── SLIDE 9: COEFFICIENT PLOT ─────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"CLASSIFICATION");
ttl(s,"What matters most? Tariff rate — by a wide margin.");
s.addImage({path:"/home/claude/fig11c.png",x:1.0,y:1.22,w:8.0,h:3.75});
bar(s,"Larger products are more resilient (structural inelasticity). Trade asymmetry adds nothing.");}

// ── SLIDE 10: MODEL COMPARISON ────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"MODEL COMPARISON");
ttl(s,"More complexity did not improve prediction");
s.addImage({path:"/home/claude/fig12.png",x:0.3,y:1.22,w:6.6,h:3.75});
const models=[
  {name:"Logistic",      auc:"0.677",col:BLUE, winner:true},
  {name:"Random Forest", auc:"0.657",col:MID,  winner:false},
  {name:"XGBoost",       auc:"0.630",col:RED,  winner:false},
];
models.forEach((m,i)=>{
  const y=1.4+i*1.18;
  const fill=m.winner?NAVY:LTGRAY; const nc=m.winner?WHITE:NAVY; const vc=m.winner?ICE:m.col;
  s.addShape(pres.ShapeType.rect,{x:7.05,y,w:2.55,h:1.0,fill:{color:fill},line:{color:fill},rectRadius:0.05});
  s.addText(m.name,       {x:7.05,y:y+0.07,w:2.55,h:0.28,fontSize:11,color:nc,bold:true,align:"center"});
  s.addText("AUC = "+m.auc,{x:7.05,y:y+0.38,w:2.55,h:0.48,fontSize:24,color:vc,bold:true,align:"center",fontFace:"Cambria"});
});
bar(s,"More complexity adds noise, not signal. The trade disruption mechanism is linear and interpretable.");}

// ── SLIDE 11: LIMITATIONS ─────────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
tag(s,"LIMITATIONS");
ttl(s,"What we do not claim");
const limits=[
  {head:"Not causality",                          body:"Cross-sectional associations at annual frequency. Causal estimates require monthly data and DiD identification."},
  {head:"Not exogeneity",                         body:"Tariff placement was strategic (Made-in-China-2025 targeting), not random assignment."},
  {head:"Not full MARL validation",               body:"Two structural predictions are consistent with the data. The simulation's clean regime geometry does not reproduce."},
  {head:"\"Largely absent\" — not \"99% collapse\"",body:"Trump 2 slope depends on the WTO snapshot date, annual aggregation, and tariff-rate matching."},
];
limits.forEach((l,i)=>{
  const y=1.3+i*0.94;
  s.addShape(pres.ShapeType.rect,{x:0.4,y,w:9.2,h:0.82,fill:{color:LTGRAY},line:{color:LTGRAY},rectRadius:0.04});
  s.addText("✗  "+l.head,{x:0.55,y:y+0.06,w:9.0,h:0.28,fontSize:13,color:RED,bold:true});
  s.addText(l.body,       {x:0.55,y:y+0.35,w:8.9,h:0.38,fontSize:11,color:DKGRAY});
});}

// ── SLIDE 12: FOUR LESSONS ────────────────────────────────────
{const s=pres.addSlide();bg(s,OFFWHT);
s.addText("Four lessons",{x:0.5,y:0.28,w:9,h:0.32,fontSize:11,color:MUTED,bold:true,charSpacing:3});
s.addText("When Tariffs Stop Moving Trade",{x:0.5,y:0.62,w:9,h:0.72,fontSize:30,color:NAVY,bold:true,fontFace:"Cambria"});
s.addShape(pres.ShapeType.line,{x:0.5,y:1.38,w:9,h:0,line:{color:BLUE,width:1}});
const lessons=[
  {num:"1",head:"Policy effects live at policy resolution.",     body:"The HS6 relationship (t = −16.4) was invisible at HS2. The signal lives where tariffs are applied."},
  {num:"2",head:"Trump 1 tariffs strongly predicted disruption.",body:"+18% untariffed, −46% heavily tariffed. A logistic model predicts disruption with AUC 0.689."},
  {num:"3",head:"Those relationships largely disappeared by 2025.",body:"Elastic products exited disproportionately (t = −6.33, p < 0.001). But even among high-elasticity survivors, the dose-response was absent — selection explains part, not all, of the attenuation."},
  {num:"4",head:"Simple models explain more than complex ones.", body:"Logistic (0.677) outperforms RF (0.657) and XGBoost (0.630). The mechanism is interpretable."},
];
lessons.forEach((l,i)=>{
  const y=1.52+i*0.92;
  s.addShape(pres.ShapeType.ellipse,{x:0.5,y:y+0.12,w:0.38,h:0.38,fill:{color:BLUE},line:{color:BLUE}});
  s.addText(l.num,{x:0.5,y:y+0.12,w:0.38,h:0.38,fontSize:13,color:WHITE,bold:true,align:"center",valign:"middle",margin:0});
  s.addText(l.head,{x:1.05,y:y+0.06,w:8.5,h:0.28,fontSize:13,color:NAVY,bold:true});
  s.addText(l.body,{x:1.05,y:y+0.34,w:8.5,h:0.44,fontSize:11,color:DKGRAY});
});
s.addShape(pres.ShapeType.rect,{x:0,y:5.15,w:"100%",h:0.475,fill:{color:NAVY}});
s.addText("Trade adapted faster than the original tariff model predicted.",{x:0.4,y:5.15,w:9.2,h:0.475,fontSize:14,color:WHITE,bold:true,italic:true,valign:"middle"});}

// ══════════════════════════════════════════════════════════════
// APPENDIX SLIDES
// ══════════════════════════════════════════════════════════════

function appTag(s,n,title){
  s.addShape(pres.ShapeType.rect,{x:0,y:0,w:"100%",h:0.42,fill:{color:LTGRAY}});
  s.addText("APPENDIX "+n+"  ·  "+title,{x:0.4,y:0,w:9.2,h:0.42,fontSize:11,color:NAVY,bold:true,valign:"middle"});
}

// ── A1: HS HIERARCHY ─────────────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
appTag(s,"A1","How the Harmonized System works — HS2 vs HS6");
s.addImage({path:"/home/claude/figA1.png",x:0.5,y:0.5,w:9.0,h:4.9});}

// ── A2: TARIFF DISTRIBUTIONS (placeholder if missing) ────────
{const s=pres.addSlide();bg(s,WHITE);
appTag(s,"A2","Tariff rate distributions: Trump 1 vs Trump 2");
const figA2exists = require("fs").existsSync("/home/claude/figA2.png");
if(figA2exists){
  s.addImage({path:"/home/claude/figA2.png",x:0.3,y:0.5,w:9.4,h:4.9});
} else {
  s.addShape(pres.ShapeType.rect,{x:0.5,y:1.0,w:9.0,h:3.5,fill:{color:LTGRAY},line:{color:"#DDE3EC"}});
  s.addText("Run scripts/21_appendix_methods.R then re-upload figA2_tariff_distribution.png",
    {x:0.5,y:2.4,w:9.0,h:0.6,fontSize:13,color:MUTED,align:"center",italic:true});
}}

// ── A3: MERGE FLOW ───────────────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
appTag(s,"A3","Data merge flow and match rates");
s.addImage({path:"/home/claude/figA3.png",x:0.5,y:0.5,w:9.0,h:4.9});}

// ── A4: TIMELINE ─────────────────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
appTag(s,"A4","US-China tariff escalation timeline, 2018–2026");
s.addImage({path:"/home/claude/figA4.png",x:0.1,y:0.5,w:9.8,h:4.9});}

// ── A5: BUCKET COMPARISON ─────────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
appTag(s,"A5","Trump 1 vs Trump 2: dose-response by tariff bucket");
s.addImage({path:"/home/claude/figA5.png",x:0.3,y:0.5,w:9.4,h:4.9});}

// ── A6: ELASTICITY EXTENSION ──────────────────────────────────
{const s=pres.addSlide();bg(s,WHITE);
appTag(s,"A6","Elasticity extension: CEPII ProTEE × tariff dose-response");
s.addImage({path:"/home/claude/figA6.png",x:0.3,y:0.5,w:9.4,h:3.85});

// Three key stats below the figure
const estats=[
  {lbl:"Exited products",   val:"σ = −11.6", sub:"more elastic"},
  {lbl:"Surviving products",val:"σ = −8.7",  sub:"less elastic"},
  {lbl:"Difference",        val:"t = −6.33", sub:"p < 0.001"},
];
estats.forEach((e,i)=>{
  const x=0.5+i*3.1;
  s.addShape(pres.ShapeType.rect,{x,y:4.45,w:2.85,h:0.85,fill:{color:LTGRAY},line:{color:LTGRAY},rectRadius:0.05});
  s.addText(e.lbl,{x,y:4.48,w:2.85,h:0.28,fontSize:10,color:MUTED,align:"center",bold:true});
  s.addText(e.val,{x,y:4.73,w:2.85,h:0.32,fontSize:16,color:NAVY,align:"center",bold:true,fontFace:"Cambria"});
  s.addText(e.sub,{x,y:5.02,w:2.85,h:0.22,fontSize:9, color:DKGRAY,align:"center",italic:true});
});
s.addShape(pres.ShapeType.rect,{x:9.55,y:4.45,w:0.1,h:0.85,fill:{color:WHITE},line:{color:WHITE}});

// Punchline
s.addShape(pres.ShapeType.rect,{x:0,y:5.3,w:"100%",h:0.33,fill:{color:NAVY}});
s.addText("Selection explains who exited. It does not explain why survivors stopped responding.",
  {x:0.4,y:5.3,w:9.2,h:0.33,fontSize:11,color:WHITE,bold:true,italic:true,valign:"middle"});}

pres.writeFile({fileName:"/home/claude/when_tariffs_stop_moving_trade.pptx"})
  .then(()=>console.log("saved")).catch(e=>console.error(e));
