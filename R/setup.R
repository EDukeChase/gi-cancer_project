# --- Core packages ---
library(broom)              # 
library(broom.helpers)      # 
library(car)                # VIF
library(gt)                 # HTML optimized tables
library(gtsummary)          # 
library(here)               # Robust file paths
library(kableExtra)         # Table formatting
library(knitr)              # Used for running R code in Quarto
library(lme4)               # Mixed-effects models
library(patchwork)          # 
library(RColorBrewer)       # Color palettes to enable color-blind friendliness
library(scales)             # Simplify palette visualization
library(tidyverse)          # Essential R packages (Can pare down later)


# --- Set seed for reproducibility ---
set.seed(4534174)

# --- Set global options ---
knitr::opts_chunk$set(
  echo = TRUE,
  fig.width = 8,
  fig.asp = 0.618,
  fig.align = 'center'
)

# --- Define color-blind friendly color palettes ---
cb_light  <- RColorBrewer::brewer.pal(8, "Set2")
cb_dark   <- RColorBrewer::brewer.pal(8, "Dark2")
cb_paired <- RColorBrewer::brewer.pal(12, "Paired")

show_pal <- function(palette) {
  scales::show_col(palette)
}

# --- Set plot options ---
theme_set(theme_minimal(base_size = 12))

# Apply color palette
options(
  ggplot2.discrete.colour = cb_light,
  ggplot2.discrete.fill = cb_light,
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis"
)

# --- Project Metadata & Variable Mapping ---

# Define clinical panels for longitudinal data
# Used for audits, visualization grouping, and type-checks
var_groups <- tibble(
  stem = c(
    "hb", "mcv", "mch", "plt", "wbc", "anc", "lcc",                # 1. CBC
    "sodium", "potassium",                                         # 2. Chem
    "tp", "alb", "tbil", "dbil", "alp", "alt", "ast", "ggt",       # 3. LFT
    "cycle_delayed", "hosp_toxicity", "hosp_days", 
    "transfusion_given", "transfusion_units", "csfg_indicated"     # 4. Mgmt
  ),
  panel = c(
    rep("1. CBC", 7),
    rep("2. Chem", 2),
    rep("3. LFT", 8),
    rep("4. Mgmt", 6)
  )
)

# Helper to identify management variables vs lab variables
mgmt_stems <- var_groups |> 
  filter(panel == "4. Mgmt") |> 
  pull(stem)
