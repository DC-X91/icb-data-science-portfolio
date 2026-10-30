#!/usr/bin/env Rscript
# =============================================================================
# run.R  |  Command-line entry point for the R computation project
#
# Purpose: Resolve the project root and selected dataset (real or synth),
#          source active library/script definitions, and dispatch analysis stages.
# Defines: No named functions; creates a stage-to-function dispatch list.
# Calls:   prep1_analysis_tables(), anl1_intergroup(),
#          anl1b_groupmodels_v_best(), anl2_mdmagroup(),
#          anl2b_usagepredicts(), anl3_multcomptest() (when selected).
# Called by: No other R script; invoked via Rscript run.R <stage>
#            [--dataset=real|synth].
# Sources: codebank/1-lib/*.R, codebank/2-scripts/*.R (non-recursively).
# Data:    Each dataset has 1-original/ and 2-derived/. Default is real.
# =============================================================================

# --- Resolve project root ---------------------------------------------------
argv0 <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (!length(argv0)) stop("Run from a shell with: Rscript run.R <stage> [--dataset=real|synth]")

root <- dirname(normalizePath(sub("^--file=", "", argv0[1L]), mustWork = TRUE))

# --- Parse CLI arguments and choose the isolated data branch ----------------
stages       <- commandArgs(trailingOnly = TRUE)
dataset_args <- grep("^--dataset=", stages, value = TRUE)

if (length(dataset_args) > 1L) stop("Specify --dataset only once")
dataset <- if (length(dataset_args)) sub("^--dataset=", "", dataset_args) else "real"
if (!dataset %in% c("real", "synth")) {
  stop("Invalid dataset: ", dataset, ". Choose --dataset=real or --dataset=synth")
}

stages <- stages[!grepl("^--dataset=", stages)]

if (!length(stages) || any(stages %in% c("-h", "--help"))) {
  cat("Usage: Rscript run.R [prep|intergroup|group-best|intragroup|usage-predicts|permutation|all]... [--dataset=real|synth]\n")
  cat("Default: --dataset=real; use --dataset=synth for synthetic demonstration.\n")
  quit(status = 0)
}

if ("all" %in% stages) {
  stages <- c("prep", "intergroup", "group-best", "intragroup",
              "usage-predicts", "permutation")
}

options(mdma.root = root, mdma.dataset = dataset)

# --- Source active computational libraries and stage definitions ------------
for (f in list.files(file.path(root, "codebank", "1-lib"),
                     pattern = "\\.R$", full.names = TRUE)) source(f)
for (f in list.files(file.path(root, "codebank", "2-scripts"),
                     pattern = "\\.R$", full.names = TRUE)) source(f)

message("Selected dataset: ", dataset, " (databank/dataset-", dataset, ")")

# --- Stage registry and dispatch --------------------------------------------
functions <- list(prep = prep1_analysis_tables,
                  intergroup = anl1_intergroup,
                  `group-best` = anl1b_groupmodels_v_best,
                  intragroup = anl2_mdmagroup,
                  `usage-predicts` = anl2b_usagepredicts,
                  permutation = anl3_multcomptest)

for (stage in stages) {
  if (!stage %in% names(functions)) stop("Unknown stage: ", stage)
  message("Running: ", stage)
  invisible(functions[[stage]](root = root))
}

message("Completed stages: ", paste(stages, collapse = ", "))
