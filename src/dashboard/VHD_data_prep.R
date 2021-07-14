# Convert VA Health Districts to sf and merge with health district data

library(sf)
library(dplyr)
library(readr)


# DATA INGESTION ------------------------------

# read in shapefile

vhd <- st_read("./data/VDH_Health_Districts/geo_export_779d2774-2ad5-42e5-811d-8c3c8ea34e4f.shp")
vhd <- st_transform(vhd, 4326)

class(vhd)


# get data on Rivanna from Eric

df <- readRDS('./data/dashboard_hd_data_07122021.rds')


# MERGE ---------------------------------------

setequal(vhd$vdh_hd, df$health_district) # FALSE

setdiff(vhd$vdh_hd, df$health_district) # "Roanoke City", "Rappahannock/Rapidan", "Rappahannock Area", 
                                        # "Pittsylvania/Danville"
setdiff(df$health_district, vhd$vdh_hd) # "Pittsylvania-Danville", "Rappahannock", 
                                        # "Rappahannock Rapidan", "Roanoke" 

vhd[vhd$vdh_hd == 'Roanoke City', 'vdh_hd'] <- "Roanoke"
vhd[vhd$vdh_hd == 'Rappahannock/Rapidan', 'vdh_hd'] <- "Rappahannock Rapidan"
vhd[vhd$vdh_hd == 'Rappahannock Area', 'vdh_hd'] <- "Rappahannock"
vhd[vhd$vdh_hd == 'Pittsylvania/Danville', 'vdh_hd'] <- "Pittsylvania-Danville"


vhd_data <- merge(df, vhd[, c(1,4,5)], by.x = "health_district", by.y = "vdh_hd", all.x = TRUE)


# RANDOM COMPOSITE DATA -----------------------

vhd_data$health_access <- runif(n=nrow(vhd_data), min=0, max=1)

vhd_data$year <- as.factor(vhd_data$year)

vhd_data <- st_as_sf(vhd_data)
vhd_data <- st_transform(vhd_data, 4326) # converts to WGS84


# WRITE -------------------------------------------

write_rds(vhd_data, './src/dashboard/app/health_district_data.rds')


