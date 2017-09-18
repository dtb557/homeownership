library(ripums)
library(tidyverse)

usa_ddi <- read_ipums_ddi("original_data/usa_00008.xml")

d <- read_ipums_micro(usa_ddi, n_max = 30000)
