# Query Unpaywall via its API to get the OA status of IntoValue publications
# Includes adaptations by Maia Salholz-Hillel (see https://github.com/maia-sh/intovalue-data)

library(dplyr)
library(readr)
library(here)
library(rio)
# renv::install("NicoRiedel/unpaywallR")
library(unpaywallR)

# Prepare IntoValue dois --------------------------------------------------

# Read in processed IntoValue dataset
intovalue <- rio::import("https://github.com/maia-sh/intovalue-data/blob/main/data/processed/trials.rds?raw=true")

write_csv(intovalue, here("data", "intovalue.csv"))

# Apply IntoValue exclusion criteria and select publications
intovalue_pubs <- intovalue %>%
  filter(
    iv_completion,
    iv_status,
    iv_interventional,
    has_german_umc_lead,
    has_publication,
    
    # In case of duplicate trials, exclude IV1 version
    !(is_dupe & iv_version == 1)
    ) 

# Create vector of unique DOIs for the Unpaywall query
intovalue_dois <- intovalue_pubs %>%
  filter(
    !is.na(doi)
  ) %>%
  distinct(doi) %>%
  pull(doi)

print(paste("Number of DOIs:", length(intovalue_dois)))

# Set unpaywall email -----------------------------------------------------

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
    intovalue_dois,
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

# Get color based on hierarchy: green OA > all OA routes ------

hierarchy_green <-
  c("green",
    "gold",
    "hybrid",
    "bronze",
    "closed")

oa_results_green <-
  unpaywallR::dois_OA_pick_color(
    oa_raw,
    hierarchy_green
  ) %>%
  select(doi, color_green = OA_color)

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

# Process and save Unpaywall data -----------------------------------------------------

oa_unpaywall <-
  full_join(oa_results_green_only, oa_results_green, by = "doi") %>%
  full_join(oa_results, by = "doi") %>%
  mutate(across(everything(), ~na_if(., "")))

# Add variable for publication year
oa_unpaywall$publication_year_unpaywall <- as.Date(oa_unpaywall$publication_date_unpaywall) %>%
  format("%Y")

# Explore Unpaywall data
unresolved_dois <- oa_unpaywall %>%
  filter(is.na(color))
print(paste("Unpaywall unresolved DOIs:", nrow(unresolved_dois)))

write_csv(oa_unpaywall, here("data", "oa-unpaywall.csv"))


# Merge initial data with OA data for pub screening flowchart -----------------

intovalue_pubs_oa <- intovalue_pubs %>%
  select(id, doi) %>%
  left_join(
  oa_unpaywall, by = "doi"
  )

write_csv(intovalue_pubs_oa, here("data", "intovalue-pubs-oa.csv"))


# Log query date ----------------------------------------------------------

loggit::set_logfile(here::here("queries.log"))
loggit::loggit("INFO", "Unpaywall")
