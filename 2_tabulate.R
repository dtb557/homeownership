library(data.table)

load("1_homeown_race_sex.Rdata")

d[ , URBAN := factor(URBAN, levels=c(1,2), 
    labels=c("Rural", "Urban"))]
d[ , FARM := factor(FARM, levels=c(1,2), 
    labels=c("Non-Farm", "Farm"))]
d[ , OWNERSHP := factor(OWNERSHP, levels=c(1,2), 
    labels=c("Owned or being bought (loan)", 
             "Rented"))]
d[ , FREE_AND_CLEAR := MORTGAGE == 1]
d[ , SEX := factor(SEX, levels=c(1,2), 
    labels=c("Male", "Female"))]
d[ ,  RACE := factor(RACE, levels=1:9, 
    labels=c("White", "Black/Negro", 
             "American Indian or Alaska Native", 
             "Chinese", "Japanese", 
             "Other Asian or Pacific Islander", 
             "Other race, nec", "Two major races", 
             "Three or more major races"))]

setkey(d, YEAR, RACE, SEX, URBAN, FARM, STATEFIP)

out <- d[ , .(own=sum(PERWT*(OWNERSHP=="Owned or being bought (loan)"), na.rm=TRUE), 
              free_and_clear=sum(PERWT*FREE_AND_CLEAR, na.rm=TRUE), 
              group_n=sum(PERWT)), by=key(d)]

write.csv(out, "2_homeownership_by_race_sex_urban_farm.csv", row.names=FALSE)
