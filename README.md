# Human Perception of Biodiversity in Naturalistic Auditory Scenes

MATLAB code accompanying:

> McWalter, R. & Lorenzi, C. "Human Perception of Biodiversity in Naturalistic Auditory Scenes." *PLOS Computational Biology* (in press).

This repository contains the acoustic analysis, psychophysical experiment, and
computational observer-model code used in the paper. The paper asks how
listeners judge the acoustic/species diversity of natural sound scenes
("choruses" of birdsong, with and without background geophony/biophony), and
tests whether a peripheral **auditory texture** representation (subband
envelope statistics and modulation statistics, in the style of McDermott &
Simoncelli's sound-texture model) can account for human discrimination
performance.

## Repository layout

The code is organized as a four-stage pipeline:

```
BirdSpeciesDistance/  ->  DistanceMeasures/  ->  Experiments/  ->  Models/
   (acoustic survey)     (behavior-relevant       (human           (observer
                          distance metrics)        psychophysics)   model + ablation)
```

| Directory | Role |
|---|---|
| `BirdSpeciesDistance/` | Exploratory acoustic analysis: extracts auditory texture statistics from field recordings of 10 European bird species and computes pairwise acoustic-distance matrices between species/recordings. |
| `DistanceMeasures/` | Computes the acoustic distance metrics used to explain human behavior (spectrum, envelope variance, envelope correlation, modulation power, loudness, pitch/YIN) and correlates them with the Experiment 4b discrimination data (`fig4e.m` → **Figure 4e**). |
| `Experiments/` | Human psychophysics: stimuli-generation/analysis scripts and raw behavioral data (`.mat`) for Experiments 1–6, plus the master data table `S3. Human_Subject_experiment_data.xlsx`. |
| `Models/` | The auditory texture observer model: a noisy ideal-observer that performs the same discrimination tasks as the human listeners, fit to human data and used for a statistic-class ablation study (Figures 5b/5d, Supplementary Figure 4). |

Each of these directories bundles its own private copy of the shared support
code it needs (see [Dependencies](#dependencies) below), so most top-level
scripts can be run directly from within their containing folder.

## Experiments

All tasks are 3-alternative forced-choice / 3-interval oddity tasks (chance =
1/3). Behavioral results are analyzed with repeated-measures ANOVA
(`fitrm`/`ranova`) and paired t-tests.

| Experiment | Script(s) | Paradigm |
|---|---|---|
| 1 | `Experiments/exp1_exp2/exp1a.m`, `exp1b.m` | Discrimination as a function of the number of chorus exemplars (1, 2, 4, 8, 16, 32), under two stimulus conditions (a/b). |
| 3 | `Experiments/exp3/exp3a.m` | Chorus-size discrimination: 3 chorus sizes (1, 8, 32 individuals) × 2 stimulus durations (0.05 s, 2 s). |
| 3 | `Experiments/exp3/exp3b.m` | Species- vs. exemplar-level discrimination, at the same 2 durations. |
| 4 | `Experiments/exp4/exp4a.m` | Mixture-discrimination task: Different-Species / Mixture / Same-Species conditions, across 5 chorus sizes (2, 4, 8, 16, 32 species). |
| 4 | `Experiments/exp4/exp4b.m` | Same 3 conditions at a fixed chorus size, broken down by all 45 pairwise species combinations. Feeds `DistanceMeasures/fig4e.m` and the `Models/Exp4b` observer model. |
| 5 | `Experiments/exp5/exp5.m` | Exemplar discrimination against a simultaneous chorus: solo, 8-chorus, 32-chorus, and "8+1"/"8+8" simultaneous-mixture conditions (with oracle-style same-exemplar-distractor controls). |
| 6 | `Experiments/exp6/exp6a.m` | Exemplar discrimination with **geophony** background (isolated vs. mixed, chorus sizes 1/8/32, plus background-only). |
| 6 | `Experiments/exp6/exp6b.m` | Same design as 6a with **biophony** background. |

## Models

`Models/` implements an **auditory texture observer model** (a noisy ideal
observer) that performs the same tasks as human listeners:

1. Extract the same 6 classes of auditory texture statistics used throughout
   the paper — envelope mean, envelope coefficient of variation, envelope
   skewness, envelope correlation, modulation power, modulation correlation —
   from the actual experimental stimuli.
2. Z-score each statistic across all stimuli.
3. On each simulated trial, add independent Gaussian internal noise to each
   statistic (noise level `NP`), then compute pairwise Euclidean distances
   between the intervals of the trial and pick the odd one out.
4. Calibrate `NP` so the model's mean performance matches mean human
   performance (a human-calibrated noisy-ideal-observer, not a free-fit
   regression).

**Ablation** studies remove one or more statistic classes from the distance
computation (by zeroing their weight) to determine which classes drive
discrimination performance — both leave-one-out and all 63 non-empty subsets
of the 6 classes are tested.

| Directory | Contents |
|---|---|
| `Models/Exp1/` | Earlier/simpler texture-distance model for Experiments 1a/1b (`texture_stats_distance_for_task1a_v2.m`, `..._task1b_v2.m`). |
| `Models/Exp4b/` | Main observer model for Experiment 4b: `texture_observer_model.m` (driver: single-statistic models, leave-one-out ablation, all-subsets ablation, `NP` calibration), `noise_and_distance.m`, `do_trials.m`, `measure_mixdisc_task_stats.m`. |
| `Models/Exp5/` | Observer model adapted to the Experiment 5 simultaneous-chorus oddity task, including an oracle-stimulus variant (`Observer_model_exp5.m`, `Observer_model_exp5_ablation.m`, `run_model.m`, `run_model_ablation.m`). |
| `Models/Model_base/`, `Models/Supporting_files/` | Shared auditory front-end (`_sts`, `_system`) and bundled toolboxes (`_ltfat`, `_minFunc_2012`) reused across model variants. |

## Figure reproduction map

| Script | Paper figure |
|---|---|
| `DistanceMeasures/fig4e.m` | Figure 4e |
| `Models/Exp4b/observer_model_figure5b.m` | Figure 5b |
| `Models/Exp4b/observer_model_figure5d.m` | Figure 5d |
| `Models/Exp4b/observer_model_suppinfo_figure4.m` | Supplementary Information Figure 4 (ablation study) |
| `BirdSpeciesDistance/measure_bird_stats.m` | Species/recording acoustic-distance matrices (see `BirdSpeciesDistance/plots/`) |

Other `Experiments/exp*.m` scripts reproduce the corresponding main-text
behavioral-results figures for each experiment; cross-check figure numbers
against the manuscript.

## Dependencies

- MATLAB (R2019b or later recommended, for `fitrm`/`ranova` and `colororder`)
- Statistics and Machine Learning Toolbox (`fitrm`, `ranova`, `anova1`,
  `ttest`, `zscore`, `pdist`/`pdist2`, `corrcoef`)
- Signal Processing Toolbox (`resample`, `hilbert`, `rms`)
- Base MATLAB audio I/O (`audioread`, `audiowrite`)

Two third-party toolboxes are bundled alongside the analysis code (added via
`addpath(genpath(...))` at the top of each script):

- **LTFAT** (Large Time-Frequency Analysis Toolbox) v1.4.3, Søndergaard et
  al. — auditory gammatone filterbank machinery. Licensed under GPLv3 (see
  `_ltfat/COPYING`).
- **minFunc** (Schmidt, 2012) — unconstrained optimization routines (L-BFGS,
  conjugate gradient).

The custom `_sts` folders contain the authors' own Sound Texture Synthesis
implementation (gammatone subbands → Hilbert envelopes → modulation
filterbank → summary statistics), and `_system` folders hold precomputed
auditory front-end parameters (gammatone/modulation filterbanks) cached by
`AudSys_Setup.m`.

## Data

- `Experiments/S3. Human_Subject_experiment_data.xlsx` is the master table of
  human-subject behavioral data referenced throughout the paper.
- Large intermediate `.mat` files (extracted statistics, per-trial model
  outputs, precomputed distance matrices) are excluded from version control
  via `.gitignore`. They are regenerated by re-running the corresponding
  pipeline script, which documents its own output location in its header
  comments (e.g. `_stats/`, `mixdiscstats/`, `exp5_model/`).
- The bundled `_ltfat` and `_minFunc_2012` toolboxes are likewise excluded
  from version control and must be obtained separately (LTFAT:
  [ltfat.org](https://ltfat.org); minFunc: Mark Schmidt's website) if not
  already present locally.

## License

Code authored by the paper's authors is provided for reproducing the
analyses reported in the paper. Note that the bundled LTFAT toolbox is
distributed under the GNU GPLv3; see `_ltfat/COPYING` for details before
redistributing.
