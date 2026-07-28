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


# --- OneDrive root --- #
# All data, tables, figures, and rendered docs live on OneDrive rather than
# in the local repo. Configure this machine's path via `.Renviron` (copy
# `.Renviron.example`, fill in GIC_ONEDRIVE_ROOT, restart R).
onedrive_root <- Sys.getenv("GIC_ONEDRIVE_ROOT", unset = NA)

if (is.na(onedrive_root) || onedrive_root == "") {
  stop(
    "GIC_ONEDRIVE_ROOT is not set. Copy .Renviron.example to .Renviron, ",
    "fill in this machine's OneDrive path, and restart R."
  )
}
if (!dir.exists(onedrive_root)) {
  stop(
    "GIC_ONEDRIVE_ROOT is set to '", onedrive_root, "', but that folder ",
    "doesn't exist. Check that OneDrive is running/synced and that the ",
    "path in .Renviron is correct for this machine."
  )
}

onedrive_path      <- function(...) file.path(onedrive_root, ...)
onedrive_data_path <- function(...) onedrive_path("data", ...)


# --- Reproducibility --- #
set.seed(4534174)


# --- Rendering options --- #
# NOTE: echo is deliberately NOT set here. opts_chunk$set() runs when this file
# is sourced, i.e. after the YAML has been applied, so setting echo here would
# silently override each document's `execute: echo:` setting. That is exactly
# what used to happen: "4 - Statistical Analysis.qmd" asks for echo: false and
# got echo: true anyway. Control echo per document in its YAML header.
knitr::opts_chunk$set(
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

# Combined ADE categories per MET-007
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


# Multicollinearity check for any model car::vif() supports (lm, glm, merMod).
# Returns a tidy tibble of (G)VIF values with a flag column rather than raw
# car::vif() output, so it can be dropped into a table/callout without
# fussing over the lm vs glm vs merMod return shape each time. Wrapped in
# tryCatch because sparse/rank-deficient model fits (common with small
# subgroup models here) make car::vif() error rather than return a value.
check_vif <- function(model, threshold = 5) {
  result <- tryCatch(car::vif(model), error = function(e) e)

  if (inherits(result, "error")) {
    return(tibble(term = NA_character_, gvif = NA_real_, flag = NA,
                  note = paste("VIF not computable:", conditionMessage(result))))
  }

  if (is.matrix(result)) {
    # Multi-df terms (factors) return a matrix with columns
    # GVIF, Df, GVIF^(1/(2*Df)) — the first column is the raw GVIF itself,
    # comparable in spirit to a single-df VIF (though strictly speaking the
    # df-adjusted third column is what's conventionally compared to
    # sqrt(threshold) for high-df terms; using raw GVIF here is the simpler,
    # more conservative screening choice).
    out <- tibble(term = rownames(result), gvif = result[, "GVIF"])
  } else {
    out <- tibble(term = names(result), gvif = as.numeric(result))
  }

  out |>
    mutate(flag = gvif > threshold, note = NA_character_)
}

# Screen a fitted binomial model for complete / quasi-complete separation, the
# way the transfusion model was checked by hand. Returns a list of two tibbles:
#
#   $cells  one row per level of each categorical predictor in the model frame,
#           with the event count and an `separated` flag marking levels where
#           the outcome never varies (all events or no events). These empty
#           cells are the *cause* of separation.
#   $coefs  fixed effects whose magnitude or standard error is implausibly
#           large, which is how separation *presents* after fitting. A real
#           clinical odds ratio above `or_max` or a standard error above
#           `se_max` on the log-odds scale is almost always separation, not a
#           finding.
#
# Works on glm and glmerMod. Note this screens categorical predictors only;
# separation on a continuous predictor (e.g. age perfectly ordering the
# outcome) will show up in $coefs but not $cells.
check_separation <- function(model, or_max = 100, se_max = 10) {
  mf     <- model.frame(model)
  y_name <- all.vars(formula(model))[1]

  # Outcome may be stored as a factor, logical, or 0/1 numeric.
  y_raw <- mf[[y_name]]
  y <- if (is.factor(y_raw)) as.integer(y_raw) - 1L else as.numeric(y_raw)

  cat_vars <- names(mf)[vapply(mf, function(x) is.factor(x) || is.character(x),
                               logical(1))]

  # A merMod model frame includes the random-effect grouping factor, e.g.
  # record_id. Left in, it would report one "separated" row per patient who
  # contributed a single cycle -- hundreds of rows of noise that mean nothing.
  grouping_vars <- if (inherits(model, "merMod")) {
    tryCatch(names(model@flist), error = function(e) character(0))
  } else {
    character(0)
  }

  cat_vars <- setdiff(cat_vars, c(y_name, grouping_vars))

  cells <- purrr::map_dfr(cat_vars, function(v) {
    tibble(level = as.character(mf[[v]]), y = y) |>
      group_by(level) |>
      summarise(n = n(), n_event = sum(y == 1, na.rm = TRUE), .groups = "drop") |>
      mutate(
        term      = v,
        pct_event = round(100 * n_event / n, 1),
        separated = n_event == 0 | n_event == n
      ) |>
      select(term, level, n, n_event, pct_event, separated)
  })

  # Fixed effects pulled directly rather than via broom/broom.mixed: plain
  # broom::tidy() does not handle merMod objects and broom.mixed is not in
  # renv.lock, so this stays dependency-free across glm and glmer.
  est <- if (inherits(model, "merMod")) lme4::fixef(model) else stats::coef(model)
  se  <- sqrt(diag(as.matrix(stats::vcov(model))))
  se  <- se[names(est)]

  coefs <- tibble(
    term      = names(est),
    estimate  = as.numeric(est),
    std.error = as.numeric(se)
  ) |>
    mutate(extreme = abs(estimate) > log(or_max) | std.error > se_max)

  list(cells = cells, coefs = coefs)
}

# Iteratively remove levels of `vars` that are fully separated on a binary
# `outcome` (every row an event, or none). Used instead of hard-coding the
# offending levels, because which levels separate depends on the stratum being
# fitted — the exclusions derived for one subset are not valid for another.
#
# Loops because removing rows for one separated level can newly separate a
# level of a different variable. Records what was removed in the
# "dropped_levels" attribute of the returned data so it can be reported in a
# table footnote.
drop_separated_levels <- function(data, outcome, vars, max_passes = 5,
                                  quiet = FALSE) {
  dropped <- list()

  for (pass in seq_len(max_passes)) {
    changed <- FALSE

    for (v in vars) {
      bad <- data |>
        group_by(.lvl = as.character(.data[[v]])) |>
        summarise(n = n(),
                  n_event = sum(.data[[outcome]] == 1, na.rm = TRUE),
                  .groups = "drop") |>
        filter(n_event == 0 | n_event == n) |>
        pull(.lvl)

      if (length(bad)) {
        dropped[[v]] <- union(dropped[[v]], bad)
        data <- data |> filter(!as.character(.data[[v]]) %in% bad)
        changed <- TRUE
      }
    }

    if (!changed) break
  }

  data <- data |>
    mutate(across(all_of(vars), \(x) if (is.factor(x)) fct_drop(x) else x))

  attr(data, "dropped_levels") <- dropped

  if (!quiet && length(dropped)) {
    message("drop_separated_levels(): removed ",
            paste(names(dropped),
                  vapply(dropped, paste, character(1), collapse = ", "),
                  sep = " = ", collapse = "; "))
  }

  data
}

# Render the dropped_levels attribute as a sentence for a table footnote.
# Attach a note beneath a gtsummary table. Wrapped so that a gtsummary build
# without modify_source_note() degrades to a warning rather than failing the
# whole render.
add_source_note <- function(tbl, text) {
  out <- tryCatch(gtsummary::modify_source_note(tbl, text),
                  error = function(e) NULL)
  if (is.null(out)) {
    warning("Could not attach source note: ", text, call. = FALSE)
    return(tbl)
  }
  out
}

# lme4 reports convergence trouble as console warnings, which are suppressed in
# the rendered analysis document. This surfaces the same information as a value,
# so it appears deliberately inside the validation callouts instead of as noise
# the collaborators have to scroll past.
check_convergence <- function(model) {
  if (!inherits(model, "merMod")) {
    return(tibble(singular_fit = NA, converged = NA, messages = "not a mixed model"))
  }
  msgs <- tryCatch(model@optinfo$conv$lme4$messages, error = function(e) NULL)
  tibble(
    singular_fit = tryCatch(lme4::isSingular(model), error = function(e) NA),
    converged    = length(msgs) == 0,
    messages     = if (length(msgs)) paste(msgs, collapse = " | ") else "none"
  )
}

# Model formula as a single tidy line, for stating plainly above a summary
# table rather than making the reader open the code.
fmt_formula <- function(model) {
  f <- paste(deparse(stats::formula(model)), collapse = " ")
  gsub("[[:space:]]+", " ", f)
}

show_formula <- function(model, label = "Model") {
  cat("*", label, ":* `", fmt_formula(model), "`\n\n", sep = "")
  invisible(NULL)
}

# Drop reference-level rows from a gtsummary regression table (20-Apr-2026 and
# 5-Jun-2026: they consume a lot of vertical space for no information), and
# record what the reference levels were in a note beneath the table.
#
# The note is deliberately *not* appended to the variable label. That was the
# first implementation and it forced labels like "Chemotherapy Type (ref:
# Platinum/Paclitaxel)" to wrap over several lines, which looked worse than the
# rows it replaced.
tbl_drop_ref_rows <- function(tbl) {
  if (!"reference_row" %in% names(tbl$table_body)) return(tbl)

  refs <- tbl$table_body |>
    filter(!is.na(reference_row), reference_row) |>
    select(variable, ref_label = label) |>
    distinct(variable, .keep_all = TRUE)

  if (nrow(refs) == 0) return(tbl)

  # Use the variable's display label in the note, not its raw column name.
  var_labels <- tbl$table_body |>
    filter(row_type == "label") |>
    select(variable, var_label = label) |>
    distinct(variable, .keep_all = TRUE)

  note <- refs |>
    left_join(var_labels, by = "variable") |>
    mutate(txt = paste0(coalesce(var_label, variable), " = ", ref_label)) |>
    pull(txt) |>
    paste(collapse = "; ")

  tbl |>
    gtsummary::remove_row_type(variables = everything(), type = "reference") |>
    add_source_note(paste0("Reference levels: ", note, "."))
}

# Display names for model variables, so tables show "Anemia grade" rather than
# "anemia_grade_f". Anything not listed falls through unchanged.
var_labels <- c(
  hiv_status     = "HIV status",
  anemia_grade_f = "Anemia grade",
  anemia_grade   = "Anemia grade",
  gcsf_grade     = "Max neutropenia/leukopenia grade",
  cancer_stage   = "Cancer stage",
  chemo_type     = "Chemotherapy type",
  cancer_site    = "Cancer site",
  age            = "Age (years)",
  sex            = "Sex",
  tx_intent      = "Treatment intent"
)

pretty_var <- function(x) {
  out <- unname(var_labels[x])
  ifelse(is.na(out), x, out)
}

# Just the levels. The explanation of *why* they were excluded belongs in the
# table caption, said once, not repeated verbatim in every row.
describe_dropped_levels <- function(data) {
  d <- attr(data, "dropped_levels")
  if (is.null(d) || !length(d)) return("None")
  paste(pretty_var(names(d)),
        vapply(d, paste, character(1), collapse = ", "),
        sep = " = ", collapse = "; ")
}

# Attach the exclusions to the model table itself, so a reader looking at an
# odd-looking factor (e.g. anemia grade showing only levels 1 and 2) can see
# immediately that the other levels were removed rather than absent from the
# data.
add_exclusion_note <- function(tbl, data) {
  d <- attr(data, "dropped_levels")
  if (is.null(d) || !length(d)) return(tbl)
  add_source_note(tbl, paste0(
    "Levels excluded because the outcome did not vary within them, so no ",
    "estimate is possible: ", describe_dropped_levels(data), "."
  ))
}



# --- Output paths ----------------------------------------------------------
#
#   tables/              hand-edited / merged copies. Code NEVER writes here.
#   tables/generated/    .docx tables, overwritten in full every render
#   tables/csv/          .csv versions of the same tables
#   figures/             .png figures
#   figures/svgs/        .svg figures, for journal submission
#
# Tables are the only output that gets edited by hand, so they are the only
# ones that need a generated/ subfolder keeping machine output separate.
# Figures are regenerated wholesale and nobody edits them, so they stay flat.

tables_edited_path    <- function(...) onedrive_path("tables", ...)
tables_generated_path <- function(...) onedrive_path("tables", "generated", ...)
tables_csv_path       <- function(...) onedrive_path("tables", "csv", ...)
figures_png_path      <- function(...) onedrive_path("figures", ...)
figures_svg_path      <- function(...) onedrive_path("figures", "svgs", ...)

# Creates the output tree on first use and drops a note in the two generated
# table folders, so anyone browsing the shared folder can tell at a glance
# which files are safe to edit.
ensure_output_dirs <- function() {
  dirs <- c(tables_edited_path(), tables_generated_path(), tables_csv_path(),
            figures_png_path(), figures_svg_path())
  for (d in dirs) if (!dir.exists(d)) dir.create(d, recursive = TRUE)

  note <- c(
    "AUTO-GENERATED -- DO NOT EDIT FILES IN THIS FOLDER.",
    "",
    "Everything here is written by the analysis code and is overwritten in",
    "full every time the pipeline is rendered. Any edit made here will be",
    "lost on the next render.",
    "",
    "Edited and reviewed copies belong one level up, in the tables/ folder",
    "itself. Nothing in the codebase writes there."
  )
  for (d in c(tables_generated_path(), tables_csv_path())) {
    readme <- file.path(d, "README.txt")
    if (!file.exists(readme)) writeLines(note, readme)
  }

  invisible(dirs)
}

# Human-readable filenames. Keyed by slug so nothing at the call sites has to
# change; anything missing falls back to a prettified slug, so a new
# save_table() call still produces a readable name without an entry here.
#
# Edit these freely -- they are only filenames. Changing one means the next
# render writes a new file rather than overwriting the old one, so delete the
# stale file from tables/generated/ if you rename.
output_names <- c(
  # Tables
  table1_descriptive             = "Table - Patient characteristics by HIV status",
  table_ae_by_category           = "Table - Adverse drug events by category and HIV status",
  tbl_severe_or_comparison       = "Table - Severe adverse events, adjusted odds by HIV status",
  tbl_any_hosp                   = "Table - Hospitalization odds within a cycle",
  tbl_hosp_days_comparison       = "Table - Hospital length of stay",
  table_early_dropout_final      = "Table - Early treatment discontinuation and adverse events",
  transfusion_rate_by_anemia_hiv = "Table - Transfusion rate by anemia grade and HIV status",
  transfusion_units_by_anemia_hiv = "Table - Transfusion units by anemia grade and HIV status",
  gcsf_rate_by_myelo_hiv         = "Table - G-CSF rate by myelosuppression grade and HIV status",
  gcsf_rate_by_anc_hiv           = "Table - G-CSF rate by neutropenia grade and HIV status",
  gcsf_rate_by_indication_hiv    = "Table - G-CSF rate by neutropenia-leukopenia grade and HIV status",
  transfusion_rate_by_grade_hiv  = "Table - Transfusion rate by anemia grade and HIV status (analysis)",
  gcsf_rate_by_grade_hiv         = "Table - G-CSF rate by severity grade and HIV status (analysis)",
  hosp_days_by_pt_hiv            = "Table - Hospital days per patient by HIV status",
  hosp_days_by_severe_hiv        = "Table - Hospital days by severe ADE count and HIV status",
  hosp_days_by_max_grade_hiv     = "Table - Hospital days by max ADE grade and HIV status",
  tx_hiv_comparison_by_stratum   = "Table - HIV and transfusion odds across strata",
  gcsf_hiv_comparison_by_stratum = "Table - HIV and G-CSF odds across strata",
  table_early_dropout_descriptive = "Table - Early dropout, descriptive breakdown",

  # Figures
  plt_cycle_completion           = "Figure - Cycle completion by HIV status (pooled)",
  plt_cycle_completion_split     = "Figure - Cycle completion by HIV status and cycles prescribed",
  plt_hosp_vs_max_grade          = "Figure - Hospital days vs adverse event grade",
  plt_early_dropout_forest       = "Figure - Early dropout and toxicity (pooled)",
  plt_early_dropout_forest_byhiv = "Figure - Early dropout and toxicity by HIV status",
  dag_transfusion                = "Figure - Causal diagram, transfusion",
  dag_gcsf                       = "Figure - Causal diagram, G-CSF"
)

output_filename <- function(slug) {
  nm <- unname(output_names[slug])

  if (is.na(nm)) {
    nm <- slug |>
      str_remove("^(tbl|table|plt|plot|fig)_") |>
      str_replace_all("_", " ") |>
      str_to_sentence()
  }

  # Characters Windows forbids in filenames, plus trailing dots/spaces.
  nm |>
    str_replace_all('[\\\\/:*?"<>|]', "-") |>
    str_squish() |>
    str_remove("\\.+$")
}


# Three of the four tables in this section have the same shape: a binary
# management outcome summarised as n/N (%) per treatment cycle, broken down by
# a severity grade (rows) and HIV status (columns). Built through one helper so
# they cannot drift apart again -- the two G-CSF tables had been left in long
# form, producing one row per HIV group per grade instead of one row per grade
# with a column for each group.
#
# Denominator: cycles where the outcome was actually recorded. Cycles carrying
# a severity grade but no record of whether the intervention was given are
# excluded rather than counted as "not given" -- mgmt_cycle keeps any cycle
# with *either* a transfusion or a G-CSF record, so a cycle can easily have one
# and not the other. Counting those as non-events understated both rates.
mgmt_rate_table <- function(data, grade_var, outcome_var, grade_label) {
  data |>
    filter(!is.na(.data[[grade_var]]), !is.na(.data[[outcome_var]])) |>
    group_by(hiv_status, grade_value = .data[[grade_var]]) |>
    summarise(
      n_cycles = n(),
      n_event  = sum(.data[[outcome_var]] == 1, na.rm = TRUE),
      .groups  = "drop"
    ) |>
    mutate(
      cell = paste0(n_event, "/", n_cycles, " (",
                    round(100 * n_event / n_cycles, 1), "%)")
    ) |>
    select(grade_value, hiv_status, cell) |>
    pivot_wider(names_from = hiv_status, values_from = cell,
                # An em dash, not "0/0" -- these cells mean "no cycles observed
                # at this grade in this group", which is not the same as "no
                # events out of no cycles".
                values_fill = "—") |>
    arrange(grade_value) |>
    rename(!!grade_label := grade_value)
}

# Shared flextable styling, so all four tables in the section match.
mgmt_rate_flextable <- function(df, spanner, footnote = NULL) {
  ft <- df |>
    flextable() |>
    add_header_row(values = c("", spanner), colwidths = c(1, ncol(df) - 1)) |>
    theme_booktabs() |>
    align(align = "center", part = "all") |>
    align(j = 1, align = "left", part = "all")

  if (!is.null(footnote)) ft <- ft |> flextable::add_footer_lines(footnote)

  autofit(ft)
}


# Run a test on a contingency table and return a tidy one-row summary rather
# than a raw htest print-out.
#
# Defaults to Fisher's exact for *every* table, matching the MET-006 decision
# to use one test throughout rather than switching on expected cell counts.
# Fisher is exact and valid at any cell count, so it is the safe common choice;
# mixing tests across tables invites questions about why each was picked.
test_contingency <- function(tbl, comparison, test = c("fisher", "chisq")) {
  test <- match.arg(test)

  res <- if (test == "fisher") {
    stats::fisher.test(tbl)
  } else {
    stats::chisq.test(tbl, correct = FALSE)
  }

  # Minimum expected count is reported rather than used to switch tests, so a
  # reader can see whether a chi-squared approximation would have been valid
  # without the choice of test varying from table to table.
  min_expected <- suppressWarnings(min(stats::chisq.test(tbl)$expected))

  tibble(
    Comparison = comparison,
    Test       = if (test == "fisher") "Fisher's exact" else "Chi-squared",
    Statistic  = if (test == "fisher") "—" else sprintf("%.2f", unname(res$statistic)),
    df         = if (test == "fisher") "—" else as.character(unname(res$parameter)),
    `p-value`  = format_p(res$p.value),
    `Min expected count` = sprintf("%.1f", min_expected)
  )
}

# Compact one-line effect summary for the HIV term, for quoting a model's
# result in prose or a table caption without tabulating the whole model.
# Handles both glm and merMod.
hiv_effect_text <- function(model) {
  est <- if (inherits(model, "merMod")) lme4::fixef(model) else stats::coef(model)
  se  <- sqrt(diag(as.matrix(stats::vcov(model))))[names(est)]
  i   <- grep("^hiv_status", names(est))

  sprintf("OR %.2f (95%% CI %.2f-%.2f), p = %s",
          exp(est[i]),
          exp(est[i] - 1.96 * se[i]),
          exp(est[i] + 1.96 * se[i]),
          format_p(2 * stats::pnorm(-abs(est[i] / se[i]))))
}

# Pull just the HIV row out of a fitted mixed model, for comparing one exposure
# estimate across analysis strata.
#
# Used instead of tbl_merge() where the strata legitimately carry different
# covariate levels: merging tables whose row sets differ silently misaligns
# rows and warns that the row counts do not match. Only the HIV row is
# comparable across strata, so only that is compared.
hiv_estimate <- function(model, stratum) {
  est <- lme4::fixef(model)
  se  <- sqrt(diag(as.matrix(stats::vcov(model))))[names(est)]
  i   <- grep("^hiv_status", names(est))

  # Derive the comparison from the fitted model rather than assuming it, so the
  # label cannot drift out of step with the factor coding. levels()[1] is the
  # reference level by construction.
  ref  <- levels(stats::model.frame(model)$hiv_status)[1]
  comp <- sub("^hiv_status", "", names(est)[i])

  tibble(
    Stratum      = stratum,
    Comparison   = paste0("HIV ", comp, " vs HIV ", ref),
    `Cycles (n)` = as.character(stats::nobs(model)),
    OR           = sprintf("%.2f", exp(est[i])),
    `95% CI`     = sprintf("%.2f, %.2f",
                           exp(est[i] - 1.96 * se[i]),
                           exp(est[i] + 1.96 * se[i])),
    `p-value`    = format_p(2 * stats::pnorm(-abs(est[i] / se[i])))
  )
}


# Save a table (gtsummary object and/or data frame) to csv + docx and
# return a flextable for display. Pass `gtsum` for gtsummary objects (df/ft
# derived automatically if not supplied), or `df`/`ft` directly for anything
# else (e.g. a plain data frame with a hand-built flextable).
save_table <- function(slug, gtsum = NULL, df = NULL, ft = NULL) {
  ensure_output_dirs()

  if (is.null(ft) && !is.null(gtsum)) ft <- as_flex_table(gtsum)
  if (is.null(df) && !is.null(gtsum)) df <- as_tibble(gtsum)
  if (is.null(ft)) ft <- df |> flextable() |> theme_booktabs() |> autofit()

  fname     <- output_filename(slug)
  csv_path  <- file.path(tables_csv_path(),       paste0(fname, ".csv"))
  docx_path <- file.path(tables_generated_path(), paste0(fname, ".docx"))

  if (!is.null(df)) write.csv(df, csv_path, row.names = FALSE)
  save_as_docx(ft, path = docx_path)

  # Invisible: a bare save_table() call at the top level of a chunk would
  # otherwise print the whole return list -- file paths, slug and all -- and
  # re-render the object underneath it.
  invisible(list(ft = ft, csv = csv_path, docx = docx_path, slug = slug,
                 name = fname))
}

save_figure <- function(plot, slug, width = 8, height = NULL, dpi = 300) {
  if (is.null(height)) height <- width * 0.618

  ensure_output_dirs()

  fname    <- output_filename(slug)
  png_path <- file.path(figures_png_path(), paste0(fname, ".png"))
  svg_path <- file.path(figures_svg_path(), paste0(fname, ".svg"))

  ggsave(png_path, plot = plot, width = width, height = height, dpi = dpi)
  ggsave(svg_path, plot = plot, width = width, height = height)

  invisible(list(plot = plot, png = png_path, svg = svg_path, slug = slug,
                 name = fname))
}

emit_buttons <- function(obj) {
  # `name` was added 2026-07-27; fall back to the slug for pub_objects .rds
  # files written before that.
  dl_name <- obj$name %||% obj$slug

  cat('<div style="display: flex; gap: 10px; margin-top: 15px; margin-bottom: 25px;">')
  print(download_file(
    path = obj$csv, output_name = dl_name,
    button_label = "Download CSV", button_type = "primary",
    class = "btn-sm", has_icon = TRUE, icon = "fa fa-database"
  ))
  print(download_file(
    path = obj$docx, output_name = dl_name,
    button_label = "Download Word Doc", button_type = "default",
    class = "btn-sm", has_icon = TRUE, icon = "fa fa-file-word"
  ))
  cat('</div>')
}


# --- Protecting hand-edited output -----------------------------------------
#
# Code writes only to tables/generated/, tables/csv/ and figures/, so a render
# no longer overwrites anything edited by hand. This is therefore a backup of
# the hand-merged copies sitting directly in tables/ -- now the least
# reproducible thing in the project. It covers a bad manual merge, an
# accidental deletion, or a OneDrive sync conflict.
#
# Deliberately archives only the files at the top level of tables/. The
# generated/ and csv/ subfolders are machine output and reproducible, so
# copying them every hour would just bloat a synced folder for nothing.
#
# Keyed to the hour, so sourcing this file once per document during a full
# pipeline render produces one snapshot, not six. Set GIC_SKIP_SNAPSHOT=1 in
# .Renviron to disable.
snapshot_outputs <- function(keep = 10, quiet = FALSE) {
  if (Sys.getenv("GIC_SKIP_SNAPSHOT") == "1") return(invisible(NULL))

  src <- onedrive_path("tables")
  if (!dir.exists(src)) return(invisible(NULL))

  files <- list.files(src, full.names = TRUE, recursive = FALSE)
  files <- files[!dir.exists(files)]
  if (length(files) == 0) return(invisible(NULL))

  archive_root <- onedrive_path("_output_archive")
  dest <- file.path(archive_root, format(Sys.time(), "%Y-%m-%d_%H"))
  if (dir.exists(dest)) return(invisible(dest))

  ok <- tryCatch({
    dir.create(dest, recursive = TRUE, showWarnings = FALSE)
    file.copy(files, dest, copy.date = TRUE)
    TRUE
  }, error = function(e) {
    # Never let a snapshot failure block a render -- but be loud about it.
    warning("Output snapshot FAILED (", conditionMessage(e),
            "). A file open in Word is the usual cause.", call. = FALSE)
    FALSE
  })

  if (!ok) return(invisible(NULL))

  # Keep the archive bounded: it lives inside a synced OneDrive folder.
  snaps <- sort(list.dirs(archive_root, recursive = FALSE))
  if (length(snaps) > keep) {
    unlink(snaps[seq_len(length(snaps) - keep)], recursive = TRUE)
  }

  if (!quiet) message("Snapshot of hand-edited tables: ", dest)
  invisible(dest)
}

snapshot_outputs()
