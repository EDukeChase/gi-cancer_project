# R Scripts

This directory contains all R scripts used for project setup and automation.

`setup.R`

**Purpose:** This is the main project setup script.

This file is sourced by the main `.qmd` document (in the setup chunk) every time the project is rendered. Its job is to:

-   Load all necessary R packages (library(...)).
-   Set global knitr chunk options (knitr::opts_chunk\$set(...)).
-   Define global plot settings (like the theme_set and color-blind friendly palettes).
-   Contain any helper functions that are used in the analysis.
