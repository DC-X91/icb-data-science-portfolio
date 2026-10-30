# =============================================================================
# anl3_multcomptest.R  |  MATLAB source: anl3_multcomptest.m
#
# Purpose: Perform the 64 within-user model searches after permuting outcomes.
#          One permutation is generated per ROI and reused for all eight
#          response representations for that ROI.
# Defines: anl3_multcomptest().
# Calls:   mdma_project_root(), mdma_load_prepared(), mdma_response_names(),
#          mdma_roi_names(), bflrtable(), mdma_result_table(),
#          mdma_derived(), mdma_save(); base::set.seed(), sample.int().
# Called by: run.R (permutation stage).
# Outputs: a3-mdmagroup-results.rds and a3-permutation-indices.rds.
#
# Reproducibility: R set.seed(101) and MATLAB rng(101) do not generate
#                  identical permutations; the indices are saved for audit.
# =============================================================================

anl3_multcomptest <- function(root = mdma_project_root(), method = "quadrature",
                              order = 128L, seed = 101L, save = TRUE) {
  # --- Prepared data and within-user covariates ------------------------------
  mdma_data <- mdma_load_prepared(root)
  nameset   <- mdma_response_names(mdma_data)
  rois      <- mdma_roi_names(mdma_data)
  useridx   <- mdma_data$demographics_raw$group == "MDPU"

  covariates <- cbind(mdma_data$demographics_raw[useridx,
                      3:ncol(mdma_data$demographics_raw), drop = FALSE],
                      mdma_data$mdmause_raw[, -1L, drop = FALSE])

  # --- Set RNG and allocate per-region permutations and results -------------
  if (!is.null(seed)) set.seed(seed)

  rows         <- vector("list", length(rois) * length(nameset))
  permutations <- vector("list", length(rois))
  names(permutations) <- rois
  ii <- 1L

  # --- Permute outcomes and compare all predictor subsets -------------------
  for (n in seq_along(rois)) {
    shuffle <- sample.int(sum(useridx))
    permutations[[n]] <- shuffle

    for (rid in nameset) {
      outcome <- mdma_data[[rid]][useridx, n + 1L, drop = FALSE]
      outcome <- outcome[shuffle, , drop = FALSE]
      b       <- bflrtable(cbind(covariates, outcome), method = method, order = order)

      rows[[ii]] <- list(ROI = rois[n], Measure = sub("_.*", "", rid),
                         RespVarSet = rid,
                         CovarSet = "demographics_raw + mdmause_raw",
                         BayesFactors = b$bf_table, BestModel = b$bestmodel,
                         BestModelNullBF = b$bf_table$lnBFx2_best[1L])
      ii <- ii + 1L
    }

    message(sprintf("Permutation ROI %d/%d: %s", n, length(rois), rois[n]))
  }

  # --- Save results and exact permutation indices ---------------------------
  out <- mdma_result_table(rows)
  if (save) {
    mdma_save(out, file.path(mdma_derived(root), "a3-mdmagroup-results.rds"))
    mdma_save(list(seed = seed, RNGkind = RNGkind(),
                   permutations = permutations),
              file.path(mdma_derived(root), "a3-permutation-indices.rds"))
  }

  out
}
