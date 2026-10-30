# =============================================================================
# measure_normed.R  |  MATLAB source: measure_normed.m
#
# Purpose: For each participant, express FA or MD across eight ROIs as
#          (1) mean-centred, (2) within-subject z-scored, and (3) mean-scaled.
# Defines: measure_normed().
# Calls:   No other project functions; uses rowMeans(), sd() and sweep().
# Called by: prep1_analysis_tables() for FA and MD independently.
#
# Note: The z-score uses the SAMPLE standard deviation (denominator n - 1),
#       matching MATLAB std(..., 0, 2); this is not demographic residualisation.
# =============================================================================

measure_normed <- function(srctbl) {
  stopifnot(is.data.frame(srctbl), ncol(srctbl) == 9L)

  # --- Within-subject moments across the eight regional measurements ---------
  values <- as.matrix(srctbl[, -1L, drop = FALSE])
  storage.mode(values) <- "double"

  means <- rowMeans(values)
  sds   <- apply(values, 1L, sd)  # MATLAB std(...,0,2): sample SD (n-1).

  # --- Three alternative representations ------------------------------------
  norm1 <- srctbl
  norm2 <- srctbl
  norm3 <- srctbl

  norm1[, -1L] <- sweep(values, 1L, means, "-")
  norm2[, -1L] <- sweep(sweep(values, 1L, means, "-"), 1L, sds, "/")
  norm3[, -1L] <- sweep(values, 1L, means, "/")

  list(meanctr = norm1, z = norm2, meanscale = norm3)
}
