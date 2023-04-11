library(dplyr)
library(readr)
library(tidycensus)

options(scipen = 999)

tidycensus::census_api_key(Sys.getenv("CENSUS_API_KEY"))

files = list.files("data/staging", pattern = "^ptccr_[0-9]{2}\\.csv$", full.names = TRUE)
years = files %>%
  stringr::str_extract("[0-9]{2}") %>%
  paste0("20", .)
names(files) = years
fat = purrr::map_dfr(files, readr::read_csv, .id = "Year") %>%
  dplyr::select(Year, County, Fatalities) %>%
  dplyr::arrange(County, Year)

# Latest available year for VMT data.
vmt = readr::read_csv("data/hand/daily_vmt_by_county_2021.csv") %>%
  dplyr::select(County, `Daily VMT (2021)` = `Daily VMT`)

state_pop = pop = tidycensus::get_decennial(
  geography = "state", variables = "P1_001N", year = 2020, sumfile = "pl", state = "NJ"
) %>%
  dplyr::mutate(NAME = dplyr::case_match(NAME, "New Jersey" ~ "Total")) %>%
  dplyr::select(FIPS = GEOID, County = NAME, `Population (2020)` = value)

# Latest available year for _credible_ population data.
county_pop = tidycensus::get_decennial(
  geography = "county", variables = "P1_001N", year = 2020, sumfile = "pl", state = "NJ"
) %>%
  dplyr::mutate(County = gsub(" County, New Jersey", "", NAME)) %>%
  dplyr::select(FIPS = GEOID, County, `Population (2020)` = value) %>%
  dplyr::union(state_pop) %>%
  dplyr::left_join(fat, by = "County") %>%
  # Latest available year for fatalities data.
  dplyr::filter(Year == 2022) %>%
  dplyr::select(-Year) %>%
  dplyr::rename(`Fatalities (2022)` = Fatalities) %>%
  dplyr::left_join(vmt, by = "County") %>%
  dplyr::mutate(
    `Fatalities per 100k pop` = (`Fatalities (2022)` / `Population (2020)`) * 100000,
    `Fatalities per 1M VMT` = (`Fatalities (2022)` / `Daily VMT (2021)`) * 1000000
  ) %>%
  dplyr::arrange(dplyr::desc(`Fatalities per 100k pop`))

readr::write_csv(fat, "data/final/fatalities_2014-2022.csv")
readr::write_csv(county_pop, "data/final/fatality_rates_2021.csv")
