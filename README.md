# ARC Lesion Segmentation Dataset

> Automatic segmentation of brain lesions based on the Aphasia Recovery Cohort dataset

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GNU Octave](https://img.shields.io/badge/GNU%20Octave-11.1.0+-blue.svg)](https://www.gnu.org/software/octave/)
[![Dataset: ARC](https://img.shields.io/badge/Dataset-ARC%20OpenNeuro%20ds004884-green.svg)](https://openneuro.org/datasets/ds004884)

This dataset contains the results of automatic brain lesion segmentation, derived from an open repository of chronic post-stroke patients with aphasia — the **Aphasia Recovery Cohort (ARC)**.

The goal of the project is to build a **reproducible tool** for automatically delineating brain lesion areas on T2-weighted MRI images. The tool is aimed at:
- researchers in neurorehabilitation
- developers of medical imaging tools
- ML specialists working on segmentation tasks

### Key metrics

- Participants processed: 207
- Mean Dice Score: 0.1704 ± 0.1183
- Data source: OpenNeuro ds004884
- Algorithm: Threshold-based segmentation (95th percentile)
- Runtime environment: GNU Octave 11.1.0

## Repository structure

```
project-root/
│
├── data/
│   ├── raw/          # Source T2w images and masks (NIfTI)
│   ├── masks/        # Automatic segmentation masks (.mat, 160×256×256)
│   └── processed/    # Intermediate processing results
│
├── results/
│   ├── batch_results.csv      # Quality metrics for all participants
│   ├── dice_distribution.png  # Dice Score distribution histogram
│   └── visuals/               # PNG visualizations (green — automatic, red — manual)
│
├── src/
│   ├── load_data.m             # Data loading
│   ├── read_nifti_octave.m     # NIfTI file parsing
│   ├── segment_lesion.m        # Segmentation algorithm
│   ├── batch_evaluate.m        # Batch processing of participants
│   └── simple_stats.m          # Statistics computation and visualization
│
├── docs/                       # Documentation and methodology materials
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

## Methodology

The algorithm is implemented in **GNU Octave** (an open-source alternative to MATLAB) and includes the following steps:

1. **Background removal** — excluding zero intensity values
2. **Threshold calculation** — 95th percentile of the intensity distribution within the brain region
3. **Binarization** — voxels above the threshold are marked as lesion area
4. **Post-processing:**
   - removal of objects < 100 voxels (noise suppression)
   - filling holes inside masks (spatial integrity)

Quality control is performed using the **Dice Similarity Coefficient** (DSC), comparing results against expert manual annotations from the original ARC dataset.

### Requirements

**Software:**
- [GNU Octave](https://www.gnu.org/software/octave/) ≥ 11.1.0

**Octave packages:**
```octave
pkg install -forge image      % >= 2.18.2
pkg install -forge datatypes  % >= 1.1.8
pkg install -forge statistics % >= 1.8.1
```

> Note: `datatypes` is required by `statistics` ≥ 1.8.0 on Octave ≥ 11.1, so it must be installed even though it is not called directly from `src/*.m`.

**System requirements:**
- RAM: ≥ 4 GB
- Disk: ≥ 10 GB free space
- CPU: ≥ 2 GHz

### Running the pipeline

```octave
% 1. Copy ARC data into data/raw/
%    (files must follow the BIDS standard: sub-XXXX)

% 2. Open GNU Octave and navigate to the project root
cd /path/to/project

% 3. Add src/ to the search path
addpath('src')

% 4. Run batch processing
batch_evaluate('data/raw')

% 5. (Optional) Visualize statistics
simple_stats()
```

**Processing results** are saved automatically:
- masks: `data/masks/`
- visualizations: `results/visuals/`
- metrics: `results/batch_results.csv`

## Algorithm limitations

> **Important:** automatic segmentation results are **not intended for clinical use** without expert verification by a neuroradiologist.

**Systematic errors:**
- lesion volume overestimation by an average of **19.6%** (capturing periventricular areas and CSF)
- reduced quality for chronic low-contrast lesions
- sensitivity threshold: lesions < 5 mm are not segmented

## Citation

If you use this dataset in publications, theses, or other research work, please cite this project as well as the original Aphasia Recovery Cohort dataset:

```bibtex
@dataset{arc_lesion_segmentation,
  title     = {ARC Lesion Segmentation Dataset},
  note      = {Automatic segmentation of brain lesions based on the Aphasia Recovery Cohort},
  url       = {https://openneuro.org/datasets/ds004884}
}
```

## Ethics and confidentiality

Source ARC data has been anonymized in accordance with **Safe Harbor guidelines**, including the application of the `spm_deface` algorithm to remove identifying information.

**Prohibited:**
- attempts to re-identify participants
- commercial use of the data without prior agreement with the authors

## License

This repository's **source code** (`src/`, `scripts/`, `tests/`) is distributed under the [MIT License](LICENSE).
**Processed results and data** (`data/`, `results/`) are provided for scientific, educational, and research purposes only, under the additional terms described in [LICENSE](LICENSE#additional-terms-for-dataset-and-processed-results).
