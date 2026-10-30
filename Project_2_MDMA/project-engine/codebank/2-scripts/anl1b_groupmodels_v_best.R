# =============================================================================
# anl1b_groupmodels_v_best.R  |  MATLAB source: anl1b_groupmodels_v_best.m
#
# Purpose: For each intergroup comparison, find the largest 2*log(BF) relative
#          to the best model among models containing the predictor 'group'.
# Defines: anl1b_groupmodels_v_best(), with a local anonymous row reducer.
# Calls:   mdma_project_root(), mdma_derived(), readRDS(), write.csv().
# Called by: run.R (group-best stage).
# Input:   a1-intergroup-results.rds from anl1_intergroup().
# Output:  a1b-groupmodels-v-best.csv (when save = TRUE).
# =============================================================================

anl1b_groupmodels_v_best <- function(root = mdma_project_root(), save = TRUE) {
  # --- Load intergroup model-comparison results ------------------------------
  infile <- file.path(mdma_derived(root), "a1-intergroup-results.rds")
  a1     <- readRDS(infile)

  # --- Best group-containing model, relative to the overall winner ----------
  maxgroupBF <- vapply(a1$BayesFactors, function(t) {
    idx <- vapply(strsplit(t$Model, "+", fixed = TRUE),
                  function(parts) "group" %in% parts, logical(1L))
    if (!any(idx)) stop("No model containing 'group' in a comparison")
    max(t$lnBFx2_best[idx])
  }, numeric(1L))

  # --- Create the compact summary and save, optionally ----------------------
  ans <- data.frame(a1[, c("ROI", "Measure", "RespVarSet", "CovarSet")],
                    maxgroupBF = maxgroupBF)

  if (save) write.csv(ans, file.path(mdma_derived(root),
                                    "a1b-groupmodels-v-best.csv"), row.names = FALSE)
  ans
}
