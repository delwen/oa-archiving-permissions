# Generate plots

library(dplyr)
library(readr)
library(here)
library(plotly)
library(ggplot2)

data <- read_csv(here("data", "oa-merged-data.csv"))


# Self-archiving permission for closed publications (absolute) -----------------------

archiving_plot <- data %>% 
  filter(
    color == "closed" | color == "green"
    ) %>%
  mutate(
    status = case_when(
      color == "green" ~ "archived",
      is_closed_archivable == TRUE ~ "permission_found",
      is_closed_archivable == FALSE ~ "permission_not_found",
      color == "closed" & is.na(is_archivable) ~ "no_data"
      )
  ) %>%
  select(
    doi,
    color,
    is_closed_archivable,
    status,
    publication_year_unpaywall
  )

archiving_plot <- archiving_plot %>% 
  count(status, publication_year_unpaywall) %>%
  arrange(publication_year_unpaywall)

archiving_plot$publication_year_unpaywall <- factor(archiving_plot$publication_year_unpaywall)


# Change color palette depending on whether "permission not found" exists
if (nrow(data %>% filter(!is_closed_archivable)) > 0) {

  archiving_plot$status <- factor(archiving_plot$status, levels = c("no_data",
                                                                    "permission_not_found",
                                                                    "permission_found",
                                                                    "archived"
  ))
  
  levels(archiving_plot$status) <- list("Permission unclear" = "no_data",
                                        "Permission not found" = "permission_not_found",
                                        "Permitted to archive" = "permission_found",
                                        "Archived" = "archived"
  )
  
  fill_colors <- c('#20303b', '#ab880c', '#539d66', '#00584e')
  

} else {
  
  archiving_plot$status <- factor(archiving_plot$status, levels = c("no_data",
                                                                    "permission_found",
                                                                    "archived"
  ))
  
  levels(archiving_plot$status) <- list("Permission unclear" = "no_data",
                                        "Permitted to archive" = "permission_found",
                                        "Archived" = "archived"
  )
  
  fill_colors <- c('#20303b', '#539d66', '#00584e')
}


t <- ggplot(archiving_plot, aes(fill=status, y=n, x=publication_year_unpaywall)) + 
  geom_bar(position="stack", stat="identity", color="black") +
  scale_x_discrete(breaks = seq(from = 2010, to = 2020, by = 2)) +
  scale_fill_manual(values = fill_colors, name = NULL) +
  xlab("Year of publication") +
  ylab("Closed-access publications") +
  ylim(0,160) +
  theme_classic() +
  theme(panel.grid.major.y = element_line(color = "black",
                                          size = 0.3,
                                          linetype = 3),
        axis.text = element_text(size = 14),
        axis.title = element_text(size = 14, face = "bold"),
        axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0)),
        legend.text = element_text(size=13),
        legend.spacing.y = unit(0.1, 'cm')) +
  guides(fill = guide_legend(byrow = TRUE))

ggsave(here("figures", "archiving-status.tiff"), t, height = 5, width = 7, dpi = 320)


# Open Access status of all publications (percentage) ----------------------------------

oa_plot <- data %>% select(doi,
                           color,
                           publication_year_unpaywall
                           )

oa_plot <- oa_plot %>% 
  count(color, publication_year_unpaywall) %>%
  arrange(publication_year_unpaywall)

oa_plot$color <- factor(oa_plot$color, levels = c("closed", "green", "bronze", "hybrid", "gold"))

levels(oa_plot$color) <- list(Closed = "closed",
                              Green = "green",
                              Bronze = "bronze",
                              Hybrid = "hybrid",
                              Gold = "gold")

oa_plot$publication_year_unpaywall <- factor(oa_plot$publication_year_unpaywall)

p <- ggplot(oa_plot, aes(fill=color, y=n, x=publication_year_unpaywall)) + 
  geom_bar(position="fill", stat="identity", color="black") +
  scale_x_discrete(breaks = seq(from = 2010, to = 2020, by = 2)) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values=c('#B6B6B6', '#007265', '#cf9188', '#634587', '#F1BA50'), name=NULL) +
  xlab("Year of publication") +
  ylab("Percentage publications") +
  theme_classic() +
  theme(axis.text=element_text(size=14),
        axis.title = element_text(size = 14, face = "bold"),
        axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0)),
        legend.text = element_text(size=13),
        legend.spacing.y = unit(0.1, 'cm')) + 
  guides(fill = guide_legend(byrow = TRUE))

ggsave(here("figures", "oa-status.tiff"), p, height = 5, width = 7, dpi = 320)


# Bar plot of embargo periods --------------------------------------------------

embargo_distribution <- data %>%
  filter(
    is_closed_archivable
    ) %>%
  count(
    embargo
  ) %>%
  rename(number = n) %>%
  mutate(embargo = factor(embargo))

e <- ggplot(
  embargo_distribution,
  aes(x = embargo, y=number)) + 
  geom_bar(stat = "identity", fill = '#9fb6cd') +
  geom_text(aes(label = number), color = "black", size = 4.5, vjust = -0.5) +
  ylim(0,800) +
  labs(y= "Closed-access publications", x = "Embargo length (months)") +
  theme_classic() +
  theme(panel.grid.major.y = element_line(color = "black",
                                          size = 0.1,
                                          linetype = 3),
        axis.text = element_text(size = 14),
        axis.title = element_text(size = 14, face = "bold"),
        axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)))

ggsave(here("figures", "embargo.tiff"), e, height = 5, width = 7, dpi = 320)