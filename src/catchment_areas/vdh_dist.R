#VDH distance to NSC (nearest source of care)
#date July-08-2021

library(devtools)
library(DBI)
library(remotes)
library(dplyr)
library(stringr)  #this operates over gsub()
library(ggplot2)
library(ggpubr)
library(osrm)
library(sf)

#1) Conexion
conn <- RPostgreSQL::dbConnect(drv = RPostgreSQL::PostgreSQL(),
                               dbname = "sdad",
                               host = "postgis1",
                               port = 5432,
                               user = "cpm9w",
                               password = "cpm9w")

#2) QUERY
dat <- RPostgreSQL::dbGetQuery(
  conn = conn,
  statement = "
  SELECT *
  FROM data_commons.virginia_block_group_centroids_closest_property_pop
 ")


#original_formats
dat <- sf::st_read(
  conn, 
  query= "
    SELECT *
    FROM data_commons.virginia_block_group_centroids_closest_property_pop"
  )





#3) Disconnect
RPostgreSQL::dbDisconnect(conn)


################################################################
#Distance

require(devtools)
install_github("JanMultmeier/GeoData/GeoDataPackage")
library(GeoData)
getDist(from="1 Infinity Loop, Cupertino, CA 95014", to="1600 Amphitheatre Pkwy, Mountain View, CA 94043",modus="driving",get="distance")


############################################################
#google api key
set.api.key("AIzaSyAZqK_3BnpiZ5YKvhNmLb_5uQ-StUenkMM")
############################################################

#localtion of HOSPITALS
#2) QUERY
hosp <- RPostgreSQL::dbGetQuery(
  conn = conn,
  statement = "
  SELECT *
  FROM data_commons.us_hospitals
  WHERE state = 'VA'
 ")

names(hosp)

#format: longitude, latitude

pos1 <- c(dat$closest_property_lon[1], dat$closest_property_lat[1])
hosp_arl <- c( hosp$longitude[1], hosp$latitude[1])



dist_hosp <- osrmRoute(src = pos1,
                     dst = hosp_arl,
                     overview = FALSE)[2]

dist_hosp[2]

###########################################################################
dist1 <- NA


for (i in 1:nrow(hosp)) {
  
  dist1[i]<- osrmRoute(src = c(dat$closest_property_lon[1], dat$closest_property_lat[1]),
                       dst = c( hosp$longitude[i], hosp$latitude[i]),
                       overview = FALSE)[2]
  
}
###########################################################################

###########################################################################
dist1 <- NA
min_each_centroid <- NA

for (j in 1:nrow(dat)) {
  
  for (i in 1:nrow(hosp)) {
    
    dist1[i]<- osrmRoute(src = c(dat$closest_property_lon[1], dat$closest_property_lat[1]),
                         dst = c( hosp$longitude[i], hosp$latitude[i]),
                         overview = FALSE)[2]
  }
  
  min_each_centroid[j] <- min(dist1)
  
}



###########################################################################
#lab 
###########################################################################

dist1 <- c()
min_each_centroid <- c()

for (j in 1:3 ) {
  
  for (i in 1:nrow(hosp)) {
    
    dist1[i]<- osrmRoute(src = c(dat$closest_property_lon[i], dat$closest_property_lat[i]),
                         dst = c( hosp$longitude[j], hosp$latitude[j]),
                         overview = FALSE)[2]
  }
  
  min_each_centroid[j] <- min(dist1)
  
  out <- paste0("iteration i", i, "-", "iteration j", j, "." )  
  print(out) 
  
  
}

matrix(NA, nrow = 3, ncol = 1)