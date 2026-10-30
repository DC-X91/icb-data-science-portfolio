# Project 1 example | Simulated SRT data and ex-Gaussian fit

This directory illustrates a selected historical inference result for 250 simulated reaction times, including the sources around its MATLAB/C/MultiNest interface. It is a technical example, not a standalone rebuild of the original HPC application.

## Contents

- `data/subject-11_model-exgauss.mat` — simulated virtual-subject reaction times (MATLAB v7.3/HDF5).
- `results/exgauss-mom-sim250_post_equal_weights.dat` — 4,322 equal-weight posterior samples; columns are `mu`, `sigma`, `tau`, and log likelihood.
- `results/exgauss-mom-sim250_stats.dat` and `_summary.txt` — archived evidence and inference summaries.
- `src/simulation/` — historical data-generating functions and parameter selection.
- `src/likelihood/` and `src/prior/` — model density, likelihood and parameter transforms.
- `src/inference/` — C callback, MATLAB Engine wrapper, configuration, Makefile and PBS job script.
- `src/analysis/` — downstream model-comparison routines.
- `verify_likelihood.py` — retrospective, read-only check of the saved data and posterior likelihoods.

## Reproduce the numerical check

```bash
python -m pip install numpy scipy h5py
python verify_likelihood.py
```

The check uses the analytic ex-Gaussian density and compares its sum of log densities with every recorded posterior log likelihood. The maximum absolute difference is approximately 2.3 × 10⁻¹². It does not reproduce the MultiNest evidence calculation, the posterior sampling run or its convergence diagnostics.

## Provenance and limits
The existing `gen_sim_data.m` generates 25,000-trial datasets, not this 250-trial historical sample. The exact old prior and matching prior-transform code are not established. MATLAB, MultiNest and HPC dependencies are not included or configured for present-day execution.
