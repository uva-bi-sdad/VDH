#Spatial access models 

#load data
va_access_geo_sf <- read_rds("~/VDH/va_access_geo_sf")

#map view format
tmap_mode("view")

#1) FCA - Floating Catchment Area
fca<- tm_shape(va_access_geo_sf) +
  tm_polygons(col = "fca_doc", midpoint = 0)+
  tm_scale_bar(position = c("left", "bottom"))+
  tmap_options(check.and.fix = TRUE) 

fca 

#2) 2FCA - 2 Step Floating Catchment Area 
twofca <- tm_shape(va_access_geo_sf) +
  tm_polygons(col = "2sfca_doc", midpoint = 0)+
  tm_scale_bar(position = c("left", "bottom"))+
  tmap_options(check.and.fix = TRUE) 

twofca

#3) E2FCA - Enhanced 2 Step Floating Catchment Area
e2fca <- tm_shape(va_access_geo_sf) +
  tm_polygons(col = "2sfca30_doc", midpoint = 0)+
  tm_scale_bar(position = c("left", "bottom"))+
  tmap_options(check.and.fix = TRUE) 

e2fca

#3) 3FCA - 3 Step Floating Catchment Area
threefca <- tm_shape(va_access_geo_sf) +
  tm_polygons(col = "3sfca_doc", midpoint = 0)+
  tm_scale_bar(position = c("left", "bottom"))+
  tmap_options(check.and.fix = TRUE) 

threefca
