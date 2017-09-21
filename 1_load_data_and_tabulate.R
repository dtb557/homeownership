library(ripums)
library(tidyverse)


# Parameters for testing --------------------------------------------------

N_MAX <- Inf


# Directories -------------------------------------------------------------
DATA_DIR <- "original_data"


# Files -------------------------------------------------------------------
DDI_FILE <- "usa_00008.xml"
OUT_FILE_PATTERN <- "1_homeownership_by_group_%s.csv"


# Load data ---------------------------------------------------------------

usa_ddi <- read_ipums_ddi(
    file.path(
        DATA_DIR,
        DDI_FILE
    )
)

d <- read_ipums_micro(usa_ddi, n_max = N_MAX)


# Make reports ------------------------------------------------------------

make_report <- function(data) {
    data %>%
        group_by(YEAR, RACE, SEX, URBAN, FARM, STATEFIP) %>%
        summarise(
            n_own = sum(PERWT * (OWNERSHP == "Owned or being bought (loan)"), na.rm=TRUE), 
            n_free_and_clear = sum(PERWT * FREE_AND_CLEAR, na.rm=TRUE), 
            n_group = sum(PERWT)
        ) %>%
        mutate(
            pct_own = 100 * n_own / n_group, 
            pct_free_and_clear = 100 * n_free_and_clear / n_group
        )
}

d <- d %>%
    mutate_if(is.labelled, as_factor) %>%
    mutate(HH_HEAD = RELATE == "Head/Householder") %>%
    mutate(FREE_AND_CLEAR = MORTGAGE == "No, owned free and clear")
    
d %>%
    make_report() %>%
    write_csv(
        sprintf(
            OUT_FILE_PATTERN, 
            "all_individuals"
        )
    )
    
d %>%
    filter(HH_HEAD) %>%
    make_report() %>%
    write_csv(
        sprintf(
            OUT_FILE_PATTERN, 
            "hh_heads_only"
        )
    )
