# Retrieve PAGES’ C-PEAT project data from PANGAEA repository
This R script (R Core Team, 2022) uses the [pangaear](https://github.com/ropensci/pangaear) package (Chamberlain et al., 2021) to retrieve metadata and data of the PAGES’ C-PEAT Global Peatland Carbon Database published in the PANGAEA repository (Felden et al., 2023). By October 2025 it consists of [758 datasets](https://www.pangaea.de/?q=project:label:PAGES_C-PEAT) (Loisel et al., in prep.).

This repository contains scripts to retrieve metadata and data from the **PAGES C-PEAT Global Peatland Carbon Database** published in the [PANGAEA](https://www.pangaea.de/) repository (Felden et al., 2023).  
Two implementations are provided:  

- **R scripts** (R Core Team, 2022) using the [`pangaear`](https://cran.r-project.org/package=pangaear) package (Chamberlain et al., 2021)  
- **Python Jupyter notebooks** using the [`pangaeapy`](https://pypi.org/project/pangaeapy/) package (Huber at al., 2025)  

As of October 2025, the database comprises **758 datasets** (Loisel et al., *in prep.*).


## Example scripts
We provide example R scripts [example R scripts](https://github.com/Danapit/C-PEAT/tree/main/R-Scripts) and an equivalent Python [Jupyter Notebook](https://github.com/Danapit/C-PEAT/tree/main/Python-Scripts) for accessing the PAGES’ C-PEAT data.

## Structure

```text
C-PEAT/
│
├── C-PEAT_download.Rproj        # R project file
├── .gitignore                   # to exclude temporary and cache files
│
├── R-Scripts/                   # example R scripts
│   ├── 01_download_all.R
│   ├── 02_geochemistry_data.R
│   └── 03_cal_age_data.R
│
├── Python-Scripts/              # example Python notebooks
│   ├── 01_download_all.ipynb
│   ├── 02_geochemistry_data.ipynb
│   └── 03_cal_age_data.ipynb
│
├── Data/                        # final exported data tables (local folder only)
│   ├── ...
│   └── ...
│
├── Downloads/                   # cache folder for pangaear package (local folder only)
│   ├── XXXXXX.tab
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
*  Huber, R; Röttenbacher, J; Selke, N; CodeShredder; Spreckelen, F; Balamurugan, A; Lowe, S; Stocker, M; Kempf, D; Iris-Hinrichs; Schindler, U & qays abou housien. (2025). pangaea-data-publisher/pangaeapy: v1.1.0 (v1.1.0). Zenodo. https://doi.org/10.5281/zenodo.15749619
*  Felden, J; Möller, L; Schindler, U; Huber, R; Schumacher, S; Koppe, R; Diepenbroek, M; Glöckner, FO (2023) _PANGAEA – Data Publisher for Earth & Environmental Science_. Scientific Data, 10(1), 347, <https://doi.org/10.1038/s41597-023-02269-x>.
*  R Core Team (2022). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL <https://www.R-project.org/>


[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7379847.svg)](https://doi.org/10.5281/zenodo.7379847)

