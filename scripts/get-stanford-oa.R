# Delwen Franzen (24/03/2022)

# Get open access data from the Unpaywall API using UnpaywallR (Nico Riedel)

library(dplyr)
library(readr)
library(here)
library(readxl)
library(tidyr)
#renv::install("NicoRiedel/unpaywallR")
library(unpaywallR)

# Prepare DOIs --------------------------------------------------
# First clean the dataset in case of issues
# Read in dataset from Excel format and only keep unique DOIs

data <- read_excel(here("data", "2022-04-07-stanford-data-clean.xlsx"))

dois <- data %>%
  drop_na(doi) %>%
  distinct(doi) %>%
  pull(doi)

print(paste("Number of DOIs:", length(dois)))


# Set unpaywall email -----------------------------------------------------
# Requires a config.ini file in the project directory with email

email_api  <-
  tryCatch({
    
    # Try to set  email from INI configuration file
    library(ConfigParser)
    cfg <- ConfigParser$new()
    cfg$read("config.ini")
    email_api <- cfg$get("email", NA, "login")
  },
  
  # Otherwise, system credential stored as "rm-email", if available
  # Else ask user and store
  error = function(err){
    ifelse(
      nrow(keyring::key_list("rm-email")) == 1,
      keyring::key_get("rm-email"),
      keyring::key_set("rm-email")
    )
  }
  )

# Download Unpaywall data

oa_raw <-
  unpaywallR::dois_OA_colors_fetch(
    dois,
    email_api,
    clusters = 2
  )

# Get color based on hierarchy: journal > repository (except bronze) ------

hierarchy <-
  c("gold",
    "hybrid",
    "green",
    "bronze",
    "closed")

oa_results <-
  unpaywallR::dois_OA_pick_color(
    oa_raw,
    hierarchy
  ) %>%
  rename(color = OA_color, publication_date_unpaywall = date)

# Get color based on hierarchy: all OA routes > green OA ------

hierarchy_green_only <-
  c("gold",
    "hybrid",
    "bronze",
    "green",
    "closed")

oa_results_green_only <-
  unpaywallR::dois_OA_pick_color(
    oa_raw,
    hierarchy_green_only
  ) %>%
  select(doi, color_green_only = OA_color)

# Save Unpaywall data -----------------------------------------------------

oa_unpaywall <-
  full_join(oa_results, oa_results_green_only, by = "doi") %>%
  mutate(across(everything(), ~na_if(., "")))

write_csv(oa_unpaywall, here("data", paste0(Sys.Date(), "-stanford-data-oa.csv")))
