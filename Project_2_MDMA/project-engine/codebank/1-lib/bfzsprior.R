# =============================================================================
# bfzsprior.R  |  MATLAB source: bfzsprior.m
#
# Purpose: Compute the Zellner-Siow Bayes factor for a regression model against
#          the intercept-only null model, using its ordinary R-squared.
# Defines: bfzs_nodes(), bfzsprior(); private cache .bfzs_cache.
# Calls:   bfzs_nodes() (from bfzsprior); base eigen() and stats::dnorm();
#          stats::integrate() for the adaptive integration alternative.
# Called by: bflrtable() (bfzsprior directly); bfzs_nodes() is internal.
#
# Method: The substitution g = n*s^2/t^2, with t ~ |N(0,1)|, transforms
#         the original Zellner-Siow integral without changing its prior.
# =============================================================================

# --- Cached Gauss-Legendre quadrature nodes and weights ----------------------

.bfzs_cache <- new.env(parent = emptyenv())

bfzs_nodes <- function(order = 128L, max_t = 9) {
  order <- as.integer(order)
  stopifnot(order >= 4L, is.finite(max_t), max_t > 0)

  key <- paste(order, max_t, sep = ":")
  if (exists(key, envir = .bfzs_cache, inherits = FALSE))
    return(get(key, envir = .bfzs_cache, inherits = FALSE))

  jj     <- seq_len(order - 1L)
  off    <- jj / sqrt(4 * jj^2 - 1)
  jacobi <- matrix(0, order, order)
  jacobi[cbind(jj, jj + 1L)] <- off
  jacobi[cbind(jj + 1L, jj)] <- off

  e <- eigen(jacobi, symmetric = TRUE)

  # Weights for [-1,1] are 2*v[1,i]^2; mapped to [0,max_t].
  z <- list(t = (e$values + 1) * max_t / 2,
            w = max_t * (e$vectors[1L, ]^2))

  assign(key, z, envir = .bfzs_cache)
  z
}


# --- Zellner-Siow Bayes factor ------------------------------------------------

bfzsprior <- function(R2, nsamps, ncov, s = 1,
                      method = c("quadrature", "adaptive"),
                      order = 128L, rel.tol = 1e-10) {
  method <- match.arg(method)
  stopifnot(length(R2) == 1L, is.finite(R2),
            R2 >= -1e-12, R2 <= 1 + 1e-12,
            length(nsamps) == 1L, is.finite(nsamps), nsamps > 0,
            nsamps == floor(nsamps),
            length(ncov) == 1L, is.finite(ncov), ncov > 0,
            ncov == floor(ncov), ncov < nsamps,
            length(s) == 1L, is.finite(s), s > 0)

  R2 <- min(1, max(0, R2))
  if (R2 == 1 && nsamps > ncov + 1)
    return(Inf)  # Perfect fit: this improper limit diverges.

  n <- as.double(nsamps)
  p <- as.double(ncov)
  A <- n * s^2

  # Integrand in the transformed t variable.
  integrand <- function(t) {
    value <- numeric(length(t))
    good  <- is.finite(t) & t > 0
    tt    <- t[good]^2

    log_h <- (n - p - 1) / 2 * log1p(A / tt) -
             (n - 1) / 2 * log1p(A * (1 - R2) / tt)

    value[good] <- 2 * dnorm(t[good]) * exp(log_h)
    value
  }

  # Reference integration or reusable quadrature, as requested.
  if (method == "adaptive") {
    return(integrate(integrand, lower = 0, upper = Inf,
                     subdivisions = 600L, rel.tol = rel.tol,
                     stop.on.error = TRUE)$value)
  }

  nw <- bfzs_nodes(order)
  sum(nw$w * integrand(nw$t))
}
