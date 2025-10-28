# -------------------------------------------------------------------------
# PAGES_C-PEAT Data Retrieval and Event Mapping
# -------------------------------------------------------------------------

library(pangaear) # Access to PANGAEA data; see package details at https://github.com/ropensci/pangaear
library(dplyr)    # Data manipulation tools; see details at https://dplyr.tidyverse.org/
library(stringr)  # String manipulation utilities


# Search PAGES_C-PEAT records ---------------------------------------------

PAGES <- pg_search("project:label:PAGES_C-PEAT", count = 500)
PAGES <- rbind(
  PAGES,
  pg_search("project:label:PAGES_C-PEAT", count = 500, offset = 500)
  )
PAGES$full_citation <- paste0(PAGES$citation, ". PANGAEA, https://doi.org/", PAGES$doi)

# write citations as txt file
write.table(sort(PAGES$full_citation), file="Data/citations_PAGES.txt", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t", na = "")

# Set pangaear cache --------------------------------------------------

# why is this relevant? pg_data automatically writes the .tab file to the cache folder,
# so it is nice to have it "at hand"
# View current cache path
pg_cache$cache_path_get()

# create a folder for download
folder_path <- (paste0(getwd(),"/Downloads"))

if (!dir.exists(folder_path)) {
  dir.create(folder_path)
  message("Folder created: ", folder_path)
} else {
  message("Folder already exists: ", folder_path)
}

# Set cache location for data downloads
# data files will be downloaded into that folder when executing pg_data()
pg_cache$cache_path_set(full_path = folder_path)

# Helper function to fetch dataset metadata -------------------------------
fetch_metadata <- function(data_f, pattern, sort_col, prefix) {
  # Filter and arrange
  subset_df <- data_f[grepl(pattern, data_f$citation), ]
  subset_df <- arrange(subset_df, citation)
  
  subset_df$event <- NA_character_
  subset_df$nrow <- NA_integer_
  subset_df$ncol <- NA_integer_
  
  # Iterate through datasets and fetch metadata
  for (i in seq_len(nrow(subset_df))) {
    success <- FALSE
    
    while (!success) {
      tryCatch({
        dataset <- pg_data(doi = subset_df$doi[i])
        
        subset_df$event[i] <- names(dataset[[1]][["metadata"]][["events"]][1])
        subset_df$nrow[i] <- nrow(dataset[[1]][["data"]])
        subset_df$ncol[i] <- ncol(dataset[[1]][["data"]])
        
        success <- TRUE
      },
      error = function(e) {
        if (grepl("HTTP 429", e$message)) {
          message("HTTP 429 error encountered. Waiting for 30 seconds...")
          Sys.sleep(30)
        } else {
          stop(e)
        }
      })
    }
  }
  
  return(subset_df)
}


# Retrieve datasets by type -----------------------------------------------
# downloaded datasets stored in cache location
PAGES_age <- fetch_metadata(PAGES, "Age determination", doi, "age")
PAGES_geochem <- fetch_metadata(PAGES, "Geochemistry", citation, "geochem")
PAGES_cal <- fetch_metadata(PAGES, "Calibrated ages", citation, "cal")


# Combine and summarize events --------------------------------------------

all_events <- rbind(PAGES_age, PAGES_cal, PAGES_geochem)
unique_events <- unique(all_events$event)

by_events <- data.frame(
  event = unique_events,
  age = NA,
  cal_age = NA,
  geochem = NA,
  stringsAsFactors = FALSE
)

# Match event IDs to dataset type
for (i in seq_len(nrow(all_events))) {
  event_row <- which(by_events$event == all_events$event[i])
  dataset_id <- gsub("10.1594/PANGAEA.", "", all_events$doi[i])
  
  if (grepl("Age determination", all_events$citation[i])) {
    by_events$age[event_row] <- dataset_id
  } else if (grepl("Geochemistry", all_events$citation[i])) {
    by_events$geochem[event_row] <- dataset_id
  } else if (grepl("Calibrated ages", all_events$citation[i])) {
    by_events$cal_age[event_row] <- dataset_id
  } else {
    message("Unmatched dataset ID: ", dataset_id)
  }
}

# Extract labels and optional labels --------------------------------------
# Optional event labels (when defined) are in brackets after event labels

by_events$label <- str_trim(str_extract(by_events$event, "^[^ ]+"))
by_events$optional_label <- str_trim(str_extract(by_events$event, "(?<=\\().*(?=\\)$)"))

by_events <- by_events[, c("label", "optional_label", "age", "cal_age", "geochem")]

# Produces by_events dataframe and saves it to file
export_filename <- paste0("Data/dataset_IDs_by_events_", Sys.Date(), ".txt")
write.table(by_events, export_filename, sep = "\t", quote = FALSE, row.names = FALSE, na = "")
