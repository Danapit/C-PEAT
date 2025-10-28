# Load libraries ------------------------------------------------------------
library(pangaear)
library(stringr)
library(tidyr)
library(dplyr)

# Prepare dataset -----------------------------
by_events <- read.delim("Data/dataset_IDs_by_events_2025-10-28.txt", stringsAsFactors = FALSE)
cal_age_datasets <- by_events[, c("label", "optional_label", "cal_age")]
cal_age_datasets <- cal_age_datasets[!is.na(cal_age_datasets$cal_age), ]


# Function to fetch and process one dataset --------------------------------
fetch_cal_age_data <- function(doi_id) {
  success <- FALSE
  while (!success) {
    tryCatch({
      cal_age <- pg_data(doi = paste0("10.1594/PANGAEA.", doi_id))[[1]]
      data <- cal_age[["data"]]
      # meta <- cal_age$metadata$events[[1]]
      
      # Add DOI and georeferencing info
      data$DOI <- paste0("10.1594/PANGAEA.", doi_id)
      data$event <- names(cal_age[["metadata"]][["events"]])[1]
      data$latitude <- cal_age[["metadata"]][["events"]][["LATITUDE"]]
      data$longitude <-cal_age[["metadata"]][["events"]][["LONGITUDE"]]
      
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
cal_age_data <- data.frame()

for (i in seq_len(nrow(cal_age_datasets))) {
  result <- fetch_cal_age_data(cal_age_datasets$cal_age[i])
  # cal_age_datasets$columns[i] <- result$ncol
  cal_age_data <- bind_rows(cal_age_data, result)
}

# length(unique(cal_age_data$event))


# Merge duplicate columns, resort columns ----------------------------------------------------------

# for which datasets the method (Oxcal / Bacon) is not indicated?
# subset <- cal_age_data[!is.na(cal_age_data$`Cal age [ka BP]`), ]
# unique(subset$DOI)
# [1] "10.1594/PANGAEA.929397" "10.1594/PANGAEA.929851" "10.1594/PANGAEA.929337" -> all Bacon - will be used later in merging

sort(names(cal_age_data))

# unite depth
cal_age_data <- unite(
  data = cal_age_data,
  col = "Depth sed [m]",
  `Depth sed [m] (Sample midpoint depth)`,
  `Depth sed [m] (Sample midpoint depth (rounded))`,
  `Depth sed [m]`,
  na.rm = TRUE,
  sep = ","
)
cal_age_data$`Depth sed [m]` <- as.numeric(cal_age_data$`Depth sed [m]`)

# unite Cal age
cal_age_data <- unite(
  data = cal_age_data,
  col = "Cal age [ka BP] Bacon",
  `Cal age [ka BP] (Median Age, Age, 14C calibrat...)...5`,
  `Cal age [ka BP]`,
  na.rm = TRUE,
  sep = ","
)
cal_age_data$`Cal age [ka BP] Bacon` <- as.numeric(cal_age_data$`Cal age [ka BP] Bacon`)

cal_age_data <- unite(
  data = cal_age_data,
  col = "Cal age max [ka BP] Bacon",
  `Cal age max [ka BP] (Age, 14C calibrated, Bacon 2....)`,
  `Cal age max [ka BP]`,
  na.rm = TRUE,
  sep = ","
)
cal_age_data$`Cal age max [ka BP] Bacon` <- as.numeric(cal_age_data$`Cal age max [ka BP] Bacon`)

cal_age_data <- unite(
  data = cal_age_data,
  col = "Cal age min [ka BP] Bacon",
  `Cal age min [ka BP] (Age, 14C calibrated, Bacon 2....)`,
  `Cal age min [ka BP]`,
  na.rm = TRUE,
  sep = ","
)
cal_age_data$`Cal age min [ka BP] Bacon` <- as.numeric(cal_age_data$`Cal age min [ka BP] Bacon`)

cal_age_data <- cal_age_data[,c(8:11,1,2:7)]

names(cal_age_data)[6:11] <- c("Cal age [ka BP] OxCal",
                                "Cal age max [ka BP] OxCal",
                                "Cal age min [ka BP] OxCal",
                                "Cal age [ka BP] Bacon",
                                "Cal age max [ka BP] Bacon",
                                "Cal age min [ka BP] Bacon")



names(cal_age_data)


# Split event label into two columns --------------------------------------
cal_age_data$event_label <- str_trim(str_extract(cal_age_data$event, "^[^ ]+"))
cal_age_data$optional_label <- str_trim(str_extract(cal_age_data$event, "(?<=\\().*(?=\\)$)"))

# Reorder to put new columns first
cal_age_data <- cal_age_data[, c("DOI", "event_label", "optional_label", "event", setdiff(names(cal_age_data), c("DOI","event_label","optional_label","event")))]

# Export full data ---------------------------------------------------------
write.table(cal_age_data,
            file = paste0("Data/cal_age_data_all_", Sys.Date(), ".txt"),
            row.names = FALSE, quote = FALSE, sep = "\t", na = "")
