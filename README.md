# Retrieve PAGES’ C-PEAT project data from PANGAEA repository
This R script (R Core Team, 2022) uses the [pangaear](https://github.com/ropensci/pangaear) package (Chamberlain et al., 2021) to retrieve metadata and data of the PAGES’ C-PEAT Global Peatland Carbon Database published in the PANGAEA repository (Felden et al., 2023). By October 2025 it consists of [758 datasets](https://www.pangaea.de/?q=project:label:PAGES_C-PEAT) (Loisel et al., in prep.).

## Example scripts
We provide example R scripts [example R scripts](https://github.com/Danapit/C-PEAT/tree/main/R-Scripts) and an equivalent Python [Jupyter Notebook](https://github.com/Danapit/C-PEAT/tree/main/Python-Scripts) for accessing the PAGES’ C-PEAT data.

## Structure

```text
C-PEAT/
│
├── C-PEAT_download.Rproj        # R project file
├── .gitignore                   # to exclude temporary and cache files
│
├── R-Scripts/                   # all R scripts and modules
│   ├── 01_download_all.R
│   ├── 02_geochemistry_data.R
│   └── 03_cal_age_data.R
│
├── Python-Scripts/              # all Python notebooks and scripts
│   ├── notebook.ipynb
│   ├── ...
│
├── Data/                        # final exported data tables (local folder only)
│   ├── ...
│   └── ...
│
├── Downloads/                   # cache folder for pangaear package (local folder only)
│   ├── XXX.tab
│   └── ...
│
└── README.md                    # project overview
```

## Contributors
Dana Ransby  
Kathrin Riemann-Campe  
Nicole Sanderson

## References
*  Chamberlain S, Woo K, MacDonald A, Zimmerman N, Simpson G (2021). _pangaear: Client for the 'Pangaea' Database_. R package version 1.1.0, <https://CRAN.R-project.org/package=pangaear>.
*  Felden, J; Möller, L; Schindler, U; Huber, R; Schumacher, S; Koppe, R; Diepenbroek, M; Glöckner, FO (2023) _PANGAEA – Data Publisher for Earth & Environmental Science_. Scientific Data, 10(1), 347, <https://doi.org/10.1038/s41597-023-02269-x>.
*  R Core Team (2022). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL <https://www.R-project.org/>


[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7379847.svg)](https://doi.org/10.5281/zenodo.7379847)

