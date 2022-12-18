# Descriptive statistics

library(dplyr)
library(readr)
library(here)

data <- read_csv(here("data", "oa-merged-data.csv"))

denom_all <- nrow(data)


# n of openly accessible publications (gold, hybrid, bronze, green)

num_oa <- data %>%
  filter(is_oa) %>%
  nrow()

print(num_oa)

perc_oa <- round(100*num_oa/denom_all, 1)
print(perc_oa)

# compare OA in 2010 vs 2020

# 2010
denom_2010 <- data %>%
  filter(
    publication_year_unpaywall == 2010) %>%
  nrow()

num_2010 <- data %>%
  filter(
    publication_year_unpaywall == 2010,
    is_oa
    ) %>%
  nrow()

perc_oa_2010 <- num_2010/denom_2010*100
print(perc_oa_2010)

# 2020
denom_2020 <- data %>%
  filter(
    publication_year_unpaywall == 2020) %>%
  nrow()

num_2020 <- data %>%
  filter(
    publication_year_unpaywall == 2020,
    is_oa
    ) %>%
  nrow()

perc_oa_2020 <- num_2020/denom_2020*100
print(perc_oa_2020)

# breakdown of OA categories

#gold
gold <- data %>%
  filter(color == "gold") %>%
  nrow()

print(gold)

perc_gold <- round(100*gold/denom_all)
print(perc_gold)

#hybrid
hybrid <- data %>%
  filter(color == "hybrid") %>%
  nrow()

print(hybrid)

perc_hybrid <- round(100*hybrid/denom_all)
print(perc_hybrid)

#bronze
bronze <- data %>%
  filter(color == "bronze") %>%
  nrow()

print(bronze)

perc_bronze <- round(100*bronze/denom_all)
print(perc_bronze)

#green
green <- data %>%
  filter(color == "green") %>%
  nrow()

print(green)

perc_green <- round(100*green/denom_all)
print(perc_green)

# n of closed publications

num_closed <- data %>%
  filter(color == "closed") %>%
  nrow()

print(num_closed)

perc_closed <- round(100*num_closed/denom_all)
print(perc_closed)


# syp responses for all pubs queried (unresolved, no best permission, no embargo info, response)

# data %>%
#   count(syp_response) %>%
#   mutate(perc = round(100*n/denom_all))


# syp responses for closed pubs (unresolved, no best permission, no embargo info, response)

denom_closed <- data %>%
  filter(color == "closed") %>%
  nrow()

data %>%
  filter(color == "closed") %>%
  count(syp_response, is_archivable) %>%
  mutate(perc = 100*n/denom_closed)


# self-archiving permissions for closed publications with a syp response

denom_closed_response <- data %>%
  filter(
    color == "closed",
    syp_response == "response",
    !is.na(is_closed_archivable)
  ) %>%
  nrow()

data %>%
  filter(
    color == "closed",
    syp_response == "response",
    !is.na(is_closed_archivable)
    ) %>%
  count(
    is_closed_archivable
    ) %>%
    mutate(
      perc = round(100*n/denom_closed_response, 1)
    )


# breakdown of permission routes (accepted/published)

denom_closed_archivable <- data %>%
  filter(
    syp_response == "response",
    is_closed_archivable) %>%
  nrow()

data %>%
  filter(
    syp_response == "response",
    is_closed_archivable
  ) %>%
  count(
    permission_accepted, permission_published
  ) %>%
  mutate(
    perc = round(100*n/denom_closed_archivable)
  )


# number of green OA articles for which an archiving permission was found

# denom_greenoa <- data %>%
#   filter(color == "green") %>%
#   nrow()
# 
# data %>%
#   filter(
#     color == "green"
#   ) %>%
#   count(
#     is_archivable
#   ) %>%
#   mutate(
#     perc = round(100*n/denom_greenoa, 1)
#   )


# realised potential of green oa

numer_green_oa <- data %>%
  filter(
    color == "green"
  ) %>%
  nrow()

denom_green_oa <- data %>%
  filter(
    is_closed_archivable | color == "green"
  ) %>%
  nrow()

numer_green_oa
round(100*numer_green_oa/denom_green_oa)


# examine embargoes for paywalled publications with a permission to archive

data %>% filter(
  is_closed_archivable
  ) %>%
  count(
    embargo
  )

# number of paywalled publications that have a permission to archive the
# accepted version and an embargo of 12 months

data %>% filter(
  is_closed_archivable,
  embargo == 12
  ) %>% count(
    permission_accepted,
    permission_published
  )