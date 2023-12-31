.DEFAULT_GOAL = help
R := Rscript --vanilla

## Usage: make [command or target]
## Commands:

.PHONY: all
##     all                                     Build all targets.
all: raw data/final/fatalities_2014-2022.csv

.PHONY: clean
##     clean                                   Delete all built targets.
clean:
	rm -rf data/staging/* data/final/*

.PHONY: help
##     help                                    (Default.) Print this message and exit.
help: Makefile
	@sed -n 's/^##//p' $<

.PHONY: raw_data
##     raw_data                                Extract raw data tables from PDF reports.
raw_data: extract.r
	$(R) $<

.PHONY: final_data
##    final_data                               Build final data tables for analysis.
final_data: main.r
	$(R) $<

