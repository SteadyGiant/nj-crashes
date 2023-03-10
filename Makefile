.DEFAULT_GOAL = help
R := Rscript --vanilla

## Usage: make [command or target]
## Commands:

.PHONY: all
##     all                                     Build all targets.
all: data/staging/ptccr_22.csv data/final/fatalities_2022.csv

.PHONY: clean
##     clean                                   Delete all built targets.
clean:
	rm -rf data/staging/* data/final/*

.PHONY: help
##     help                                    (Default.) Print this message and exit.
help: Makefile
	@sed -n 's/^##//p' $<

## Targets:

##     data/staging/ptccr_22.csv               Extract raw data table from PDF report.
data/staging/ptccr_22.csv: extract.r data/raw/ptccr_22.pdf
	$(R) $<

##     data/final/fatalities_2022.csv          Final dataset for analysis.
data/final/fatalities_2022.csv: main.r data/staging/ptccr_22.csv
	$(R) $<
