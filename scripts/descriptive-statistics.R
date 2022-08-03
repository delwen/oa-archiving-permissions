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

perc_oa <- round((num_oa/denom_all)*100, 2)
print(perc_oa)

# n of closed publications

num_closed <- data %>%
  filter(color == "closed") %>%
  nrow()

print(num_closed)

perc_closed <- round((num_closed/denom_all)*100, 2)
print(perc_closed)

# syp responses (unresolved, no best permission, no embargo info, response)

data %>%
  count(syp_response) %>%
  mutate(perc = round((n/denom_all)*100, 2))

# syp responses for closed pubs (unresolved, no best permission, no embargo info, response)

denom_closed <- data %>%
  filter(color == "closed") %>%
  nrow()

data %>%
  filter(color == "closed") %>%
  count(syp_response) %>%
  mutate(perc = round((n/denom_closed)*100, 2))

