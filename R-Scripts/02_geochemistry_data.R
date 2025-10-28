# Load libraries ------------------------------------------------------------
library(pangaear)
library(stringr)
library(tidyr)
library(dplyr)

# Prepare dataset -----------------------------
by_events <- read.delim("Data/dataset_IDs_by_events_2025-10-28.txt", stringsAsFactors = FALSE)
geochem_datasets <- by_events[, c("label", "optional_label", "geochem")]
geochem_datasets <- geochem_datasets[!is.na(geochem_datasets$geochem), ]


# Function to fetch and process one dataset --------------------------------
fetch_geochem_data <- function(doi_id) {
  success <- FALSE
  while (!success) {
    tryCatch({
      geochem <- pg_data(doi = paste0("10.1594/PANGAEA.", doi_id))[[1]]
      data <- geochem[["data"]]
      # meta <- geochem$metadata$events[[1]]
      
      # Add DOI and georeferencing info
      data$DOI <- paste0("10.1594/PANGAEA.", doi_id)
      data$event <- names(geochem[["metadata"]][["events"]])[1]
      data$latitude <- geochem[["metadata"]][["events"]][["LATITUDE"]]
      data$longitude <-geochem[["metadata"]][["events"]][["LONGITUDE"]]
      
      # Store result in a variable
      result <- data
      
      success <- TRUE
    }, error = function(e) {
      if (grepl("HTTP 429", e$message)) {
        message("HTTP 429 error: waiting 30 seconds...")
        Sys.sleep(30)
      } else stop(e)
    })
  }
  return(result)
}

# Loop through all datasets ------------------------------------------------

# initiate final data frame
geochem_data <- data.frame()

for (i in seq_len(nrow(geochem_datasets))) {
  result <- fetch_geochem_data(geochem_datasets$geochem[i])
  # geochem_datasets$columns[i] <- result$ncol
  geochem_data <- bind_rows(geochem_data, result)
}

# length(unique(geochem_data$event))

# Merge duplicate columns, resort columns ----------------------------------------------------------
names(geochem_data)

# unite depth
geochem_data <- unite(
  data = geochem_data,
  col = "Depth sed [m]",
  `Depth sed [m] (Sample midpoint depth)`,
  `Depth sed [m]`,
  na.rm = TRUE,
  sep = ","
)
geochem_data$`Depth sed [m]` <- as.numeric(geochem_data$`Depth sed [m]`)

# unite Cal age
geochem_data <- unite(
  data = geochem_data,
  col = "Age [ka BP]",
  `Age [ka BP] (Loisel et al. 2014)`,
  `Age [ka BP]`,
  na.rm = TRUE,
  sep = ","
)
geochem_data$`Age [ka BP]` <- as.numeric(geochem_data$`Age [ka BP]`)

# unite OM
geochem_data <- unite(
  data = geochem_data,
  col = "OM [%]",
  `OM [%]`,
  `LOI [%]`,
  `LOI [%] (weight-%)`,
  na.rm = TRUE,
  sep = ","
)
geochem_data$`OM [%]` <- as.numeric(geochem_data$`OM [%]`)

# unite peat
geochem_data <- unite(
  data = geochem_data,
  col = "Peat type",
  `Peat type`,
  `Peat type (Loisel et al. 2014)`,
  na.rm = TRUE,
  sep = ","
)
geochem_data$`Peat type`[geochem_data$`Peat type` == ""] <- NA

names(geochem_data)
new_order <- c("DOI", "event", "latitude", "longitude", "Depth sed [m]", "Depth sed [m] (LOI sample depth)", "Age [ka BP]",
               "Samp vol [cm**3]", "Samp thick [cm]", "Cum mass [g/cm**2]", "SR [cm/a]", "PCAR [g/m**2/a]", "DBD [g/cm**3]", "Water wm [%]",
               "OM [%]", "OM dens [g/cm**3]", "C [%]", "TC [%]", "TOC [%]", "Corg dens [g/cm**3]", "TIC [%]",
               "TN [%]",  "Peat type", "Comment" 
)

geochem_data <- geochem_data[, new_order]


# Split event label into two columns --------------------------------------
geochem_data$event_label <- str_trim(str_extract(geochem_data$event, "^[^ ]+"))
geochem_data$optional_label <- str_trim(str_extract(geochem_data$event, "(?<=\\().*(?=\\)$)"))

# Reorder to put new columns first
geochem_data <- geochem_data[, c("DOI", "event_label", "optional_label", "event", setdiff(names(geochem_data), c("DOI","event_label","optional_label","event")))]

# Export full data ---------------------------------------------------------
write.table(geochem_data,
            file = paste0("Data/geochem_data_all_", Sys.Date(), ".txt"),
            row.names = FALSE, quote = FALSE, sep = "\t", na = "")
