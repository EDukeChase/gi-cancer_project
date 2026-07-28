# Statistical Analysis (Methods Section) — Draft Outline

*Style target: JAMA / JCO / JCO Global Oncology "Statistical Analysis" subsection. Written as a detailed outline with draft sentence stems — fill in bracketed values from final analysis before submission. Derived from `1 - Data Cleaning.qmd`, `2 - Data Validation.qmd`, `3 - Descriptive Statistics.qmd`, `4 - Statistical Analysis.qmd`, and `5 - Publication Figures.qmd`.*

*Last reconciled against the code on 2026-07-27. Terminology note: this draft uses **adverse drug event (ADE)** throughout to match the manuscript. The `.qmd` files and variable names still use "AE" — that is a deliberate split, since renaming code identifiers is not worth the breakage. Prose in the analysis documents has not been aligned yet.*

---

## 1. Overview / Software

- All statistical analyses were performed using R (version 4.6.0; R Foundation for Statistical Computing, Vienna, Austria), with `tidyverse` 2.0.0, `gtsummary` 2.5.1, `lme4` 2.0-1, `lmerTest` 3.2-1, and `car` 3.1-5 used for data management, tabulation, and modeling. Reproducible analysis pipelines were implemented in Quarto, with the package environment pinned via `renv`.
- A two-sided α of 0.05 was used to define statistical significance unless otherwise specified. [Confirm whether any one-sided tests were used — none currently identified.]
- Where multiple related hypothesis tests were performed within the same comparison family (e.g., per-adverse-event-type associations with early treatment dropout), p-values were adjusted using the Benjamini-Hochberg procedure to control the false discovery rate; adjusted q-values are reported alongside raw p-values.

## 2. Study Design and Population

- Brief restatement of design (retrospective cohort, single/multi-institution, study period) — *pull dates/site from elsewhere in the project, not present in the .qmd files reviewed.*
- Patients were stratified throughout by HIV serostatus (negative vs positive) as the primary exposure of interest.
- Sample size: N = `[total]` patients (HIV-negative n = `[x]`, HIV-positive n = `[y]`).

## 3. Data Cleaning and Quality Control

*(Methods-section framing of `01_data-cleaning.qmd` / `02_data-validation.qmd`; most papers compress this to 2-4 sentences plus a footnote/supplement reference.)*

- Source data were extracted from a structured REDCap/Excel case report form and underwent a multi-stage cleaning pipeline prior to analysis, including resolution of duplicate or mislabeled fields, harmonization of longitudinal (per-cycle) variable naming, and type coercion of categorical and date variables.
- Logical consistency checks were performed to confirm agreement between the number of chemotherapy cycles received and the presence of cycle-level laboratory/management data, and between recorded cycles given and cycles prescribed; discrepant records were manually adjudicated against source documentation.
- A small number of data-entry errors (e.g., an implausible height value, miscoded sex, a non-numeric laboratory value) were identified through range and logic checks and corrected or set to missing as detailed in a data-cleaning log; corrections affected `[n]` of `[N]` records (<`[X]`%).
- *Consider whether this level of detail belongs in the main Methods vs. a supplementary data-quality appendix — JAMA/JCO house style typically keeps this very brief in the main text.*

## 4. Variable Definitions

### 4.1 Adverse Event Grading
- Adverse events (anemia, leukopenia, neutropenia, thrombocytopenia, lymphopenia, hyponatremia, hypernatremia, hypokalemia, hyperkalemia, hypoalbuminemia, hyperbilirubinemia, and transaminase elevation) were graded for each treatment cycle from laboratory values using CTCAE v5 severity thresholds (Supplemental Table `[X]` / `grading_rules.csv`).
- "Severe" adverse events were defined as CTCAE grade ≥3. Related laboratory adverse events were collapsed into clinically interpretable composite categories (e.g., myelosuppression = leukopenia, neutropenia, thrombocytopenia, lymphopenia; raised transaminases = ALT, AST, ALP) for summary reporting.
- Patient-level summary variables included: any adverse event (grade >0) at any point in treatment, any severe adverse event, maximum grade across all cycles, and the same restricted to an early-treatment window (cycles 1–`[4]`, see below).

### 4.2 Early Treatment Discontinuation
- Early treatment discontinuation ("early dropout") was defined a priori as receipt of ≤`[4]` cycles among patients prescribed more than `[4]` cycles. Sensitivity cutoffs of `[2]` and `[4]` cycles were examined.
- For adverse-event predictors of early dropout, the maximum grade per adverse-event category within cycles 1–`[4]` was used; patients without any recorded grade for a given category in that window were excluded from that category's model (complete-case), as opposed to imputing grade 0, because [state rationale: clinical plausibility for liver panel markers vs. hematologic markers — to be finalized].

### 4.3 Other Derived Outcomes
- Cycles prescribed and cycles received (chemotherapy "completion rate" = cycles given / cycles prescribed).
- Toxicity-attributable hospitalization: any hospitalization in a cycle (binary) and length of hospital stay among hospitalized cycles (continuous, days).
- Receipt and quantity (units) of red-cell transfusion, and receipt of granulocyte colony-stimulating factor (G-CSF), evaluated relative to graded anemia/neutropenia severity in the same cycle.

## 5. Descriptive Statistics

- Continuous variables are summarized as median (interquartile range [IQR]) [confirm: median/IQR was the primary summary used; mean (SD) reported secondarily for some variables (e.g., cycles prescribed, completion rate) — state which is primary for Table 1 vs. text]. Categorical variables are summarized as frequency (%).
- Baseline patient, disease, and treatment characteristics were tabulated overall and stratified by HIV status (Table 1), with comorbidities and exposure history summarized similarly.
- Group comparisons in descriptive tables used the Wilcoxon rank-sum test for continuous variables and Fisher's exact test for categorical variables; these comparisons are descriptive/exploratory and unadjusted for multiple comparisons unless stated otherwise.
- For 2×2 and r×c contingency tables (e.g., cancer site × HIV status, chemotherapy regimen × HIV status), the chi-square test of independence was used when all expected cell counts were ≥5; Fisher's exact test was substituted when any expected cell count was <5.
- For global associations found to be significant in r×c tables (e.g., cancer site vs. HIV status), post hoc one-vs-rest 2×2 comparisons were performed for each level against all remaining levels combined, using Fisher's exact test, to localize the source of the association. [Flag: confirm whether multiplicity correction was applied to these post hoc comparisons — current code does not appear to adjust them; consider whether it should, e.g., BH or Bonferroni across cancer sites.]

## 6. Primary and Secondary Analyses

*(Frame each analysis around a clinical question, consistent with JCO/JCO GO style — one short paragraph per outcome family, stating the model, covariates, and effect measure.)*

### 6.1 Severe Adverse Events by HIV Status
- The association between HIV status and occurrence of any severe (grade ≥3) adverse event was assessed using logistic regression, reported as odds ratios (ORs) with 95% confidence intervals (CIs).
- An unadjusted model and a multivariable model adjusting for cancer stage, chemotherapy regimen, treatment intent, age, and sex were both fit. Estimates were closely consistent, so only the adjusted model is tabulated; the unadjusted result is stated in text.
- Reference levels for categorical covariates are named in the variable label rather than shown as separate table rows.
- [Note for methods text: a parallel model with "any adverse event" (rather than severe) as outcome could not be fit due to complete separation (100% event rate in the HIV-positive group); this limitation should be stated explicitly rather than omitted.]

### 6.2 HIV Status as Outcome (Reverse Association)
- A complementary analysis modeled HIV status as the outcome, with maximum CTCAE grade across all cycles as the predictor, unadjusted and adjusted for cancer stage, chemotherapy regimen, treatment intent, age, and sex, to characterize the bidirectional association between toxicity burden and HIV serostatus.

### 6.3 Chemotherapy Cycles Prescribed
- The number of chemotherapy cycles prescribed was modeled using Poisson regression as a function of HIV status, cancer site, cancer stage, chemotherapy regimen, treatment intent, and age, exponentiated to rate ratios (RRs) with 95% CIs.
- Nested models with and without cancer site were compared via likelihood ratio test to assess whether site contributed meaningfully to model fit. [Confirm: was overdispersion checked / negative binomial considered as an alternative to Poisson? Not currently in code — worth deciding before finalizing methods text.]

### 6.4 Toxicity-Related Hospitalization
- Any hospitalization attributable to toxicity in a given cycle was modeled using a mixed-effects logistic regression (generalized linear mixed model) with a patient-level random intercept to account for repeated cycles within patients, with fixed effects for maximum AE grade in the cycle, HIV status, age, and sex; results reported as ORs (95% CI).
- Length of hospital stay (days) among hospitalized cycles was modeled using a linear mixed-effects model with a patient-level random intercept, unadjusted (HIV status only) and adjusted (additionally for age, sex, chemotherapy regimen, and cancer stage).

### 6.5 Early Treatment Discontinuation
- The global association between HIV status and early discontinuation (at each cutoff examined) was tested using the chi-square test (or Fisher's exact test where expected cell counts were <5).
- For each adverse-event category, the univariate association between maximum grade in cycles 1–`[4]` and early discontinuation, adjusting for HIV status, was estimated by logistic regression (OR, 95% CI); adverse-event categories with fewer than 5 patients with any non-zero grade in either HIV group were excluded from modeling as too sparse for stable estimation.
- P-values across adverse-event categories were adjusted for multiple comparisons using the Benjamini-Hochberg method; results are also displayed as a forest plot of adjusted ORs.
- In a secondary analysis, each adverse-event association was estimated **separately within each HIV group** rather than pooled with HIV as a covariate, to show whether the two groups track together. Benjamini-Hochberg correction was applied within each group, with the number of tests set to the number of models that could actually be fit. Adverse-event categories that could not be estimated within a stratum (too few events, or no variation in grade) are reported explicitly alongside the figure rather than omitted, since absence from one panel reflects sparsity rather than absence of association. *[The HIV-positive group is small; state plainly in the text that this stratified analysis is descriptive and underpowered.]*
- Multicollinearity for each univariate model (AE grade and HIV status) was assessed using the generalized variance inflation factor (GVIF), with GVIF >5 flagged for review.

### 6.6 Transfusion and G-CSF Utilization
**Transfusion.** Because transfusion is near-universal at high anemia grades and near-absent at low ones, a single pooled model is uninformative. The analysis was therefore run on two separate strata and the effect estimates compared for consistency, rather than pooled:

1. **Cycles with anemia grade ≥2** — patients with a clinical indication for transfusion.
2. **Cycles belonging to patients transfused at least once** — patients for whom transfusion was demonstrably available, so that variation in receipt reflects a treatment decision rather than the absence of any indication.

Each stratum was modeled by mixed-effects logistic regression with a patient-level random intercept and fixed effects for HIV status, anemia grade, cancer stage, chemotherapy regimen, and cancer site. Consistency of the HIV estimate across the two strata, rather than either estimate alone, is the quantity of interest. A grade-2-only model is retained as a sensitivity analysis.

*[Interpretation caveat to carry into the Discussion: grade ≥2 patients are indicated for transfusion, but blood supply constraints in this setting mean a substantial proportion do not receive one. The grade ≥2 stratum should be described as "had an indication", not "was eligible and able to receive". A null HIV effect is consistent with either equitable treatment or with supply constraints dominating clinical decision-making, and the paper should not claim the former.]*

*[Open question for the statistical team: stratum 2 conditions on a consequence of the exposure. Confirm this framing is acceptable before reporting it as a primary result.]*

**Blood units.** Among transfused cycles, the number of units administered was modeled by linear mixed-effects regression as a function of HIV status and anemia grade, with a patient-level random intercept.

**G-CSF.** The odds of receiving G-CSF were modeled by mixed-effects logistic regression with a patient-level random intercept and fixed effects for HIV status, myelosuppression severity, age, cancer stage, chemotherapy regimen, and cancer site. Severity was defined as the per-cycle maximum of neutropenia (ANC) and leukopenia (WBC) grade, since either can indicate G-CSF and neutropenia is a component of leukopenia. Age was included on the clinical rationale that older patients are more likely to experience a count drop and to be supported. A model restricted to cycles with severity grade ≥2 was fit in parallel, mirroring the transfusion stratification.

*[Framing note: the covariates here reflect the expectation that cancer site, stage, and regimen drive neutropenia and therefore G-CSF indication, whereas any HIV effect is plausibly behavioural — clinicians may over-indicate G-CSF for HIV-positive patients out of perceived immune risk. If an HIV association is found, this distinction matters for how it is interpreted.]*

### 6.7 Chemotherapy Cycle Completion

- Cycle completion was summarized as the proportion of patients receiving cycle *k* among those prescribed at least *k* cycles, plotted by HIV status with pointwise 95% Wilson score intervals. Wilson intervals were used rather than Wald because the proportions approach 0 and 1 at the extremes of the curve.
- Because patients prescribed six cycles necessarily stop contributing after cycle 6, the pooled curve confounds the prescribed regimen with genuine early discontinuation. A stratified version, split by number of cycles prescribed (1–6, 8, 11–12) and crossed with HIV status, is presented alongside it.
- *[This figure resembles a Kaplan-Meier curve but is not one — there is no censoring and no time axis. State this explicitly in the legend. Decide which of the two versions goes in the main paper.]*
- *[The intervals are pointwise, not simultaneous: the same patients contribute at successive cycles. Do not describe the bands as a confidence region for the whole curve.]*

## 7. Model Diagnostics

- Multicollinearity among covariates in all multivariable regression models was assessed using the variance inflation factor (VIF) for linear/logistic models and the generalized VIF (GVIF) for models containing multi-level categorical predictors; a threshold of [VIF/GVIF >5] was used to flag concerning collinearity.
- For the logistic model of HIV status on toxicity grade, linearity of the logit was assessed graphically using empirical log-odds plots across levels of the predictor, and influential observations were evaluated using Cook's distance (threshold 4/n) [consider whether/how influential-observation handling affected reported estimates — current notebook documents the check as exploratory ("will have to do more investigation") and should not be characterized as resolved unless it has been].
- All binomial models were screened for complete and quasi-complete separation, both before fitting (cross-tabulating the outcome against every level of each categorical predictor to identify levels with no variation in outcome) and after fitting (flagging coefficients with implausibly large magnitude or standard error). Where separation was present, the affected covariate levels were excluded from the model in question; excluded levels are reported alongside each affected table, and are identified from the data for each analysis stratum rather than carried over between strata. Descriptive tables retain all levels.
  - *[Consider stating Firth's penalised likelihood or a weakly-informative Bayesian fit as the more principled alternative that was considered but not adopted, and why.]*
- [Add explicitly if used in final analysis: assessment of overdispersion for Poisson models; convergence diagnostics for mixed-effects models; goodness-of-fit (e.g., Hosmer-Lemeshow) if performed.]

## 8. Handling of Missing Data

- Analyses used available-case (complete-case) data for each specific model or comparison; the denominator for each statistic is reported alongside the estimate.
- For the early-dropout adverse-event analysis specifically, missing per-cycle adverse-event grades within the early window were imputed to grade 0 for the primary descriptive/coverage tables under the assumption that an unmeasured marker reflected no clinical indication to test, an assumption considered more defensible for hepatic panel markers than for hematologic markers (e.g., hemoglobin, platelets); a complete-case sensitivity analysis (excluding rather than imputing missing grades) is noted to substantially reduce sample size (n ≈ 97, ~26 events) and [state final decision — was the imputed or complete-case version used for the reported univariate/forest-plot results? Confirm before finalizing, since this materially changes how the methods should be worded.]
- No formal multiple imputation was performed. [Confirm this remains true in the final analysis — if MI is added later, this section needs rewriting along with a description of the imputation model and number of imputations per Rubin's rules.]

## 9. Subgroup and Sensitivity Analyses

- Sensitivity of the cycles-prescribed-by-age association was examined across multiple age cutoffs (50, 55, 60, 65, 70 years) stratified by HIV status.
- Early-dropout cutoffs of 2 and 4 cycles were both examined.
- [Add any additional planned sensitivity analyses, e.g., excluding patients with incomplete cycle data, restricting to a single cancer site, or restricting to a single chemotherapy regimen.]

## 10. Items Still Needed Before Finalizing

1. ~~R and package version numbers~~ — done. R 4.6.0, confirmed; README corrected to match.
2. ~~Confirm CTCAE version~~ — v5, confirmed against the grading rules.
3. Decide and state whether post hoc one-vs-rest site comparisons need multiplicity correction.
4. State explicitly the complete-separation limitation for "any AE by HIV status" models rather than leaving as a code comment.
5. Resolve and state final approach to missing AE grades in the early-dropout analysis (impute-to-0 vs. complete case) — pick one as primary and report the other as sensitivity.
6. Decide whether Poisson overdispersion was checked / whether negative binomial was substituted.
7. Confirm study dates, setting(s), and recruitment/eligibility criteria for the Study Design subsection (not present in the analysis .qmd files; pull from protocol or earlier manuscript draft).
8. Confirm primary continuous-variable summary statistic for Table 1 (median/IQR appears primary; reconcile with any mean/SD reporting elsewhere).
9. Confirm the second transfusion stratum ("patients transfused at least once") is an acceptable framing, given it conditions on a consequence of the exposure.
10. Decide which cycle-completion figure (pooled vs. stratified by cycles prescribed) goes in the main paper, and which of the two dropout forest plots.
11. Decide the fate of the deprecated any-ADE model: delete it, or keep it as the source of the "100% of HIV-positive patients experienced an ADE" statement.
12. Agree the 4-tables / 4-figures main-paper split, with the remainder moved to supplementary.
13. Align "AE" language in the analysis documents with "ADE" in the manuscript. Prose and captions only — variable names should stay as they are.
