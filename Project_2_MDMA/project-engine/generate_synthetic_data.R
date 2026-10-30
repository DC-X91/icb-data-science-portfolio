#!/usr/bin/env Rscript
# =============================================================================
# generate_synthetic_data.R | Standalone synthetic-cohort generator
#
# Purpose: Create two schema-compatible, fictional FA and MD input CSV files
#          for the existing R Bayesian model-comparison pipeline.
# Defines: synth_rng(), synth_permute(), synth_truncnorm(), synth_group(),
#          synth_cohort(), synth_validate(), synth_write().
# Calls:   Only base R and stats::pnorm(). NO real-data inputs are read.
# Called by: User from Terminal: Rscript generate_synthetic_data.R
#              [--scenario=null|signal] [--seed=20261030] [--overwrite]
# Outputs: databank/dataset-synth/1-original/MDMA_{fa,md}_relevant_data.csv
#          databank/dataset-synth/SCENARIO.txt
#
# The reference cohort contains 22 fictional MDMA users, 20 controls, seven
# women (3 users and 4 controls) and exactly 11 heavy users (>100 exposures).
# Users have >=3 lifetime exposures and last use 8-365 days before assessment.
# Statistical calibration uses a limited number of rounded, aggregate
# estimates of the original cohort. No real records are sampled/copied.
# Reproducibility: internal Park-Miller LCG seeded by --seed, not R's global RNG.
# =============================================================================

# --- Reproducible platform-independent pseudo-random generator -------------
# Park-Miller minimal-standard generator; Box-Muller normally distributed draws.
# The 16807 * state product stays exactly representable as a double in R.
synth_rng <- function(seed) {
  modulus <- 2147483647
  state   <- as.double(seed) %% modulus
  if (!is.finite(state) || state != floor(state) || state < 1)
    stop("Seed must be a positive integer with a nonzero remainder mod 2147483647.")

  next_uniform <- function() {
    state <<- (16807 * state) %% modulus
    state / modulus
  }

  next_normal <- function() {
    sqrt(-2 * log(next_uniform())) * cos(2 * pi * next_uniform())
  }

  list(u = next_uniform, z = next_normal)
}

synth_permute <- function(n, rng) {
  x <- seq_len(n)

  if (n >= 2L) {
    for (i in seq.int(n, 2L)) {
      j <- floor(rng$u() * i) + 1L
      tmp <- x[i]
      x[i] <- x[j]
      x[j] <- tmp
    }
  }

  x
}

synth_truncnorm <- function(rng, mu, sigma, lower, upper) {
  if (lower > upper) stop("Invalid truncation interval")

  for (i in seq_len(30000L)) {
    z <- rng$z()
    x <- mu + sigma * z
    if (x >= lower && x <= upper) return(list(value = x, z = z))
  }

  stop("Truncated normal sampler failed; inspect the parameter bounds")
}

# --- Group-conditional age and ordinal education ---------------------------
# Smoothed education counts are aggregated parameters, NOT individual records.
# Age-education dependence uses a weak Gaussian copula. A random-offset
# systematic quantile allocation holds the realised categorical frequencies
# close to their smoothed probabilities, avoiding rare unrepresentative draws.
synth_group <- function(rng, group, n, n_female) {
  age_par <- switch(group, MDPU = c(24.65, 4.20),
                    Control = c(23.69, 3.45), stop("Invalid group"))
  bins   <- 10:17
  counts <- if (group == "MDPU") c(2, 1, 2, 4, 0, 1, 2, 10) else
                                   c(0, 0, 1, 3, 1, 1, 3, 11)
  counts_all  <- c(2, 1, 3, 7, 1, 2, 5, 21)
  global_prob <- (counts_all + 0.5) / (42 + 8 * 0.5)
  edu_prob    <- (counts + 5 * global_prob) / (n + 5)
  cum_prob    <- cumsum(edu_prob)
  rho         <- 0.18

  ages  <- numeric(n)
  edus  <- integer(n)
  z_edu <- numeric(n)

  # Gaussian copula: age is the inverse CDF of a truncated Gaussian,
  # driven by a standard-normal latent z_age. The second latent normal
  # drives ordinal education with correlation rho to the first.
  p_age_lo <- pnorm((18 - age_par[1L]) / age_par[2L])
  p_age_hi <- pnorm((35 - age_par[1L]) / age_par[2L])

  for (i in seq_len(n)) {
    z_age   <- rng$z()
    p_age   <- p_age_lo + (p_age_hi - p_age_lo) * pnorm(z_age)
    ages[i] <- round(age_par[1L] + age_par[2L] * qnorm(p_age), 8L)
    z_edu[i] <- rho * z_age + sqrt(1 - rho^2) * rng$z()
  }

  # Systematic sampling of the smoothed ordinal marginal: each cumulative
  # category count differs from its expectation by at most one. Assign the
  # balanced education values in the order of Gaussian-copula latent scores,
  # retaining stochastic age-education dependence without copying records.
  u_shift    <- rng$u()
  quantiles  <- (seq_len(n) - 1L + u_shift) / n
  categories <- bins[pmin(findInterval(quantiles, cum_prob) + 1L,
                           length(bins))]
  edus[order(z_edu)] <- categories

  sex <- rep("m", n)
  sex[synth_permute(n, rng)[seq_len(n_female)]] <- "f"

  data.frame(sex = sex, age = ages, edu = edus,
             group = rep(group, n), stringsAsFactors = FALSE)
}

# --- Generate coherent exposure histories and DTI measurements ------------
synth_cohort <- function(seed = 20261030, scenario = "null") {
  if (!scenario %in% c("null", "signal"))
    stop("Scenario must be exactly 'null' or 'signal'.")

  rng  <- synth_rng(seed)
  demo <- rbind(synth_group(rng, "MDPU", 22L, 3L),
                synth_group(rng, "Control", 20L, 4L))
  demo$MDMA <- sprintf("SYN%05d", seq_len(nrow(demo)))

  # Synthetic MDMA debut ages are integer values; duration is the resulting
  # age difference. This preserves the deterministic years_taken derivation.
  debut    <- rep(NA_integer_, 42L)
  duration <- rep(NA_real_, 42L)
  for (i in seq_len(22L)) {
    avg    <- 19.23 + 0.50 * (demo$age[i] - 24.65)
    upper  <- min(31, floor(demo$age[i] - 2))
    draw   <- synth_truncnorm(rng, avg, 2.35, 16, upper + 0.499999)
    debut[i]    <- max(16, min(upper, floor(draw$value + 0.5)))
    duration[i] <- demo$age[i] - debut[i]
  }

  # Draw exactly 11 heavy-user labels, preferentially (but not invariably)
  # among participants with longer exposure histories. This is a synthetic
  # association, NOT the original participants' heavy/light classifications.
  scores <- numeric(22L)
  for (i in seq_len(22L)) {
    scores[i] <- 2.40 * log(duration[i]) - log(-log(rng$u()))
  }
  heavy <- seq_len(22L) %in% order(scores, decreasing = TRUE)[seq_len(11L)]

  exposure <- integer(42L)
  monthly  <- rep(NA_real_, 42L)
  lastuse  <- rep(NA_integer_, 42L)
  dose     <- integer(42L)

  for (i in seq_len(22L)) {
    mu    <- if (heavy[i]) 5.50 else 2.61
    sigma <- if (heavy[i]) 0.63 else 0.95
    good  <- FALSE

    for (attempt in seq_len(30000L)) {
      candidate <- floor(exp(mu + 0.35 * (log(duration[i]) - 1.55) +
                             sigma * rng$z()) + 0.5)
      good <- if (heavy[i]) candidate >= 101 && candidate <= 850 else
                              candidate >= 3 && candidate <= 100
      if (good) break
    }
    if (!good) stop("Exposure-count sampler failed")

    exposure[i] <- as.integer(candidate)
    # Average monthly exposure is DERIVED from lifetime count and years
    # since debut, using 30.5 days/month and 365.25 days/year. This matches
    # the dominant arithmetic relationship in the historical CSVs. It is not
    # a separate observed stochastic variable.
    monthly[i] <- round(exposure[i] * 30.5 /
                        (duration[i] * 365.25), 9L)

    draw_dose <- 5 * floor(exp(5.40 +
                       0.27 * (log(exposure[i]) - 4.05) +
                       0.45 * rng$z()) / 5 + 0.5)
    dose[i] <- as.integer(min(850, max(50, draw_dose)))

    draw_last <- floor(exp(3.99 -
                    0.15 * (log(monthly[i]) - 0.03) -
                    0.35 * (log(dose[i]) - 5.45) +
                    0.80 * rng$z()) + 0.5)
    # Recruitment: use in previous year, abstention of at least seven days.
    # A lower limit of eight whole days is deliberately conservative.
    lastuse[i] <- as.integer(min(365, max(8, draw_last)))
  }

  # Eight region-specific diffusion measurements. Shared latent factors
  # generate cross-region covariance; one factor loads oppositely on FA/MD.
  rois  <- c("medinffg", "medinftempg", "occ", "orbfrc", "parc",
             "senmotc", "supfg", "suptempg")
  fa_mu <- c(0.454, 0.424, 0.474, 0.377, 0.474, 0.479, 0.435, 0.409)
  md_mu <- c(0.786, 0.775, 0.734, 0.821, 0.746, 0.750, 0.799, 0.801)
  # Region-specific residual noise: superior-frontal MD is notably more
  # variable in the source; the other values remain deliberately restrained.
  md_sigma <- c(0.011, 0.010, 0.008, 0.013, 0.012, 0.012, 0.026, 0.011)
  fa    <- matrix(NA_real_, 42L, length(rois))
  md    <- matrix(NA_real_, 42L, length(rois))

  for (i in seq_len(42L)) {
    u <- rng$z()
    v <- rng$z()

    for (j in seq_along(rois)) {
      eps_fa <- rng$z()
      eps_md <- rng$z()
      base_f <- fa_mu[j]
      base_m <- md_mu[j]

      fa_shift <- 0.0145 * u + 0.010 * eps_fa -
                  0.00025 * (demo$age[i] - 24)
      md_shift <- -0.016 * u + 0.009 * v + md_sigma[j] * eps_md +
                   0.0004 * (demo$age[i] - 24)

      if (scenario == "signal" && demo$group[i] == "MDPU") {
        if (rois[j] == "supfg") fa_shift <- fa_shift - 0.030
        if (rois[j] == "occ") {
          md_shift <- md_shift +
                      0.030 * (log(exposure[i]) - 4.05) / 1.67
        }
      }

      fa[i, j] <- round(plogis(qlogis(base_f) +
                       fa_shift / (base_f * (1 - base_f))), 7L)
      md[i, j] <- round(base_m * exp(md_shift / base_m), 7L)
    }
  }
  colnames(fa) <- paste0(rois, "_FA")
  colnames(md) <- paste0(rois, "_MD")

  # Exact original CSV field ordering; missing controls use '.' on export.
  common <- data.frame(MDMA = demo$MDMA, sex = demo$sex,
                       age = demo$age, edu = demo$edu, group = demo$group,
                       mdma_debut = debut, total_exposures = exposure,
                       avg_monthly_exposures = monthly,
                       time_since_last_use = lastuse,
                       avg_dose_per_session = dose,
                       stringsAsFactors = FALSE)
  list(fa = cbind(common, as.data.frame(fa)),
       md = cbind(common, as.data.frame(md)),
       heavy = heavy, scenario = scenario, seed = seed)
}

# --- Structural and semantic validation before writing source CSVs -----------
synth_validate <- function(data) {
  fa <- data$fa
  md <- data$md
  common <- c("MDMA", "sex", "age", "edu", "group", "mdma_debut",
              "total_exposures", "avg_monthly_exposures",
              "time_since_last_use", "avg_dose_per_session")
  rois <- c("medinffg", "medinftempg", "occ", "orbfrc", "parc",
            "senmotc", "supfg", "suptempg")
  expected_fa <- c(common, paste0(rois, "_FA"))
  expected_md <- c(common, paste0(rois, "_MD"))

  stopifnot(nrow(fa) == 42L, nrow(md) == 42L,
            identical(names(fa), expected_fa),
            identical(names(md), expected_md),
            identical(fa[common], md[common]),
            !anyDuplicated(fa$MDMA),
            all(grepl("^SYN[0-9]{5}$", fa$MDMA)))

  users    <- fa$group == "MDPU"
  controls <- fa$group == "Control"
  stopifnot(sum(users) == 22L, sum(controls) == 20L,
            sum(users & fa$sex == "f") == 3L,
            sum(controls & fa$sex == "f") == 4L,
            sum(users & fa$total_exposures > 100) == 11L,
            all(fa$age >= 18 & fa$age <= 35),
            all(fa$edu %in% 10:17),
            all(fa$total_exposures[users] >= 3),
            all(fa$total_exposures[controls] == 0),
            all(fa$avg_dose_per_session[controls] == 0),
            all(is.na(fa$mdma_debut[controls])),
            all(is.na(fa$avg_monthly_exposures[controls])),
            all(is.na(fa$time_since_last_use[controls])))

  duration <- fa$age[users] - fa$mdma_debut[users]
  expected_monthly <- fa$total_exposures[users] * 30.5 /
                      (duration * 365.25)
  stopifnot(all(is.finite(duration) & duration >= 2),
            all(fa$mdma_debut[users] >= 16),
            all(fa$mdma_debut[users] < fa$age[users]),
            all(fa$time_since_last_use[users] >= 8 &
                fa$time_since_last_use[users] <= 365),
            all(fa$time_since_last_use[users] < duration * 365.25),
            all(fa$avg_dose_per_session[users] > 0),
            all(abs(fa$avg_monthly_exposures[users] - expected_monthly) < 1e-8))

  for (values in list(as.matrix(fa[expected_fa[-seq_along(common)]]),
                      as.matrix(md[expected_md[-seq_along(common)]]))) {
    stopifnot(all(is.finite(values)),
              all(values > 0),
              all(apply(values, 1L, sd) > 0))
  }
  stopifnot(all(as.matrix(fa[expected_fa[-seq_along(common)]]) < 1))
  invisible(TRUE)
}

synth_write <- function(data, root, overwrite = FALSE) {
  synth_validate(data)
  dest <- file.path(root, "databank", "dataset-synth", "1-original")
  paths <- file.path(dest, c("MDMA_fa_relevant_data.csv",
                              "MDMA_md_relevant_data.csv"))
  if (any(file.exists(paths)) && !overwrite)
    stop("Synthetic CSVs already exist. Specify --overwrite to replace them.")

  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  write.csv(data$fa, paths[1L], row.names = FALSE, na = ".", quote = FALSE)
  write.csv(data$md, paths[2L], row.names = FALSE, na = ".", quote = FALSE)

  metadata <- c("MDMA-DTI fictional synthetic cohort (no individual records copied)",
                paste("scenario:", data$scenario),
                paste("seed:", data$seed),
                "model_revision: 2",
                "education_sampling: random-offset systematic CDF + copula ranks",
                "heavy_use_selection: 2.40*log(duration) + Gumbel noise",
                "MD_residual_scales: region-specific, supfg=0.026",
                "generator: generate_synthetic_data.R", 
                "execution_engine: R (when generated by Rscript)",
                "participants: 22 MDPU, 20 controls; 11 heavy MDPU",
                "monthly-frequency formula: total_exposures * 30.5 / (years_taken * 365.25)",
                "NOTE: Re-running the generator invalidates existing 2-derived/",
                "results until Rscript run.R all --dataset=synth is re-run.")
  writeLines(metadata, file.path(root, "databank", "dataset-synth",
                                 "SCENARIO.txt"))
  message("Synthetic CSVs written to ", dest,
          "; scenario=", data$scenario, "; seed=", data$seed)
  invisible(paths)
}

# --- Command-line entry point ----------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
if (any(args %in% c("-h", "--help"))) {
  cat("Usage: Rscript generate_synthetic_data.R [--scenario=null|signal] [--seed=20261030] [--overwrite]\n")
} else {
  scenario_arg <- grep("^--scenario=", args, value = TRUE)
  seed_arg     <- grep("^--seed=", args, value = TRUE)
  if (length(scenario_arg) > 1L || length(seed_arg) > 1L)
    stop("Specify each option at most once")
  if (any(!grepl("^--(scenario|seed)=|^--overwrite$", args)))
    stop("Unrecognised option: ", paste(args, collapse = " "))

  scenario <- if (length(scenario_arg)) sub("^--scenario=", "", scenario_arg) else "null"
  seed     <- if (length(seed_arg)) as.double(sub("^--seed=", "", seed_arg)) else 20261030
  overwrite <- "--overwrite" %in% args

  argv0 <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (!length(argv0)) stop("Invoke from a shell with Rscript generate_synthetic_data.R")
  root <- dirname(normalizePath(sub("^--file=", "", argv0[1L]), mustWork = TRUE))

  synth_write(synth_cohort(seed, scenario), root, overwrite)
}
