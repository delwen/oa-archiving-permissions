source(here::here("scripts", "environment.R"))

filename <- "2021-04-25_intovalue-filtered-oa"

data <- read_csv(file.path(data_dir, paste0(filename, ".csv")), col_types = "cdccccccD") %>%
  mutate(color = if_else(is.na(color), "unknown", color))

OA_data <- data %>%
  count(color) %>%
  rename(count = n) %>%
  mutate(perc = (count/sum(OA_data$count))*100) %>%
  arrange(desc(perc)) %>%
  mutate(lab_ypos = cumsum(perc) - 0.5 * perc) %>%
  mutate(publications = "")

OA_data$color <- factor(OA_data$color, levels = OA_data$color[6:1])

png(file.path(data_dir, paste0(filename, "-status.png")),
    width = 5,
    height = 4,
    units = 'in',
    res = 300)

#first <- "#E2D7BF"
first <- "#ccbe9f"
second <- "#DDB247"
third <- "#C3675D"
fourth <- "#457373"
fifth <- "#5B3547"
sixth <- "#131826"

s <- ggplot(data = OA_data, aes(x = publications, y = perc)) + 
  geom_col(aes(fill = color), width = 0.5, alpha = 0.7) +
  ggtitle(paste0("OA status of clinical trial publications (n = ", sum(OA_data$count), ")")) +
  geom_text(aes(y = lab_ypos, label = round(perc, digits = 1), group=color), color = "white") +
  ylab("Percentage publications (%)") + xlab("") +  
  scale_fill_manual(values = c(sixth, fifth, fourth, third, second, first))

print(s)
dev.off()
