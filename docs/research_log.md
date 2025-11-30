# Research Issues & Tasks Log

This document tracks outstanding questions, data anomalies, and to-do items identified during analysis.

**Status Legend:**
- [ ] Open (Needs attention)
- [/] In Progress
- [x] Resolved (See notes for resolution details)

---

## Data Integrity & Anomalies
*Issues requiring investigation into the raw data's accuracy or meaning.*

- [ ] **Baseline vs. cycle 1 electrolytes:**
    - *Observation:* `HypoNa+.1` is identical to `Baseline.Na+` (same for Potassium). This pattern does not hold for other biomarkers.
	- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
    - *Task:* Verify if Cycle 1 is officially the baseline for electrolytes, or if this is a data duplication error.
- [ ] **Possible Blood transfusion duplication:**
    - *Observation:* For cycles 4, 7, 8, 9, and 11, `transfusion_given` and `transfusion_units` are identical.
	- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
    - *Implication:* This implies every single transfusion in those cycles was exactly 1 unit.
    - *Task:* Check `transfusion_units` with other cycles to see if this is likely, or data entry mistake.
- [ ] **Cycle 10 hospitalization variable:**
    - *Observation:* `Hospitalization.required...10` is identical to `Was.the.cycle.delayed...10`.
	- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
    - *Task:* Compare with other cycles to see if this correlation is plausible or a data entry mistake.
- [ ] **Zero comorbidities:**
    - *Observation:* No patients have COPD, Kidney Disease, or Epilepsy recorded.
	- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
    - *Task:* Verify this isn't a data loss error (low priority, likely accurate).
- [ ] **Empty `dbil_12`:**
    - *Issue:* Column is entirely empty, however there were other liver panel results for patients in cycle 12.
	- *Location:* `02_data-cleaning.qmd` (Chunk: tbd)
    - *Task:* Confirm if this is expected missingness (not tested) or data loss
- [ ] **Cancer stage 4 ambiguity:**
    - *Observation:* The column name implies `4` could mean either "Stage IV" or "Unknown/Undocumented".
	- *Location:* `02_data-validation.qmd` (Chunk: tbd)
    - *Task:* Clarify with Tinashe. Until then, treat as "IV / Unknown".
- [ ] **Investigate baseline measurement outliers:**
    - *Issue:* Impossible values found (Height > 14 meters, BMI 0.2).
	- *Location:* `02_data-validation.qmd` (Chunk: tbd)
    - *Task:* Implement cleaning logic in `02_data-validation.qmd`.

## 2. Technical Tasks (To-Do)
*Action items for coding, refactoring, data cleaning, and validation scripts.*

- [ ] **Begin data validation:**
	- *Tasks:* 
		- Convert columns to correct data type and audit for accidental changes
		- Examine missingness
		- Identify invalid entries
		- Veryify that `cycles_prescribed` >= `cycles_given`.
		- Verify that `cycles_given` matches up with actual number of cycles containing data for each patient.
		- Verify composite variables (`completion_rate`, `bmi`).
		- Add graded adverse event columns.
- [ ] **Standardize Audit Functions:**
    - *Task:* Modify `format_audit_table()` to be a single, universal function that handles all audit types (duplicates, cycles, static vars) to reduce code duplication.

## 3. Methodology
*Decisions affecting the statistical plan or grading logic.*

- [/] **Febrile Neutropenia vs. ANC:**
    - *Issue:* Raw data had `ANC` and `Febrile.Neutropenia` as identical columns.
	- *Location:* `01_data-cleaning.qmd` (Chunk: `duplicate-column-contents`)
    - *Decision:* Deleted `Febrile.Neutropenia` to remove redundancy.
    - *Task:* FN is neutropenia with a fever, but there is no fever data present, and the `ANC` and `Febrile.Neutropenia` columns contained identical measurements.
- [ ] **Adverse Event Grading Rules:**
    - *Issue:* Edge case ambiguity in adverse event grading criteria.
	- *Location:* `NOrmal ranges and Adverse Events grading system.xlsx`
    - *Task:* Secure a definitive reference standard from the Tinashe.

## 4. Project Management & Admin
*Communication, documentation updates, and external coordination.*
- [ ] **Update Glossary:**
    - *Task:* Add `transfusion_units` valid ranges once verified.
	- *Location:* `docs/glossary.md`, `docs/glossary.xlsx`.
- [ ] **Email Tinashe:**
    - *Topic:* Inquire about outstanding issues/tasks/questions.


---

## Resolved Items Archive

- [x] **Duplicate column names:**
    - *Issue:* The raw Excel file contained several columns with identical or mislabeled headers.
    - *Resolved:* [2025-11-16] Renamed/Deleted duplicates in `01_data_cleaning.qmd` (Chunk: `fix_duplicate-column-names`). Confirmed Cycle 7 fix with Dr. Hendricks.
- [x] **Redundant data columns:**
    - *Issue:* Several columns identified as duplicates or artifacts.
    - *Resolved:* [2025-11-16] The columns were removed in `01_data_cleaning.qmd` (Chunk: `fix_duplicate-column-contents`).
- [x] **Inconsistent Variable Naming:**
    - *Issue:* Several cycle variables had minor inconsistencies, missing suffixes, or typos in their naming.
    - *Resolved:* [2025-11-28] Harmonized naming conventions in `01_data_cleaning.qmd` (Chunk: `fix_cycle-var-consistency`).
- [x] **General Variable Renaming:**
    - *Issue:* Raw variable names contained factor levels and long strings.
    - *Resolved:* [2025-11-29] Converted all variables to standardized snake_case format in `01_data_cleaning.qmd` (Chunk: `rename`).