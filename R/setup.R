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
# Drop reference-level rows from a gtsummary regression table (20-Apr-2026 and
# 5-Jun-2026: they consume a lot of vertical space for no information), while
# still telling the reader what the reference level was by appending it to the
# variable's label row: "Cancer Stage (ref: I)".
#
# Uses gtsummary's public modify_table_body() / remove_row_type() rather than
# editing $table_body in place, so it survives gtsummary internals changing.
tbl_drop_ref_rows <- function(tbl) {
  if (!"reference_row" %in% names(tbl$table_body)) return(tbl)

  refs <- tbl$table_body |>
    filter(!is.na(reference_row), reference_row) |>
    select(variable, .ref_label = label) |>
    distinct(variable, .keep_all = TRUE)

  if (nrow(refs) == 0) return(tbl)

  tbl |>
    gtsummary::modify_table_body(
      \(tb) tb |>
        left_join(refs, by = "variable") |>
        mutate(label = if_else(
          row_type == "label" & !is.na(.ref_label),
          paste0(label, " (ref: ", .ref_label, ")"),
          label
        )) |>
        select(-.ref_label)
    ) |>
    gtsummary::remove_row_type(variables = everything(), type = "reference")
}

describe_dropped_levels <- function(data) {
  d <- attr(data, "dropped_levels")
  if (is.null(d) || !length(d)) {
    return("No levels required exclusion for separation.")
  }
  paste0(
    "Excluded from this model due to complete separation (no variation in the ",
    "outcome within the level): ",
    paste(names(d), vapply(d, paste, character(1), collapse = ", "),
          sep = " = ", collapse = "; "), "."
  )
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

  list(ft = ft, csv = csv_path, docx = docx_path, slug = slug, name = fname)
}

save_figure <- function(plot, slug, width = 8, height = NULL, dpi = 300) {
  if (is.null(height)) height <- width * 0.618

  ensure_output_dirs()

  fname    <- output_filename(slug)
  png_path <- file.path(figures_png_path(), paste0(fname, ".png"))
  svg_path <- file.path(figures_svg_path(), paste0(fname, ".svg"))

  ggsave(png_path, plot = plot, width = width, height = height, dpi = dpi)
  ggsave(svg_path, plot = plot, width = width, height = height)

  list(plot = plot, png = png_path, svg = svg_path, slug = slug, name = fname)
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
