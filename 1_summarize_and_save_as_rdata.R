library(data.table)

d <- data.table(read.csv("original_data/usa_00006.csv"))

save(d, file="1_homeown_race_sex.Rdata")

# load("homeown_race_sex.Rdata")

summary(d)
