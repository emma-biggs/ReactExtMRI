# Reactivation-Extinction MRI
**Project ID: ReactExtMRI**

GitHub Author: Emma Biggs

## Introduction & data collection procedures

[To be updated]

- Further study details at OSF [link]
- Raw (individual-level) data available upon request from the author

## Data preparation

The data preparation pipeline includes the following steps:

- **ID Alignment:** Mapping numeric codes to participant IDs.
- **Outlier Detection:** Automated removal of values exceeding 4 SD from the group mean, calculated per phase and CS type.
- **Differential Scoring:** Calculation of CS- adjusted responses for SCR and gPPI.
- **Data Tidying:** Transformations to facilitate statistical modeling.

## Analysis

The analysis is divided into two primary research questions:

**RQ1:** *Are there differences between the reactivated versus non-reactivated CS+?*

- Method: Using the bain package, we evaluate informative hypotheses
- Inference: Posterior Model Probabilities (PMPs) and Bayes Factors (BFs) are used to determine evidence for the experimental hypotheses vs. the null.
- Visualization: A heatmap is produced showing the winning model over the variables tested.

**RQ2:** *Do changes in effective connectivity relate to changes in SCR? Does this relationship differ between CS+R and CS+NR?*

 - Method: Linear interaction models (SCR ~ CS Type * gPPI).
 - Inference: P-values and Benjamini-Hochberg FDR adjusted P-values are calculated.
 - Visualization: Results are summarized using Forest Plots categorized by anatomical circuits.

## The github repo:

### Layout

`
├── data/
│   ├── raw/          # Original (study-level) SCR, Ratings, and gPPI CSVs
│   └── processed/    # Cleaned master_data.csv
├── notebooks/
│   └── Analysis.Rmd  # Analysis pipeline
├── output/
│   ├── figures/      # Forest plots, Heatmaps
│   └── tables/       # Statistic summary tables
├── src/			  # Matlab scripts for generating study-level .csv datafiles from individual-level files
└── README.md
`

### Requirements & Quick Start

This project was developed using **R version 4.3.0.**

To replicate the analysis, you will need the following R packages installed:

- Data Structuring: tidyverse, stringr, forcats, broom
- Bayesian Statistics: bain (Note: ensures compatibility with JASP outputs)
- Marginal Effects: emmeans
- Reporting & Visualization: DT, kableExtra, tidytext, RColorBrewer

You can install all **dependencies** at once by running:

`install.packages(c("tidyverse", "bain", "emmeans", "broom", "DT", "kableExtra", "tidytext", "RColorBrewer"))`

To **Quick Start** this project:

1) Clone the repository:

	`git clone https://github.com/emma-biggs/ReactExtMRI.git`

2) Open the .Rproj file in RStudio to ensure the working directory is set correctly to the project root.

3) Check the raw data files (Ratings, SCR, and gPPI) are located in the data/raw folder

4) Run the notebooks/Analysis.Rmd file, use Knit to create the .html output file.



