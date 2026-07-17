# Data Directory

Raw and processed data now live on OneDrive rather than in this folder (see the root `README.md` for how each machine is configured). This local `data/` folder only holds two files that are intentionally tracked in git:

-   `README.md`: this file.
-   `grading_rules.csv`: adverse-event grading criteria (not patient data), versioned here so changes to grading logic are tracked in commit history.

Everything else — the raw source files (`IPROTECTARetrospecti_DATA_2025-08-19_2157 FINAL SHEET*`, `different_administered.csv`) and `processed/*.rds` — lives under `<OneDrive project root>/data/` and `<OneDrive project root>/data/processed/`, resolved in code via `onedrive_data_path()` (defined in `R/setup.R`).
