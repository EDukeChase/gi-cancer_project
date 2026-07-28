2026-Jul-27 — carried-forward items reconciled

  The dated entries below are left exactly as written; this block records where
  each recurring open item actually stands as of tonight. Checked against the
  code, not against memory.

  RESOLVED
  - Evaluate CSF-G model for extreme separation (open since Jun-19)
      Done. Pre-fit cell screen (`chk-gcsf-separation`) and post-fit coefficient
      screen (`chk-gcsf-given-separation`) in doc 4. Generalised into
      `check_separation()` / `drop_separated_levels()` and logged as MET-008.
  - Check for multicollinearity in existing models
      Done 2026-06-23 via `check_vif()`; now also applied to the two new
      transfusion strata and both G-CSF models.
  - Modify table download function to save parts to output/tables
      Done, and superseded twice since: output now goes to `tables/generated/`
      and `tables/csv/` with human-readable filenames.
  - Review notes from the last two meetings re: tables and figures
      Effectively done. The priority list was built from those notes and every
      P1 and P2 item in it has been implemented.

  STILL OPEN — yours, I can't do these
  - Read Summix paper
  - Read textbook sections on DAGs and regression model handling
  - Add transcription capabilities to laptop (whisper.cpp)
  - Add explanations to the publication figures document
      Captions are complete in doc 5; the interpretive prose is yours.
  - Remove extra elements from the DAGs, keeping only what Audrey suggested
      Doc 6 has two DAGs (transfusion, G-CSF). I can't tell which elements were
      Audrey's suggestion and which you added, so I left them alone.

  NEEDS A DECISION, NOT JUST WORK
  - Modify data prep blocks to incorporate `patient_static`
      Determination: `patient_static` is built and saved in doc 3 and used for
      its stated purpose — joining patient-level columns onto the cycle-level
      `mgmt_cycle`. Doc 4 never loads it and uses `gic_models` directly.
      Because `patient_static` is a strict column-subset of `gic_models`,
      extending it into doc 4 is a consistency refactor with no functional
      gain, and would touch ~20 call sites. Not worth doing unattended before a
      meeting. Either close this item as done-for-its-purpose, or scope it
      deliberately — but it is not the loose end it looks like.
  - Migrate the research log to GitHub Issues
      Not started. Worth reconsidering: the log has just been brought current
      (26 of 46 entries now resolved), so the argument for migrating is weaker
      than it was when it was drifting.

2026-Jul-27
  - [x] Fixed unclosed code fence in `4 - Statistical Analysis.qmd` (`model-transfusion-given`) — the document could not render
  - [x] P1.1 Rebuilt transfusion analysis on two strata (anemia grade 2+, ever-transfused patients) with a side-by-side comparison table; grade-2-only kept as sensitivity
  - [x] P1.2 Added age to the G-CSF model; added pre-fit separation screen (closes the 19-Jun item); added grade-2+ variant
  - [x] P1.3 Cycle completion plot split by cycles prescribed, Wilson CI bands added, x-axis labelled
  - [x] P1.4 Added early-dropout forest plot split by HIV status as a separate figure
  - [x] P2.1 Reference rows dropped from all 7 regression tables, reference level moved into the variable label
  - [x] P2.2 Unadjusted column dropped from the severe ADE table (model still fit)
  - [x] P2.3 `model_any_basic` invalidity promoted to a visible callout — decision on delete vs keep still open
  - [x] P2.5 "Gall bladder" -> "Gallbladder"
  - [x] P3.2 Removed stale LASSO wording
  - [x] Captions added across `5 - Publication Figures.qmd` (now complete) + explanatory prose
  - [x] Added `snapshot_outputs()` — archives shared tables/ and figures/ before a render can overwrite Tinashe's hand-edited docx files
  - [ ] **Check OneDrive web "Modified By" + version history before first render** — find out what Tinashe has edited, recover anything already clobbered
  - [x] Reworked output layout again: `tables/generated/` (docx) + `tables/csv/`, figures stay flat with `figures/svgs/`. Confirmed all 7 publication figures emit SVGs for submission
  - [x] P3.1 partial: reconciled `docs/statistical-methods-draft.md` against the current code — stale filenames, R/package versions, CTCAE v5, the two transfusion strata, revised G-CSF model, cycle completion, separation screening, HIV-stratified dropout analysis
  - [ ] P3.1 remainder: the draft is an outline, not prose. Needs the bracketed numbers filled in and turning into manuscript text
  - [ ] Align "AE" -> "ADE" in qmd prose and captions (variable names stay as-is)
  - [ ] Add explanations to publication figures document (mine to write)
  - [x] Management tables restructured: G-CSF tables pivoted wide by HIV status, denominators corrected to cycles with a recorded decision, shared helper so the four tables cannot drift apart
  - [ ] **Ask Tinashe (MET-010):** which severity definition should indicate G-CSF? The neutropenia-only table looks like a leftover from before the myelosuppression collapse, and neither existing table matched what doc 4 models. Added a max-of-neutropenia/leukopenia table as the interim
  - [x] Doc 4 pass: reference levels now a footnote under each table (labels were wrapping), applied to all model tables including the ones missed first time round
  - [x] Model formulas printed above every regression table; code, warnings and messages hidden in the rendered doc, convergence surfaced deliberately via `check_convergence()`
  - [x] Transfusion strata table fixed: `anemia_grade_f` was not being screened for separation, which is why grade 3-4 produced ORs of 1e21 and Inf. Replaced the mismatched `tbl_merge()` with a compact HIV-across-strata comparison plus separate full model tables
  - [x] G-CSF models now actually *drop* separated levels (Gallbladder had zero G-CSF) rather than only reporting them - that was the cause of the singular-Hessian warnings
  - [x] Hospitalization tables: HIV moved into columns, mean (SD) to match the headers (was calling median/IQR), all made downloadable
  - [x] Early-dropout stacked table split into a descriptive table and a model table
  - [x] `geom_errorbar(height=)` -> `width=` (ggplot 4.x rename) - source of the "height was translated to width" messages
  - [x] GVIF explanation added at first use; hardcoded "cycles 1-4" replaced with `early_dropout_cycles` in R code
  - [ ] `early_dropout_cycles`: still hardcoded in three chunk *captions* (`tbl-univariate-ae-results`, `plt-ae-early-dropout-heatmap`, `tbl-ae-coverage`) - needs `!expr` in the chunk option, left alone as untested
  - [x] Fixed the by-HIV exclusions table: it was looping over every ADE type and logging the *global* sparsity exclusion once per HIV group, so all four rows were categories that were never in the stratified analysis to begin with. Now iterates over the categories that passed the coverage check, and reports only genuine per-stratum failures
  - [x] Table clarity pass: column-percentage note on the dropout descriptive table, plain-English q-value explanation, HIV comparison direction stated explicitly (derived from the model, not assumed)
  - [x] Exclusion tables cleaned up: repeated boilerplate moved to the caption, raw variable names replaced with display labels, and exclusions now also attached as a note on each model table so a truncated factor is self-explaining
  - [x] G-CSF separation screen now runs per stratum - screening only the full data made the grade 2+ exclusions look unjustified
  - [x] Found why `echo: false` never worked in doc 4: `R/setup.R` called `opts_chunk$set(echo = TRUE)`, which runs *after* the YAML is applied and silently overrode it. Removed; echo is now controlled per document in its YAML. Docs 1-3, 5, 6 keep their previous collapsed-code behaviour
  - [x] Unadjusted severe-ADE model reinstated alongside the adjusted one (reverses the 5-Jun decision to drop it); stale captions in docs 4 and 5 corrected
  - [x] Chunk label audit across docs 3-5: 13 chunks produced captioned tables without a `tbl-` label, so Quarto was not numbering them. All renamed; two uncaptioned table chunks given labels and captions
  - [x] Reverted the unadjusted severe-ADE column (Audrey's 5-Jun call stands); the unadjusted OR/CI/p is now computed and quoted in the table caption instead, so "closely consistent" carries a number. Same wording reused in doc 5 via a stored string rather than a second fit
  - [x] Restored the chi-squared tests in doc 4 - the whole `tests-chi-sq` chunk had been commented out, so that subsection rendered contingency tables with no result attached. Now reported via a `test_contingency()` helper that also states which test was used and why
  - [x] Swept doc 4 for results that only appeared as console output: the early-dropout test (cat + raw htest), the influential-observations report (three cat lines), and the deprecated any-ADE model (raw glm summary). All now proper captioned tables; the any-ADE one reports the 100% rate, which is the actual reportable fact
  - [ ] Three commented-out chunks remain in doc 4 (`tbl-hiv-simple-or`, `tbl-hiv-basic-or`, `tbl-ae-early-dropout`) - all superseded by live equivalents, left alone. Delete when convenient
  - [x] AE -> ADE across all display text in docs 3 and 4 and `R/setup.R` (109 occurrences); CTCAE -> ADE (2). Variable names untouched - uppercase AE only ever appeared in labels, captions and prose, so no identifier could be caught
  - [x] Commented out the chi-squared subsection in doc 4 per Audrey's preference for a single test type; `test_contingency()` now defaults to Fisher's exact for every table (matching MET-006) and reports the minimum expected count rather than switching test on it
  - [x] Doc 6 fixed: `save_figure()` and `save_table()` now return invisibly, which was the cause of the duplicated images and the printed paths/slugs. DAG chunks given fig- labels and captions so they are numbered
  - [x] Moved a narrative `print()` in the HIV assumptions check into prose
  - [ ] Tell Tinashe the layout changed — edited copies stay in `tables/`, fresh output appears in `tables/generated/`
  - [x] **Deleted `_freeze/` and rendered the whole pipeline clean**
  - [x] Dropped the automatic "HIV Status" spanning header from Table 1 and the ADE table
  - [x] R version confirmed as 4.6.0; corrected README (said 4.5.0) and the methods draft
  - [x] Reordered ADE categories: haematologic, electrolyte, hepatic (CBC/BMP/LFT panel order) instead of alphabetical, so hypo/hyper pairs sit together. Applied to both the ADE category table and the grouped summary table
  - [x] Added `_dependencies.R` at project root so renv sees the runtime-only deps (broom.mixed + the easystats tidier chain). Never sourced, exists purely for the scanner
  - [ ] Run `renv::snapshot()` to get those into the lockfile, then re-render to confirm nothing broke
  - [ ] Then `renv::clean()` is safe for the usethis and future/furrr stacks (confirmed unused)
  - [ ] renv version mismatch: 1.2.3 loaded, 1.1.5 recorded — `renv::record("renv@1.2.3")`
  - [ ] Decide `model_any_basic`: delete or keep as the source of the "100% ADE rate in HIV+" claim
  - [ ] Confirm with Audrey: is "all patients who received a transfusion" the patient-level stratum implemented, or something else?
  - [ ] Sort out CRLF churn — every file shows as fully modified in git, hiding real diffs
  - [ ] P2.4 Captions in `3 -` and `4 -` still incomplete
  - [ ] P3.1 Statistical methods write-up (draft outline exists at `docs/statistical-methods-draft.md`)
  - [ ] Modify data prep blocks to incorporate new `patient_static` dataframe
  - [ ] Begin migration to using GitHub issues instead of the research log

2026-Jun-23
  - [ ] Evaluate CSF-G model to determine if there's extreme separation like the transfusion model
  - [ ] Review notes from last two meetings, especially meeting with Tinashe regarding adjustments to tables and figures
  - [x] Check for multicollinearity in existing models
  - [ ] Add explanations to publication figures document
  - [ ] Read Summix paper
  - [ ] Begin reading relevant textbook sections on DAGs and how to handle different things in regression models
  - [ ] Begin migration to using GitHub issues instead of the research log
  - [ ] Modify data prep blocks to incorporate new `patient_static` dataframe
  - [ ] Add transcription capabilities to laptop

2026 Jun-19
  - [x] Update transfusion model to only look at grade 2 anemia
  - [ ] Evaluate CSF-G model to determine if there's extreme separation like the transfusion model
  - [ ] Review notes from last two meetings, especially meeting with Tinashe regarding adjustments to tables and figures
  - [ ] Check for multicollinearity in existing models
  - [ ] Add explanations to publication figures document
  - [ ] Read Summix paper
  - [ ] Begin reading relevant textbook sections on DAGs and how to handle different things in regression models
  - [ ] Begin migration to using GitHub issues instead of the research log
  - [x] Modify table download function so that the parts are saved to output/tables instead of the root folder
  - [ ] Modify data prep blocks to incorporate new `patient_static` dataframe
  - [ ] Add transcription capabilities to laptop


2026 June-18
  - [ ] Add transcription capabilities to laptop
  - [ ] Add explanations to publication figures document
  - [x] Build preliminary transfusion and G-CSF models
    - [x] Track down and fix typo in G-CSF variable
      - Unneeded, in the xlsx document he named it csf-g
  - [ ] Review notes from last two meetings, especially meeting with Tinashe regarding adjustments to tables and figures
  - [x] Read LLM paper
  - [ ] Read Summix paper
  - [ ] Begin reading relevant textbook sections on DAGs and how to handle different things in regression models
  - [ ] Begin migration to using GitHub issues instead of the research log
  - [ ] Modify table download function so that the parts are saved to output/tables instead of the root folder


2026 June-12
  - Needing to make a commit before changing more stuff, tried to migrate to just working on laptop, still worthwhile, but need to add transcription capabilities (whisper.cpp stuff). Git migration to laptop didn't go well, it's a bit buggy, so I've got to get that figured out before I can do the commit. 
  - Finish adding explanations to the publication figures document so it's clear what everything is
  - Check the paper again to see what I need to add next
  - Remove extra elements I'd added to the DAGs, just have what Audrey suggested and leave any additions to Tinashe
