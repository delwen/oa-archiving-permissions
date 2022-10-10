# Includes adaptations by Maia Salholz-Hillel (see https://github.com/maia-sh/intovalue-data)

# Bring together data Unpaywall and SYP data

library(dplyr)
library(readr)
library(here)

oa_unpaywall <- read_csv(here("data", "oa-unpaywall.csv"))
oa_syp <- read_csv(here("data", "oa-syp-permissions.csv"))

oa_data <- oa_unpaywall %>%
  
  # Join share your paper data
  left_join(oa_syp, by = "doi") %>%
  
  rename(journal_unpaywall = journal) %>%
  
  # Create booleans for whether publication is OA and, if not, whether can be archived
  # `is_oa` is TRUE for publications that are either gold, green, hybrid, or bronze;
  #            FALSE if closed;
  #            NA if no unpaywall data
  
  # `is_archivable` TRUE if EITHER accepted or published version may be archived according to SYP, regardless of unpaywall status;
  #                 FALSE if NEITHER accepted nor published can be archived regardless of unpaywall status
  
  # `is_closed_archivable` is NA if OA status anything other than closed or if no unpaywall OA data,
  #                           TRUE if EITHER accepted or published version may be archived according to SYP AND publication is closed according to unpaywall,
  #                           FALSE if NEITHER accepted nor published version may be archived according to SYP AND publication is closed according to unpaywall
  mutate(
    is_oa = color == "gold" | color == "hybrid" | color == "green" | color == "bronze",
    is_archivable = case_when(
      permission_accepted | permission_published ~ TRUE,
      !(permission_accepted | permission_published) ~ FALSE,
      TRUE ~ NA
      ),
    is_closed_archivable = if_else(color != "closed", NA, is_archivable, missing = NA)
    ) %>%

  filter(
    publication_year_unpaywall > "2009" & publication_year_unpaywall < "2021"
  ) %>%
  
  # Remove publications for which the DOI points to the pre-print
  filter(
    !is.na(journal_unpaywall)
    )

write_csv(oa_data, here("data", "oa-merged-data.csv"))