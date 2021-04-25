source(here::here("scripts", "environment.R"))

filename <- "2021-04-25_intovalue-filtered-oa-permissions"

data <- read_csv(file.path(data_dir, paste0(filename, ".csv")), col_types = "cdccccccDlclclllccccccDlll")

results <- data %>%
  filter(color == "closed") %>%
  rename(permission = permission_postprint) %>%
  mutate(permission = ifelse(permission, "yes", "no")) %>%
  mutate(permission = ifelse(is.na(permission), "nodata", permission)) %>%
  count(permission) %>%
  rename(count = n) %>%
  arrange(desc(count)) %>%
  mutate(lab_ypos = cumsum(count) - 0.5 * count) %>%
  mutate(publications = "closed")

png(file.path(data_dir, paste0(filename, ".png")),
    width = 6,
    height = 4,
    units = 'in',
    res = 300)

first <- "#1D9A6C"
second <- "#137177"
third <- "#0A2F51"

p <- ggplot(data = results, aes(x = publications, y = count)) + 
  geom_col(aes(fill = permission), width = 0.7) +
  ggtitle(paste0("Permission to archive the postprint for closed publications (n = ", sum(results$count), ")")) +
  geom_text(aes(y = lab_ypos, label = round(count, digits = 1), group=permission), color = "white") +
  ylab("Publications") + 
  scale_fill_manual(values = c(third, second, first))

print(p)
dev.off()