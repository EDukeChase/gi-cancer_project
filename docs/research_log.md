# Research Issues & Tasks Log

This document tracks outstanding questions, data anomalies, coding tasks, and administrative actions for the project.

**Entry Status Legend**
- [ ] **Open:** Needs attention or action.
- [/] **In Progress:** Investigation started or partially implemented.
- [x] **Resolved:** Fixed or decided (see notes for details).

**Priority Legend**
- **[P0] Critical:** Analysis cannot proceed until fixed.
- **[P1] High:** Must fix before the next major stage (e.g., validation/analysis).
- **[P2] Medium:** Needs fixing, but analysis can proceed cautiously.
- **[P3] Low:** Likely accurate or minor impact; confirm when time permits.
- **[P4] Very Low:** Refactoring, formatting, or UI tweaks; does not affect results.

---

## Project Status & Workflow
- [ ] **Data Cleaning (`01_data-cleaning.qmd`)**
	- [ ] **Apply manual data patch (DAT-018).**
	- [x] [2025-11-16] **Duplicate Names:** Identified and resolved raw columns with identical names in the excel file.
		- *Resolved Tasks:* DAT-001.
	- [ ] **Duplicate Content:** Identified redundant columns; unresolved anomalies flagged for validation.
		- *Resolved Tasks:* DAT-002, DAT-004, DAT-005
		- [ ] DAT-006 [P2]: Empty `dbil_12`
		- [ ] DAT-007 [P2]: Empty `abli_score_0` and `cr_clear_0`
		- [ ] DAT-008 [P2]: Possible Blood transfusion duplication
		- [ ] DAT-009 [P2]: Cycle 10 hospitalization variable
	- [x] [2025-11-28] **Longitudinal Consistency:** Verified and standardized variable names across all 12 cycles.
		- *Resolved Tasks:* DAT-003.
	- [x] [2025-11-29] **Standardization:** Converted all variable names to snake_case and `stem_#` format.
		- *Resolved Tasks:* DAT-011.
	- [x] [2025-11-29] **Naming Audit:** Audited renaming steps to ensure traceability to raw data.
	- [ ] **Type Encoding:** Converted types (Factors, Dates, Numerics).
		- *Resolved Tasks:* DAT-012, DAT-013, DAT-014, DAT-015.
		- [ ] DAT-010 [P1]: Cancer stage encoding ambiguity
	- [ ] **Encoding Audit:** Verified integrity of type conversion.
		- *Resolved Tasks:* DAT-017.
		- [ ] DAT-016 [P2]: Numeric Column as Character
- [ ] **Data Validation (`02_data-validation.qmd`):**
    - [ ] **Logic Check:** Verify `cycles_given` matches actual data presence.
        - [ ] DAT-019 [P1]: Extraneous cycle data
    - [x] [2025-12-01] **Logic Check:** Verify `cycles_given` <= `cycles_prescribed`.
    - [ ] **Logic Check:** Verify temporal consistency (e.g., Death Date > Treatment Start).
	- [ ] **Calculation Check:** Verify composite variables (`completion_rate`, `bmi`) match their components.
		- Complete, but need to reincorporate missing patient data.
    - [x] **Range Check:** Identify and handle impossible body measurement values.
		- *Resolved Tasks:* DAT-020
    - [ ] **Range Check:** Scan for clinically impossible lab values.
    - [ ] **Missingness:** Examine missingness patterns (Random vs. Systematic/Attrition).
    - [ ] **Feature Engineering:** Generate graded adverse event columns using `grading_rules.csv`.
		- *Resolved Tasks:* MET-001
		- [ ] MET-002 [P1]: Adverse Event Grading Rules

## Planned Analysis & Feature Engineering (PLN)
*Planned analysis-ready derived variables and dataset assembly tasks (not data problems).*

- **PLN-001 [P2]: Cycle-level adverse event summaries**
  - **Status:** Open
  - **Created:** 2026-01-12
  - **Last updated:** 2026-01-12
  - **Location:** `03_exploratory-data-analysis.qmd` (chunks: `engineer-ae-variables`, `tbl-ae-by-pt`, `tbl-ae-by-cycle`)
  - **Summary:** Add cycle-level derived variables summarizing adverse events from existing per-cycle grade columns, and incorporate them into the analysis dataset used for modeling/reporting.
  - **Impact:** Enable per-cycle adverse event summaries/models and prevent having to rely only on whole-treatment summaries.
  - **Scope:** All patients in `gic_validated`; cycles 1–12; uses existing `*_grade_#` columns.
  - **Actions:**
    - [x] Merge cycle-level adverse event counting logic into `engineer-ae-variables` from `engineer-ae-counts`, then remove `engineer-ae-counts`.
	- [x] Fix grade parsing so numeric extraction works reliably.
	- [x] Update `tbl-ae-summary` (and/or add a new table) to usefully display new cycle-level summaries.
	- [ ] Improve table metric choices
	- [ ] Generate plots to explore new cycle-level AE variables stratified by `hiv_status`.
	- [ ] Validate against raw grade columns to confirm derived values.
		- [ ] Spot check against a small set of patients/cycles.
		- [ ] Thorough validation pass.
  - **Timeline:**
	- 2026-01-12: Merged `engineer-ae-variables` and `engineer-ae-counts` and dropped the latter. Added table describing the meanings of new variables that were created. Built tables summarizing new variables by `hiv_status` (`tbl-ae-by-pt`, `tbl-ae-by-cycle`).
    - 2025-12-18: Discussed adding cycle-level adverse event measures to better tie adverse events to clinical variables (e.g., `hosp_days_#`) for clinically oriented analysis. (source: Zoom meeting).

## Data Integrity & Anomalies (DAT)
*Issues regarding the accuracy, completeness, or logic of the raw data.*

- [/] **DAT-007 [P2]: Empty `abli_score_0` and `cr_clear_0`**
	- *Update:* [2025-12-05] (Email from Dr. Mazhindu) Received DOI links for definitive formulas for both ALBI score and Creatinine Clearance.
	- *Update:* [2025-12-02] (Zoom meeting) Dr. Mazhindu confirmed these are derived variables. Calculation formulas were not immediately available; follow-up email sent same day.
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
		- **Current location:** `01_data-cleaning.qmd` (Chunk: `assess-duplicate-content`).
	- *Summary:* Columns are entirely empty.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
		- *No Action:* Leave columns in place, do not include in analysis.
	- *Task:* Confirm if data are missing, or if columns should be removed.
- [/] **DAT-009 [P2]: Cycle 10 hospitalization variable**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
		- **Current location:** 
	- *Summary:* `Hospitalization.required...10` is identical to `Was.the.cycle.delayed...10`.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
		- *No Action:* Assume data are correct.
	- *Task:* Compare with other cycles to see if this correlation is plausible or a data entry mistake.
- [ ] **DAT-018 [P1]: Chemotherapy Data Discrepancy**
	- *Update:* [2025-12-18] Investigated record ids 14 and 231 (which were flagged by Dr. Hendrick's early validation but not Duke's). Record id 14 has NA for cycle_delayed_3, 231 doesn't have any data for cycle 10
	- *Update:* [2025-12-01](Email from Dr. Mazhindu) Will discuss during meeting.
	- *Observed:* [2025-12-01] via email from Dr. Mazhindu [2025-10-08].
	- *Summary:* `different_administered.csv` contains corrected administration counts for 6 patients.
- [/] **DAT-019 [P2]: Extraneous cycle data**
	- *Update:* [2025-12-18] Removed cycle 12 data for record_id 146, updated cycles given data for record_id 27, 498, and 766 to reflect data presence in `01_data-cleaning.qmd` (Chunk: `apply_manual-patches`). For record_id 498, they don't have any bloodwork data.
		- **Current location:** 
	- *Update:* [2025-12-05] (Email from Dr. Mazhindu) Confirmed that for record_id 146, only cycle 1 was administered and cycle 12 values should be disregarded.
	- *Update:* [2025-12-02] (Zoom meeting) Dr. Mazhindu stated that for patients where there is a mismatch between recorded number of cycles given, and the number of cycles which actually contain data, the latter should be considered more accurate barring other irregularities.
    - *Observed:* [2025-12-01] in `02_data-validation.qmd` (Chunk: `assess_extraneous-data`).
		- **Current location:** 
    - *Summary:* 4 patients (Record IDs: 27, 146, 498, 766) have data recorded for cycles beyond their `cycles_given` count.
		- *Investigation:* The patients with record IDs 27, 498, and 766 had some amount of data for one more cycle than prescribed. The patient with record ID 146 had expected data for cycle 1, but also had data for cycle 12.
	- *Temporary Resolution*: [2025-12-01] in `02_data-validation.qmd` (Chunk: `fix_extraneous-data`).
		- *Excluded Patients:* Excluded these 4 records from analysis.
    - *Task:* Check if that should count as a cycle completed or not.
- [ ] **DAT-023 [P3]: Plotting warning (Body measurements)**
	- *Observed:* [2025-12-01] in `02_data-validation.qmd` (Chunk: `assess_body-measurements`).
		- **Current location:** 
    - *Summary:* `ggplot` warning: "Removed 21 rows containing non-finite values".
    - *Task:* Verify if these correspond exactly to the known `NA`s in Height, Weight, and BMI, or if valid data is being excluded.

## Methodology (MET)
*Decisions affecting the statistical plan.*

- [ ] **MET-002 [P1]: Adverse Event Grading Rules**
	- *Update:* [2025-12-02] During Zoom meeting, Dr. Mazhindu confirmed **NCI-CTCAE v5** as the definitive reference standard.
		- *Status:* Document logged in Zotero
		- *Next Step:* Update `data/grading_rules.csv` to match v5 criteria.
	- *Observed:* [2020-11-29] in `NOrmal ranges and Adverse Events grading system.xlsx`
	- *Summary:* Edge case ambiguity in adverse event grading criteria.
	- *Task:* Secure a definitive reference standard from the Dr. Mazhindu. [Resolved 2025-12-02]

## Technical Tasks (TEC)
*Action items for coding, refactoring, data cleaning, and validation scripts.*

- [ ] **TEC-001 [P4]: Standardize Audit Functions**
	- *Location:* `01_data-cleaning.qmd`.
    - *Task:* Modify `format_audit_table()` to be a single, universal function that handles all audit types (duplicates, cycles, static vars) to reduce code duplication.
- [ ] **TEC-002 [P4]: Fix ToC Issue**
	- *Location:* `01_data-cleaning.qmd`.
	- *Issue:* Table of contents on right side of rendered HTML pages is no longer dynamic aside from acting as links; it only shows top level headers and the first one is always highlighted, regardless of what link was last clicked. Links do work. Suspect this might have something to do with the `kableExtra::scroll_box()` function used throughout.
- [/] **TEC-003 [P3]: Update Research Log Format**
	- *Location:* `research_log.md`.
	- *Task:* Reorder items under entries in chronological order (See DAT-016 for example).
- [ ] **TEC-004 [P4]: Implement ID Cross-Referencing**
	- *Location:* `01_data-cleaning.qmd`.
	- *Goal:* Ensure bidirectional traceability between the code, the report, and the research log.
	- *Task:* Refactor code comments and callout blocks to explicitly reference Research Log IDS (e.g., `DAT-001`).
- [ ] **TEC-005 [P4]: Create custom save function**
    - *Location:* `R/setup.R`
    - *Goal:* Reduce code duplication by replacing verbose save chunks in `01_data-cleaning.qmd` and `02_data-validation.qmd` with a single function call.
    - *Task:* Define a wrapper function (e.g., `safe_save_rds`) to handle the interactive overwrite prompt logic.
- [ ] **TEC-006 [P2]: Fix 'File Path Too Long' Warnings**
    - *Observed:* 
		- [2025-11-30] in `01_data-cleaning.qmd`.
		- [2025-12-02] in `02_data-cleaning.qmd` in Chunk(`assess_body-measurements`)
		- **Current location:** 
    - *Issue:* RStudio fails to copy font files to the cache because the OneDrive path exceeds 260 characters.
    - *Attempted Resolutions:* 
		1. Set `embed-resources: false` in `_quarto.yml`. (Result: Error persisted during interactive chunk execution).
        2. Created Directory Junction from `.Rproj.user` to `C:/R_Cache/gi-cancer/`. (Result: Error persisted, likely due to RStudio accessing the project via the original long path).
    - *Task:* Disable "Show output inline for all R Markdown documents" in RStudio Global Options to bypass the notebook cache entirely.
- [ ] **TEC-007 [P1]: Audit adverse event grading**
    - *Location:* `02_data-validation.qmd` (Chunk: `derive_adverse-events`).
		- **Current location:** 
    - *Task:* Verify that the adverse event grading logic correctly assigned values (e.g., check that `ast_5` values map to the correct `ast_grade_5` labels) and ensure missing values (`NA`) were handled correctly.
- **TEC-008 [P4] Adjust chunk naming**
	- **Status:** In progress
	- **Location:** `01_data-cleaning.qmd`, `02_data-validation.qmd`, `research_log.md`
	- **Summary:** Rename chunk labels to use dashes to comply with Quarto best practices and update all references in `research_log.md` so chunk pointers remain navigable.
	- **Actions:**
		- [ ] Update chunk references in active log entries to match current chunk labels.
		- [ ] For archived entries, keep original chunk labels and add a dated `Current location:` line only when the original chunk label no longer exists.
	- **Timeline (newest first):**
		- 2026-01-09 — Renamed chunk labels in `01_data-cleaning.qmd` and `02_data-validation.qmd` (replaced underscores with dashes). Research log references still need to be updated.
		- 2025-12-12 — Observed inconsistent/noncompliant chunk naming in `01_data-cleaning.qmd`, `02_data-validation.qmd`.
- [ ] **TEC-009 [P3] Fine-grained lab missingness audit**
	- *Task:* Develop secondary audit to check for internal lab panel completeness (e.g., cases where LFT is present but CBC is missing within a cycle)

## Project Management & Admin (ADM)
*Communication, documentation updates, and external coordination.*

- [ ] **ADM-001 [P3]: Update Glossary**
	- *Task:* Add all missing valid and reference ranges.
- [ ] **ADM-002 [P0]: Outstanding Inquiries (for Dr. Mazhindu)**
	- *Status:* Reply received [2025-12-01]
	- *Outcomes:*
		1. DAT-010: Confirmed `4` = "Stage IV".
		2. DAT-018: Resolve during meeting on 2025-12-02
		3. DAT-016: Replace "pn" with 28.
		4. MET-001: Will move forward with ANC only analysis.
	
## Archived Log Entries

- [x] **DAT-001: ANC Column Duplication**
	- *Resolved:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-names`).
		- **Current location:** 
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-names`).
		- **Current location:** 
	- *Summary:* The raw Excel file contained several columns with identical or mislabeled headers.
	- *Details:*
      - *ANC Duplication:* `ANC.3...108` and `ANC.3...109` were identical. Removed `...109`, renamed `...108` to `ANC.3`.
      - *Potassium Naming:* Two columns were named `HyperK+.3`, with no `HypoK+.3`. Renamed the first instance to `HypoK+.3`.
      - *Cycle 7 Mislabeling:* Variables labeled `.6` in the Cycle 7 section were renamed to Cycle 7.
- [x] **DAT-021: Potassium Naming**
- [x] **DAT-022: Cycle 7 Mislabeling**

- [x] **DAT-002: Redundant data columns**
	- *Resolved:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`).
		- **Current location:** 
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
		- **Current location:** 
	- *Summary:* Several columns identified as duplicates or artifacts.
	- *Details:*
		- *Redundant Content:* `Febrile.Neutropenia` (duplicate of `ANC`) and `HyperK+` (duplicate of `HypoK+`) were removed for all cycles.
		- *Duplicate Column:* `Hypernatramia.Na+.3` (identical to `Hyponatramia.Na+.3`) was removed.
		- *Documentation Artifacts:* All `Cycle #` spacer columns removed.
- [x] **DAT-003: Inconsistent Variable Naming**
	- *Resolved:* [2025-11-28] in `01_data-cleaning.qmd` (Chunk: `fix_longitudinal-consistency`)
		- **Current location:** .
	- *Observed:*[2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_longitudinal-consistency`).
		- **Current location:** 
	- *Summary:* Several longitudinal variables had minor inconsistencies, missing suffixes, or typos.
	- *Details:*
		- *Harmonized:* Capitalized all stems (`DBIL`, `HB`, `TBIL`), realigned with original naming scheme (`HypoNa+`).
		- *Corrected:* Applied missing suffixes (`Hospitalization.days.2`), fixed typos (`Hospitalization.required.due.to.toxicity?`).
- [x] **DAT-011: General Variable Renaming**
	- *Resolved:* [2025-11-29] in `01_data-cleaning.qmd` (Chunk: `apply_standard-names`).
		- **Current location:** 
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-names`).
		- **Current location:** 
	- *Summary:* Raw variable names contained factor levels and long strings.
	- *Details:* 
		- *Standardized:* Simplified names and converted all to snake case. Baseline measurements denoted with `_0` suffix. Longitudinal measurements denoted with `_#` suffix for appropriate cycle number.
- [x] **DAT-012: Factors Encoded as Numeric**
	- *Resolved:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
		- **Current location:** 
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
		- **Current location:** 
	- *Summary:* Categorical variables were imported as numeric. 
	- *Details:* 
	  - *Coerced Data Types:* Converted to factors with explicit labels based on variable names from `IPROTECTARetrospecti_DATA_2025-08-19_2157 FINAL SHEET.xlsx`.
- [x] **DAT-013: Empty Columns as Logical**
	- *Resolved:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
		- **Current location:** 
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
		- **Current location:** 
	- *Summary:* `cr_clear_0`, `albi_score_0`, and `dbil_12` are stored as `logical` because they contain only `NA`.
	- *Details:*
	  - *Coerced Data Types:* Converted all to `numeric`.
- [x] **DAT-014: Date Precision**
	- *Resolved:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
		- **Current location:** 
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
		- **Current location:** 
	- *Summary:* `death_date` is stored as `POSIXct` (DateTime).
	- *Details:* 
		- *Coerced Data Type:* Converted to `Date` class.
- [x] **DAT-017: Invalid `sex` Level** 
	- *Resolved:* [2025-12-01] in `01_data-cleaning.qmd` (Chunk: `fix_dat-017_sex-error`).
		- **Current location:** 
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `audit_encoding_static-factor`).
		- **Current location:** 
	- *Summary:* The variable `sex` contained the raw value `3`.
    - *Details:*
		- *Patched Data Error:* Corrected raw value of `3` to `1` (Male) per confirmation from Dr. Mazhindu [2025-10-08].
- [x] **MET-001 [P3]: Febrile Neutropenia vs. ANC**
	- *Resolved:* [2025-12-01] Definition confirmed by Dr. Mazhindu in email.
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
		- **Current location:** 
	- *Summary:* Raw data had `ANC` and `Febrile.Neutropenia` as identical columns.
	- *Details:*
		- *Confirmation:* `Dr. Mazhindu confirmed that using `ANC` as a proxy for the analysis is acceptable given the lack of fever data. The deletion of the redundant column stands.
- [x] **DAT-005 [P2]: Baseline vs. cycle 1 electrolytes**
	- *Resolved:* [2025-12-02] During Zoom meeting, Dr. Mazhindu confirmed that data was recorded during cycle 1
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
		- **Current location:** 
	- *Summary:* `HypoNa+.1` is identical to `Baseline.Na+` (same for Potassium). This pattern does not hold for other biomarkers.
- [x] **DAT-010 [P1]: Cancer stage encoding ambiguity**
	- *Resolved:* [2025-12-02] Updated encoding in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`)
		- **Current location:** 
	- *Update:* [2025-12-01](Email from Dr. Maxhindu) Confirmed `4` indicates "Stage IV", as treatment implies known stage.
	- *Observed:* [2025-11-28] in `01_data-cleaning.qmd` (Chunk: `apply_standard-names`).
		- **Current location:** 
	- *Summary:* The column name implies `4` could mean either "Stage IV" or "Unknown/Undocumented".
	- *Temporary Resolution:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk `apply_type-coercion`)
		- **Current location:** 
		- *Use Ambiguous Label:* Map a value of `4` as "Stage IV / Unknown".
- [x] **DAT-015 [P2]: Residence factor level mismatch**
	- *Resolved:* [2025-12-05] (Zoom meeting) Dr. Mazhindu confirmed the temporary resolution was the right correction.
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
		- **Current location:** 
	- *Summary:* The documented encoding for `residence` is "1 = urban; 2 = rural; 3 = peri-urban", but observed levels are 0, 1, and 2.
	- *Temporary Resolution:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk `apply_type-coercion`).
		- **Current location:** 
		- *Alternate Encoding:* Will assume 0 = urban, 1 = rural, 2 = peri-urban.
- [x] **DAT-020 [P2]: Body measurement outlier**
	- *Resolved:* [2025-12-18] Moved definitive fix to `01_data-cleaning.qmd` (Chunk: `apply-manual-patches`). BMI recalculated to maintain data integrity.
	- *Update:* [2025-12-02] (Zoom meeting) Dr. Mazhindu confirmed that 1498 was a decimal entry error, correct value is 149.8 cm.
	- *Observed:* [2025-12-01] in `02_data-validation.qmd` (Chunk: `asses_body-measurements`).
	- *Summary:* One patient record (record ID 614) contains physically impossible values for height/bmi.
	- *Temporary Resolution*: [2025-12-01] in `02_data-validation.qmd` (Chunk: `fix_body-measurements`).
		- *Data Correction:* Replace value of 1498 with 149.8 and recalculate BMI.
	- *Task:* Determine correct value for `height_0` for this patient. Current value is 1498, suspect it should be 149.8.
- [x] **DAT-004 [P3]: Zero comorbidities**
	- *Resolved:* [2025-12-02] (Zoom meeting) Dr. Mazhindu confirmed that this is correct based on the source data.
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* No patients have COPD, Kidney Disease, or Epilepsy recorded.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
		- *No Action:* Assume data are correct.
- [x] **DAT-016 [P2]: Numeric Column as Character**
	- *Resolved:* [2025-12-18] Applied definitive fix in `01_data-cleaning.qmd` (Chunk: `apply-manual-patches`). Removed temporary `if_else` coercion from `02_data-validation.qmd` (Chunk: `apply-type-coercion`).
	- *Update:* [2025-12-02](Email from Dr. Mazhindu) Confirmed "pn" should be `28`.
	- *Temporary Resolution*: [2025-11-30] in `01_data-cleaning.qmd` (Chunk `apply_type-coercion`).
		- *Coerced Data Types:* Converted `ast_1` to numeric and explicitly coerced "pn" to `NA`.
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
	- *Summary:* `ast_1` is stored as a character vector.
		- *Investigation:* `record_id == 64` contains the value "pn" for `ast_1`.
- [x] **DAT-006 [P2]: Empty `dbil_12`**
	- *Resolved:* [2025-12-18] Confirmed as expected clinical/technical missingness; column left as all-NA numeric.
	- *Update:* [2025-12-02] (Zoom meeting) Dr. Mazhindu confirmed that liver metabolites are sometimes omitted due to chemo toxicity profiles or lab-specific processing variations.
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* Column is entirely empty, however there were other liver panel results for patients in cycle 12.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
		- *No Action:* Assume data are correct.
	- *Task:* Confirm if this is expected missingness (not tested) or data loss.
- [x] **DAT-008 [P2]: Transfusion Data Inconsistency**
	- *Resolved:* [2025-12-18] Applied manual patches for 6 records in `01_data-cleaning.qmd` (Chunk: `apply-manual-patches`) using corrected values.
	- *Update:* [2025-12-05] (Email from Dr. Mazhindu) Received table of corrected values.
    - *Update:* [2025-12-02] Audit revealed active data mismatches (missing units/unexpected units) in cycles outside the initial duplication list.
    - *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
    - *Summary:* Columns `transfusion_given` and `transfusion_units` show both redundant data entry and active inconsistencies.
    - *Original Observation (Duplication):* Columns were mathematically identical (implied 1 unit) in cycles 4, 7, 8, 9, and 11.
    - *New Finding (Active Errors):* Found explicit errors where the `transfusion_given` flag contradicts the `units` count.
    - *Temporary Resolution:* [2025-11-16] Assumed data were correct (No action taken on the columns yet).