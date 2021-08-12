# Create random data for each census-tract in VA.  This will be used for a mock-up of the VDH 
# data commons dashboard

library(readr)
library(dplyr)
library(tigris)
library(leaflet)
library(sf)

#
# Get Virginia (FIPS 51) Geometry data -------------------------------------------
#

tract_data <- tracts(state = 'VA', cb = TRUE)
tract_data <- st_transform(tract_data, 4326) # converts to WGS84

cty_data <- counties(state = 'VA', cb = TRUE)
cty_data <- st_transform(cty_data, 4326) # converts to WGS84

cty_names <- cty_data %>%
  select(COUNTYFP, NAME)

cty_names$geometry <- NULL

tract_data <- merge(tract_data, cty_names, by='COUNTYFP', all.x = TRUE)

tract_data <- tract_data %>%
  rename(NAME_TRACT = NAME.x,
         NAME_COUNTY = NAME.y)

# #test
# leaflet(data2) %>%
#   addTiles() %>%
#   addPolygons(popup = ~NAMELSAD)


#
# add random tract_data --------------------------------------------------------------
#

#Columns will be health_access_20YY, m1_20YY, m2_20YY, m3_20YY, m4_20YY

# composite variables
for(i in 2017:2019)
{
  s <- paste0("health_access_", i)
  tract_data[ ,s] <- runif(n=nrow(tract_data), min=0, max=1)
}

# measure variables
for(i in 1:4)
{
  for(j in 2017:2019)
  {
    s <- paste0("m", i, "_", j)
    tract_data[ ,s] <- runif(n=nrow(tract_data), min=0, max=1)
  }
}


#
# add random composite county data ------------------------------
#

#Columns will be health_access_20YY, m1_20YY, m2_20YY, m3_20YY, m4_20YY

# composite variables
for(i in 2017:2019)
{
  s <- paste0("health_access_", i)
  cty_data[ ,s] <- runif(n=nrow(cty_data), min=0, max=1)
}


#
# write data
#

write_rds(tract_data, "test_tract_data.rds")
write_rds(cty_data, "test_cty_data.rds")

