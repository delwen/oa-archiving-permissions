source(here::here("scripts", "environment.R"))

filename <- "2021-04-25_intovalue-filtered-oa-permissions"

data <- read_csv(file.path(data_dir, paste0(filename, ".csv")), col_types = "cdccccccDlclclllccccccDlll")

results <- data %>%
  filter(color == "closed") %>%
  rename(permission = permission_postprint) %>%
  mutate(permission = ifelse(permission, "yes", "no")) %>%
  mutate(permission = ifelse(is.na(permission), "no data", permission)) %>%
  count(permission) %>%
  rename(count = n) %>%
  arrange(desc(count)) %>%
  mutate(lab_ypos = cumsum(count) - 0.5 * count) %>%
  mutate(publications = "")

png(file.path(data_dir, paste0(filename, ".png")),
    width = 5,
    height = 4,
    units = 'in',
    res = 300)

first <- "#56B870"
second <- "#137177"
third <- "#0A2F51"

p <- ggplot(data = results, aes(x = publications, y = count)) + 
  geom_col(aes(fill = permission), width = 0.5, alpha = 0.8) +
  ggtitle("Permission to archive the postprint") +
  geom_text(aes(y = lab_ypos, label = round(count, digits = 1), group=permission), color = "white") +
  ylab("Closed publications") + xlab("") +
  scale_fill_manual(values = c(third, second, first))

print(p)
dev.off()