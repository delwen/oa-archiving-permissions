# Query Unpaywall API to get OA status of publications based on pre-defined hierarchy
# https://github.com/NicoRiedel/unpaywallR

source(here::here("scripts", "environment.R"))

#-----------------------------------------------------------------------------------------------------------------------------
# Define filepaths
#-----------------------------------------------------------------------------------------------------------------------------

filename <- "intovalue-filtered"

input <- file.path(data_dir, paste0(filename, ".csv"))
output <- file.path(data_dir, paste0(Sys.Date(), "_", filename, "-oa.csv"))

#-----------------------------------------------------------------------------------------------------------------------------
# Read in dataset and get the OA status for all publications
#-----------------------------------------------------------------------------------------------------------------------------

doi_table <- read_csv(input, col_types = "cdcc")

n_publications <- nrow(doi_table)

cols <- c("doi","color","issn","journal","publisher","date")
df <- data.frame(matrix(ncol = length(cols), nrow = 0))
colnames(df) <- cols

doi_batch <- doi_table[["doi"]]
print(paste0("DOI number: ", length(doi_batch)))

#retrieve OA colors for the DOIs from unpaywall
unpaywall_results <- unpaywallR::dois_OA_colors(doi_batch,
                                                email_api,
                                                clusters = 2,
                                                color_hierarchy = c("gold", "hybrid", "green", "bronze", "closed"))

oa_results <- tibble(doi = doi_batch,
                       color = unpaywall_results$OA_color,
                       issn = unpaywall_results$issn,
                       journal = unpaywall_results$journal,
                       publisher = unpaywall_results$publisher,
                       date = unpaywall_results$date)

df <- rbind(df, oa_results)

all_results <- left_join(doi_table, df, by = "doi")

write_csv(all_results, output)

test <- all_results %>%
  verify(nrow(.)==n_publications)

print(paste0("Number of publications: ", n_publications))
