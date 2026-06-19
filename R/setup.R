# ===================== #
#     Project Setup     #
# ===================== #


# --- Packages --- #

library(broom)              # 
library(broom.helpers)      # 
library(car)                # VIF
library(downloadthis)       # Download csv versions of gt tables
library(flextable)          # Table formatting for docx
library(glue)               # Easier syntax than paste0
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


# --- Reproducibility --- #
set.seed(4534174)


# --- Rendering options --- #
knitr::opts_chunk$set(
  echo = TRUE,
  fig.width = 8,
  fig.asp = 0.618,
  fig.align = 'center'
)


# --- Color palettes --- #
cb_light  <- RColorBrewer::brewer.pal(8, "Set2")
cb_dark   <- RColorBrewer::brewer.pal(8, "Dark2")
cb_paired <- RColorBrewer::brewer.pal(12, "Paired")

show_pal <- function(palette) {
  scales::show_col(palette)
}


# --- Plot theme --- #
theme_set(theme_minimal(base_size = 12))

options(
  ggplot2.discrete.colour = cb_light,
  ggplot2.discrete.fill = cb_light,
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis"
)


# --- Project parameters ---
# [MET-005] Patients who stopped at or before this cycle count as early dropouts
early_dropout_cycles <- 4

# --- Variable metadata --- #

# Clinical panels for longitudinal data (audits, visualization grouping, type-checks)
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

mgmt_stems <- var_groups |> 
  filter(panel == "4. Mgmt") |> 
  pull(stem)

ae_labels <- c(
  hb            = "Anemia",
  plt           = "Thrombocytopenia",
  wbc           = "Leukopenia",
  anc           = "Neutropenia",
  lcc           = "Lymphopenia",
  hyponatremia  = "Hyponatremia",
  hypernatremia = "Hypernatremia",
  hypokalemia   = "Hypokalemia",
  hyperkalemia  = "Hyperkalemia",
  alb           = "Hypoalbuminemia",
  tbil          = "Hyperbilirubinemia",
  alp           = "Elevated ALP",
  alt           = "Elevated ALT",
  ast           = "Elevated AST"
)

# Combined AE categories per MET-007
ae_group_map <- c(
  hb            = "Anemia",
  plt           = "Myelosuppression",
  wbc           = "Myelosuppression",
  anc           = "Myelosuppression",
  lcc           = "Myelosuppression",
  hyponatremia  = "Hyponatremia",
  hypernatremia = "Hypernatremia",
  hypokalemia   = "Hypokalemia",
  hyperkalemia  = "Hyperkalemia",
  alb           = "Hypoalbuminemia",
  tbil          = "Hyperbilirubinemia",
  alp           = "Raised transaminases",
  alt           = "Raised transaminases",
  ast           = "Raised transaminases"
)

# --- Helper functions --- #

# Format count and percentage for binary variables
summ_n_pct <- function(x, digits = 1) {
  n <- sum(x == 1, na.rm = TRUE)
  pct <- 100 * n / sum(!is.na(x))
  paste0(n, " (", round(pct, digits), "%)")
}

summ_stats <- function(x, mean = TRUE, range = FALSE, digits = 1) {
  x <- x[!is.na(x)]
  
  if (mean) {
    # Format: Mean (SD); Lower–Upper
    avg    <- mean(x)
    spread <- sd(x)
    outer  <- if (range) range(x) else quantile(x, c(0.25, 0.75), names = FALSE)
    
    paste0(
      round(avg, digits), " (", round(spread, digits), "); ",
      round(outer[1], digits), "–", round(outer[2], digits)
    )
  } else {
    # Format: Median (IQR)
    med <- median(x)
    iqr <- quantile(x, c(0.25, 0.75), names = FALSE)
    
    paste0(round(med, digits), " (", round(iqr[1], digits), "–", round(iqr[2], digits), ")")
  }
}

# Format median with IQR
summ_median_iqr <- function(x, digits = 1) {
  x <- x[!is.na(x)]
  med <- median(x)
  q <- quantile(x, probs = c(0.25, 0.75), names = FALSE)
  paste0(round(med, digits), " (", round(q[1], digits), "–", round(q[2], digits), ")")
}

# Format mean, SD, and range
summ_mean_sd_range <- function(x, digits = 1) {
  x <- x[!is.na(x)]
  m <- mean(x)
  s <- sd(x)
  rng <- range(x)
  paste0(
    round(m, digits), " (", round(s, digits), "); ",
    round(rng[[1]], digits), "–", round(rng[[2]], digits)
  )
}

# Format mean, SD, and IQR
summ_mean_sd_iqr <- function(x, digits = 1) {
  x <- x[!is.na(x)]
  m <- mean(x)
  s <- sd(x)
  q <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE, names = FALSE)
  paste0(
    round(m, digits), " (", round(s, digits), "); ",
    round(q[1], digits), "–", round(q[2], digits)
  )
}

# Format p-values (scientific notation below 0.001)
format_p <- function(p) {
  if (is.na(p)) return("—")
  if (p < 0.01) return(formatC(p, format = "e", digits = 2))
  as.character(round(p, 2))
}

# Safe/interactive save function
save_rds_safe <- function(object, path) {
  if (file.exists(path) && interactive()) {
    response <- readline(prompt = paste("Warning:", basename(path), "already exists. Overwrite? (y/n):"))
    if (tolower(substr(response, 1, 1)) == "y") {
      saveRDS(object, path)
      message("File overwritten: ", basename(path))
    } else {
      message("Save operation cancelled: ", basename(path))
    }
  } else {
    saveRDS(object, path)
    message("File saved: ", basename(path))
  }
}


save_table_docx <- function(gtsum, name) {
  if (!save_outputs) return(invisible(NULL))
  gtsum |>
    as_flex_table() |>
    flextable::save_as_docx(path = here("output", "tables", paste0(name, ".docx")))
}

# Write a data frame to csv + docx and return a flextable for display
make_downloadable <- function(df, slug, ft = NULL) {
  csv_path  <- here("output", "tables", paste0(slug, ".csv"))
  docx_path <- here("output", "tables", paste0(slug, ".docx"))
  
  write.csv(df, csv_path, row.names = FALSE)
  if (is.null(ft)) ft <- df |> flextable() |> theme_booktabs() |> autofit()
  save_as_docx(ft, path = docx_path)
  
  list(ft = ft, csv = csv_path, docx = docx_path, slug = slug)
}

emit_buttons <- function(obj) {
  cat('<div style="display: flex; gap: 10px; margin-top: 15px; margin-bottom: 25px;">')
  print(download_file(
    path = obj$csv, output_name = obj$slug,
    button_label = "Download CSV", button_type = "primary",
    class = "btn-sm", has_icon = TRUE, icon = "fa fa-database"
  ))
  print(download_file(
    path = obj$docx, output_name = obj$slug,
    button_label = "Download Word Doc", button_type = "default",
    class = "btn-sm", has_icon = TRUE, icon = "fa fa-file-word"
  ))
  cat('</div>')
}
