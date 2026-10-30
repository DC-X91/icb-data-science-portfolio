# =============================================================================
# anl2_mdmagroup.R  |  MATLAB source: anl2_mdmagroup.m
#
# Purpose: Within 22 MDMA users, compare all subsets of 11 demographic and
#          exposure predictors: 64 outcomes x 2048 models (including the null).
# Defines: anl2_mdmagroup().
# Calls:   mdma_project_root(), mdma_load_prepared(), mdma_response_names(),
#          mdma_roi_names(), bflrtable(), mdma_result_table(),
#          mdma_derived(), mdma_save().
# Called by: run.R (intragroup stage).
# Output:  a2-mdmagroup-results.rds; used by anl2b_usagepredicts().
# =============================================================================

anl2_mdmagroup <- function(root = mdma_project_root(), method = "quadrature",
                           order = 128L, save = TRUE) {
  # --- Prepared data and within-user predictor set ---------------------------
  mdma_data <- mdma_load_prepared(root)
  nameset   <- mdma_response_names(mdma_data)
  rois      <- mdma_roi_names(mdma_data)
  useridx   <- mdma_data$demographics_raw$group == "MDPU"

  covariates <- cbind(mdma_data$demographics_raw[useridx,
                      3:ncol(mdma_data$demographics_raw), drop = FALSE],
                      mdma_data$mdmause_raw[, -1L, drop = FALSE])
  if (ncol(covariates) != 11L) stop("Expected eleven intragroup predictors")

  # --- Exhaustive subset comparisons by ROI and response form ---------------
  rows <- vector("list", length(rois) * length(nameset))
  ii   <- 1L

  for (n in seq_along(rois)) {
    for (rid in nameset) {
      outcome <- mdma_data[[rid]][useridx, n + 1L, drop = FALSE]
      b       <- bflrtable(cbind(covariates, outcome), method = method, order = order)

      rows[[ii]] <- list(ROI = rois[n], Measure = sub("_.*", "", rid),
                         RespVarSet = rid,
                         CovarSet = "demographics_raw + mdmause_raw",
                         BayesFactors = b$bf_table, BestModel = b$bestmodel,
                         BestModelNullBF = b$bf_table$lnBFx2_best[1L])
      ii <- ii + 1L
    }

    message(sprintf("Intragroup ROI %d/%d: %s", n, length(rois), rois[n]))
  }

  # --- Assemble and optionally persist result table -------------------------
  out <- mdma_result_table(rows)
  if (save) mdma_save(out, file.path(mdma_derived(root), "a2-mdmagroup-results.rds"))
  out
}
