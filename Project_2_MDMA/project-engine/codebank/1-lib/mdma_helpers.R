# =============================================================================
# mdma_helpers.R  |  Project-specific R infrastructure (no MATLAB counterpart)
#
# Purpose: Resolve real/synthetic dataset-specific paths, load/save R objects,
#          identify regional responses, and assemble analysis-result tables.
#
# Defines / direct callers:
#   mdma_project_root(): default project root for path and stage functions.
#   mdma_dataset():      validate the selected real/synth dataset branch.
#   mdma_dataset_dir():  root path for either dataset; called by path helpers.
#   mdma_input():        prep1_analysis_tables() (CSV input directory).
#   mdma_derived():      all six stages (output directory).
#   mdma_prepared():     mdma_load_prepared(), prep1_analysis_tables().
#   mdma_load_prepared(): intergroup, intragroup, usage and permutation stages.
#   mdma_save():         data preparation, model-comparison and summary stages.
#   mdma_response_names(), mdma_roi_names(): model-comparison stages.
#   mdma_result_table(): intergroup, intragroup and permutation stages.
#
# Calls (project): mdma_project_root() and mdma_dataset() for path resolution;
#                  mdma_prepared() from mdma_load_prepared();
#                  mdma_response_names() from mdma_roi_names().
# Loading: run.R sources this file for either selected dataset.
# =============================================================================

# --- Project root and selected dataset paths -------------------------------
mdma_project_root <- function(root = getOption("mdma.root")) {
  if (is.null(root)) stop("Project root missing: run via Rscript run.R <stage> or set options(mdma.root=...).")
  normalizePath(root, mustWork = TRUE)
}

mdma_dataset <- function(dataset = getOption("mdma.dataset", "real")) {
  if (!is.character(dataset) || length(dataset) != 1L || is.na(dataset) ||
      !dataset %in% c("real", "synth")) {
    stop("Dataset must be exactly 'real' or 'synth'.")
  }
  dataset
}

mdma_dataset_dir <- function(root = mdma_project_root(),
                             dataset = mdma_dataset()) {
  file.path(root, "databank", paste0("dataset-", mdma_dataset(dataset)))
}

mdma_input <- function(root = mdma_project_root()) {
  file.path(mdma_dataset_dir(root), "1-original")
}

mdma_derived <- function(root = mdma_project_root()) {
  file.path(mdma_dataset_dir(root), "2-derived")
}

mdma_prepared <- function(root = mdma_project_root()) {
  file.path(mdma_derived(root), "mdma_data.rds")
}


# --- RDS persistence ---------------------------------------------------------

mdma_load_prepared <- function(root = mdma_project_root()) {
  path <- mdma_prepared(root)
  if (!file.exists(path)) stop("Prepared file not found: run Rscript run.R prep first.")
  readRDS(path)
}

mdma_save <- function(object, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  saveRDS(object, path, compress = "xz")
  invisible(path)
}


# --- Response-variable and region-of-interest identifiers -------------------

mdma_response_names <- function(mdma_data) {
  grep("^(fa|md)_", names(mdma_data), value = TRUE)
}

mdma_roi_names <- function(mdma_data) {
  sub("_.*$", "", names(mdma_data[[mdma_response_names(mdma_data)[1L]]])[-1L])
}


# --- Common structure for per-ROI/model-comparison results ------------------

mdma_result_table <- function(rows) {
  data.frame(ROI             = vapply(rows, `[[`, "", "ROI"),
             Measure         = vapply(rows, `[[`, "", "Measure"),
             RespVarSet      = vapply(rows, `[[`, "", "RespVarSet"),
             CovarSet        = vapply(rows, `[[`, "", "CovarSet"),
             BayesFactors    = I(lapply(rows, `[[`, "BayesFactors")),
             BestModel       = vapply(rows, `[[`, "", "BestModel"),
             BestModelNullBF = vapply(rows, `[[`, 0.0, "BestModelNullBF"),
             stringsAsFactors = FALSE)
}
