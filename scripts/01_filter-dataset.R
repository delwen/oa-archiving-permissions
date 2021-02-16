# ----------------------------------------------------------------------------------------------------------------
# Optional: Generate a filtered dataset based on the main results table
# ----------------------------------------------------------------------------------------------------------------

source(here::here("scripts", "environment.R"))

selected_umc <- "berlin"
selected_year <- 2018
selected_approach <- "approach_3"

# Load the main dataset with all publications and specificity checks results
data <- read_csv(file.path(data_dir, "main.csv"), col_types = "ccdddcccccdccccdlllllc")

# Duplicate and filter for desired publications
data_filtered <- data %>%
  filter(city == selected_umc) %>%
  filter(year_published == selected_year) %>%
  filter(approach == selected_approach)

#--- Extract total number of publications

print(paste0("Total number of publications:", nrow(data_filtered)))

# Save the resulting file to CSV
write_csv(data_filtered, file.path(data_dir, paste0(selected_umc, "-", selected_year, ".csv")))
