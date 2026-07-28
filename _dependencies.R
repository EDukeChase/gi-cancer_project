# _dependencies.R
#
# THIS FILE IS NEVER SOURCED OR RUN. It exists only so that renv's dependency
# scanner can see packages the pipeline depends on at runtime but which never
# appear in a library() or :: call anywhere in the project.
#
# Why this is needed
# ------------------
# renv::snapshot() and renv::clean() both work by *static analysis* -- they read
# the .R/.qmd files looking for library(), require() and pkg:: calls. That
# cannot see one package handing off to another at runtime.
#
# The concrete case here: tbl_regression() is called on glmer/lmer fits all
# through "4 - Statistical Analysis.qmd". gtsummary delegates the tidying to
# broom.helpers, which reaches for a mixed-model tidier at runtime. None of
# that is visible to a static scan, so renv::clean() reports these packages as
# unused and renv::snapshot() omits them from the lockfile. Restoring this
# project on a clean machine would then produce an environment where doc 4
# fails partway through.
#
# Everything listed below was flagged as removable by renv::clean() on
# 2026-07-27 and is deliberately retained.
#
# Maintaining this file
# ---------------------
# Add a package here if removing it breaks a render but nothing in the codebase
# references it by name. Run renv::snapshot() afterwards so the lockfile picks
# it up. Listing a package that is already a transitive dependency of another
# is harmless -- it just makes the requirement explicit rather than incidental.

# --- Mixed-model tidying for gtsummary tables ------------------------------
# Required by every tbl_regression() call on a glmer() or lmer() fit.
library(broom.mixed)

# The easystats chain that broom.helpers falls back to when broom itself has no
# tidier for a model class. parameters pulls in the other three, but they are
# listed explicitly so a future renv::clean() does not report them as orphans.
library(parameters)
library(insight)
library(datawizard)
library(bayestestR)

# Pulled in by the above for posterior/MCMC summaries. Listed defensively: it
# is a Suggests rather than an Imports in places, which means a snapshot may
# not record it even when something reaches for it at runtime.
library(coda)


# --- Deliberately NOT listed ------------------------------------------------
#
# The following were also flagged by renv::clean() and are genuinely unused by
# this project. They are development conveniences that ended up in the library,
# not analysis dependencies, and are safe to remove:
#
#   usethis, gh, gert, gitcreds, credentials, ini, whisker, desc, httr2
#     -- the usethis tooling tree
#   furrr, future, globals, listenv, parallelly
#     -- parallel execution stack; nothing in the pipeline runs in parallel
#
# If any of these are ever needed, add them above rather than relying on them
# being present by accident.
