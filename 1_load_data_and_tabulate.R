library(ripums)
library(tidyverse)
library(Hmisc)


# Parameters for testing --------------------------------------------------

N_MAX <- Inf
TEST_DDI_FILE <- "usa_00009.xml"
TESTING <- FALSE


# Directories -------------------------------------------------------------
DATA_DIR <- "original_data"


# Files -------------------------------------------------------------------
DDI_FILE <- "usa_00008.xml"
OUT_FILE_PATTERN <- "1_homeownership_by_group_%s.csv"


# Load data ---------------------------------------------------------------

usa_ddi <- read_ipums_ddi(
    file.path(
        DATA_DIR,
        ifelse(TESTING, TEST_DDI_FILE, DDI_FILE)
    )
)

d <- read_ipums_micro(usa_ddi, n_max = N_MAX)

if(TESTING) {
    d <- d %>%
        slice(
            sample(
                1:nrow(d), 
                5e4
            )
        )
}

# Consumer price index ----------------------------------------------------

# Source: https://www2.census.gov/library/publications/1975/compendia/hist_stats_colonial-1970/hist_stats_colonial-1970p1-chE.pdf, page 210, Series E 135-166. 1967 dollars = 100
# 2016 value comes from: https://data.bls.gov/pdq/SurveyOutputServlet

cpi <- c(
  "1860" = 27, 
  "1870" = 38, 
  "1880" = 29, 
  "1890" = 27, # Note: 1890 is NA, but 1889 and 1891 equal 27
  "1900" = 25, 
  "1910" = 28, 
  "1920" = 60.0, 
  "1930" = 50.0, 
  "1940" = 42.0, 
  "1950" = 72.1, 
  "1960" = 88.7, 
  "1970" = 116.3, 
  "2016" = 719.0
)

cpi_2016 <- 100 * cpi / cpi["2016"]


# Make reports ------------------------------------------------------------

make_report <- function(data) {
    data %>%
        group_by(YEAR, RACE, SEX, URBAN, FARM, STATEFIP) %>%
        summarise(
            n_own = sum(PERWT * (OWNERSHP == "Owned or being bought (loan)"), na.rm=TRUE), 
            n_free_and_clear = sum(PERWT * FREE_AND_CLEAR, na.rm=TRUE), 
            n_group = sum(PERWT), 
            avg_value = Hmisc::wtd.mean(
                VALUEH, 
                PERWT
            ), 
            avg_value_2016_dollars = Hmisc::wtd.mean(
                VALUEH_2016_dollars, 
                PERWT
            )
        ) %>%
        mutate(
            pct_own = 100 * n_own / n_group, 
            pct_free_and_clear = 100 * n_free_and_clear / n_group
        )
}

d <- d %>%
    mutate_if(is.labelled, as_factor) %>%
    mutate(VALUEH = VALUEH %>%
               as.character(.) %>%
               as.numeric(.) # This step coerces all special values to NA
    ) %>%
    mutate(VALUEH = ifelse(OWNERSHP == "Rented", NA, VALUEH)) %>%
    mutate(VALUEH_2016_dollars = 100 * VALUEH / cpi_2016[as.character(YEAR)]) %>%
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
