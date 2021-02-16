# Adapted from Maia Salholz-Hillel (https://github.com/maia-sh/trn-pop/blob/master/R/environment.R)

# Install and load packages for R scripts -----------------------------------------------

cran_pkgs <- c(

  # config
  "ConfigParser",
  
  # General
  "dplyr", "tidyr", "stringr", "readr", "here", "tibble",
  
  # Data visualization
  "gridExtra", "ggvis", "ggplot2"
)


to_install <- cran_pkgs[!cran_pkgs %in% installed.packages()]

if (length(to_install) > 0) {
  install.packages(to_install, deps = TRUE, repos = "https://cran.r-project.org")
}

# non-CRAN packages
if (!"unpaywallR" %in% installed.packages()) {
  devtools::install_github("NicoRiedel/unpaywallR")
}

invisible(lapply(c(cran_pkgs), library, character.only = TRUE))


# Specify configuration  -----------------------------------------------
cfg <- ConfigParser$new()
cfg$read("config.ini")

# Specify data directory
data_dir <- cfg$get("data", NA, "paths")

# Specify email
email_api <- cfg$get("email", NA, "login")
