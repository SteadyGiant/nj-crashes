library(readr)
# install.packages("rJava")
# remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))
library(tabulizer)

tbl = tabulizer::extract_tables("data/raw/ptccr_22.pdf", output = "data.frame")
readr::write_csv(tbl[[1]], "data/staging/ptccr_22.csv")
