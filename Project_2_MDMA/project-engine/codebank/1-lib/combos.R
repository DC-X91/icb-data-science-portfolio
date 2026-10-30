# =============================================================================
# combos.R  |  MATLAB source: combos.m
#
# Purpose: Enumerate all nonempty predictor subsets in source-compatible order.
#          The last (always TRUE) column denotes the response variable.
# Defines: combos().
# Calls:   No other project functions; uses base bitwise and ordering functions.
# Called by: bflrtable().
#
# Ordering: Number of selected predictors, followed by MATLAB's original binary
#           enumeration with its subsequent fliplr() reversal.
# =============================================================================

combos <- function(p) {
  stopifnot(length(p) == 1L, is.finite(p), p == floor(p), p >= 0L, p <= 24L)

  p <- as.integer(p)
  if (p == 0L) return(matrix(TRUE, nrow = 0L, ncol = 1L))

  # --- Enumerate all binary inclusion patterns -------------------------------
  v <- 0:(2^p - 1L)
  C <- vapply((p - 1L):0L, function(b) bitwAnd(bitwShiftR(v, b), 1L),
              integer(length(v)))
  dim(C) <- c(length(v), p)

  # --- Sort and remove the empty model ---------------------------------------
  idx <- order(rowSums(C), seq_len(nrow(C)), method = "radix")
  C   <- C[idx, p:1L, drop = FALSE]
  C   <- C[-1L, , drop = FALSE]
  storage.mode(C) <- "logical"

  cbind(C, response = rep(TRUE, nrow(C)))
}
