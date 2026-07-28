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
  - [x] Durable fix done: code now writes only to `generated/`; `tables/` and `figures/` are human-only. CSVs split into `generated/csv/`, docx filenames now human-readable via the `output_names` lookup
  - [ ] Tell Tinashe the layout changed — edited copies stay in `tables/`, fresh output appears in `generated/tables/`
  - [ ] Delete `_freeze/` before the next full render, or doc 6's DAG figures stay in the old location
  - [ ] **Render the full pipeline** — all of the above is unverified, written without R available
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
