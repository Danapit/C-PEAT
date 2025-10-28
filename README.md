# An R-script to retrieve PAGES’ C-PEAT project data from PANGAEA repository
This R script (R Core Team, 2022) uses the [pangaear](https://github.com/ropensci/pangaear) package (Chamberlain et al., 2021) to retrieve metadata and data of the PAGES’ C-PEAT Global Peatland Carbon Database published in the PANGAEA repository. By October 2025 it consists of [758 datasets](https://www.pangaea.de/?q=project:label:PAGES_C-PEAT) (Loisel et al., in prep.).

## An example script
The provided R script [download_all.R](https://github.com/Danapit/C-PEAT/blob/main/download_all.R) is an example of accessing the PAGES’ C-PEAT data.

## Directories
/Downloads : a chache directory, here all datasets called by the script will be downloaded  
/Data : a directory for download of edited data tables

## Contributors
Dana Ransby
Kathrin Riemann-Campe
Nicole Sanderson

## References
*  Chamberlain S, Woo K, MacDonald A, Zimmerman N, Simpson G (2021). _pangaear: Client for the
  'Pangaea' Database_. R package version 1.1.0, <https://CRAN.R-project.org/package=pangaear>.
*  R Core Team (2022). R: A language and environment for statistical computing. R Foundation for Statistical
  Computing, Vienna, Austria. URL <https://www.R-project.org/>


[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7379847.svg)](https://doi.org/10.5281/zenodo.7379847)

