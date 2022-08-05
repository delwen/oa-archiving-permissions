library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(here)

# Prepare trial publications ----------------------------------------------------------

intovalue_pubs_oa <- read_csv(here("data", "intovalue-pubs-oa.csv"))

pubs_raw <- intovalue_pubs_oa %>%
  group_by(doi) %>%
  mutate(is_dupe_doi = if_else(n() > 1 & row_number() != 1, TRUE, FALSE)) %>%
  ungroup()

pubs_raw <- pubs_raw %>%
  mutate(
    has_doi = if_else(!is.na(doi), TRUE, FALSE),
    is_unique_doi = if_else(!is_dupe_doi, TRUE, FALSE),
    is_resolved_unpaywall = if_else(!is.na(doi) & !is.na(color), TRUE, FALSE),
    is_published_2010_2020 = if_else(publication_year_unpaywall > "2009" & publication_year_unpaywall < "2021", TRUE, FALSE)
  )

# Prepare screening functions ---------------------------------------------

# Apply screening criteria
# Returns list of inclusion counts and filtered dataframe
count_filter <- function(data, vars) {
  
  counts <-
    tibble(name = as.character(),
           value = as.logical(),
           n = as.integer()
    )
  
  for (var in vars) {
    counts <-
      data %>%
      count(.data[[var]]) %>%
      pivot_longer(-n) %>%
      add_row(counts, .)
    
    data <- filter(data, .data[[var]])
  }
  
  list(data = data, counts = counts)
  
}

# Report screening summary counts
report_n <- function(counts, var, condition) {
  n <-
    counts %>%
    filter(name == var & value == condition) %>%
    pull(n)
  
  # If empty, count is 0
  if (rlang::is_empty(n)){n <- 0}
  
  n
}


# Screen trial publications -----------------------------------------------------------

screening_criteria <- c(
  "has_doi",
  "is_unique_doi",
  "is_resolved_unpaywall",
  "is_published_2010_2020"
)

pubs_screened <- count_filter(pubs_raw, screening_criteria)

pubs <- pubs_screened$data

#write_csv(pubs, here("data", "pubs.csv"))

# Tabularize pub screening counts ---------------------------------------

pubs_screening <-
  
  pubs_raw %>%
  
  bind_rows(pubs_screened$counts)


# Report trial screening counts -------------------------------------------

n_pubs_iv <- nrow(pubs_raw)
n_pubs_doi <- report_n(pubs_screening, "has_doi", TRUE)
n_pubs_doi_ex <- report_n(pubs_screening, "has_doi", FALSE)
n_pubs_deduped <- report_n(pubs_screening, "is_unique_doi", TRUE)
n_pubs_deduped_ex <- report_n(pubs_screening, "is_unique_doi", FALSE)
n_pubs_resolved <- report_n(pubs_screening, "is_resolved_unpaywall", TRUE)
n_pubs_resolved_ex <- report_n(pubs_screening, "is_resolved_unpaywall", FALSE)
n_pubs_2010_2020 <- report_n(pubs_screening, "is_published_2010_2020", TRUE)
n_pubs_2010_2020_ex <- report_n(pubs_screening, "is_published_2010_2020", FALSE)


# Remove unnecessary variables --------------------------------------------

rm(screening_criteria, pubs_screened, report_n)
