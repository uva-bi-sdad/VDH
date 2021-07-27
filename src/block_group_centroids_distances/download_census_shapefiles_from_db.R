library(sf)

# load helper functions, including database connection function
source("src/helper_functions.R")

# create database connection
# get_db_conn() assumes you have db_usr = "your db username" db_pwd = "your db password" set in a .Renviron file in your home directory
# other wise, you will need to add those like get_db_conn(db_usr = "your db username", db_pwd = "your db password") BUT DON'T LEAVE THESE IN CODE! CREATE A .Renviron file!
con <- get_db_conn()

# Get U.S. Counties and limit to Virginia
us_county_shp <- st_read(con, c("gis_census_cb", "cb_2016_us_county_500k"))
va_county_shp <- us_county_shp[us_county_shp$STATEFP == "51",]

# Get Virginia Census Tracts
va_tract_shp <- st_read(con, c("gis_census_cb", "cb_2018_51_tract_500k"))

# disconnect from database
dbDisconnect(con)

# Take a look!
plot(st_geometry(va_county_shp))
plot(st_geometry(va_tract_shp))
