# Human perception of avian biodiversity in naturalistic auditory scenes

MATLAB code accompanying:

> McWalter, R. & Lorenzi, C. "Human perception of avian biodiversity in naturalistic auditory scenes.".
>
> Laboratoire des Systèmes Perceptifs, Département d'Études Cognitives, École Normale Supérieure, PSL University, CNRS, Paris, France.

This repository contains the acoustic analysis, psychophysical experiment, and
observer-model code used in the paper.

## Repository layout

The code is organized as a four folders:

```
BirdSpeciesDistance/  ->  Experiments/  ->  DistanceMeasures/  ->  Models/
   (acoustic survey)      (human            (behavior-relevant   (observer
                           psychophysics)    distance metrics)    model + ablation)
```

| Directory | Role |
|---|---|
| `BirdSpeciesDistance/` | Exploratory acoustic analysis: extracts auditory texture statistics from field recordings of 10 European bird species and computes pairwise acoustic-distance matrices between species/recordings. |
| `Experiments/` | Human psychophysics: stimuli-generation/analysis scripts and raw behavioral data (`.mat`) for Experiments 1–6, plus the master data table `S3. Human_Subject_experiment_data.xlsx`. |
| `DistanceMeasures/` | Computes the acoustic distance metrics used to explain human behavior (spectrum, envelope variance, envelope correlation, modulation power, loudness, pitch/YIN) and correlates them with the Experiment 4b discrimination data (`fig4e.m` → **Figure 4e**). |
| `Models/` | The auditory texture observer model: a noisy ideal-observer that performs the same discrimination tasks as the human listeners, fit to human data and used for a statistic-class ablation study (Figures 5b/5d, Supplementary Figure 4). |

Each of these directories contains reference to the shared support
code it needs (see [Dependencies](#dependencies) below), so most top-level
scripts can be run directly from within their containing folder.

## Experiments

All tasks are three-interval, forced-choice oddity tasks (chance = 1/3):
listeners hear three intervals, two of which are the "standard" and one the
"target," and must identify the odd one out. Behavioral results are analyzed
with repeated-measures ANOVA (`fitrm`/`ranova`) and paired t-tests. Ten bird
species (recordings from the Cornell Lab of Ornithology's Macaulay Library,
sampled to reflect the Parc naturel régional de la Haute Vallée de Chevreuse,
France) form the stimulus database; "chorus size" is the number of
superimposed individual bird vocalizations.

| Experiment | Script(s) | Paradigm |
|---|---|---|
| 1 (species abundance) | `Experiments/exp1_exp2/exp1a.m` | Chorus-size discrimination: standard and target choruses (1–32 individuals) sampled from the **same** recording/individual. |
| 1 (species abundance) | `Experiments/exp1_exp2/exp1b.m` | Same design as 1a, but the two standard intervals are sampled from **different** recordings/individuals of the same species. |
| 2 (within/across species) | trials intermixed with `exp1a.m`/`exp1b.m` | Same-species discrimination (standard/target = same species, different individuals) and different-species discrimination (standard/target = different species), at matched chorus sizes 1–32. |
| 3 (abundance cues) | `Experiments/exp3/exp3a.m` | Exemplar discrimination for chorus sizes 1, 8, 32, at two interval durations (50 ms vs. 2 s), testing reliance on temporal detail vs. summary statistics. |
| 3 (abundance cues) | `Experiments/exp3/exp3b.m` | Exemplar discrimination vs. species discrimination at chorus size 32, same two durations. |
| 4 (species richness) | `Experiments/exp4/exp4a.m` | Species-mixture discrimination: Different-Species / Mixture-of-2-Species / Same-Species conditions, across chorus sizes 2, 4, 8, 16, 32. |
| 4 (species richness) | `Experiments/exp4/exp4b.m` | Same 3 conditions at a fixed chorus size of 16, covering all 45 pairwise combinations of the 10 species. Feeds `DistanceMeasures/fig4e.m` and the `Models/Exp4b` observer model. |
| 5 (grouping/segregation) | `Experiments/exp5/exp5.m` | Exemplar discrimination with a concurrent chorus of a different species: baselines (1, 8, 32 same-species) plus "8+1", "8+1\*", "8+8", "8+8\*" mixture conditions (`*` = species pair with most *similar* texture statistics; unstarred = most *different*). |
| 6a (geophony) | `Experiments/exp6/exp6a.m` | Exemplar discrimination (chorus sizes 1/8/32) with vs. without a concurrent **geophony** background (rain, river, wind), plus a background-only condition. |
| 6b (biophony) | `Experiments/exp6/exp6b.m` | Same design as 6a with a concurrent **biophony** (non-bird biological) background (insects, frogs). |

## Models

`Models/` implements **observer models** — noisy ideal observers that perform
the same discrimination tasks as human listeners, given the trial's actual
stimuli. For Experiment 4b, seven variants are compared: one built on the
6-class **auditory texture** representation, and six built on individual
acoustic cues (frequency spectrum (envelope mean), envelope coefficient of variation,
envelope correlation, modulation power, loudness - Chalupper 2002, pitch - YIN). The auditory
texture model's 6 statistic classes are envelope mean, envelope coefficient
of variation, envelope skewness, envelope correlation, modulation power, and
modulation correlation. The shared model structure:

1. Extract the relevant statistic(s) from each of the three trial intervals,
   over the stimulus's actual extent.
2. Z-score each statistic class across all stimuli.
3. Add independent Gaussian internal noise to each statistic (magnitude
   `NP`, one value per class), then compute the pairwise Euclidean distance
   between the three intervals and pick the interval most different from the
   other two.
4. Calibrate `NP` so the model's performance matches mean human performance
   for the auditory texture model this calibration is class-specific.

**Ablation** studies remove one or more statistic classes from the distance
computation (by zeroing their weight) to determine which classes drive
discrimination performance — both leave-one-out and all 63 non-empty subsets
of the 6 classes are tested.

| Directory | Contents |
|---|---|
| `Models/Exp1/` | Texture-statistics distance model for Experiments 1a/1b and 2, simulating the 3-AFC abundance/species task directly from statistic distances (no internal-noise observer stage): `texture_stats_distance_for_task1a_v2.m`, `..._task1b_v2.m`. |
| `Models/Exp4b/` | Main observer model for Experiment 4b: `texture_observer_model.m` (driver: single-statistic models, leave-one-out ablation, all-subsets ablation, `NP` calibration), `noise_and_distance.m`, `do_trials.m`, `measure_mixdisc_task_stats.m`. |
| `Models/Exp5/` | Observer model (and an "oracle" variant that operates on the individual, pre-mixture species streams) for the Experiment 5 simultaneous-chorus oddity task, plus a leave-one-out/all-subsets ablation: `Observer_model_exp5.m`, `Observer_model_exp5_ablation.m`, `run_model.m`, `run_model_ablation.m`, `AudTextModel_exp5_measure_stats.m`. |
| `Models/Exp6/` | Observer model for the Experiment 6 geophony/biophony background task (paper Figure 7B): `observer_model_v3_geo.m`/`observer_model_v3_bio.m` extract and z-score texture statistics for the geophony/biophony stimulus sets, `run_model_v2.m` runs the noisy-observer oddity-task decision, and `observer_model_exp6_v3.m` is the driver that runs the model and plots model-vs-human performance. |
| `Models/Model_base/`, `Models/Supporting_files/` | Shared auditory front-end (`_sts`, `_system`) and bundled toolboxes (`_ltfat`, `_minFunc_2012`) reused across model variants. |

## Figure reproduction map

| Script | Paper figure |
|---|---|
| `BirdSpeciesDistance/measure_bird_stats.m` | Figure 1D–E (auditory texture model schematic; within-/between-species acoustic-distance matrix) |
| `Experiments/exp1_exp2/exp1a.m`, `exp1b.m` | Figure 2 (Experiment 1 abundance discrimination, panels A–B; Experiment 2 species discrimination, panels C–D) |
| `Experiments/exp3/exp3a.m`, `exp3b.m` | Figure 3 (Experiment 3a/b: exemplar/species discrimination vs. duration and chorus size) |
| `Experiments/exp4/exp4a.m`, `exp4b.m` | Figure 4A–D (Experiment 4a/b: species-mixture discrimination) |
| `DistanceMeasures/fig4e.m` | Figure 4E (correlation of 6 acoustic-cue distances with mixture-discrimination performance) |
| `Models/Exp4b/observer_model_figure5b.m` | Figure 5B (per-condition model-vs-human comparison, 7 observer models) |
| `Models/Exp4b/observer_model_figure5d.m` | Figure 5D (model-vs-human correlation scatter, 7 observer models) |
| `Models/Exp4b/observer_model_suppinfo_figure4.m` | Supporting Information S1 Figure 4a (Experiment 4b ablation study) |
| `Experiments/exp5/exp5.m` | Figure 6A–D (Experiment 5: species-mixture exemplar discrimination) |
| `Experiments/exp6/exp6a.m`, `exp6b.m` | Figure 6E–F (Experiment 6a/b: geophony/biophony background) |
| `Models/Exp5/Observer_model_exp5.m` | Figure 7A (Experiment 5 observer model and oracle model) |
| `Models/Exp5/Observer_model_exp5_ablation.m` | Supporting Information S1 Figure 4b (Experiment 5 ablation study) |
| `Models/Exp1/texture_stats_distance_for_task1a_v2.m`, `..._task1b_v2.m` | Figure 7C–D (Experiment 1/2 abundance and species discrimination as texture-statistics distance) |
| `Models/Exp6/observer_model_exp6_v3.m` | Figure 7B (Experiment 6 geophony/biophony observer model) |

## Dependencies

- MATLAB (R2019b or later recommended, for `fitrm`/`ranova` and `colororder`)
- Statistics and Machine Learning Toolbox (`fitrm`, `ranova`, `anova1`,
  `ttest`, `zscore`, `pdist`/`pdist2`, `corrcoef`)
- Signal Processing Toolbox (`resample`, `hilbert`, `rms`)
- Base MATLAB audio I/O (`audioread`, `audiowrite`)

Two third-party toolboxes are bundled alongside the analysis code (added via
`addpath(genpath(...))` at the top of each script):

- **[LTFAT](https://ltfat.org)** (Large Time-Frequency Analysis Toolbox)
  v1.4.3, Søndergaard et al. — auditory gammatone filterbank machinery.
  Licensed under GPLv3 (see `_ltfat/COPYING`).
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

Code authored by the paper's authors is released under the [MIT
License](https://opensource.org/licenses/MIT) — free to use, modify, and
redistribute. Note that the bundled third-party [LTFAT](https://ltfat.org)
toolbox is distributed separately under the GNU GPLv3 (see
`_ltfat/COPYING`) and retains its own license terms.
