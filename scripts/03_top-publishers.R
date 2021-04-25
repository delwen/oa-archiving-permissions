# extract top 5 publishers for closed/bronze and open publications
# note for high res: https://www.r-bloggers.com/high-resolution-figures-in-r/

source(here::here("scripts", "environment.R"))

#----------------------------------------------------------------------------------------------------------------------------------#
# Closed publishers
#----------------------------------------------------------------------------------------------------------------------------------#

filename <- "2021-04-25_intovalue-filtered-oa"

data <- read_csv(file.path(data_dir, paste0(filename, ".csv")), col_types = "cdccccccD")

closed_data <- data %>%
  filter(color == "closed")

n_closed <- nrow(closed_data)

top_publishers <- closed_data %>%
  group_by(publisher) %>%
  summarize(Publications = n()) %>%
  arrange(desc(Publications)) %>%
  mutate(OA_status = "closed") %>%
  mutate(lab_ypos = cumsum(Publications) - 0.5 * Publications) %>%
  slice(1:5)
  #knitr::kable()

top_five <- sum(top_publishers$Publications)

top_publishers <- top_publishers %>%
  add_row(publisher = "Other", Publications = n_closed - top_five, OA_status = "closed", lab_ypos = n_closed - 0.5 * (n_closed - top_five))

top_publishers$publisher <- factor(top_publishers$publisher, levels = top_publishers$publisher[6:1])

png(file.path(data_dir, paste0(filename, "-closed-publishers.png")),
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

c <- ggplot(data = top_publishers, aes(x = OA_status, y = Publications)) +
  geom_col(aes(fill = publisher), width = 0.7)+
  ggtitle(paste0("Top 5 publishers of closed publications (n = ", n_closed, ")")) +
  geom_text(aes(y = lab_ypos, label = Publications, group=publisher), color = "white") +
  scale_fill_manual(values = c(sixth, fifth, fourth, third, second, first))

print(c)
dev.off()

print(paste0("Number of closed publications: ", n_closed))

#----------------------------------------------------------------------------------------------------------------------------------#
# Open publishers
#----------------------------------------------------------------------------------------------------------------------------------#

# extract top 5 publishers for open publications

data <- read_csv(file.path(data_dir, paste0(filename, ".csv")), col_types = "cdccccccD")
open_data <- data %>%
  filter(color == "green" | color == "gold" | color == "hybrid" | color == "bronze")

n_open <- nrow(open_data)

top_publishers <- open_data %>%
  group_by(publisher) %>%
  summarize(Publications = n()) %>%
  arrange(desc(Publications)) %>%
  mutate(OA_status = "open") %>%
  mutate(lab_ypos = cumsum(Publications) - 0.5 * Publications) %>%
  slice(1:5)
#knitr::kable()

top_five <- sum(top_publishers$Publications)

top_publishers <- top_publishers %>%
  add_row(publisher = "Other", Publications = n_open - top_five, OA_status = "open", lab_ypos = n_open - 0.5 * (n_open - top_five))

top_publishers$publisher <- factor(top_publishers$publisher, levels = top_publishers$publisher[6:1])

png(file.path(data_dir, paste0(filename, "-open-publishers.png")),
    width = 6,
    height = 4,
    units = 'in',
    res = 300)

first <- "#2A4A5D"
second <- "#3E6086"
third <- "#5170AF"
fourth <- "#68A4BE"
fifth <- "#81CBC6"
sixth <- "#8DD2C0"

o <- ggplot(data = top_publishers, aes(x = OA_status, y = Publications)) +
  geom_col(aes(fill = publisher), width = 0.7)+
  ggtitle(paste0("Top 5 publishers of openly accessible publications (n = ", n_open, ")")) +
  geom_text(aes(y = lab_ypos, label = Publications, group=publisher), color = "white") +
  scale_fill_manual(values = c(sixth, fifth, fourth, third, second, first))

print(o)
dev.off()

print(paste0("Number of open publications: ", n_open))
