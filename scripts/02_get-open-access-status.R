# Query Unpaywall API to get OA status of publications based on pre-defined hierarchy
# https://github.com/NicoRiedel/unpaywallR

source(here::here("scripts", "environment.R"))

#-----------------------------------------------------------------------------------------------------------------------------
# Define filepaths
#-----------------------------------------------------------------------------------------------------------------------------

filename <- "berlin-2018"

input <- file.path(data_dir, paste0(filename, ".csv"))
output <- file.path(data_dir, paste0(Sys.Date(), "_", filename, "-oa.csv"))

#-----------------------------------------------------------------------------------------------------------------------------
# Read in dataset and get the OA status for all publications
#-----------------------------------------------------------------------------------------------------------------------------

doi_table <- read_csv(input, col_types = "ccdddcccccdccccdlllllc")

n_publications <- doi_table %>%
  summarise(publications = n())

cities <- doi_table$city %>% unique()
years <- doi_table$year_published %>% unique()

cols <- c("doi","city","year_published","color","issn","journal","publisher","date")
df <- data.frame(matrix(ncol = length(cols), nrow = 0))
colnames(df) <- cols

#Split dataset in chunks and do requests and save results on the chunks
for(cty in cities)
{
  for(yr in years)
  {
    print(paste0("City: ", cty))
    print(paste0("Year published: ", yr))

    doi_batch <- (doi_table %>%
                    filter(year_published == yr) %>%
                    filter(city == cty))[["doi"]]
    print(paste0("DOI number: ", length(doi_batch)))

    #retrieve OA colors for the DOIs from unpaywall
    unpaywall_results <- unpaywallR::dois_OA_colors(doi_batch,
                                                    email_api,
                                                    clusters = 2,
                                                    color_hierarchy = c("gold", "hybrid", "green", "bronze", "closed"))
    city_results <- tibble(city = cty,
                           doi = doi_batch,
                           color = unpaywall_results$OA_color,
                           year_published = as.numeric(yr),
                           issn = unpaywall_results$issn,
                           journal = unpaywall_results$journal,
                           publisher = unpaywall_results$publisher,
                           date = unpaywall_results$date)

    df <- rbind(df, city_results)
  }
}

all_results <- merge(doi_table, df)
all_results <- all_results %>%
  distinct(city, year_published, doi, .keep_all = TRUE)
all_results <- all_results[order(all_results$city),]

write_csv(all_results, output)

print(paste0("Number of publications: ", n_publications))
