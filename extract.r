library(magrittr)
library(purrr)
library(readr)
# install.packages("rJava")
# remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))
library(tabulizer)

files = list.files("data/raw", pattern = "\\.pdf$", full.names = TRUE)

dfs = files %>%
  purrr::map(tabulizer::extract_tables, output = "data.frame") %>%
  purrr::map(purrr::pluck, 1)

new_files = files %>%
  tools::file_path_sans_ext() %>%
  basename() %>%
  paste0("data/staging/", ., ".csv")

purrr::walk2(dfs, new_files, write_csv)
