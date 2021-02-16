#based on Nico Riedel's scripts in https://codeberg.org/QUEST/responsible-metrics/src/branch/master/shiny-app

source(here::here("scripts", "environment.R"))

filename <- "2021-02-16_berlin-2018-oa.csv"

data <- read_csv(file.path(data_dir, filename), col_types = "ccdddcccccdccccdlllllcccccD") %>%
  rename(year = year_published) %>%
  mutate(color = if_else(is.na(color), "unknown", color)) %>%
  mutate(color = if_else(color == "bronze", "closed", color))

n_publications <- data %>%
  summarise(publications = n())

print(paste0("Number of publications: ", n_publications))

data$city <- sub("berlin", "charite", data$city)

OA_data <- data %>%
  count(color, city, year) %>%
  rename(count = n)

OA_data <- OA_data[order(OA_data$city),]

cities_combined <- OA_data %>%
  group_by(color, year) %>%
  summarise(count = sum(count)) %>%
  ungroup() %>%
  add_column(city = "All cities combined")

#OA_data_combined <- rbind(OA_data, cities_combined)
OA_data_combined <- OA_data # uncomment this line and comment line above if only one city

OA_percentages <- calculate_OA_percentages(OA_data_combined)
results_table <- make_plot_data_OA(OA_percentages, TRUE, "2018")
title <- "OA status"
plot_ranking(results_table, title)

#------------------------------------------------------------------------------------------------------------------
# Open Access functions
#------------------------------------------------------------------------------------------------------------------

#calculate main result number
calc_main_result_OA <- function(input_table)
{
  results_table <- make_plot_data_OA(input_table, FALSE, "18")
  percentage <- (results_table %>% filter(city == "All cities combined"))[["percent"]]
  percentage <- round(percentage * 100, 0)

  return(percentage)
}


#arranges OA data for plotting
make_plot_data_OA <- function(plot_data, show_OA_colors, input_year)
{
  plot_data <- plot_data %>%
    filter_data_OA(input_year) %>%
    rank_cities_OA() %>%
    set_OA_colors(show_OA_colors) %>%
    add_plot_data_modifications_OA()

  return(plot_data)
}


filter_data_OA <- function(plot_data, input_year)
{
  plot_data <- plot_data %>%
    filter(year == input_year)

  return(plot_data)
}


set_OA_colors <- function(plot_data, show_OA_colors)
{
  col_list <- c("#f7be16", "#008950", "#410b5b", "FF6666", "A0A0A0", "#73706f")

  if(show_OA_colors) {
    plot_data <- plot_data %>%
      filter(color != "all_OA") %>%
      arrange(color)

    plot_data$bar_col <- OA_color_to_rgb(plot_data$color)

    plot_data$bar_col <- factor(plot_data$bar_col, levels = col_list)

  } else {
    plot_data <- plot_data %>%
      filter(color == "all_OA")

    plot_data$bar_col <- ifelse(plot_data$city == "All cities combined", "#e9a602", "#90B2C4") # #E97F02
  }

  return(plot_data)
}


rank_cities_OA <- function(plot_data)
{
  OA_ranking <- plot_data %>%
    filter(color == "all_OA") %>%
    arrange(desc(percent)) %>%
    add_column(ranking = 1:length(unique(plot_data$city))) %>%
    select(city, ranking)

  plot_data <- plot_data %>%
    left_join(OA_ranking)

  plot_data <- plot_data %>%
    arrange(ranking)

  return(plot_data)
}


add_plot_data_modifications_OA <- function(plot_data)
{
  #modifications specific for plotting
  plot_data$city <- factor(plot_data$city, levels = unique(plot_data$city))
  plot_data$id = 1:dim(plot_data)[1]
  plot_data$tooltip <- as.character(paste0("<b>", plot_data$city, "</b><br>",
                                           plot_data$OA, " ", plot_data$color , " Open Access publications <br>",
                                           plot_data$all, " total publications"))
  return(plot_data)
}


OA_color_to_rgb <- function(color_vec)
{
  col_list <- c("#f7be16", "#008950", "#410b5b", "FF6666", "A0A0A0", "#73706f")
  names(col_list) <- c("gold", "green", "hybrid", "bronze", "closed", "unknown")

  return(col_list[color_vec])
}

#------------------------------------------------------------------------------------------------------------------
# Open Access data loading & preprocessing functions
#------------------------------------------------------------------------------------------------------------------

calculate_OA_percentages <- function(OA_data)
{
  #number of publications
  publ_all <- OA_data %>%
    #filter(color != "unknown") %>%
    group_by(city, year) %>%
    summarise(all = sum(count))

  #number of publ in all OA categories
  publ_OA <- OA_data %>%
    filter(color %in% c("gold", "green", "hybrid", "bronze", "closed", "unknown")) %>%
    group_by(city, year) %>%
    summarise(OA = sum(count))

  publ_OA_colors <- OA_data %>%
    filter(color %in% c("gold", "green", "hybrid", "bronze", "closed", "unknown")) %>%
    group_by(city, color, year) %>%
    summarise(OA = sum(count))

  #OA percentages
  OA_perc <- publ_OA %>%
    left_join(publ_all) %>%
    mutate(percent = OA/all) %>%
    add_column(color = "all_OA") %>%
    ungroup()

  OA_perc_colors <- publ_OA_colors %>%
    left_join(publ_all) %>%
    mutate(percent = OA/all) %>%
    ungroup()

  OA_perc <- rbind(OA_perc, OA_perc_colors)

  return(OA_perc)
}

#--------------------------------------------------------------------------------------------------
# Code for plotting ranking bar & line graphs
#--------------------------------------------------------------------------------------------------

plot_ranking <- function(plot_data, y_title)
{
  plot_result <- plot_data %>%
    ggvis(x=~city, y=~percent) %>%
    layer_bars(fill :=~bar_col, stroke := "#3C5D70", fillOpacity := 0.5, fillOpacity.hover := 0.8,
               key := ~tooltip, width = 0.8) %>%
    hide_legend("fill") %>%
    add_axis("x", title = "",
             properties = axis_props(
               labels = list(angle = -90, align = "right", baseline = "middle", fontSize = 15))) %>%
    add_axis("y", title = y_title, title_offset = 60,
             format = "%",
             properties = axis_props(
               labels = list(fontSize = 14),
               title = list(fontSize = 16))) %>%
    add_tooltip(function(data){
      as.character(data$tooltip)
    }, "hover") %>%
    set_options(width = 1000, height = 650) %>%
    scale_numeric("y", domain = c(0, 1))

  return(plot_result)
}



