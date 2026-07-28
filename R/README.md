# R Scripts

This directory contains all R scripts used for project setup and automation.

`setup.R`

**Purpose:** This is the main project setup script.

This file is sourced by the main `.qmd` document (in the setup chunk) every time the project is rendered. Its job is to:

-   Load all necessary R packages (library(...)).
-   Set global knitr chunk options (knitr::opts_chunk\$set(...)).
-   Define global plot settings (like the theme_set and color-blind friendly palettes).
-   Contain any helper functions that are used in the analysis.

## Helpers added 2026-07-27

- `snapshot_outputs()` — copies the shared `tables/` and `figures/` folders into
  `<OneDrive>/_output_archive/<date_hour>/` before a render can overwrite them.
  Runs automatically when `setup.R` is sourced, at most once per hour, pruned to
  the last 10 snapshots. This protects hand-edited `.docx` tables. It is a
  recovery net, not prevention — see the note below.
- `check_separation(model)` — screens a fitted binomial model for complete /
  quasi-complete separation. Returns `$cells` (levels where the outcome never
  varies) and `$coefs` (implausibly large estimates or standard errors).
- `drop_separated_levels(data, outcome, vars)` — iteratively removes fully
  separated levels, recording what it removed in a `dropped_levels` attribute.
- `describe_dropped_levels(data)` — renders that attribute as a table footnote.
- `tbl_drop_ref_rows(tbl)` — removes reference rows from a gtsummary regression
  table and appends the reference level to the variable label instead.

### Output layout

Code writes **only** to `<OneDrive>/generated/`, which is disposable and
overwritten in full on every render:

```
generated/
  README.txt              note telling anyone browsing not to edit here
  tables/                 .docx tables, human-readable filenames
  csv/                    .csv versions of the same tables
  figures/                .png
  figures/svgs/           .svg
```

`tables/` and `figures/` one level up are **human territory**. Nothing in the
codebase writes to them, so hand edits are safe there. Merging new generated
output into them is a deliberate manual step.

Filenames come from `output_names`, a slug-to-title lookup in `setup.R`. Slugs
at the call sites did not change; only the filenames on disk did. Anything
missing from the lookup falls back to a prettified slug, so a new
`save_table()` call still produces something readable. Renaming an entry means
the next render writes a new file rather than overwriting the old one — delete
the stale file from `generated/` if you rename.

- `generated_path(...)` — path helper for the above.
- `ensure_generated_dirs()` — creates the tree and drops the README on first use.
- `output_filename(slug)` — applies the lookup and strips characters Windows
  forbids in filenames.
