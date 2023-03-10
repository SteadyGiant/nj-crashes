library(dplyr)
library(readr)
library(tidycensus)

options(scipen = 999)

tidycensus::census_api_key(Sys.getenv("CENSUS_API_KEY"))

fat = readr::read_csv("data/staging/ptccr_22.csv") %>%
  dplyr::mutate(`Cyclist/Pedestrian Fatalities (2022)` = Pedalcyclist + Pedestrian) %>%
  dplyr::select(County, `Cyclist/Pedestrian Fatalities (2022)`, `Total Fatalities (2022)` = Fatalities)

state_pop = pop = tidycensus::get_decennial(
  geography = "state", variables = "P1_001N", year = 2020, sumfile = "pl", state = "NJ"
) %>%
  dplyr::mutate(NAME = dplyr::case_match(NAME, "New Jersey" ~ "Total")) %>%
  dplyr::select(GEOID, County = NAME, `Population (2020)` = value)

county_pop = tidycensus::get_decennial(
  geography = "county", variables = "P1_001N", year = 2020, sumfile = "pl", state = "NJ"
) %>%
  dplyr::mutate(County = gsub(" County, New Jersey", "", NAME)) %>%
  dplyr::select(GEOID, County, `Population (2020)` = value) %>%
  dplyr::union(state_pop) %>%
  dplyr::left_join(fat, by = "County") %>%
  dplyr::mutate(
    `Cyclist/Pedestrian Fatality Rate` = (`Cyclist/Pedestrian Fatalities (2022)` / `Population (2020)`) * 100000,
    `Fatality Rate` = (`Total Fatalities (2022)` / `Population (2020)`) * 100000
  ) %>%
  dplyr::arrange(dplyr::desc(`Fatality Rate`))

readr::write_csv(county_pop, "data/final/fatalities_2022.csv")
