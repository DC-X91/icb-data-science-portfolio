# Project 2 | Synthetic data: design and use

## Purpose

The synthetic branch contains 42 synthetic subjects (22 MDMA-use records, 20 control records) with the same input schema as the Bayesian DTI analysis. The default scenario is constructed without an injected MDMA effect; a separate `signal` scenario introduces known simulated effects. These examples are intended to aid in demonstrating how the computational pipeline behaves. They do not reproduce participant records or empirical research findings: they should not be interpreted as evidence about the biological effect of MDMA, nor as reproductions of the historical paper's results.

For the saved-file dependencies, see [`CODE_MAP.md`](CODE_MAP.md).

## Generation and execution

From the engine root:

```bash
# Run the supplied fictional inputs
Rscript run.R all --dataset=synth

# Intentionally regenerate synthetic inputs (replaces existing CSVs)
Rscript generate_synthetic_data.R --scenario=null --seed=20261030 --overwrite
Rscript run.R all --dataset=synth   # See note just below
```

The generator writes `databank/dataset-synth/1-original/MDMA_fa_relevant_data.csv`, `MDMA_md_relevant_data.csv` and a `SCENARIO.txt` describing settings. The analysis writes only to `databank/dataset-synth/2-derived/` when `--dataset=synth` is supplied. Regenerating a scenario without rerunning the analysis leaves out-of-date derived results; always regenerate the latter too with `Rscript run.R all --dataset=synth`.

The generator uses a self-contained Park–Miller pseudorandom generator and Box–Muller normal draws, rather than R's global random-number state. The default generator seed is 20261030. The analysis permutation stage uses a separate seed, 101.

## Generative assumptions

- **Demographics:** group-specific truncated age distributions and a smoothed, ordinal education distribution; sex and heavy-use counts fixed by design. Education is allocated using randomly shifted quantiles and a modest age–education copula dependence.
- **Exposure:** debut age is generated conditionally on current age; heavy-use assignment favours longer use histories. Total exposures follow constrained lognormal distributions conditional on duration and category. Dose and recency depend probabilistically on exposure history and use intensity.
- **FA/MD:** eight regional baselines, shared subject-level Gaussian factors and region-specific residual variation give plausible within-person regional correlation. FA is bounded in `(0,1)` and MD is positive. Weak age dependence is included. These are synthetic modelling choices, not an estimate of the original participants' joint distribution.
- **Scenarios:** `null` adds no direct group/exposure effect to regional FA or MD; `signal` injects a reduced FA value in the superior-frontal region and an MD association with lifetime exposure in the occipital region. Apparent associations in a realised null sample can still arise from sampling variability.

Some broad calibration constants were informed by rounded study-level aggregates, rather than participant-level sampling or copying.