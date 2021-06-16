# modify prototype dataset

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(sf)

df <- readRDS("../../data/dashboard_data_06172021.rds")

df <- df %>%
  separate(col = 'area_name', into = c('tract_name', 'county_name', 'state_name'), sep = ', ' )

df$county_name <- gsub("County", "", df$county_name, fixed = TRUE)
df$county_name <- str_trim(df$county_name, side = 'both')

# add random data for composite index

df$health_access <- runif(n=nrow(df), min=0, max=1)

df$year <- as.factor(df$year)

df <- st_as_sf(df)
df <- st_transform(df, 4326) # converts to WGS84


write_rds(df, "prototype_data.rds")

