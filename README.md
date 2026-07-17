# Gastrointestinal Cancer

Comparing real world gastrointestinal cancer chemotherapy treatment related adverse events incidence and severity between HIV positive and HIV negative patients in Zimbabwe - Hematological and hepatic functions.

## Contributors

-   Tinashe A. Mazhindu
-   Audrey E. Hendricks
-   E. Duke Chase

## Repository Contents

This project is structured as a reproducible R environment using `renv` and Quarto.

-   `1 - Data Cleaning.qmd` through `5 - Publication Figures.qmd`: The numbered Quarto pipeline (data cleaning, validation, descriptive stats, analysis, publication figures/tables), rendered in order.
-   `6 - Causal Diagrams (DAGs).qmd`: Supplementary causal diagrams.
-   `R/setup.R`: The R script that loads packages, sets global options, and resolves the OneDrive path/helpers.
-   `R/README.md`: Describes `setup.R`'s helpers in more detail.
-   `_quarto.yml` / `_quarto-laptop.yml` / `_quarto-desktop.yml`: Project configuration; the `_quarto-<profile>.yml` files set each machine's rendered-output destination (see below).
-   `data/`: Holds only the two files that are tracked in git (`README.md`, `grading_rules.csv`) — all raw and processed data lives on OneDrive, not in this repo.
-   `docs/`: Reference materials and documentation (partially tracked — see `docs/README.md`).
-   `renv.lock` / `.Rprofile`: Files that ensure the R environment is fully reproducible.

## Data & Output Location

Raw data, processed `.rds` files, tables, figures, and rendered `.html` docs all live on a shared OneDrive folder rather than in this repository, both to protect patient privacy and so a non-programmer collaborator has one place to look for results. Each machine that works on this project needs a `.Renviron` file (copy `.Renviron.example`, fill in `GIC_ONEDRIVE_ROOT` and `QUARTO_PROFILE` for that machine, restart R) — see `R/setup.R` for how these are used.

## System Details

-   **R Version**: 4.5.0
-   **OS**: Windows 11 Pro (E. Duke Chase)

## How to Reproduce the Analysis

1.  **Clone the Repository**: `git clone <repository-url>`
2.  **Open the Project**: Open the `.Rproj` file in RStudio.
3.  **Configure OneDrive access**: Copy `.Renviron.example` to `.Renviron` and fill in `GIC_ONEDRIVE_ROOT` and `QUARTO_PROFILE` for this machine, then restart R.
4.  **Restore the Environment**: Run `renv::restore()` in the R console to install the exact package versions used.
