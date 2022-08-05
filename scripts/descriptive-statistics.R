# Descritive statistics

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

perc_oa <- round(100*num_oa/denom_all)
print(perc_oa)


# n of closed publications

num_closed <- data %>%
  filter(color == "closed") %>%
  nrow()

print(num_closed)

perc_closed <- round(100*num_closed/denom_all)
print(perc_closed)


# syp responses for all pubs queried (unresolved, no best permission, no embargo info, response)

data %>%
  count(syp_response) %>%
  mutate(perc = round(100*n/denom_all))


# syp responses for closed pubs (unresolved, no best permission, no embargo info, response)

denom_closed <- data %>%
  filter(color == "closed") %>%
  nrow()

data %>%
  filter(color == "closed") %>%
  count(syp_response) %>%
  mutate(perc = round(100*n/denom_closed))


# permissions for closed publications

data %>%
  filter(
    color == "closed"
    ) %>%
  count(
    is_closed_archivable
    ) %>%
    mutate(
      perc = round(100*n/denom_closed)
    )


# breakdown of permission routes (accepted/published)

denom_closed_archivable <- data %>%
  filter(is_closed_archivable) %>%
  nrow()

data %>%
  filter(
    is_closed_archivable
  ) %>%
  count(
    permission_accepted, permission_published
  ) %>%
  mutate(
    perc = round(100*n/denom_closed_archivable)
  )


# realised potential of green oa

numer_green_oa <- data %>%
  filter(
    color_green_only == "green"
  ) %>%
  nrow()

denom_green_oa <- data %>%
  filter(
    is_closed_archivable | color_green_only == "green"
  ) %>%
  nrow()

numer_green_oa
round(100*numer_green_oa/denom_green_oa)


# examine embargoes for paywalled publications

data %>% filter(
  color == "closed",
  syp_response == "response"
  ) %>%
  count(
    embargo
  )
