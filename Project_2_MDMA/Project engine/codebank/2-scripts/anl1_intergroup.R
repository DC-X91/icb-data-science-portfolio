# =============================================================================
# anl1_intergroup.R  |  MATLAB source: anl1_intergroup.m
#
# Purpose: Compare all subsets of four predictors (group, sex, age, education)
#          for FA and MD, in four representations, across eight ROIs.
#          This yields 64 outcome comparisons x 16 models (including the null).
# Defines: anl1_intergroup().
# Calls:   mdma_project_root(), mdma_load_prepared(), mdma_response_names(),
#          mdma_roi_names(), bflrtable(), mdma_result_table(),
#          mdma_derived(), mdma_save().
# Called by: run.R (intergroup stage).
# Output:  a1-intergroup-results.rds; consumed by anl1b_groupmodels_v_best().
# =============================================================================

anl1_intergroup <- function(root = mdma_project_root(), method = "quadrature",
                            order = 128L, save = TRUE) {
  # --- Analysis inputs -------------------------------------------------------
  mdma_data  <- mdma_load_prepared(root)
  nameset    <- mdma_response_names(mdma_data)
  rois       <- mdma_roi_names(mdma_data)
  covariates <- mdma_data$demographics_raw[, -1L, drop = FALSE]

  # --- Exhaustive subset comparisons by ROI and response form ---------------
  rows <- vector("list", length(rois) * length(nameset))
  ii   <- 1L

  for (n in seq_along(rois)) {
    for (rid in nameset) {
      outcome <- mdma_data[[rid]][, n + 1L, drop = FALSE]
      b       <- bflrtable(cbind(covariates, outcome), method = method, order = order)

      rows[[ii]] <- list(ROI = rois[n], Measure = sub("_.*", "", rid),
                         RespVarSet = rid, CovarSet = "demographics_raw",
                         BayesFactors = b$bf_table,
                         BestModel = b$bestmodel,
                         BestModelNullBF = b$bf_table$lnBFx2_best[1L])
      ii <- ii + 1L
    }
  }

  # --- Assemble and optionally persist result table -------------------------
  out <- mdma_result_table(rows)
  if (save) mdma_save(out, file.path(mdma_derived(root), "a1-intergroup-results.rds"))
  out
}
