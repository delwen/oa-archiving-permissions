# Generate plots

library(dplyr)
library(readr)
library(here)
library(plotly)
library(ggplot2)

data <- read_csv(here("data", "oa-merged-data.csv"))


# Self-archiving permission for closed publications -----------------------
# Adapted from Benjamin Gregory Carlisle (https://github.com/quest-bih/clinical-dashboard)

plot_data <- tribble(
  ~year, ~percentage, ~can_archive,   ~cant_archive,    ~no_data
  )
  
upperlimit <- 0
  
for (year in unique(data$publication_year_unpaywall)) {
    
  all_archived <- data %>%
    filter(
      color_green_only == "green",
      publication_year_unpaywall == year
    ) %>%
    nrow()
  
  all_can_archive <- data %>%
    filter(
      is_closed_archivable == TRUE,
      publication_year_unpaywall == year
    ) %>%
    nrow()
  
  all_cant_archive <- data %>%
    filter(
      is_closed_archivable == FALSE,
      publication_year_unpaywall == year
    ) %>%
    nrow()
  
  all_no_data <- data %>%
    filter(
      color == "closed",
      is.na(is_closed_archivable),
      publication_year_unpaywall == year
    ) %>%
    nrow()
  
  plot_data <- plot_data %>%
    bind_rows(
      tribble(
        ~year, ~percentage, ~can_archive,   ~cant_archive,    ~no_data,
        year, all_archived, all_can_archive, all_cant_archive, all_no_data
      )
    )
    
    year_upperlimit <- 1.1 * sum(all_archived, all_can_archive, all_cant_archive, all_no_data)
    upperlimit <- max(year_upperlimit, upperlimit)
  }
  
ylabel <- "Paywalled publications"
  
p <- plot_ly(
  plot_data,
  x = ~year,
  y = ~percentage,
  name = "Archived",
  type = 'bar',
  marker = list(
    color = "#007265",
      line = list(
        color = 'rgb(0,0,0)',
        width = 1.5
      )
  )
) %>%
  add_trace(
    y = ~can_archive,
    name = "Can archive",
    marker = list(
      color = "#539d66",
        line = list(
          color = 'rgb(0,0,0)',
          width = 1.5
        )
    )
  ) %>% 
  add_trace(
    y = ~cant_archive,
    name = "Can't archive",
    marker = list(
      color = "#ab880c",
        line = list(
          color = 'rgb(0,0,0)',
          width = 1.5
        )
    )
  ) %>%
  add_trace(
    y = ~no_data,
    name = "No data",
    marker = list(
      color = "#20303b",
        line = list(
          color = 'rgb(0,0,0)',
          width = 1.5
        )
    )
  ) %>%
  layout(
    #title = "Realised potential of green OA for paywalled publications",
    barmode = 'stack',
    legend = list(
      font = list(
        size = 18
      )
    ),
    xaxis = list(
      title = list(text = '<b>Year of publication</b>', standoff = 20),
      titlefont = list(size = 18),
      tickfont = list(size = 19),
      dtick = 2
    ),
    yaxis = list(
      title = list(text = paste('<b>', ylabel, '</b>'), standoff = 20),
      titlefont = list(size = 18),
      tickfont = list(size = 19),
      range = c(0, upperlimit)
    ),
    paper_bgcolor = "#FFFFFF",
      plot_bgcolor = "#FFFFFF"
  )


# Open Access status of all publications ----------------------------------
# Adapted from Benjamin Gregory Carlisle (https://github.com/quest-bih/clinical-dashboard)

plot_data <- tribble(
  ~x_label, ~gold,    ~green,    ~hybrid,    ~na,    ~closed,    ~bronze
)

upperlimit <- 0

for (year in unique(data$publication_year_unpaywall)) {
  
  gold_num <- data %>%
    filter(
      publication_year_unpaywall == year,
      color == "gold"
    ) %>%
    nrow()
  
  green_num <- data %>%
    filter(
      publication_year_unpaywall == year,
      color == "green"
    ) %>%
    nrow()
  
  hybrid_num <- data %>%
    filter(
      publication_year_unpaywall == year,
      color == "hybrid"
    ) %>%
    nrow()
  
  na_num <- data %>%
    filter(
      publication_year_unpaywall == year,
      is.na(color)
    ) %>%
    nrow()
  
  closed_num <- data %>%
    filter(
      publication_year_unpaywall == year,
      color == "closed"
    ) %>%
    nrow()
  
  bronze_num <- data %>%
    filter(
      publication_year_unpaywall == year,
      color == "bronze"
    ) %>%
    nrow()
  
  year_denom <- data %>%
    filter(
      publication_year_unpaywall == year
    ) %>%
    nrow()
  
    plot_data <- plot_data %>%
      bind_rows(
        tribble(
          ~x_label, ~gold,    ~green,    ~hybrid,    ~na,    ~closed,    ~bronze,
          year, gold_num, green_num, hybrid_num, na_num, closed_num, bronze_num
        )
      )
  
  year_upperlimit <- 1.1*year_denom
  upperlimit <- max(year_upperlimit, upperlimit)
  
}

ylabel <- "Publications"

plot_ly(
  plot_data,
  x = ~x_label,
  y = ~gold,
  name = "Gold",
  type = 'bar',
  marker = list(
    color = "#F1BA50",
    line = list(
      color = 'rgb(0,0,0)',
      width = 1.5
    )
  )
) %>%
  add_trace(
    y = ~green,
    name = "Green",
    marker = list(
      color = "#007265",
      line = list(
        color = 'rgb(0,0,0)',
        width = 1.5
      )
    )
  ) %>%
  add_trace(
    y = ~hybrid,
    name = "Hybrid",
    marker = list(
      color = "#634587",
      line = list(
        color = 'rgb(0,0,0)',
        width = 1.5
      )
    )
  ) %>%
  add_trace(
    y = ~bronze,
    name = "Bronze",
    marker = list(
      color = "#cf9188",
      line = list(
        color = 'rgb(0,0,0)',
        width = 1.5
      )
    )
  ) %>%
  add_trace(
    y = ~closed,
    name = "Paywalled",
    marker = list(
      color = "#B6B6B6",
      line = list(
        color = 'rgb(0,0,0)',
        width = 1.5
      )
    )
  ) %>%
  layout(
    #title = "Open Access status of publications",
  barmode = 'stack',
  legend = list(
    font = list(
      size = 18
      )
    ),
  xaxis = list(
    titlefont = list(size = 18),
    tickfont = list(size = 21),
    title = list(text='<b>Year of publication</b>', standoff = 20),
    dtick = 2
  ),
  yaxis = list(
    titlefont = list(size = 18),
    tickfont = list(size = 21),
    title = list(text = paste('<b>', ylabel, '</b>'), standoff = 20),
    range = c(0, upperlimit)
  ),
  paper_bgcolor = "#FFFFFF",
  plot_bgcolor = "#FFFFFF"
)


# Self-archiving permissions for publications without green version -------

results <- data %>%
  filter(color_green != "green") %>%
  rename(permission = is_archivable) %>%
  mutate(permission = ifelse(permission, "yes", "no")) %>%
  mutate(permission = ifelse(is.na(permission), "no data", permission)) %>%
  count(permission) %>%
  rename(count = n) %>%
  arrange(desc(count)) %>%
  mutate(lab_ypos = cumsum(count) - 0.5 * count) %>%
  mutate(publications = "")

png(here("data", "permissions.png"),
    width = 5,
    height = 4,
    units = 'in',
    res = 300)

first <- "#56B870"
second <- "#137177"
third <- "#0A2F51"

o <- ggplot(data = results, aes(x = publications, y = count)) + 
  geom_col(aes(fill = permission), width = 0.5, alpha = 0.8) +
  ggtitle("Permission to archive the postprint or published version") +
  geom_text(aes(y = lab_ypos, label = round(count, digits = 1), group=permission), color = "white") +
  ylab("Publications") + xlab("") +
  scale_fill_manual(values = c(third, second, first))

print(o)
dev.off()