# Gastrointestinal Cancer

Comparing real world gastrointestinal cancer chemotherapy treatment related adverse events incidence and severity between HIV positive and HIV negative patients in Zimbabwe - Hematological and hepatic functions.

## Contributors

-   Tinashe A. Mazhindu
-   Audrey E. Hendricks
-   E. Duke Chase

## Repository Contents

This project is structured as a reproducible R environment using `renv` and Quarto.

-   `01_data-cleaning.qmd`: The main Quarto document containing initial exploratory analyses, data cleaning, and validation.
-   `R/setup.R`: The R script that loads packages and sets global options.
-   `_quarto.yml`: The project configuration file, which sets the HTML theme and other rendering options.
-   `data/`: **(Ignored by Git)** Directory for raw data files.
-   `docs/`: **(Ignored by Git)** Reference materials.
-   `output/`: **(Ignored by Git)** Directory for saved results and exported plots.
-   `renv.lock` / `.Rprofile`: Files that ensure the R environment is fully reproducible.

## Data Availability

The raw data for this project involves patient medical records and is not included in this repository to protect patient privacy.

## System Details

-   **R Version**: 4.5.0
-   **OS**: Windows 11 Pro (E. Duke Chase)

## How to Reproduce the Analysis

1.  **Clone the Repository**: `git clone <repository-url>`
2.  **Open the Project**: Open the `.Rproj` file in RStudio.
3.  **Add Data**: Ensure raw data files are present in the `data/` directory.
4.  **Restore the Environment**: Run `renv::restore()` in the R console to install the exact package versions used.
