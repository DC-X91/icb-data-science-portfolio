# Project 1 | Source and data map

The historical project engine is organised by analysis stage; the smaller `exemplar/` directory selects representative files and one archived ex-Gaussian run. Paths below are relative to `Project_1_Bayes_SRT/`.

## Data and execution flow

```text
Project engine/codebank/stage1_data-simulation/
  MATLAB generators and fitted parameter selections
        ↓
Project engine/databank/simdata-250/
  simulated per-subject MAT files
        ↓
Project engine/codebank/stage2_bayes-inf/jobs/
  C callback → MATLAB Engine (prior + log likelihood) → MultiNest
  configured and launched using Bash / PBS / MPI
        ↓
Project engine/codebank/stage2_bayes-inf/results/
  posterior draws, evidence and run statistics
        ↓
Project engine/codebank/stage3_model-selection-analysis/
  within-subject and cross-subject model comparisons
Project engine/codebank/stage4_param-estim-analysis/
  posterior-parameter recovery
```

## Representative sources

| Component | Selected files in `exemplar/` | Role |
| --- | --- | --- |
| Data simulation | `src/simulation/gen_sim_data.m`, `find_best_subs.m`, `exgaussrnd.m` | Choose source parameters and generate virtual response times |
| Statistical model | `src/likelihood/loglike_srt_exgauss.m`, `exgausspdf.m` | Evaluate ex-Gaussian likelihood |
| Prior interface | `src/prior/parsfromhcube.m`, `convert_exgauss.m` | Transform unit-cube samples to model parameters |
| Nested sampling | `src/inference/bayesfit-exgauss-mom-sim250.c`, `get_loglike_exgauss.m`, `multinest.h` | C ↔ MATLAB interface to external MultiNest |
| HPC configuration | `src/inference/config-init.sh`, `pbs-init-script`, `Makefile` | Build, configure and schedule historical jobs |
| Model comparison | `src/analysis/x2_intrasubject_comparisons.m`, `x3_transsubject_comparisons.m`, `bayes_model_comp.m`, `bayes_ensemble_comp.m` | Compare model evidence within and across simulated subjects |

## Archived example

```text
exemplar/data/subject-11_model-exgauss.mat
        ↓ [250 simulated trials]
exemplar/results/exgauss-mom-sim250_post_equal_weights.dat
exemplar/results/exgauss-mom-sim250_stats.dat
exemplar/results/exgauss-mom-sim250_summary.txt
        ↓
exemplar/verify_likelihood.py  [read-only, retrospective check]
```

The posteriors and evidence are **archived results**, not output regenerated from the files in `exemplar/`. In particular, the available MATLAB generator requests a different trial count, the historical prior pathname is unresolved, and the source versions have a prior-transform argument mismatch. The selected code illustrates architecture; it is not guaranteed to build or execute in isolation.
