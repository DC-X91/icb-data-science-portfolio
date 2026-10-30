# Technical portfolio | Two Bayesian research projects

This portfolio presents two examples of statistical modelling and scientific computing. The README.md summaries in the project directories are the best starting points; the code maps in under each projects `Project engine/docs` provide overviews of the implementation, and an exemplar contained in the `exemplar` directory in the first project traces one path through a multi-stage parallelised workflow.

## Project 1 — Bayesian modelling of simple reaction time

- **Start:** [`Project_1_Bayes_SRT/Project 1 – Summary.md`](Project_1_Bayes_SRT/Project%201%20%E2%80%93%20Summary.md)
- **Implementation:**  [`Project_1_Code_map.md`](Project_1_Bayes_SRT/Project engine/docs/Project_1_Code_map.md)
- **Example:** [`exemplar/README.md`](Project_1_Bayes_SRT/exemplar/README.md)

The PhD project integrated MATLAB modelling, C/MATLAB Engine callbacks, MultiNest nested sampling, and HPC batch execution. The selected example contains genuine archived results for 250 simulated reaction times and a reproducible numerical likelihood check. The original cluster installation is **not** packaged as a portable executable.

## Project 2 — Bayesian analysis of MDMA exposure and diffusion measurements

- **Start:** [`Project_2_MDMA/Project 2 – Summary.md`](Project_2_MDMA/Project%202%20%E2%80%93%20Summary.md)
- **Code:** [`Project engine/README.md`](Project_2_MDMA/Project%20engine/README.md), with [`CODE_MAP.md`](Project_2_MDMA/Project%20engine/docs/CODE_MAP.md) and [`SYNTHETIC_DATA.md`](Project_2_MDMA/Project%20engine/docs/SYNTHETIC_DATA.md)

This is a collaborative observational study I am currently involved in, to which I am contributing the Bayesian methodology and analysis. The supplied R uses synthetic inputs to allow for an end-to-end demonstration of the pipeline while avoiding issues relating to data protection. While the synthetic data has been generated to accurately reflect the key features of the real data, it is not intended and cannot be used to draw real-world conclusions.
