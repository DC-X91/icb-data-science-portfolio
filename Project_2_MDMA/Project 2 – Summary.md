# Project 2 Summary

**Investigating the Effects of MDMA Use on Brain White Matter Using Bayesian Statistical Modelling**

Research Project | Neuroimaging, Bayesian Statistics and Data Analysis

## Project overview
### Background
This collaborative research project investigated whether recreational MDMA use is associated with measurable differences in brain white matter microstructure, using neuroimaging data from a Copenhagen cohort comprising MDMA users and non-drug-using controls.

Research using positron emission tomography (PET) has previously identified evidence of reduced serotonin transporter availability in particular brain regions among MDMA users; furthermore, research in animals has linked serotonergic abnormalities in certain brain regions to possible axonal damage following MDMA administration. Against this background, the study sought to investigate whether differences in white matter microstructure could be detected through diffusion tensor imaging (DTI) metrics, which are derived from diffusion-weighted imaging (DWI), itself an application of magnetic resonance imaging (MRI). DTI offers indirect measures of tissue microstructure, providing a way to investigate whether molecular imaging findings coincide with structural differences.

The analysis focused on two established DTI metrics:

- Mean diffusivity (MD): A measure of the average diffusion of water molecules within tissue.
- Fractional anisotropy (FA): A measure of how directionally constrained water diffusion is, providing information about white matter microstructure.

The cohort comprised 22 recreational MDMA users (who also used other drugs) and 20 non-drug-using controls. DTI measurements were extracted for eight regions of interest, preselected because earlier PET results had identified reduced serotonin transporter availability in those regions. The scientific questions were (a) whether group membership predicted regional FA or MD and (b) whether, among users, measures of exposure history helped explain variation in those measurements.

The observational, cross-sectional design and polydrug exposure limit causal inference.

### Research objectives
The study addressed two related questions. First, did regional MD and FA measurements differ between MDMA polydrug users and non-drug-using controls, allowing for age, sex and education as alternative or additional explanatory variables? Second, among MDMA users, did measures of exposure history—including lifetime use, frequency and dosage—help explain variation in those diffusion measurements?

I used Bayesian linear regression and model comparison to assess the evidence for these associations across alternative combinations of predictors, including models without the group or exposure variables of interest. The analysis addressed statistical associations, not causal effects.

### Statistical design
The workflow considered eight regions, two diffusion metrics and four response representations (raw, within-person mean-centred, within-person standardised and within-person mean-scaled), totalling 64 outcome configurations. These representations answer somewhat different questions about regional magnitude and within-person patterns.

#### 1. Intergroup analysis
For each FA/MD-by-region outcome, Bayesian linear regression assessed alternative combinations of MDMA group, age, sex and education as predictors. The model space contained 16 subsets of four candidate predictors, including an intercept-only reference. Model evidence was evaluated with Zellner-Siow regression priors, allowing comparisons between models with and without group membership rather than relying exclusively on a null-hypothesis significance threshold.

#### 2. Exposure analysis within MDMA users
Among the 22 users, the analysis compared 2,048 candidate subsets of 11 demographic and exposure-history predictors per outcome, including an intercept-only reference model. The predictors included lifetime exposures, frequency of use, age at first use, duration of use and dosage measures.

### Technical implementation
The original Bayesian analyses were implemented in MATLAB. I developed and applied a workflow for preparing regional diffusion measurements, specifying candidate Bayesian regression models, comparing their marginal likelihoods under Zellner–Siow priors, and interpreting the resulting evidence.

For this portfolio, I reconstructed the statistical workflow file-for-file in R, which I had been intending to anyway to harmonise with my collaborators’ coding choices. The executable project separates four components:

- **Data preparation:** Reading matched FA and MD inputs and constructing alternative representations of the regional measurements.
- **Bayesian analyses:** Enumerating and comparing candidate predictor subsets for intergroup and within-user regressions.
- **Results and diagnostic checks:** Extracting selected model comparisons and performing a limited permutation diagnostic.
- **Reproducible demonstration:** Running the pipeline on synthetic data with the same input schema while keeping restricted original research data in a separate branch.

The six-stage R pipeline has been run on the supplied synthetic dataset, generating its expected outputs to allow one to establish that the reconstructed execution path runs end-to-end. I have already confirmed it works on my local machine.

### Findings
The analysis did not identify convincing evidence that mean diffusivity or fractional anisotropy varied systematically with the MDMA-use variables investigated.

These findings did not support the hypothesised associations within the analysed dataset, although they do not establish that MDMA use has no effects on white matter.

## Portfolio notes
### Project significance
This project demonstrates the application of Bayesian statistical modelling to a neuroscientific research question involving complex biological measurements and competing hypotheses.

The work required translating a theoretical relationship between serotonin dysfunction and potential structural abnormalities into testable statistical models, systematically comparing alternative explanations and interpreting findings in the context of the available evidence.

It also illustrates the importance of reporting negative findings appropriately, distinguishing between a lack of evidence for an association and evidence that an association is absent.

### My role and contribution
I contributed the Bayesian statistical methodology, analysis, interpretation and visual presentation within a multidisciplinary team and participated in developing and revising the manuscript. The manuscript (in preparation) credits me (DC) under methodology, investigation, visualisation, and writing—review and editing. Data acquisition, MRI preprocessing, PET analysis and other statistical analyses were conducted collaboratively or by other team members; the study as a whole should not be attributed solely to me.

### Example code and data sources
The example code illustrates my analytical and methodological contribution to this collaborative study. The supplied R engine is a **2026 reconstruction** of the earlier MATLAB analysis, run here on synthetic rather than participant-level data. This allows the operation of the statistical workflow to be demonstrated without distributing the original research observations. The reconstructed computing environment is not the exact historical one, and its synthetic outputs do not reproduce the empirical findings.

The `project-engine` directory contains the executable R workflow, synthetic inputs and outputs, and supporting documentation. The retained `dataset-real` branch contains restricted research data and derived results; it must be excluded from any external submission without data-controller approval. A `.gitignore` file does not, by itself, exclude these files from a manually prepared ZIP archive.

See:

- `project-engine/README.md`
- `project-engine/docs/CODE_MAP.md`
- `project-engine/docs/SYNTHETIC_DATA.md`

for details of the implementation, synthetic data and remaining audit limitations.

### Key skills demonstrated
#### Scientific and statistical reasoning
- Bayesian linear regression and Zellner–Siow prior specification
- Marginal-likelihood and Bayes-factor model comparison
- Exhaustive subset-model evaluation and comparison of null and alternative models
- Group comparisons and exposure–response analysis
- Assessment of model multiplicity, collinearity and small-sample limitations
- Interpretation of diffusion-MRI measures and limitations of observational studies
- Critical reporting of negative and inconclusive statistical findings

#### Programming and analytical computing
- MATLAB (historical analysis) and R (2026 reconstruction)
- Modular scientific programming and reusable statistical functions
- Automated regression modelling, predictor-subset enumeration and numerical integration
- Reproducible command-line workflows and deterministic synthetic-data generation
- Data preparation, transformation, schema validation and organisation of derived outputs
- Independent numerical checks, code mapping and provenance documentation
- Separation of restricted research data from demonstration materials

#### Research collaboration and transferable skills
- Interdisciplinary work across statistics, neuroimaging and clinical science
- Translating scientific questions into operational statistical comparisons
- Communicating methodological assumptions, uncertainty and limitations to collaborators
- Data visualisation and collaborative manuscript development and revision
- Responding constructively to scientific criticism
- Self-directed methodological implementation
- Research integrity, confidentiality and responsible disclosure of sensitive data
