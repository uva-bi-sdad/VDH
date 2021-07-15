library(dplyr)
library(tibble)
library(tidygeocoder)
library(RPostgreSQL)
source("src/helper_functions.R")

# create a dataframe with addresses
some_addresses <- tribble(
  ~name,                  ~addr,
  "White House",          "1600 Pennsylvania Ave NW, Washington, DC",
  "Transamerica Pyramid", "600 Montgomery St, San Francisco, CA 94111",     
  "Willis Tower",         "233 S Wacker Dr, Chicago, IL 60606"                                  
)

con <- get_db_conn()
test_records <- dbGetQuery(con, "SELECT * FROM data_commons.virginia_primary_care_doctors LIMIT 10")
dbDisconnect(con)

test_addrs <- as_tibble(test_records[, c("name", "address")])

# geocode the addresses
lat_longs <- test_addrs %>%
  geocode(address, 
          method = 'geocodio', 
          lat = latitude , 
          long = longitude, 
          full_results = TRUE, 
          verbose = T, 
          custom_query = list(fields = 'census2020'))
