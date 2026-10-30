# =============================================================================
# bflrtable.R  |  MATLAB source: bflrtable.m
#
# Purpose: Exhaustively compare every subset of candidate predictors using
#          Zellner-Siow regression Bayes factors and summarise the winner.
# Defines: bflrtable(), bf_evidence_interp().
# Calls:   combos(), bfzsprior(), bf_evidence_interp(), stats::lm().
# Called by: anl1_intergroup(), anl2_mdmagroup(), anl3_multcomptest().
# =============================================================================

# R bflrtable.m: exhaustive subsets of predictors, continuous outcome
# in the final column, with a Zellner-Siow BF for each linear model.
# IMPORTANT: BayesFactor_best preserves the source's extra division by sum(BF).
# It is NOT a valid pairwise Bayes factor. lnBFx2_best IS the correct log ratio.

bf_evidence_interp <- function(log_bf2, reference_index) {
  v <- abs(log_bf2)
  strength  <- ifelse(v == 0, "None",
               ifelse(v < 2,  "Weak",
               ifelse(v < 6,  "Positive",
               ifelse(v < 10, "Strong", "Very strong"))))
  direction <- ifelse(log_bf2 > 0, "for",
               ifelse(log_bf2 < 0, "against", "either way"))
  strength[reference_index] <- "Reference"
  direction[reference_index] <- "Reference"
  list(strength = strength, direction = direction)
}

bflrtable <- function(analysis_table, s = 1, method = "quadrature", order = 128L) {
  stopifnot(is.data.frame(analysis_table), ncol(analysis_table) >= 2L)
  stopifnot(!anyDuplicated(names(analysis_table)))
  
  response <- names(analysis_table)[ncol(analysis_table)]
  stopifnot(is.numeric(analysis_table[[response]]))
  
  C           <- combos(ncol(analysis_table) - 1L)
  nmodels     <- nrow(C) + 1L
  model       <- rep(NA_character_, nmodels)
  coeff       <- vector("list", nmodels)
  bf          <- rep(NA_real_, nmodels)
  model[1L]   <- "Null"
  coeff[[1L]] <- "(Intercept)"
  bf[1L]      <- 1

  for (j in seq_len(nrow(C))) {
    chosen     <- which(C[j, -ncol(C)])
    predictors <- names(analysis_table)[chosen]
    subtable   <- analysis_table[, c(predictors, response), drop = FALSE]
    model_fit  <- lm(reformulate(predictors, response = response), data = subtable,
                     na.action = na.omit)
    
    n <- nobs(model_fit)
    p <- model_fit$rank - 1L  # Effective number of estimated slopes.
    
    if (p < 1L || p >= n)
      stop(sprintf("Model %s: effective rank is invalid (p=%d, n=%d)",
                   paste(predictors, collapse = "+"), p, n))
    
    r2 <- summary(model_fit)$r.squared
    j1 <- j + 1L
    
    model[j1]   <- paste0("1+", paste(predictors, collapse = "+"))
    coeff[[j1]] <- names(coef(model_fit))
    bf[j1]      <- bfzsprior(r2, n, p, s = s, method = method, order = order)
  }

  if (anyNA(bf) || any(bf <= 0) || any(!is.finite(bf)))
    stop("Non-finite or non-positive Bayes factor; inspect the model design.")
  
  logbf   <- 2 * log(bf)
  bestidx <- which.max(logbf)
  logbest <- logbf - logbf[bestidx]
  sum_bf  <- sum(bf)
  enull   <- bf_evidence_interp(logbf, 1L)
  ebest   <- bf_evidence_interp(logbest, bestidx)
  
  out <- data.frame(Model = model, stringsAsFactors = FALSE)
  out$CoefficientNames      <- I(coeff)
  out$PosteriorProb         <- bf / sum_bf
  out$BayesFactor_null      <- bf
  out$lnBFx2_null           <- logbf
  out$EvidenceStrength_null <- enull$strength
  out$EvidenceDir_null      <- enull$direction
  out$BayesFactor_best      <- (bf / bf[bestidx]) / sum_bf
  out$lnBFx2_best           <- logbest
  out$EvidenceStrength_best <- ebest$strength
  out$EvidenceDir_best      <- ebest$direction
  
  list(bf_table = out, bestmodel = model[bestidx])
}

