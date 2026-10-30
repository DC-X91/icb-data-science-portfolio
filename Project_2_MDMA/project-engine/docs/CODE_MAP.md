# Project 2 | R code map

All paths are relative to the directory containing `run.R`. The entry point loads helper functions from `codebank/1-lib/`, loads stage functions from `codebank/2-scripts/`, and dispatches them in dependency order. Stages communicate through **saved files**, not by directly calling subsequent stage functions.

## Dataset isolation

```text
databank/
  dataset-synth/
    1-original/    generated FA and MD input CSVs
    2-derived/     results of the synthetic pipeline
  dataset-real/
    .gitignore     restricted branch; keep data out of Git
    1-original/    restricted participant-level CSVs
    2-derived/     restricted derived research results
```

The `--dataset=synth|real` switch selects all input and output paths for one run. The synthetic generator writes only to `dataset-synth/1-original/`; the analysis stores results only under the selected branch. `run.R` defaults to `real`, so **specify `--dataset=synth` for any demonstration**.

## File dependencies

```text
Selected branch/1-original/MDMA_fa_relevant_data.csv
Selected branch/1-original/MDMA_md_relevant_data.csv
        |
        v
prep1_analysis_tables()                  [prep]
        +-- 2-derived/mdma_data.rds
                      |
            +---------+--------------------------+
            |                                    |
            v                                    v
     anl1_intergroup()                     anl2_mdmagroup()
     [intergroup]                          [intragroup]
            |                                    |
            v                                    v
     a1-intergroup-results.rds             a2-mdmagroup-results.rds
            |                                    |
            v                                    v
     anl1b_groupmodels_v_best()             anl2b_usagepredicts()
     [group-best]                          [usage-predicts]
            |                                    |
            v                                    v
     a1b-groupmodels-v-best.csv            a2b-usagepredicts.rds/.csv

From mdma_data.rds:
     anl3_multcomptest() [permutation]
            +-- a3-mdmagroup-results.rds
            +-- a3-permutation-indices.rds
```

## Active source files

| Source | Main function or role |
| --- | --- |
| `run.R` | Parse stage and dataset selection; source libraries and dispatch stage functions |
| `generate_synthetic_data.R` | Independently generate schema-compatible fictional FA/MD input files |
| `codebank/1-lib/mdma_helpers.R` | Dataset path isolation, prepared-data I/O and regional labels |
| `codebank/1-lib/measure_normed.R` | Raw, mean-centred, standardised and mean-scaled response representations |
| `codebank/1-lib/combos.R` | Enumerate predictor subsets |
| `codebank/1-lib/bflrtable.R` | Fit linear regressions and assemble model comparisons |
| `codebank/1-lib/bfzsprior.R` | Evaluate Zellner–Siow marginal-likelihood Bayes factors |
| `codebank/2-scripts/prep1_analysis_tables.R` | Prepare inputs and outcome representations |
| `codebank/2-scripts/anl1_intergroup.R` | Group/demographic models; 16 subsets × 64 outcomes |
| `codebank/2-scripts/anl1b_groupmodels_v_best.R` | Best group-containing model summaries |
| `codebank/2-scripts/anl2_mdmagroup.R` | Within-user models; 2,048 subsets × 64 outcomes |
| `codebank/2-scripts/anl2b_usagepredicts.R` | Exposure-predictor model summaries |
| `codebank/2-scripts/anl3_multcomptest.R` | Seeded single-permutation diagnostic |