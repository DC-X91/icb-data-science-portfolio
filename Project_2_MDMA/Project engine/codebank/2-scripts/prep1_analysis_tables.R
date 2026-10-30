# =============================================================================
# prep1_analysis_tables.R  |  MATLAB source: prep1_analysis_tables.m
#
# Purpose: Prepare 42-participant FA/MD data for Bayesian model selection:
#          demographics, MDMA usage measures, and four representations of
#          each diffusion measure (raw, mean-centred, z, mean-scaled).
# Defines: prep1_analysis_tables(), with local read_source() and z() helpers.
# Calls:   mdma_project_root(), mdma_input(), measure_normed(),
#          mdma_prepared(), mdma_save(); base read.csv() and stats::sd().
# Called by: run.R (prep stage).
# Output:  databank/dataset-{real|synth}/2-derived/mdma_data.rds
#          (when save = TRUE, in the selected data branch).
#
# Provenance: Loads ORIGINAL regional measures, not residuals after regressing
#             out demographics. Demographic adjustment is handled by candidate
#             predictors in the subsequent Bayesian model comparisons.
# =============================================================================

prep1_analysis_tables <- function(root = mdma_project_root(), save = TRUE) {
  # --- Read original data and verify participant correspondence ---------------
  source_dir <- mdma_input(root)

  read_source <- function(filename) {
    read.csv(file.path(source_dir, filename), stringsAsFactors = FALSE,
             check.names = FALSE, na.strings = c(".", "NA", ""))
  }

  src_fa <- read_source("MDMA_fa_relevant_data.csv")
  src_md <- read_source("MDMA_md_relevant_data.csv")

  stopifnot(identical(src_md$MDMA, src_fa$MDMA), nrow(src_fa) == nrow(src_md))
  stopifnot(ncol(src_fa) == 18L, ncol(src_md) == 18L)

  z <- function(x) (x - mean(x)) / sd(x)  # MATLAB std = sample SD.

  # --- Demographic covariates ------------------------------------------------
  demographics <- src_fa[, c(1L, 5L, 2L, 3L, 4L), drop = FALSE]
  names(demographics)[1L] <- "subject_id"
  demographics$group       <- factor(demographics$group)
  demographics$sex         <- factor(demographics$sex)

  mdma_data <- list(demographics_raw = demographics,
                    demographics_z = demographics)

  mdma_data$demographics_z$age <- z(demographics$age)
  mdma_data$demographics_z$edu <- z(demographics$edu)

  # --- MDMA user exposure histories and derived predictors -------------------
  useridx <- demographics$group == "MDPU"
  mdmause <- src_fa[useridx, c(1L, 6L:10L), drop = FALSE]
  names(mdmause)[1L] <- "subject_id"

  if (anyNA(mdmause)) stop("Missing MDPU exposure values; cannot reproduce source analysis.")
  for (j in 2:ncol(mdmause)) mdmause[[j]] <- as.numeric(mdmause[[j]])

  mdmause$accumulated_dose    <- mdmause$total_exposures * mdmause$avg_dose_per_session
  mdmause$avg_dose_per_month <- mdmause$avg_monthly_exposures * mdmause$avg_dose_per_session
  mdmause$years_taken        <- demographics$age[useridx] - mdmause$mdma_debut

  mdma_data$mdmause_raw <- mdmause
  mdma_data$mdmause_z   <- mdmause
  for (j in 2:9) mdma_data$mdmause_z[[j]] <- z(mdmause[[j]])

  # --- Four representations of FA and MD across eight regions ----------------
  fa <- src_fa[, c(1L, 11L:18L), drop = FALSE]
  md <- src_md[, c(1L, 11L:18L), drop = FALSE]
  names(fa)[1L] <- "subject_id"
  names(md)[1L] <- "subject_id"

  fa_norm <- measure_normed(fa)
  md_norm <- measure_normed(md)

  # Preserve field insertion order in the source MATLAB structure.
  mdma_data$fa_raw       <- fa
  mdma_data$fa_meanctr   <- fa_norm$meanctr
  mdma_data$fa_z         <- fa_norm$z
  mdma_data$fa_meanscale <- fa_norm$meanscale
  mdma_data$md_raw       <- md
  mdma_data$md_meanctr   <- md_norm$meanctr
  mdma_data$md_z         <- md_norm$z
  mdma_data$md_meanscale <- md_norm$meanscale

  # --- Save prepared dataset, optionally ------------------------------------
  if (save) mdma_save(mdma_data, mdma_prepared(root))
  mdma_data
}
