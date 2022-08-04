# Create flowcharts

library(dplyr)
library(readr)
library(rio)

iv_data <- rio::import("https://github.com/maia-sh/intovalue-data/blob/main/data/processed/trials.rds?raw=true")

iv_data <- iv_data %>%
  mutate(
    has_publication = if_else(publication_type == "journal publication", TRUE, FALSE, missing = FALSE)
  )


# Trial screening ---------------------------------------------------------

print(paste0("Number of IV trials: ", nrow(iv_data)))

print(paste0("Number of IV1 trials: ",
             iv_data %>%
               filter(iv_version == 1) %>%
               nrow()))

print(paste0("Number of IV2 trials: ",
             iv_data %>%
               filter(iv_version == 2) %>%
               nrow()))

iv_completion <- iv_data %>%
  filter(iv_completion)

print(paste0("Trials not iv_completion: ", nrow(iv_data) - nrow(iv_completion)))

iv_status <- iv_completion %>%
  filter(iv_status)

print(paste0("Trials not iv_status: ", nrow(iv_completion) - nrow(iv_status)))

iv_interventional <- iv_status %>%
  filter(iv_interventional)

print(paste0("Trials not iv_interventional: ", nrow(iv_status) - nrow(iv_interventional)))

print(paste0("Trials meeting IV criteria: ", nrow(iv_interventional)))

iv_german <- iv_interventional %>%
  filter(has_german_umc_lead)

print(paste0("Trials not german UMC lead: ", nrow(iv_interventional) - nrow(iv_german)))
print(paste0("Trials with german UMC lead: ", nrow(iv_german)))

iv_german_unique <- iv_german %>%
  filter(
    !(is_dupe & iv_version == 1)
  )

print(paste0("Duplicate trials: ", nrow(iv_german) - nrow(iv_german_unique)))
print(paste0("Trials with duplicates removed: ", nrow(iv_german_unique)))



# Publication screening ---------------------------------------------------

iv_pubs <- iv_german_unique %>%
  filter(has_publication)

print(paste0("No publications: ", nrow(iv_german_unique) - nrow(iv_pubs)))
print(paste0("Trial pubs: ", nrow(iv_pubs)))

iv_doi <- iv_pubs %>%
  filter(!is.na(doi))

print(paste0("No DOI: ", nrow(iv_pubs) - nrow(iv_doi)))
print(paste0("DOI: ", nrow(iv_doi)))

iv_unique <- distinct(iv_doi, doi, .keep_all = TRUE)

print(paste0("Duplicate pubs: ", nrow(iv_doi) - nrow(iv_unique)))
print(paste0("Unique pubs: ", nrow(iv_unique)))

iv_resolved <- iv_unique %>%
  filter(!is.na(color))

print(paste0("Unresolved in Unpaywall: ", nrow(iv_unique) - nrow(iv_resolved)))
print(paste0("Resolved in Unpaywall: ", nrow(iv_resolved)))

iv_resolved$pub_year_unpaywall <- as.Date(iv_resolved$publication_date_unpaywall) %>%
  format("%Y")

iv_year <- iv_resolved %>%
  filter(pub_year_unpaywall > "2009" & pub_year_unpaywall < "2021")

print(paste0("Published before 2010 or after 2020: ", nrow(iv_resolved) - nrow(iv_year)))
print(paste0("Published between 2010 and 2020: ", nrow(iv_year)))
