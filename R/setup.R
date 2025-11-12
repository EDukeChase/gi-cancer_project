# --- Always used packages ---
library(here)               # Robust file paths
library(knitr)              # Used for running R code in Quarto
library(RColorBrewer)       # Color palettes to enable color-blind friendliness
library(tidyverse)          # Essential R packages (Can pare down later)


# --- Set seed for reproducibility ---
set.seed(4534174)

# --- Set global chunk options ---
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.width = 8,
  fig.asp = 0.618,
  fig.align = 'center'
)

# --- Set plot options ---
theme_set(theme_minimal(base_size = 12))
options(
  ggplot2.discrete.colour = RColorBrewer::brewer.pal(3, "Dark2"),
  ggplot2.discrete.fill = RColorBrewer::brewer.pal(3, "Dark2"),
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis"
)

# --- Custom Functions ---
