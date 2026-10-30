# Project 1 Summary

**Bayesian Modelling of Simple Reaction Time Using High-Performance Computing**

PhD Research Project | Computational Modelling, Bayesian Statistics and Scientific Programming

## Project overview
### Background, objectives, and approach
During my PhD, I developed and implemented a computational framework for modelling human performance in the Simple Reaction Time (SRT) task, a cognitive experiment used to investigate attention and response preparation. The task consists of a sequence of trials, and each trial starts with a “foreperiod” (FP) – a variable waiting time – followed by an “imperative stimulus” (IS). The aim of the task is to respond as quickly as possible to IS upon its appearance, but not before. The task is of basic importance to cognitive science, since it represents the simplest possible variation of a wide range of commonly used stimulus-response decision-making and attention tasks.

Previous empirical research had established that mean response time (RT) varies systematically with FP duration; furthermore, it found that the very form of the relationship between FP duration and mean RT itself changes predictably according to the overall distribution of FP durations in the task, implying the presence of learning and attention allocation mechanisms. However, previous mathematical modelling work had generally focused only on modelling the overall distribution of response times resulting from an individual’s performance of the task as simple parameterised distributions, essentially treating trials as independently and identically distributed, thereby ignoring the demonstrated systematic effects of FP duration on mean RT.

My objective was to develop alternative mathematical models incorporating foreperiod-dependent behaviour and evaluate their performance against established models using Bayesian model comparison.

### Technical implementation
See also: `Project_1_Architecture_note.md`.

The central technical challenge was the computational complexity of the proposed models. Most of the newly developed models required reaction-time distributions to be estimated from repeated simulations at the individual-trial level, making conventional parameter estimation computationally impracticable.

To address this, I used MultiNest, a nested-sampling algorithm capable of efficiently estimating posterior parameter distributions and Bayesian model evidence.

I designed and built a multi-layered computational workflow integrating four functional layers:

- **SRT modelling (MATLAB):** Implementing mathematical reaction-time models, specifying priors and parameter transformations, loading simulated or empirical data, and evaluating model log likelihoods.
- **Bayesian inference (C/MATLAB Engine and MultiNest):** Connecting the MATLAB likelihood functions to MultiNest's nested-sampling implementation, enabling posterior parameter estimation and model-evidence calculations, including MPI-based parallel execution.
- **Job orchestration (Bash, PBS and HPC):** Configuring combinations of datasets, models and priors; building and staging executable components; allocating cluster resources; and scheduling jobs on Imperial College's High Performance Computing cluster. The empirical study involved data from 18 subjects, with inference jobs scheduled in parallel.
- **Results management and analysis (MATLAB):** Retrieving posterior samples and evidence estimates for within-subject and cross-subject comparisons and parameter-recovery analysis.

The architecture allowed different combinations of models, priors and datasets to be evaluated through a configurable workflow, while transferring computationally intensive operations to the HPC environment.

## Portfolio notes
### Project significance
This project combined cognitive science research with Bayesian statistical inference, simulation-based mathematical modelling and distributed scientific computing.

Beyond developing and evaluating mathematical models, I was responsible for engineering the computational infrastructure required to run them efficiently, integrating software written in different programming languages and managing execution on a high-performance computing system.

### My contribution and responsibilities
I was solely responsible for the scientific direction, architecture, implementation and execution of this PhD project. I selected models and comparison logic, developed and maintained the custom MATLAB/C/Bash integration, configured large HPC runs, and interpreted their results. I integrated the published MultiNest algorithm; I did not develop MultiNest itself.

### Example code and data sources
The code presented represents a validation stage in the project, which used simulated participant-level reaction times, where the simulation parameters were obtained from fits of plausible models to empirical data. The computational pipeline is substantially the same as that used in the subsequent empirical analysis, while using simulated observations avoids distributing participant-level reaction-time records. Because some simulation parameters came from empirical fits, the selected materials still require a provenance and disclosure review before external sharing.

The `exemplar` directory illustrates one archived inference run using genuine simulated observations and saved results, together with a retrospective numerical likelihood check. The historical HPC dependencies are not supplied as a portable, end-to-end executable package.

See:

- `Project_1_Architecture_note.md`
- `Project_1_Code_map.md`
- `exemplar/README.md`

for further details.

### Key skills demonstrated
#### Statistical and scientific reasoning
 - Probabilistic generative modelling
 - Model specification and identifiability
 - Bayesian statistics:
     - prior specification and reparameterisation
     - likelihood construction; nested sampling
     - posterior inference
     - marginal likelihood/Bayes factors computation
- Simulation-based benchmarking
- Model and parameter recovery; interpretation of uncertainty and model misspecification

#### Programming and research computing
- MATLAB scientific programming
- C/MATLAB Engine interoperability
- Integration of Fortran/MPI scientific libraries
- Bash configuration and automation; Makefiles; Unix/Linux; PBS array jobs
- HPC resource management and distributed execution
- Modular code architecture
- Dataset and result organisation

#### Research leadership and transferable skills
- Autonomous problem formulation and project ownership
- Systems thinking and computational design
- Analysis of a complex problem into independently testable modules
- Technical troubleshooting across interfaces
- Organising and prioritising experimental runs
- Communicating complex methods to technical and non-technical audiences
- Persistence in long-horizon investigation