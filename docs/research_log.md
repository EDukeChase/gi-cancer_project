# Research Issues & Tasks Log

This document tracks outstanding questions, data anomalies, and to-do items identified during analysis.

**Status Legend:**
- [ ] Open (Needs attention)
- [/] In Progress
- [x] Resolved (See notes for resolution details)

---

## Analysis Roadmap
- **Data Cleaning:**
	- [x] Check columns that had the same names in the excel file.
	- [/] Check columns that have identical contents.
	- [x] Check consistency of cycle specific variables.
	- [x] Standardize variable names using snake case.
	- [x] Audit each step of variable name standardization.
	- [x] Encode variables as correct data types.
	- [/] Audit variables after encoding.
- **Data Validation:**
	- [x] [2025-11-30] Convert columns to correct data type and audit for accidental changes
	- [ ] Examine missingness
	- [ ] Identify invalid entries
	- [ ] Veryify that `cycles_prescribed` >= `cycles_given`.
	- [ ] Verify that `cycles_given` matches up with actual number of cycles containing data for each patient.
		- Consider cycle data in chunks of "CBC Panel", "Chemisty Panel", "LFT Panel" and "Management"
	- [ ] Verify composite variables (`completion_rate`, `bmi`).
	- [ ] Add graded adverse event columns.

## Data Integrity & Anomalies
*Issues requiring investigation into the raw data's accuracy or meaning.*

- [/] **Baseline vs. cycle 1 electrolytes:**
    - *Observation:* `HypoNa+.1` is identical to `Baseline.Na+` (same for Potassium). This pattern does not hold for other biomarkers.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
	- *Temporary Resolution:* Assume data are correct.
    - *Task:* Verify if Cycle 1 is officially the baseline for electrolytes, or if this is a data duplication error.
- [/] **Possible Blood transfusion duplication:**
    - *Observation:* For cycles 4, 7, 8, 9, and 11, `transfusion_given` and `transfusion_units` are identical.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
    - *Implication:* This implies every single transfusion in those cycles was exactly 1 unit.
	- *Temporary Resolution:* Assume data are correct.
    - *Task:* Check `transfusion_units` with other cycles to see if this is likely, or data entry mistake.
- [/] **Cycle 10 hospitalization variable:**
    - *Observation:* `Hospitalization.required...10` is identical to `Was.the.cycle.delayed...10`.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
	- *Temporary Resolution:* Assume data are correct.
    - *Task:* Compare with other cycles to see if this correlation is plausible or a data entry mistake.
- [/] **Zero comorbidities:**
    - *Observation:* No patients have COPD, Kidney Disease, or Epilepsy recorded.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
	- *Temporary Resolution:* Assume data are correct.
    - *Task:* Verify this isn't a data loss error (low priority, likely accurate).
- [/] **Factor level mismatch:**
	- *Observation:* The documented encoding for `residence` is "1 = urban; 2 = rural; 3 = peri-urban", but observed levels are 0, 1, and 2.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `encode-types`)
	- *Temporary Resolution:* Will assume 0 = urban, 1 = rural, 2 = peri-urban.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `encode-types`).
	- *Task:* Clarify correct encoding.
- [/] **Numeric Column as Character:**
	- *Issue:* `ast_1` is stored as a character vector.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `type-scan`)
	- *Investigation:* `record_id == 64` contains the value "pn" for `ast_1`.
	- *Temporary Resolution*: Coerced "pn" to `NA`.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `encode-types`).
	- *Task:* Clarify whether this was data misentry or if "pn" has a specific meaning.
- [/] **Invalid Level (`sex`):** 
	- *Issue:* The variable `sex` contained the raw value `3` (defined levels: 1=Male, 2=Female).
    - *Investigation:* Traced to `record_id == 94`.
    - *Temporary Resolution:* Value was coerced to `NA` during encoding to maintain factor integrity.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `encode-types`).
    * *Task:* Clarify with Tinashe if `3` represents a valid category or a data entry error.
- [/] **Empty `dbil_12`:**
    - *Observation:* Column is entirely empty, however there were other liver panel results for patients in cycle 12.
		- *Location:* `02_data-cleaning.qmd` (Chunk: tbd)
	- *Temporary Resolution:* Assume data are correct.
    - *Task:* Confirm if this is expected missingness (not tested) or data loss
- [/] **Empty `abli_score_0` and `cr_clear_0`:**
	- *Observation:* Columns are entirely empty.
		- *Location:* `02_data-cleaning.qmd` (Chunk: tbd)
	- *Temporary Resolution:* Leave columns in place, exclude from analysis.
	- *Task:* Confirm if data are missing, or if columns should be removed.
- [ ] **Cancer stage 4 ambiguity:**
    - *Observation:* The column name implies `4` could mean either "Stage IV" or "Unknown/Undocumented".
		- *Location:* `02_data-validation.qmd` (Chunk: tbd)
%%	- *Temporary Resolution:* Treat a value of `4` as "Stage IV / Unknown".
    - *Task:* Clarify with Tinashe.
- [ ] **Investigate baseline measurement outliers:**
    - *Observation:* Impossible values found (Height > 14 meters, BMI 0.2).
		- *Location:* `02_data-validation.qmd` (Chunk: tbd)
    - *Task:* Implement cleaning logic in `02_data-validation.qmd`.

## Technical Tasks (To-Do)
*Action items for coding, refactoring, data cleaning, and validation scripts.*

- [ ] **Standardize Audit Functions:**
	- *Priority:* Very low
	- *Location:* `01_data-cleaning.qmd`.
    - *Task:* Modify `format_audit_table()` to be a single, universal function that handles all audit types (duplicates, cycles, static vars) to reduce code duplication.
- [ ] **Fix ToC Issue**
	- *Priority:* Very low
	- *Location:* `01_data-cleaning.qmd`.
	- *Issue:* Table of contents on right side of rendered HTML pages is no longer dynamic aside from acting as links; it only shows top level headers and the first one is always highlighted, regardless of what link was last clicked. Links do work. Suspect this might have something to do with the `kableExtra::scroll_box()` function used throughout.

## Methodology
*Decisions affecting the statistical plan or grading logic.*

- [/] **Febrile Neutropenia vs. ANC:**
    - *Issue:* Raw data had `ANC` and `Febrile.Neutropenia` as identical columns.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
    - *Temporary Resolution:* Deleted `Febrile.Neutropenia` to remove redundancy.
    - *Task:* Consult with Tinashe, since FN is neutropenia with a fever, but there is no fever data present, and the `ANC` and `Febrile.Neutropenia` columns contained identical measurements.
- [ ] **Adverse Event Grading Rules:**
    - *Issue:* Edge case ambiguity in adverse event grading criteria.
		- *Location:* `NOrmal ranges and Adverse Events grading system.xlsx`
    - *Task:* Secure a definitive reference standard from the Tinashe.

## Project Management & Admin
*Communication, documentation updates, and external coordination.*
- [ ] **Update Glossary:**
	- *Task:* Add all missing valid and reference ranges.
		- *Location:* `docs/glossary.md`, `docs/glossary.xlsx`.
- [ ] **Email Tinashe:**
    - *Topic:* Inquire about outstanding issues/tasks/questions.


---

## Resolved Items Archive

[2025-11-16]

- [x] **Duplicate column names:**
    - *Issue:* The raw Excel file contained several columns with identical or mislabeled headers.
    - *Resolved:* [2025-11-16] Renamed/deleted duplicates. 
		- *Location*: `01_data-cleaning.qmd` (Chunk: `fix_duplicate-column-names`). 
- [x] **Redundant data columns:**
    - *Issue:* Several columns identified as duplicates or artifacts.
    - *Resolved:* [2025-11-16] The columns were removed.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `fix_duplicate-column-contents`).

[2025-11-28]

- [x] **Inconsistent Variable Naming:**
    - *Issue:* Several cycle variables had minor inconsistencies, missing suffixes, or typos in their naming.
    - *Resolved:* [2025-11-28] Harmonized naming conventions
		- *Location:* `01_data-cleaning.qmd` (Chunk: `fix_cycle-var-consistency`).

[2025-11-29]

- [x] **General Variable Renaming:**
    - *Issue:* Raw variable names contained factor levels and long strings.
    - *Resolved:* [2025-11-29] Converted all variables to standardized snake_case format.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `rename`).

[2025-11-30]

- [x] **Factors Encoded as Numeric:**
	- *Issue:* Categorical variables were imported as numeric.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `type-scan`).
	- *Resolved:* [2025-11-30] Converted to factors with explicit labels based on variable names from `IPROTECTARetrospecti_DATA_2025-08-19_2157 FINAL SHEET.xlsx`.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `encode-types`).
- [x] **Empty Columns as Logical:**
	- *Issue:* `cr_clear_0`, `albi_score_0`, and `dbil_12` are stored as `logical` because they contain only `NA`.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `type-scan`).
	- *Resolved:* [2025-11-30] Coerced to `numeric`.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `encode-types`).
- [x] **Date Precision:**
	- *Issue:* `death_date` is stored as `POSIXct` (DateTime).
		- *Location:* `01_data-cleaning.qmd` (Chunk: `type-scan`).
	- *Resolved:* [2025-11-30] Converted to `Date` class.
		- *Location:* `01_data-cleaning.qmd` (Chunk: `encode-types`).