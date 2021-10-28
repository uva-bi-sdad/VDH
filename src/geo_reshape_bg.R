library(sf)
library(tidycensus)
library(data.table)

# TRANSFORM ACS BLOCK GROUP DEMOGRAPHICS TO NEW NEIGHBORHOOD GEOGRAPHY
# THIS EXAMPLE WORKS WITH THE WAVERLY HILLS NEIGHBORHOOD IN ARLINGTON COUNTY VIRGINIA
# THE WAVERLY HILLS NEIGHBORHOOD OVERLAPS 3 BLOCK GROUPS ENTIRELY ("510131007005", "510131007002", "510131007001") AND 1 BLOCK GROUP PARTIALLY ("510131006003")

# vars <- tidycensus::load_variables(2019, "acs5", cache = TRUE)

# Load the Arlington VA Master Housing Unit Database
va_arl_housing_units <- st_read("https://opendata.arcgis.com/datasets/628f6de7205641169273ea684a74fb0f_0.geojson")

# Reduce to Housing Units in the Block Groups touching Waverly Hills Neighborhood
va_arl_housing_units_wavhills_bgs <- va_arl_housing_units[substr(va_arl_housing_units$Full_Block, 1, 12) %in% c("510131007005", "510131007002", "510131007001", "510131006003"),
                                          c("RPC_Master", "Unit_Type", "Total_Units", "geometry")]

plot(va_arl_housing_units_wavhills_bgs[, c("Unit_Type")])

# Load Virginia Block Group Geographies (Use Tigerline files "tl" NOT Cartographic Boundary files "cb" as the simplified "cb" files can split some parcels)
con <- get_db_conn()
arl_bgs <- st_read(con, c("gis_census_tl", "tl_2021_51_bg"))
DBI::dbDisconnect(con)

# Reduce to the Block Group Geographies Touching Waverly Hills Neighborhood
arl_bgs <- arl_bgs[arl_bgs$COUNTYFP=="013",]
arl_bgs_wgs84 <- st_transform(arl_bgs, crs = 4326)
arl_bgs_wgs84_wavhills <- arl_bgs_wgs84[arl_bgs_wgs84$GEOID %in% c("510131007005", "510131007002", "510131007001", "510131006003"),]

# Assign the correct Block Group for each Unit
intersect <- st_intersection(va_arl_housing_units_wavhills_bgs, arl_bgs_wgs84_wavhills)

# Get ACS Demographics
tidycensus::census_api_key(Sys.getenv("CENSUS_API_KEY"))
acs <- tidycensus::get_acs(geography = "block group", state = "VA", county = "013", variables = c("B02001_003", "B02001_002", "B01001_001"))
acs_bgs <- setDT(acs[acs$GEOID %in% c("510131007005", "510131007002", "510131007001", "510131006003"),])
acs_bgs_totals <- dcast(acs_bgs, GEOID ~ variable, value.var = c("estimate"))
colnames(acs_bgs_totals) <- c("GEOID", "total_pop", "white", "afr_amer")

# Add the ACS Demographics to the final dataset
intersect_dmgs <- setDT(merge(intersect, acs_bgs_totals, by = "GEOID"))

# Calculate Total Units per Block Group
tot_units <- intersect_dmgs[, .(bg_units = sum(Total_Units)), c("GEOID")]

# Add the Total Units per Block Group to the final dataset
intersect_dmgs_units <- merge(intersect_dmgs, tot_units, by = "GEOID")

# Calculate and add parcel level demographics to the final dataset
intersect_dmgs_units[, prcl_pop := (Total_Units * total_pop)/bg_units]
intersect_dmgs_units[, prcl_wht := (Total_Units * white)/bg_units]
intersect_dmgs_units[, prcl_blk := (Total_Units * afr_amer)/bg_units]

# We now need to remove the parcels that are not part of the Waverly Hills Neighborhood
# All parcels from Block Groups 510131007005, 510131007002, and 510131007001 are included
# Only the following parcels are included from Block Group 510131006003
parcels_from_510131006003 <- c("06001006", "06001005", "06001024", "06001025", "06001026", "06001027", "06001028", "06001029", "06001030", "06001032", "06001033", "06001PCA")

# Waverly Hills Parcels with Parcel-Level Demographic Estimates
wav_hills_parcels <- intersect_dmgs_units[GEOID %in% c("510131007005", "510131007002", "510131007001") | RPC_Master %in% parcels_from_510131006003,]

# Load Arlington Civic Association Geographies
arl_civic_assoc <- st_read("data/Civic_Association_Polygons/Civic_Association_Polygons.shp")
arl_civic_assoc_wgs84 <- st_transform(arl_civic_assoc, crs = 4326)
arl_civic_assoc_wgs84_wavhills <- arl_civic_assoc_wgs84[arl_civic_assoc_wgs84$LABEL=="Waverly Hills",]

# Final Dataset of Waverly Hills Demographics
wav_hills_demographics <- data.table(neighborhood = "Waverly Hills",
                                     total_population = round(sum(wav_hills_parcels$prcl_pop)),
                                     white_population = round(sum(wav_hills_parcels$prcl_wht)),
                                     black_population = round(sum(wav_hills_parcels$prcl_blk)))
  
# Print Waverly Hills Demographics
wav_hills_demographics

# Plot Waverly Hills Parcels
plot(va_arl_housing_units_wavhills_bgs[va_arl_housing_units_wavhills_bgs$RPC_Master %in% wav_hills_parcels$RPC_Master, c("Unit_Type")])


wav_hills_parcels_sf <- sf::st_as_sf(wav_hills_parcels)
wav_hills_parcels_sf <- st_transform(wav_hills_parcels_sf, crs = 4326)

plot(st_geometry(arl_bgs_wgs84_wavhills))

plot(wav_hills_parcels_sf[,c("prcl_blk")])
plot(wav_hills_parcels_sf[,c("Total_Units")])
plot(st_geometry(wav_hills_parcels_sf))

plot(st_geometry(intersect))
plot(st_geometry(arl_bgs_wgs84_wavhills), border = 2, lwd = 3, add = T)
plot(wav_hills_parcels_sf[,c("COUNTYFP")], add = T)


plot(wav_hills_parcels_sf[,c("prcl_blk")])
plot(st_geometry(arl_bgs_wgs84_wavhills), border = 2, lwd = 3, add = T)




plot(st_geometry(arl_bgs_wgs84_wavhills), border = 2, lwd = 3)
plot(st_geometry(intersect), add = T)
plot(st_geometry(arl_civic_assoc_wgs84_wavhills), add = T, border = 3, lwd = 3)
plot(va_arl_housing_units_wavhills_bgs[, c("Total_Units")], key.pos = 4, add = T)
plot(st_geometry(arl_civic_assoc_wgs84_wavhills), add = T, border = 4, lwd = 4)


plot(wav_hills_parcels_sf[,c("Total_Units")])



colnms <- colnames(wav_hills_parcels_sf)
colnms[colnms == "prcl_blk"] <- "prcl_afr_amer"
colnames(wav_hills_parcels_sf) <- colnms
plot(wav_hills_parcels_sf[,c("prcl_afr_amer")])


plot(wav_hills_parcels_sf[,c("Total_Units")], add = T)

plot(st_geometry(arl_civic_assoc_wgs84_wavhills), border = 4, lwd = 4)
plot(va_arl_housing_units_wavhills_bgs[, c("Total_Units")], pal = heat.colors, add = T)

