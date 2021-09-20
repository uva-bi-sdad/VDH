library(sf)
library(rmapshaper)

vhd_data <- readRDS("health_district_data.rds")
tract_data <- readRDS("tract_prototype_data.rds")
county_data <- readRDS("county_data.rds")

# standardizing data
vhd_data$region_type <- vhd_data$hd_rural
tract_data$region_type <- tract_data$srhp_rural
county_data$region_type <- county_data$srhp_rural

county_data$health_district <- county_data$HealthDistrict
tract_data$health_district <- vapply(tract_data$county_id, function(county) {
  county_data[which(county_data$county_id == county)[1], "HealthDistrict", drop = TRUE]
}, "")

tract_data$name <- tract_data$tract_name
county_data$name <- county_data$county_name
vhd_data$name <- vhd_data$health_district

tract_data$id <- tract_data$census_tract_fips
county_data$id <- county_data$county_id
vhd_data$id <- as.character(vhd_data$fid)

# drop duplicates
data <- lapply(list(
  district = vhd_data,
  county = county_data,
  tract = tract_data
), function(d) {
  d <- d[!st_is_empty(d$geometry), ]
  nums <- vapply(d, is.numeric, TRUE)
  d[, nums] <- round(d[, nums, drop = TRUE], 4)
  d
})

# simplify polygons
# features <- c("health_district", "county_name", "tract_name", "name", "id", "geometry")
# shapes <- lapply(lapply(data, function(d) d[!duplicated(d$id), features[features %in% colnames(d)]]), function(d) {
#   if (nrow(d) > 50) st_geometry(d) <- ms_simplify(d$geometry, .05, keep_shapes = TRUE)
#   d
# })
# 
# # write preformatted data files
# dir.create("assets", FALSE)
# for (n in names(shapes)) {
#   # write json
#   unlink(paste0("assets/", n, ".geojson"))
#   st_write(
#     st_as_sf(shapes[[n]], coords = c("x", "y"), crs = 28992, agr = "constant"),
#     paste0("assets/", n, ".geojson")
#   )
# 
#   # write csv
#   write.csv(st_drop_geometry(data[[n]]), paste0("assets/", n, ".csv"), row.names = FALSE)
# }

# write json
year_range <- range(as.numeric(as.character(data$district$year)))
nyears <- nlevels(data$district$year)
write_json(lapply(data, function(s) {
  s <- st_drop_geometry(s)
  d <- split(s[, !colnames(s) %in% c(
    "name", "health_district", "county_name", "tract_name",
    "id", "fid", "county_id", "census_tract_fips", "hd_rural",
    "region_type", "HealthDistrict", "srhp_rural", "state_name"
  )], s$id)
  for(i in seq_along(d)){
    if(nrow(d[[i]]) != nyears){
      td <- rbind(d[[i]], rep(NA, nyears - nrow(d[[i]])))
      td[-seq_len(nrow(d[[i]])), "year"] <- year_range[!year_range %in% d[[i]]$year]
      d[[i]] <- td[order(td$year),]
    }
  }
  d
}), paste0("assets/data.json"), dataframe = "columns", auto_unbox = TRUE)

# collect and write metadata
format_name <- function(name) {
  gsub("\\b(\\w)", "\\U\\1", gsub("_", " ", name, fixed = TRUE), perl = TRUE)
}

measures <- list(
  "health_access" = list(
    description = "Health Access Description",
    icon = "alarm",
    name = "Health Access",
    part_of = list(),
    related_to = list(),
    components = list(
      "district" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      ),
      "county" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      ),
      "tract" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      )
    )
  )
)
format_summary = function(v, y){
  # s <- as.data.frame(do.call(rbind, tapply(v, y, summary, na.rm = TRUE)))
  # colnames(s) = c("min", "q1", "median", "mean", "q3", "max", if(length(s) > 6) "nas")
  # as.list(s)
  list()
}

for (variable in colnames(vhd_data)) {
  if (
    is.numeric(vhd_data[, variable, drop = TRUE]) &&
      variable %in% colnames(county_data) &&
      variable %in% colnames(tract_data)
  ) {
    v <- c(
      vhd_data[, variable, drop = TRUE],
      county_data[, variable, drop = TRUE],
      tract_data[, variable, drop = TRUE]
    )
    if (!all(v == 0)) {
      measures[[variable]]$name <- format_name(variable)
      measures[[variable]]$summaries <- list(
        district = format_summary(vhd_data[, variable, drop = TRUE], vhd_data$year),
        county = format_summary(county_data[, variable, drop = TRUE], county_data$year),
        tract = format_summary(tract_data[, variable, drop = TRUE], tract_data$year)
      )
      measures[[variable]]$components <- measures[[variable]]$components
    }
  }
}

measures$bphigh_crudeprev
for(comp in names(measures)){
  l = measures[[comp]]
  if(length(l$components)) for(s in names(l$components)) for(m in l$components[[s]]){
    measures[[m]]$part_of[[s]] = c(measures[[m]]$part_of[[s]], comp)
  }
}


jsonlite::write_json(measures, "assets/measures.json", auto_unbox = TRUE)

rm(list = ls())
