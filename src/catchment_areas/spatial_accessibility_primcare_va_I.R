#SPATIAL ACCESSIBILITY - HEALTH SERVICES 
#Detail: census block group
#State: VA

###############################################################################################
#libraries
###############################################################################################
#Installing and loading packages
# install.packages("matrixStats")
# install.packages("SpatialAcc")

library(sf)
library(tidyverse)
library(tmap)
library(tidycensus)
library(tigris)
library(matrixStats)
library(SpatialAcc)
library(geojsonio)
library(rmapshaper)
library(sp)
library(ggplot2)
library(plotly)


#reference: https://crd230.github.io/lab5a.html#read-in-the-bank-data

###############################################################################################
#Read in census tract data
###############################################################################################

#load in your Census API Key
census_api_key("eba406410c653b81d6a795ac4e989221f7bdf302")

# Bring in census tract data. 
va.tracts.bg <- get_acs(geography = "block group", 
                        year = 2019,
                        variables = c(tpop = "B01003_001E"
                                      , tpopr = "B03002_001E",
                                      nhwhite = "B03002_003E", nhblk = "B03002_004E",
                                      nhasn = "B03002_006E", hisp = "B03002_012E",
                                      medinc = "B19013_001E"
                        ),
                        state = "VA",
                        survey = "acs5",
                        output = "wide",
                        geometry = TRUE)

#open name to separate county names
va.tracts.bg <- separate(va.tracts.bg, NAME, c("bgroup", "ctract", "county", "state"), sep = ",")

# Make the data tidy, calculate percent race/ethnicity, and keep essential vars.
va.tracts <- va.tracts.bg %>% 
  mutate(pnhwhite = nhwhite/tpopr, pnhasn = nhasn/tpopr, 
         pnhblk = nhblk/tpopr, phisp = hisp/tpopr, county=county) %>%
  rename(tpop = tpop, medinc = medinc) %>%
  dplyr::select(c(GEOID,tpop, pnhwhite, pnhasn, pnhblk, phisp, medinc, county))  

# Bring in city boundary data in VA
va.bg <- block_groups(state = "VA", year = 2019, cb = TRUE)


#Clip tracts using VA boundary
va.bg.tracts <- ms_clip(target = va.tracts, clip = va.bg, remove_slivers = TRUE)

#reproject to UTM 
va.bg.tracts.utm <-st_transform(va.bg.tracts, crs = 4326)  #4326 for whole US
#Identify invalid spherical geometry.
inv_geom <- which(st_is_valid(va.bg.tracts.utm)== "FALSE")
#1 block group has not adequate geometry.  then slice if needed
va.bg.tracts.utm <- va.bg.tracts.utm %>% slice(-c(inv_geom))


###############################################################################################
#Read in the urgent care services data
###############################################################################################
#original_formats
prim.care.va <- sf::st_read(
  conn, 
  query= "
    SELECT *
    FROM data_commons.virginia_primary_care_doctors_geolocated_blks"
)

#3) Disconnect
RPostgreSQL::dbDisconnect(conn)

#Make sure the tract and bank Coordinate Reference Systems are the same and in UTM.
st_crs(va.bg.tracts.utm)$proj4string
#st_crs(hosp_va)$proj4string
st_crs(prim.care.va)$proj4string

#FIGURE ONE: prim.care physicians 
tmap_mode("view")

prim.care <- tm_shape(va.bg.tracts.utm) +
  tm_polygons() +
  tm_shape(prim.care.va) +
  tm_dots(col = "red")+
  tm_scale_bar(position = c("left", "bottom"))+
  tmap_options(check.and.fix = TRUE) 

prim.care
###############################################################################################
#Points in Polygon
###############################################################################################
#old
va.bg.tracts.prim.care <- prim.care.va  %>% 
  st_join(va.bg.tracts.utm) %>%
  group_by(GEOID) %>% 
  summarize(prim.care.n = n()) 

#new
#1 st_join
va.bg.tracts.prim.care <- prim.care.va  %>% 
  st_join(va.bg.tracts.utm)
#2 order
va.bg.tracts.prim.care <- va.bg.tracts.prim.care[order(va.bg.tracts.prim.care$GEOID),]
#3 drop geom
va.bg.tracts.prim.care <- st_drop_geometry(va.bg.tracts.prim.care)
#4 group and summarize
va.bg.tracts.prim.care <- va.bg.tracts.prim.care %>%
  group_by(GEOID) %>% 
  summarize(prim.care.n = n()) 

##save for exercise uchi

#Now, use left_join() and assign a 0 to tracts with no banks using the replace_na() function within mutate().
va.bg.tracts.utm <- va.bg.tracts.utm %>% 
  left_join(va.bg.tracts.prim.care, by= "GEOID") %>%
  mutate( prim.care.n = replace_na(prim.care.n,0  ))

#Calculate the number of hospitals per resident population, multiplying the ratio by 10,000 to get more meaningful accessibility ratio sizes.
va.bg.tracts.utm <- va.bg.tracts.utm %>% mutate( prim.care.n.perpop = prim.care.n/tpop*10000)

# What does the distribution of this variable look like?
summary(va.bg.tracts.utm$prim.care.n.perpop) 

#Create a choropleth map of banks per 10,000 population.

#FIGURE TWO
tm_shape(va.bg.tracts.utm, unit = "mi") +
  tm_polygons(col = "prim.care.n.perpop", style = "jenks",palette = "Reds", 
              border.alpha = 0, title = "Primary Care Physicians per\n10k population") +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(main.title = "Primary Care Physicians spatial accessibility in Virginia",
            main.title.size = 0.95, frame = FALSE,
            legend.outside = TRUE, legend.outside.position = "right") 




###############################################################################################
#Point proximity buffers
###############################################################################################
#CENTROIDS  use the sf function st_centroid()
tract.centroids <- st_centroid(va.bg.tracts.utm) 

#Plot the centroids on top of the tracts so we know what we produced

tm_shape(va.bg.tracts.utm) +
  tm_polygons(col = "blue") +
  tm_shape(tract.centroids) +
  tm_dots(col = "red")

# 
# We then create circular buffers of distance r around each tract’s centroid. The size of the buffer radius depends on the 
# city you are examining and the context of your question. To start, let’s use 1-mile or 1609-meter buffers.
# We use the sf function st_buffer() to create buffers. The required arguments are your sf object and the distance dist =. 
# Remember that the units for UTM is meters, so specifying dist = 1609 means 1609 meters.

#1mile=1609 meters
dist.buffer <- 20   #in miles
tract.buff  <-st_buffer(tract.centroids, dist = 1609*dist.buffer)
#tract.buff

#And let’s map it onto tracts with the banks.

tmap_mode("view")

tm_shape(va.bg.tracts.utm) +
  tm_polygons() +
  tm_shape(tract.centroids) +
  tm_dots(size = 0.01) 

#same format for tract.buff
tract.buff.sf <- st_transform(tract.buff, crs = 4326)

#confirm same format
#prim.care.va
st_crs(prim.care.va)$proj4string
#tract.buff
st_crs(tract.buff.sf)$proj4string

#simplify db
prim.care.va <- prim.care.va %>% select(name, geometry)
tract.buff.sf <- tract.buff.sf %>% select(GEOID, tpop, county, geometry )

#old
# buff.prim.care.va <- prim.care.va  %>% 
#   st_join(tract.buff.sf) %>%
#   group_by(GEOID) %>% 
#   summarize(prim.care.10m= n()) 

###new try
buff.prim.care.va <- prim.care.va  %>% 
  st_join(tract.buff.sf) 

#write_csv(buff.prim.care.va, "~/VDH/buff.prim.care.va.exercise.csv"  )
#drop geometry
buff.prim.care.va <- st_drop_geometry(buff.prim.care.va)
#order
buff.prim.care.va <- buff.prim.care.va[order(buff.prim.care.va$GEOID),]
#estimate prim.care. in 10 miles
buff.prim.care.va <- buff.prim.care.va %>%
  group_by(GEOID) %>% 
  summarize(prim.care.10m= n()) 


#buff.prim.care.va <- buff.prim.care.va %>% select(GEOID, tpop)

#buff.prim.care.va <- buff.prim.care.va %>%
 # group_by(GEOID) %>% 
  #summarize(prim.care.10m= n()) 





########
# buff.prim.care.va <-  buff.prim.care.va %>%
#   group_by(GEOID) %>% 
#   summarize(prim.care.20m= n())


#######

#st_join() significa "distribuir en":  distribuyame las geometrias de hospitales en los buffers de los tracts. 
va.bg.tracts.utm <- va.bg.tracts.utm %>%
  left_join(buff.prim.care.va, by = "GEOID")  %>%
  mutate(prim.care.10m = replace_na(prim.care.10m, 0)) %>%
  mutate(prim.care.buff5m = (prim.care.10m/(tpop)*10000))


#We can then use summarize() to find the mean number of hospitals that occur within 1 mile of a tract.

#mean 
mean(va.bg.tracts.utm$prim.care.20m)


# There are on average 1.229 hospitals within 10 miles of tracts in block groups in VA. 
# There are on average 10.2 hospitals within 20 miles of tracts in block groups in VA.
#This is likely not representative given 
# that there are a small number of tracts with a lot of banks within a 1-mile radius, as demonstrated by the histogram 
# below. It’s common practice to test the sensitivity of your results by choosing different buffer sizes.

#Let’s create a choropleth map of banks per population within a 1-mile radius.

tmap_mode("plot")

# FIGURE THREE
tm_shape(va.bg.tracts.utm, unit = "mi") +
  tm_polygons(col = "prim.care.buff5m", style = "fisher",palette = "Reds", 
              border.alpha = 0, title = "Primary care per\n10k population") +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(main.title = "Primary Care spatial accessibility in Virginia",
            main.title.size = 0.95, frame = FALSE,
            legend.outside = TRUE, legend.outside.position = "right")+
  tm_shape(prim.care.va) +
  tm_dots(col = "blue")




###############################################################################################
#Distance to nearest hosp
###############################################################################################


# We limit ourselves a bit by capturing banks just within a radius distance. 
# Why not calculate the distance to all banks and summarize that distribution? 
#   Distance is typically measured in Euclidean distance. Euclidean distance, also referred to as straight-line distance or “as the crow flies,” 
# is the distance between two points connected by a straight line on a flat surface. To calculate the distance (in meters) 
# from each tract’s centroid to each bank we use the sf function st_distance().

prim.care.dist<-st_distance(tract.centroids, prim.care.va)

#For the object bank.dist, the rows represent the tracts and the columns are the banks. You can check this by comparing dimensions

#number of tracts is 999
dim(tract.centroids)
## [1] 999  10
#number of banks is 622
dim(prim.care.va)
## [1] 616   8
#999 by 622
dim(prim.care.dist)

# What we have with bank.dist is a distance matrix. That is, we have each tracts’s distance to each bank. 
# Note that st_distance() will calculate distance using the Coordinate Reference System’s units, in this case meters. 
# A common spatial accessibility measure is the distance to the closest amenity (e.g. nearest bank). 
# It allows one to evaluate the immediate proximity to the bank. We can use the function rowMins() in the package matrixStats to calculate the shortest distance.
# 
# The function rowMins() does exactly what you think it would do - get the minimum value across columns for each row. 
# For bank.dist, this means we get the minimum distance to a bank for each neighborhood. 
# Note that the order of tracts in bank.dist is the same as in la.city.tracts.utm. 
# Therefore, we can run rowMins() within mutate() to save the resulting value in our main data set la.city.tracts.utm.

va.bg.tracts.utm <- va.bg.tracts.utm %>%
  mutate(prim.care.dmin = rowMins(prim.care.dist))
#mutate(hospmin = (hosp.dist))


#We can use summarize() to find the mean minimum distance to banks.

#this can wait
va.bg.tracts.utm %>%
  summarize(meanmin = mean(prim.care.dmin, na.rm=TRUE)) %>%
  st_drop_geometry()

#average
mean(va.bg.tracts.utm$prim.care.dmin)


# The closest hosp to a neighborhood in Virginia is on average 8077 meters, or about 5.01 a mile.
# Let’s create a choropleth map of nearest bank distance.

tmap_mode("plot")

dist.near <- tm_shape(va.bg.tracts.utm, unit = "mi") +
  tm_polygons(col = "prim.care.dmin", style = "fisher",palette = "Reds", 
              border.alpha = 0, title = "Distance to nearest \n primary care (m)") +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(main.title = "Primary care spatial accessibility in Virginia",
            main.title.size = 0.95, frame = FALSE,
            legend.outside = TRUE, legend.outside.position = "right")+
  #tm_markers(text = "county")+
  tm_shape(prim.care.va) +
  tm_dots(col = "blue")+
  tm_scale_bar(position = c("left", "bottom"))


#interactive mode
tmap_mode("view")
dist.near



#interactive

dist.near.plot <- tm_shape(va.bg.tracts.utm, unit = "mi") +
  tm_polygons(col = "prim.care.dmin", style = "fisher",palette = "Reds", 
              border.alpha = 0, title = "Distance to nearest \nhospital (m)") +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(main.title = "Hospital spatial accessibility in Arlington",
            main.title.size = 0.95, frame = FALSE,
            legend.outside = TRUE, legend.outside.position = "right")+
  tm_shape(prim.care.va) +
  tm_dots(col = "blue")+
  tm_scale_bar(position = c("left", "bottom"))

dist.near.plot

###############################################################################################
#Floating Catchment Area
###############################################################################################

# The Floating Catchment Area (FCA) method extends the buffer approach by incorporating the demand of other nearby tracts for an amenity. 
# Similar to the basic buffer approach, FCA draws a circle (or buffer) of radius d around a tract’s centroid and defines this filtering 
# window as that location’s catchment area. In contrast to the simple buffer method, FCA accounts for not just the number of amenities 
# that fall inside the buffer, but also the centroids of other nearby tracts. The method accounts for competition for services among residents
# in other neighborhoods (competing demand).
# 
# We’ve already calculated the FCA numerator in the buffer analysis (banks1m). 
# We apply the buffer analysis to count tract centroids tract.centroids rather than banks within a 1 mile buffer of each tract tract.buff. 
# We sum up the populations of tracts

#this may take a while -  40 min aprox for 20 miles buffer
# buff.tracts <- tract.centroids  %>% 
#   select(tpop) %>% #we don't need other variables
#   st_join(tract.buff.sf) %>%
#   group_by(GEOID) %>% 
#   summarize(buffpop = sum(tpop.x)) 

############
#exercise

buff.tracts <- tract.centroids  %>% 
  select(tpop) %>% #we don't need other variables
  st_join(tract.buff.sf) 

#drop geometries
buff.tracts <- st_drop_geometry(buff.tracts )   
  
#order GEOID
buff.tracts <- buff.tracts[order(buff.tracts$GEOID),]


buff.tracts <- buff.tracts %>%
  group_by(GEOID) %>% 
  summarize(buffpop = sum(tpop.x)) 

############
# The variable buffpop in buff.tracts reflects the total population of tracts whose centroids fall into a tract’s 1-mile buffer. 
# We join this variable back into our main tibble.

# We next create the variable fca by dividing the number of banks in the buffer’s tract by the tract’s population and the population of 
# nearby tracts whose centroids fall inside the buffer. We multiply by 10,000 to make it a per 10,000 population rate.

va.bg.tracts.utm <- va.bg.tracts.utm %>%
  left_join(buff.tracts, by = "GEOID") %>%
  mutate(buffpop = replace_na(buffpop, 0)) %>%
  mutate(fca = (prim.care.10m/buffpop)*10000)

#FORTH FIGURE
fca_plot <- tm_shape(va.bg.tracts.utm, unit = "mi") +
  tm_polygons(col = "fca", style = "fisher",palette = "Reds", 
              border.alpha = 0, title = "FCA") +
  tm_scale_bar(position = c("left", "top")) +
  tm_layout(main.title = "Hospital spatial accessibility in Virginia",
            main.title.size = 0.95, frame = FALSE,
            legend.outside = TRUE, legend.outside.position = "right")+
  tm_shape(prim.care.va) +
  tm_dots(col = "blue")+
  tm_scale_bar(position = c("left", "bottom"))

fca_plot

#interactive mode
tmap_mode("view")
fca_plot
#with street map
fca_plot + tm_basemap(server = "OpenTopoMap")






###############################################################################################
#Two-step Floating Catchment Area
###############################################################################################

# The basic Floating Catchment Area method calculates access strictly from the demand (resident population) perspective. 
# The method does not take into account the service area of the supplier (bank). 
# The two-step Floating Catchment Area (2SFCA) method remedies this issue by calculating catchment areas for both supplier and consumer.
# 
# To calculate 2SFCA ratios, we use the function ac() which is part of the SpatialAcc package. 
# There are five inputs you need to supply ac(). First, a matrix of distances between tracts to banks. 
# We already did that above when we constructed bank.dist, but the resulting object is not a matrix, but has class “units”

class(hosp.dist)
# Let’s instead use the function distance() which is part of the SpatialAcc package. 
# In order to use this function, you will need to first get the coordinates of the tract centroids and banks. Use the sf function st_coordinates().

# centroid.coords <- st_coordinates(tract.centroids)
# bank.coords <- st_coordinates(banks)

centroid.coords <- st_coordinates(tract.centroids)
hosp.coords <- st_coordinates(prim.care.va)

#Then plug these into the function distance(), specifying type = "euclidean" to calculate euclidean distances.

dist.matrix <- distance(centroid.coords, hosp.coords, type = "euclidean")
class(dist.matrix)


# In addition to the distance matrix, we also need to specify measures of demand p and supply n in the function ac(). 
# The measures we’ve used so far proxy the demand for banks as total resident population. What about supply? 
#   In the basic Floating Catchment Area method, we treated every bank equally. In other words, we assumed that capacity and quality are equal across banks. 
# This is likely not true. One measure of bank capacity (less about quality) is the number of its deposits in dollars. 
# This is measured by the variable deposits in the file banks, which measures the amount of deposits in millions. 
# Plug these demand and supply values into ac() to get 2SFCA measures of accessibility.

# In addition to the distance matrix, we also need to specify measures of demand p and supply n in the function ac(). 
# The measures we’ve used so far proxy the demand for banks as total resident population. What about supply? 
#   In the basic Floating Catchment Area method, we treated every bank equally. 
# In other words, we assumed that capacity and quality are equal across banks. 
# This is likely not true. One measure of bank capacity (less about quality) is the number of its deposits in dollars. 
# This is measured by the variable deposits in the file banks, which measures the amount of deposits in millions. 
# Plug these demand and supply values into ac() to get 2SFCA measures of accessibility.


# TSFCA <- ac(p = la.city.tracts.utm$tpop, 
#             n = banks$deposits, 
#             D = dist.matrix, d0 = 1609, family = "2SFCA")

#simulate
prim.care.va$factor <- rnorm(nrow(prim.care.va), mean = 100, sd= 50)


TSFCA <- ac(p = va.bg.tracts.utm$tpop, 
            n = prim.care.va$factor, 
            #n = prim.care.va$BEDS, 
            D = dist.matrix, 
            d0 = 1609*dist.buffer, 
            family = "2SFCA")

#We also had to specify the threshold distance that defines the catchment area (like the buffer radius r). 
#Here, we use 1609 meters, or one mile. The resulting object is a vector of 2SFCA values. Save the results in la.city.tracts.utm.

va.bg.tracts.utm <- va.bg.tracts.utm %>%
  mutate(TSFCA = TSFCA)


#Then mapificate

#FIGURE FIVE

tmap_mode("view")

tsfca_plot <- tm_shape(va.bg.tracts.utm, unit = "mi") +
  tm_polygons(col = "TSFCA", style = "fisher",palette = "Reds", 
              border.alpha = 0, title = "2SFCA") +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(main.title = "Hospital spatial accessibility in Virginia",
            main.title.size = 0.95, frame = FALSE,
            legend.outside = TRUE, legend.outside.position = "right")

tsfca_plot


###############################################################################################
#data
###############################################################################################





