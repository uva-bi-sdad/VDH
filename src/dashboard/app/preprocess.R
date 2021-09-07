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
features <- c("health_district", "county_name", "tract_name", "name", "id", "geometry")
shapes <- lapply(lapply(data, function(d) d[!duplicated(d$id), features[features %in% colnames(d)]]), function(d) {
  if (nrow(d) > 50) st_geometry(d) <- ms_simplify(d$geometry, .05, keep_shapes = TRUE)
  d
})

# write geojson and csvs
dir.create("assets", FALSE)
for (n in names(shapes)) {
  # write json
  unlink(paste0("assets/", n, ".geojson"))
  st_write(
    st_as_sf(shapes[[n]], coords = c("x", "y"), crs = 28992, agr = "constant"),
    paste0("assets/", n, ".geojson")
  )

  # write csv
  write.csv(st_drop_geometry(data[[n]]), paste0("assets/", n, ".csv"), row.names = FALSE)
}

# collect and write metadata
format_name <- function(name) {
  gsub("\\b(\\w)", "\\U\\1", gsub("_", " ", name, fixed = TRUE), perl = TRUE)
}

measures <- list(
  "Health Access" = list(
    name = "health_access",
    components = list(
      "Health District" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      ),
      "County" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "High Cholesterol" = "highchol_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      ),
      "Census Tract" = c(
        "No Health Insurance" = "no_health_ins",
        "High Blood Pressure" = "bphigh_crudeprev",
        "Cancer" = "cancer_crudeprev",
        "High Cholesterol" = "highchol_crudeprev",
        "Obesity" = "obesity_crudeprev",
        "Diabetes" = "diabetes_crudeprev",
        "Mental Health" = "mhlth_crudeprev",
        "Physical Health" = "phlth_crudeprev"
      )
    )
  )
)
for (variable in colnames(vhd_data)) {
  if (
    is.numeric(vhd_data[, variable, drop = TRUE]) &&
      variable %in% colnames(county_data) &&
      variable %in% colnames(tract_data)
  ) {
    formatted <- format_name(variable)
    v <- c(
      vhd_data[, variable, drop = TRUE],
      county_data[, variable, drop = TRUE],
      tract_data[, variable, drop = TRUE]
    )
    if (!all(v == 0)) {
      measures[[formatted]] <- list(
        name = variable,
        ranges = list(
          "Health District" = range(vhd_data[, variable, drop = TRUE], na.rm = TRUE),
          "County" = range(vhd_data[, variable, drop = TRUE], na.rm = TRUE),
          "Census Tract" = range(vhd_data[, variable, drop = TRUE], na.rm = TRUE)
        ),
        components = measures[[formatted]]$components
      )
    }
  }
}
jsonlite::write_json(measures, "assets/measures.json", auto_unbox = TRUE)

rm(list = ls())
