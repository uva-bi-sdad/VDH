source("src/helper_functions.R")
library(sf)
library(spatialrisk)

### NOT WORKING YET

con <- get_db_conn()

a_property <- st_read(con, query = "select * from data_commons.virginia_block_group_centroids_closest_property_pop limit 1")

prop_lon <- a_property$closest_property_lon[[1]]
prop_lat <- a_property$closest_property_lat[[1]]


other_properties <- st_read(con, query = "select * from data_commons.virginia_block_group_centroids_closest_property_pop offset 1 limit 200")

dbDisconnect(con)

op <- other_properties[, c("closest_property_lon", "closest_property_lat")]
op$bg_ctr_geom <- NULL
colnames(op) <- c("lon", "lat")
points_in_circle(data = op, lon_center = prop_lon, lat_center = prop_lat, radius = 2000)

