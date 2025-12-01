# Research Issues & Tasks Log

This document tracks outstanding questions, data anomalies, coding tasks, and administrative actions for the project.

**Status Legend**
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
- [ ] **Data Cleaning**
	- [x] Check columns that had the same names in the excel file.
	- [/] Check columns that have identical contents.
	- [x] Check consistency of cycle specific variables.
	- [x] Standardize variable names using snake case.
	- [x] Audit each step of variable name standardization.
	- [x] Encode variables as correct data types.
	- [/] Audit variables after encoding.
- [ ] **Data Validation**
	- [x] [2025-11-30] Convert columns to correct data type and audit for accidental changes
	- [ ] Examine missingness
	- [ ] Identify invalid entries
	- [ ] Veryify that `cycles_prescribed` >= `cycles_given`.
	- [ ] Verify that `cycles_given` matches up with actual number of cycles containing data for each patient.
		- Consider longitudinal data in chunks of "CBC Panel", "Chemisty Panel", "LFT Panel" and "Management"
	- [ ] Verify composite variables (e.g., `completion_rate`, `bmi`).
	- [ ] Add graded adverse event columns.
		- MET-002 [P2]: Adverse Event Grading Rules

## Data Integrity & Anomalies (DAT)
*Issues regarding the accuracy, completeness, or logic of the raw data.*

- [/] **DAT-004 [P3]: Zero comorbidities**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* No patients have COPD, Kidney Disease, or Epilepsy recorded.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
	- *Details:* 
		- *No Action:* Assume data are correct.
	- *Task:* Verify this isn't a data entry error.
- [/] **DAT-005 [P2]: Baseline vs. cycle 1 electrolytes**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* `HypoNa+.1` is identical to `Baseline.Na+` (same for Potassium). This pattern does not hold for other biomarkers.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
	- *Details:* 
		- *No Action:* Assume data are correct.
	- *Task:* Verify if Cycle 1 is officially the baseline for electrolytes, or if this is a data duplication error.
- [/] **DAT-006 [P2]: Empty `dbil_12`**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* Column is entirely empty, however there were other liver panel results for patients in cycle 12.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
	- *Details:* 
		- *No Action:* Assume data are correct.
	- *Task:* Confirm if this is expected missingness (not tested) or data loss.
- [/] **DAT-007 [P2]: Empty `abli_score_0` and `cr_clear_0`**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* Columns are entirely empty.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
	- *Details:* 
		- *No Action:* Leave columns in place, do not include in analysis.
	- *Task:* Confirm if data are missing, or if columns should be removed.
- [/] **DAT-008 [P2]: Possible Blood transfusion duplication**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* For cycles 4, 7, 8, 9, and 11, `transfusion_given` and `transfusion_units` are identical.
		- *Implication:* This implies every single transfusion in those cycles was exactly 1 unit.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
	- *Details:* 
		- *No Action:* Assume data are correct.
	- *Task:* Check `transfusion_units` in other cycles to see if this is likely, or data entry mistake.
- [/] **DAT-009 [P2]: Cycle 10 hospitalization variable**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* `Hospitalization.required...10` is identical to `Was.the.cycle.delayed...10`.
	- *Temporary Resolution:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`)
	- *Details:* 
		- *No Action:* Assume data are correct.
	- *Task:* Compare with other cycles to see if this correlation is plausible or a data entry mistake.
- [ ] **DAT-010 [P1]: Cancer stage encoding ambiguity**
	- *Observed:* [2025-11-28] in `01_data-cleaning.qmd` (Chunk: `apply_standard-names`).
	- *Summary:* The column name implies `4` could mean either "Stage IV" or "Unknown/Undocumented".
	- *Temporary Resolution:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk `fix_duplicate-content`)
	- *Details:* 
		- *Leave Ambiguous Label:* Treat a value of `4` as "Stage IV / Unknown".
	- *Task:* Clarify correct encoding.
- [/] **DAT-015 [P1]: Residence factor level mismatch**
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
	- *Summary:* The documented encoding for `residence` is "1 = urban; 2 = rural; 3 = peri-urban", but observed levels are 0, 1, and 2.
	- *Temporary Resolution:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk `apply_type-coercion`).
	- *Details:* 
		- *Alternate Encoding:* Will assume 0 = urban, 1 = rural, 2 = peri-urban.
	- *Task:* Clarify correct encoding.
- [/] **DAT-016 [P2]: Numeric Column as Character**
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
	- *Summary:* `ast_1` is stored as a character vector.
		- *Investigation:* `record_id == 64` contains the value "pn" for `ast_1`.
	- *Temporary Resolution*: [2025-11-30] in `01_data-cleaning.qmd` (Chunk `apply_type-coercion`).
	- *Details:* 
		- *Coerced Data Types:* Converted `ast_1` to numeric and explicitly coerced "pn" to `NA`.
	- *Task:* Clarify whether this was data misentry or if "pn" has a specific meaning.
- [/] **DAT-017 [P1]: Invalid Level (`sex`)** 
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `audit_encoding_static-factor`).
	- *Summary:* The variable `sex` contained the raw value `3` (defined levels: 1=Male, 2=Female).
		- *Investigation:* Traced to `record_id == 94`.
    - *Temporary Resolution:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk `apply_type-coercion`).
	- *Details:*
		- *Coerced Data Type:* Converted `sex` to a factor value, exlicitly coerced `3` to `NA` during encoding to maintain factor integrity.
    * *Task:* Clarify with Dr. Mazhindu if `3` represents a valid category or a data entry error.
- [ ] **[P1]: Investigate baseline measurement outliers**
	- *Observed:* [2025-11-??] in `02_data-validation.qmd` (Chunk: ``)
    - *Summary:* Impossible values found (Height > 14 meters, BMI 0.2).
	- *Task:* Investigate possible causes, consult with Dr. Mazhindu

## Methodology (MET)
*Decisions affecting the statistical plan.*

- [/] **MET-001 [P3]: Febrile Neutropenia vs. ANC**
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* Raw data had `ANC` and `Febrile.Neutropenia` as identical columns.
	- *Temporary Resolution:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk `apply_type-coercion`).
	- *Details:*
		- **Redundant Content:** `Febrile.Neutropenia` (duplicate of `ANC`) was removed for all cycles.
	- *Task:* Consult with Dr. Mazhindu, since FN is neutropenia with a fever, but there is no fever data present, and the `ANC` and `Febrile.Neutropenia` columns contained identical measurements.
- [ ] **MET-002 [P2]: Adverse Event Grading Rules**
	- *Observed:* [2020-11-29] in `NOrmal ranges and Adverse Events grading system.xlsx`
	- *Summary:* Edge case ambiguity in adverse event grading criteria.
	- *Task:* Secure a definitive reference standard from the Dr. Mazhindu.

## Technical Tasks (TEC)
*Action items for coding, refactoring, data cleaning, and validation scripts.*

- [ ] **TEC-001 [P4]: Standardize Audit Functions**
	- *Location:* `01_data-cleaning.qmd`.
    - *Task:* Modify `format_audit_table()` to be a single, universal function that handles all audit types (duplicates, cycles, static vars) to reduce code duplication.
- [ ] **TEC-002 [P4]: Fix ToC Issue**
	- *Location:* `01_data-cleaning.qmd`.
	- *Issue:* Table of contents on right side of rendered HTML pages is no longer dynamic aside from acting as links; it only shows top level headers and the first one is always highlighted, regardless of what link was last clicked. Links do work. Suspect this might have something to do with the `kableExtra::scroll_box()` function used throughout.

## Project Management & Admin (ADM)
*Communication, documentation updates, and external coordination.*

- [ ] **ADM-001 [P3]: Update Glossary**
	- *Task:* Add all missing valid and reference ranges.
- [ ] **ADM-002 [P0]: Outstanding Inquiries (for Dr. Mazhindu)**
	- *Status:* Draft
	- *Content:*
		1. DAT-010 [P1]: Cancer stage encoding ambiguity
		2. DAT-015 [P1]: Residence factor level mismatch
		3. DAT-017 [P1]: Invalid Level (`sex`)
		4. DAT-005 [P2]: Baseline vs. cycle 1 electrolytes
		5. DAT-006 [P2]: Empty `dbil_12`
		6. DAT-007 [P2]: Empty `abli_score_0` and `cr_clear_0`
		7. DAT-008 [P2]: Possible Blood transfusion duplication
		8. DAT-009 [P2]: Cycle 10 hospitalization variable
		9. DAT-016 [P2]: Numeric Column as Character
		10. MET-002 [P2]: Adverse Event Grading Rules
	
## Resolved Items Archive

- [x] **DAT-001: Duplicate column names**
	- *Resolved:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-names`).
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-names`).
	- *Summary:* The raw Excel file contained several columns with identical or mislabeled headers.
	- *Details:*
      - *ANC Duplication:* `ANC.3...108` and `ANC.3...109` were identical. Removed `...109`, renamed `...108` to `ANC.3`.
      - *Potassium Naming:* Two columns were named `HyperK+.3`, with no `HypoK+.3`. Renamed the first instance to `HypoK+.3`.
      - *Cycle 7 Mislabeling:* Variables labeled `.6` in the Cycle 7 section were renamed to Cycle 7.
- [x] **DAT-002: Redundant data columns**
	- *Resolved:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `fix_duplicate-content`).
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-content`).
	- *Summary:* Several columns identified as duplicates or artifacts.
	- *Details:*
		- *Redundant Content:* `Febrile.Neutropenia` (duplicate of `ANC`) and `HyperK+` (duplicate of `HypoK+`) were removed for all cycles.
		- *Duplicate Column:* `Hypernatramia.Na+.3` (identical to `Hyponatramia.Na+.3`) was removed.
		- *Documentation Artifacts:* All `Cycle #` spacer columns removed.

- [x] **DAT-003: Inconsistent Variable Naming**
	- *Resolved:* [2025-11-28] in `01_data-cleaning.qmd` (Chunk: `fix_longitudinal-consistency`).
	- *Observed:*[2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_longitudinal-consistency`)
	- *Summary:* Several longitudinal variables had minor inconsistencies, missing suffixes, or typos.
	- *Details:*
		- *Harmonized:* Capitalized all stems (`DBIL`, `HB`, `TBIL`), realigned with original naming scheme (`HypoNa+`).
		- *Corrected:* Applied missing suffixes (`Hospitalization.days.2`), fixed typos (`Hospitalization.required.due.to.toxicity?`).

- [x] **DAT-011: General Variable Renaming**
	- *Resolved:* [2025-11-29] in `01_data-cleaning.qmd` (Chunk: `apply_standard-names`).
	- *Observed:* [2025-11-16] in `01_data-cleaning.qmd` (Chunk: `assess_duplicate-names`).
	- *Summary:* Raw variable names contained factor levels and long strings.
	- *Details:* 
		- *Standardized:* Simplified names and converted all to snake case. Baseline measurements denoted with `_0` suffix. Longitudinal measurements denoted with `_#` suffix for appropriate cycle number.

[2025-11-30]

- [x] **DAT-012: Factors Encoded as Numeric**
	- *Resolved:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
	- *Summary:* Categorical variables were imported as numeric. 
	- *Details:* 
	  - *Coerced Data Types:* Converted to factors with explicit labels based on variable names from `IPROTECTARetrospecti_DATA_2025-08-19_2157 FINAL SHEET.xlsx`.
- [x] **DAT-013: Empty Columns as Logical**
	- *Resolved:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
	- *Summary:* `cr_clear_0`, `albi_score_0`, and `dbil_12` are stored as `logical` because they contain only `NA`.
	- *Details:*
	  - *Coerced Data Types:* Converted all to `numeric`.
- [x] **DAT-014: Date Precision**
	- *Resolved:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `apply_type-coercion`).
	- *Observed:* [2025-11-30] in `01_data-cleaning.qmd` (Chunk: `assess_data-types`).
	- *Summary:* `death_date` is stored as `POSIXct` (DateTime).
	- *Details:* 
		- *Coerced Data Type:* Converted to `Date` class.