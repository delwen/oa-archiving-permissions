source(here::here("scripts", "environment.R"))

filename <- "2021-02-18_berlin-2018-oa-permissions.csv"

data <- read_csv(file.path(data_dir, filename), col_types = "ccdddcccccdccccdlllllcccccDlclclllccccdcDlllc")

archiveable <- data %>%
  filter(permission_postprint == TRUE)
n_data <- nrow(archiveable)

archiveable <- archiveable %>%
  group_by(publisher) %>%
  summarize(Articles = n()) %>%
  arrange(desc(Articles)) %>%
  mutate(version = "postprint") %>%
  mutate(lab_ypos = cumsum(Articles) - 0.5 * Articles) %>%
  slice(1:5)
#knitr::kable()

top_five <- sum(archiveable$Articles)

archiveable <- archiveable %>%
  add_row(publisher = "Other",
          Articles = n_data - top_five,
          version = "postprint",
          lab_ypos = n_data - 0.5 * (n_data - top_five))

archiveable$publisher <- factor(archiveable$publisher, levels = archiveable$publisher[6:1])

png(file.path(data_dir, paste0(filename, "-publishers.png")),
    width = 6,
    height = 4,
    units = 'in',
    res = 300)

first <- "#0A2F51"
second <- "#137177"
third <- "#1D9A6C"
fourth <- "#56B870"
fifth <- "#99D492"
sixth <- "#BFE1B0"

c <- ggplot(data = archiveable, aes(x = version, y = Articles)) +
  geom_col(aes(fill = publisher), width = 0.7)+
  ggtitle(paste0("Top 5 publishers of self-archiveable publications (n = ", n_data, ")")) +
  geom_text(aes(y = lab_ypos, label = Articles, group=publisher), color = "white") +
  scale_fill_manual(values = c(sixth, fifth, fourth, third, second, first))

print(c)
dev.off()

print(paste0("Number of self-archiveable publications: ", n_data))
