# install.packages('pangaear')
# install.packages('dplyr')
library(pangaear) # see package details at https://github.com/ropensci/pangaear
library(dplyr) # set of tools for data manipulation, see details at https://dplyr.tidyverse.org/

#=============== 1. SEARCH (by PROJECT) and download citations =================
# Documentation of PANGAEA search: https://wiki.pangaea.de/wiki/PANGAEA_search
# Website: https://www.pangaea.de/?q=project:label:PAGES_C-PEAT
# search with pg_search: maximum = 500 records (set with count, continue with offset to add additional record beyond 500) 
# 2022-11: There are 875 datasets PUBLISHED
PAGES <- pg_search("project:label:PAGES_C-PEAT", count = 500)

# Download all dataset citations:
# rbind function: joins 2 or more dataframes
PAGES <- rbind(PAGES, pg_search("project:label:PAGES_C-PEAT", count = 500, offset = 500))
#create a column with full citation
PAGES$fullcitation <- paste0(PAGES$citation, ". PANGAEA, https://doi.org/", PAGES$doi)

# write citations as txt file
write.table(sort(PAGES$fullcitation), file="citations_pages.txt", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t", na = "")

#=============== 2. SETTING PANGAEAR CACHE ===================
# why is this relevant? pg_data automatically writes the .tab file to the cache folder, so it is nice to have it "at hand", See 3. GET DATA
# check the location of the cache path of pangaear
pg_cache$cache_path_get()

# create a folder for download - a warning comes if the directory already exists
getwd()
dir.create(path=paste0(getwd(),"/Downloads"))
folderpath <- (paste0(getwd(),"/Downloads"))

# set the location of the cache path of pangaear 
pg_cache$cache_path_set(full_path = folderpath)
# now data files are downloaded into that folder when executing pg_data()

#=============== 3. GET DATA =================
# download single dataset
# pg_data returns list, data table -> data frame
# pg_data automatically writes the .tab file to the cache folder (in this case /Downloads, see 2. SETTING PANGAEAR CACHE)
Joey_core12 <- pg_data(doi="10.1594/PANGAEA.890405")
Joey_core12 <- Joey_core12[[1]][["data"]]

# create a directory for download of edited data tables - a warning comes if the directory already exists
getwd()
dir.create(path=paste0(getwd(),"/Data"))
datapath <- paste0(getwd(),"/Data/")

# write table as txt file
# paste function: concatenate vectors by converting them into character (list of vectors, separator), paste0() - without separator
write.table(Joey_core12, file=paste0(datapath,"Joey_core12.txt"), row.names = FALSE, quote = FALSE, sep = "\t", na = "")

#=============== 4. FILTER SEARCH RESULTS =================
# in this scenario, we are only interested in "geochemistry" PAGES_C-PEAT datasets from a limited area in Nothern Sweden
# 
# restrict the search by geographical coordinates with an attribute bbox=c(minlon, minlat, maxlon, maxlat)
# pay attention to the coordinate sequence and correct signs ("-"/negative for South and West)
PAGES_Sweden <- pg_search("project:label:PAGES_C-PEAT", count = 500, bbox=c(17.7, 67.7, 21, 69))

# filter only datasets with "Geochemistry" in title (column citation)
# grepl function: looks for a given pattern in data
# filter function from dplyr package: subsetting data (arguments: data frame and logical condition specifying the rows that should be returned)
PAGES_Sweden <- filter(PAGES_Sweden, grepl("Geochemistry", citation))

#=============== 5. GET MULTIPLE DATA =================
# combine data from the previous search into a single data frame

# initiate a data frame
PAGES_Sweden_data <- data.frame()

# loop over all filtered datastes listed in PAGES_Sweden

# function bind_rows from dplyr package: unlike for rbind, the number of columns of the dataframes doesn't need to be the same
for (i in 1:nrow(PAGES_Sweden)) {
  # using pg_data will automatically download the .tab format of the datasets (metadata + data) in the cache folder
  geochem <- pg_data(doi=PAGES_Sweden[i,2])
  # extract georeferencing
  latitude <- geochem[["doi"]][["metadata"]][["events"]][["LATITUDE"]]
  longitude <- geochem[["doi"]][["metadata"]][["events"]][["LONGITUDE"]]
  geochem <- geochem[[1]]$data
  # add columns identifying unique source of data for further attribution
  geochem$DOI <- as.character(PAGES_Sweden[i,2])
  geochem$citation <- as.character(PAGES_Sweden[i,5])
  # add columns with georeferencing
  geochem$latitude <- latitude
  geochem$longitude <- longitude
  # append table
  PAGES_Sweden_data <- bind_rows(PAGES_Sweden_data, geochem)
}

# write table as txt file
write.table(PAGES_Sweden_data, file=paste0(datapath,"Sweden_geochem.txt"), row.names = FALSE, quote = FALSE, sep = "\t", na = "")
