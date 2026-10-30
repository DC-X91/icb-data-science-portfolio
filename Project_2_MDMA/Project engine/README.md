# Project 2 | Bayesian DTI regression engine (R)

This R project reconstructs the statistical-analysis component of a collaborative observational study involving **22 recreational MDMA polydrug users** and **20 non-drug-using controls**. Regional fractional anisotropy (FA) and mean diffusivity (MD) measurements were recorded for eight regions of interest. The earlier Bayesian analysis was implemented in MATLAB; the R implementation and synthetic demonstration date from **2026**. It does not implement neuroimaging acquisition or preprocessing.

## Quick start

Use R 4.2+ and standard R packages. From this directory:

```bash
Rscript run.R all --dataset=synth
```

The supplied synthetic inputs are generated using a deterministic seed and match the input field structure expected by the analysis. To regenerate the source CSVs and then rerun the analysis:

```bash
Rscript generate_synthetic_data.R --scenario=null --seed=20261030 --overwrite
Rscript run.R all --dataset=synth
```

**Always include `--dataset=synth` when using this demonstration.** `run.R` currently defaults to `real` for compatibility with the historical workflow. Regenerating synthetic CSVs requires `--overwrite`; after regeneration, rerun the analysis to prevent mismatch between inputs and saved outputs.

## Workflow and outputs

| Stage | Purpose | Principal output (`databank/dataset-synth/2-derived/`) |
| --- | --- | --- |
| `prep` | Import FA/MD data; construct raw and within-person transformed outcomes | `mdma_data.rds` |
| `intergroup` | Compare 16 group/demographic predictor subsets across 64 outcomes | `a1-intergroup-results.rds` |
| `group-best` | Summarise the best group-containing regression models | `a1b-groupmodels-v-best.csv` |
| `intragroup` | Compare 2,048 predictor subsets among MDMA users | `a2-mdmagroup-results.rds` |
| `usage-predicts` | Summarise candidate models containing MDMA-use predictors | `a2b-usagepredicts.rds`, `.csv` |
| `permutation` | One seeded, limited permuted-data diagnostic | `a3-mdmagroup-results.rds`, `a3-permutation-indices.rds` |

The complete pipeline has been executed on the supplied synthetic null-scenario inputs. Its two CSV summary outputs have been numerically cross-checked. This confirms a reproducible execution path, **not** complete independent validation of every large binary RDS result, the historical empirical analysis or its scientific conclusions. The permutation stage is not a full permutation test or family-wise error correction.

## File organisation

```text
run.R                         command-line dispatcher
codebank/1-lib/               model comparison, priors and shared helpers
codebank/2-scripts/           six analysis stages
generate_synthetic_data.R     fictional input generator
databank/dataset-synth/       fictional inputs and synthetic-only outputs
databank/dataset-real/        RESTRICTED original data and derived results
docs/CODE_MAP.md              call and file dependencies
docs/SYNTHETIC_DATA.md        data-generating design and validation limits
```

`bflrtable()` fits predictor subsets using `stats::lm()` and evaluates Zellner–Siow-prior Bayes factors with `bfzsprior()`. Some predictors are strongly correlated or arithmetically related. Model rankings in this 22-person subgroup should therefore be interpreted cautiously.

**Reporting caveat:** the inherited field `BayesFactor_best` contains an extra normalisation and must not be described as a pairwise Bayes factor. Use appropriately defined contrasts, such as `lnBFx2_best`, with their documented interpretation.

## Research-data boundary

**Do not include the entire `databank/dataset-real/` branch in an external submission** without specific authorisation, including its high-precision derived model results. The synthetic observations are fictional and are not a surrogate for the participants or a reproduction of the study's findings. Some synthetic calibration constants were informed by rounded study aggregates, so disclosure decisions still require judgement. Both the root and branch-local `.gitignore` rules help prevent accidental Git staging; they do **not** filter files added to a ZIP manually. Check the actual export manifest before sharing.

For code dependencies, see [`docs/CODE_MAP.md`](docs/CODE_MAP.md); for the generator assumptions and fixed seeds, see [`docs/SYNTHETIC_DATA.md`](docs/SYNTHETIC_DATA.md).
