# =============================================================================
# anl2b_usagepredicts.R  |  MATLAB source: anl2b_usagepredicts.m
#
# Purpose: Extract intragroup winning models containing an MDMA usage
#          predictor; retain comparisons with |2*log(BF(best/null))| > 2.
# Defines: anl2b_usagepredicts(), with a local model-name predicate.
# Calls:   mdma_project_root(), mdma_load_prepared(), mdma_derived(),
#          mdma_save(); readRDS() and write.csv().
# Called by: run.R (usage-predicts stage).
# Inputs:  Prepared data and a2-mdmagroup-results.rds from anl2_mdmagroup().
# Outputs: a2b-usagepredicts.rds and a2b-usagepredicts.csv (if save = TRUE).
# =============================================================================

anl2b_usagepredicts <- function(root = mdma_project_root(), save = TRUE) {
  # --- Load MDMA exposure variable names and model winners ------------------
  mdma_data <- mdma_load_prepared(root)
  a2        <- readRDS(file.path(mdma_derived(root), "a2-mdmagroup-results.rds"))
  usage_vars <- names(mdma_data$mdmause_raw)[-1L]

  # --- Select winning models containing at least one usage predictor ---------
  usage_predicts <- vapply(a2$BestModel, function(m) {
    parts <- strsplit(m, "+", fixed = TRUE)[[1L]]
    any(parts %in% usage_vars)
  }, logical(1L))

  # --- Apply evidence threshold and select report columns -------------------
  T  <- a2[usage_predicts, , drop = FALSE]
  T2 <- T[abs(T$BestModelNullBF) > 2, , drop = FALSE]
  T3 <- T2[, c("ROI", "RespVarSet", "BestModel", "BestModelNullBF"), drop = FALSE]

  # --- Optional results export ---------------------------------------------
  if (save) {
    mdma_save(list(usage_predicts = usage_predicts, T = T, T2 = T2, T3 = T3),
              file.path(mdma_derived(root), "a2b-usagepredicts.rds"))
    write.csv(T3, file.path(mdma_derived(root), "a2b-usagepredicts.csv"),
              row.names = FALSE)
  }

  T3
}
