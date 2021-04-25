# ----------------------------------------------------------------------------------------------------------------
# Optional: Generate a filtered dataset based on the original IntoValue dataset
# ----------------------------------------------------------------------------------------------------------------

source(here::here("scripts", "environment.R"))

filename <- "intovalue"

# Load the original dataset
data <- read_csv(file.path(data_dir, paste0(filename, ".csv")))

# Filter for trials with pre-defined characteristics
data_filtered <- data %>%
  filter(has_german_umc_lead,
         has_publication,
         !is.na(doi),
         recruitment_status=="Completed",
         main_sponsor=="Other")

# Remove duplicates
data_filtered <- distinct(data_filtered, doi, .keep_all = TRUE)

data_filtered <- data_filtered %>%
  select(id, pmid, doi, lead_cities)

print(paste0("Total number of publications:", nrow(data_filtered)))

# Save the resulting file to CSV
write_csv(data_filtered, file.path(data_dir, paste0(filename, "-filtered.csv")))