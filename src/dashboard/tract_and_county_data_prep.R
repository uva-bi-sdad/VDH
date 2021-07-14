# modify prototype dataset

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(sf)
library(tabulizer)

#
# tract level data -----------------------------------------------
#

#df <- readRDS("../../data/dashboard_data_06172021.rds")
df <- readRDS("../../../data/dashboard_tract_data_06292021.rds")

df <- df %>%
  separate(col = 'area_name', into = c('tract_name', 'county_name', 'state_name'), sep = ', ' )

df$county_name <- gsub("County", "", df$county_name, fixed = TRUE)
df$county_name <- str_trim(df$county_name, side = 'both')

# add random data for composite index

df$health_access <- runif(n=nrow(df), min=0, max=1)

df$year <- as.factor(df$year)

df <- df %>%
  rename(census_tract_fips = tract_id)

df <- st_as_sf(df)
df <- st_transform(df, 4326) # converts to WGS84


write_rds(df, "tract_prototype_data.rds")


#
# county level data -------------------------------------------------------------------
#

df <- readRDS("../../data/dashboard_county_data_06292021.rds")

df <- df %>%
  separate(col = 'area_name', into = c('county_name', 'state_name'), sep = ', ' )

df$county_name <- gsub("County", "", df$county_name, fixed = TRUE)
df$county_name <- str_trim(df$county_name, side = 'both')

# add random data for composite index

df$health_access <- runif(n=nrow(df), min=0, max=1)

df$year <- as.factor(df$year)

# read in health district data by county - pdf from VDH website. copied and pasted to Word to Excel

hd <- read_csv("VDH_by_County.csv")
hd$CountyFIPS <- as.character(hd$CountyFIPS)

# merge health district for each county into county dataset

df_w_hd <- merge(df, hd[ , c(2,3)], by.x = 'county_id', by.y = 'CountyFIPS', all.x = TRUE)

df_w_hd <- st_as_sf(df_w_hd)
df_w_hd <- st_transform(df_w_hd, 4326) # converts to WGS84


write_rds(df_w_hd, "app/county_data.rds")
