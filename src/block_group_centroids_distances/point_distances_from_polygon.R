library(sf)
library(RPostgreSQL)

con <- dbConnect(
  drv = PostgreSQL(),
  dbname = "sdad",
  host = "postgis1",
  port = "5432",
  user = Sys.getenv("db_usr"),
  password = Sys.getenv("db_pwd")
)

# select and combine two block groups
bg <- st_read(con, query = "select * from gis_census_cb.cb_2018_51_bg_500k where \"GEOID\" = '510131001002' or \"GEOID\" = '510131001003'")

# transform to a CRS that uses meters
bg_26918 <- st_transform(bg, 26918)

# combine the block groups to create a single custom multipolyon shape
bg_26918_combined <- st_as_sf(data.frame(st_combine(bg_26918$geometry)))

# create new multilinestring geometry (the boundary) from the multipolygon
bg_26918_combined$boundary_geom <- sf::st_union(sf::st_boundary(bg_26918_combined))

# plot he new geometry (boundary)
plot(bg_26918_combined$boundary_geom)

# get some properties in a neighboring block group
props <- st_read(con, query = "select * from corelogic_usda.current_tax_200627_latest_all_add_vars_add_progs_geom_blk where geoid_cnty = '51013' and geoid_blk like '510131001004%' limit 10")
dbDisconnect(con)

# transform to same CRS that uses meters
props_26918 <- st_transform(props, 26918)

# plot the points over the shape plot
plot(st_geometry(props_26918), add = T)

# get the distances of each property from the shape
dists <- st_distance(bg_26918_combined$boundary_geom, props_26918$geometry)[1,]

dists

# Units: [m]
# [1]  69.60009  59.62456  31.45467  31.41642 120.91201 121.49115 123.16128  93.95583 233.07422 122.85216

