
con <- get_db_conn()
daycare_fca <- setDT(st_read(con, c("dc_working", "va_sdad_daycare_fca")))
va_hd_cts <- setDT(DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hd_vhd_2021_virginia_health_districts"), row.names = FALSE))
va_counties <- setDT(st_read(con, c("dc_common", "va_ct_sdad_2021_virginia_county_geoids")))
DBI::dbDisconnect(con)

va_hd <- unique(va_hd_cts[, .(health_district, fid)])

daycare_fca$geometry <- NULL
va_hd_cts$geometry <- NULL

daycare_fca_fid <- merge(daycare_fca, va_hd, by.x = "region_id", by.y = "health_district", all.x = TRUE)
daycare_fca_fid[!is.na(fid), region_name := region_id]
daycare_fca_fid[!is.na(fid), region_id := fid]

daycare_fca_fid_regions <- merge(daycare_fca_fid, va_counties, by.x = "region_id", by.y = "geoid", all.x = TRUE)
daycare_fca_fid_regions[!is.na(region_name.y), region_name.x := region_name.y]


con <- get_db_conn(db_host = "localhost")
va_tracts <- setDT(st_read(con, c("dc_common", "va_tr_sdad_2021_virginia_tract_geoids")))
DBI::dbDisconnect(con)

daycare_fca_fid_regions_tr <- merge(daycare_fca_fid_regions, va_tracts, by.x = "region_id", by.y = "geoid", all.x = TRUE)
daycare_fca_fid_regions_tr[!is.na(region_name.x), region_name := region_name.x]

daycare_fca_fixed_final <- daycare_fca_fid_regions_tr[, .(geoid = region_id, region_type, region_name, year, measure, value, measure_type)]
daycare_fca_fixed_final <- daycare_fca_fixed_final[region_type == "census tract", region_type := "tract"]
daycare_fca_fixed_final <- daycare_fca_fixed_final[region_type == "health_district", region_type := "health district"]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_education_training", "va_ct_sdad_2021_daycare_services_access_scores", daycare_fca_fixed_final[region_type == "county"])
dc_dbWriteTable(con, "dc_education_training", "va_tr_sdad_2021_daycare_services_access_scores", daycare_fca_fixed_final[region_type == "tract"])
dc_dbWriteTable(con, "dc_education_training", "va_hd_sdad_2021_daycare_services_access_scores", daycare_fca_fixed_final[region_type == "health district"])
DBI::dbDisconnect(con)


#####################
con <- get_db_conn()
third_grd_read_scr <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid, region_type, region_name, year, measure, value, measure_type 
                   FROM dc_education_training.va_ct_vdoe_2019_2021_3rd_grade_mean_median_read_score WHERE measure_type = 'median'
                   UNION
                   SELECT geoid, region_type, region_name, year, measure, value, measure_type 
                   FROM dc_education_training.va_hd_vdoe_2019_2021_3rd_grade_mean_median_read_score WHERE measure_type = 'median'")
dc_dbWriteTable(con, "dc_education_training", "va_hdct_vdoe_2019_2021_3rd_grade_median_read_score", third_grd_read_scr)
write_csv(third_grd_read_scr, "data/dc_webapp/va_hdct_vdoe_2019_2021_3rd_grade_median_read_score.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
health_literacy <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_tr_sdad_2019_health_literacy_estimates WHERE measure = 'health_literacy_estimate'
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_ct_sdad_2019_health_literacy_estimates WHERE measure = 'health_literacy_estimate'
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_hd_sdad_2019_health_literacy_estimates WHERE measure = 'health_literacy_estimate'")
dc_dbWriteTable(con, "dc_education_training", "va_hdcttr_sdad_2019_health_literacy_estimates", health_literacy)
write_csv(health_literacy, "data/dc_webapp/va_hdcttr_sdad_2019_health_literacy_estimates.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
college_access_2yr <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_tr_sdad_2019_2year_colleges_access_scores
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_ct_sdad_2019_2year_colleges_access_scores
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_hd_sdad_2019_2year_colleges_access_scores;")
dc_dbWriteTable(con, "dc_education_training", "va_hdcttr_sdad_2019_2year_colleges_access_scores", college_access_2yr)
write_csv(college_access_2yr, "data/dc_webapp/va_hdcttr_sdad_2019_2year_colleges_access_scores.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
tradeschool_access_2yr <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_tr_sdad_2019_trade_schools_access_scores
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_ct_sdad_2019_trade_schools_access_scores
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_hd_sdad_2019_trade_schools_access_scores;")
dc_dbWriteTable(con, "dc_education_training", "va_hdcttr_sdad_2019_trade_schools_access_scores", tradeschool_access_2yr)
write_csv(tradeschool_access_2yr, "data/dc_webapp/va_hdcttr_sdad_2019_trade_schools_access_scores.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
post_hs_ed <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_tr_acs_2015_2019_post_hs_education
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_ct_acs_2015_2019_post_hs_education
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_hd_acs_2015_2019_post_hs_education;")
dc_dbWriteTable(con, "dc_education_training", "va_hdcttr_acs_2015_2019_post_hs_education", post_hs_ed)
write_csv(post_hs_ed, "data/dc_webapp/va_hdcttr_acs_2015_2019_post_hs_education.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
drive_to_2yr_col <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_tr_osrm_2021_drive_times_nearest_2year_colleges
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_ct_osrm_2021_drive_times_nearest_2year_colleges
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_hd_osrm_2021_drive_times_nearest_2year_colleges;")
dc_dbWriteTable(con, "dc_education_training", "va_hdcttr_osrm_2021_drive_times_nearest_2year_colleges", drive_to_2yr_col)
write_csv(drive_to_2yr_col, "data/dc_webapp/va_hdcttr_osrm_2021_drive_times_nearest_2year_colleges.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
drive_to_2yr_tradeschool <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_tr_osrm_2021_drive_times_nearest_trade_schools
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_ct_osrm_2021_drive_times_nearest_trade_schools
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_hd_osrm_2021_drive_times_nearest_trade_schools;")
dc_dbWriteTable(con, "dc_education_training", "va_hdcttr_osrm_2021_drive_times_nearest_trade_schools", drive_to_2yr_tradeschool)
write_csv(drive_to_2yr_tradeschool, "data/dc_webapp/va_hdcttr_osrm_2021_drive_times_nearest_trade_schools.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
drive_to_daycares <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_tr_osrm_2021_drive_times_nearest_daycares
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_ct_osrm_2021_drive_times_nearest_daycares
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_education_training.va_hd_osrm_2021_drive_times_nearest_daycares;")
dc_dbWriteTable(con, "dc_education_training", "va_hdcttr_osrm_2021_drive_times_nearest_daycares", drive_to_daycares)
write_csv(drive_to_daycares, "data/dc_webapp/va_hdcttr_osrm_2021_drive_times_nearest_daycares.csv")
DBI::dbDisconnect(con)


category_measures <- read.csv("data/dc_webapp/category_measures.csv")
new_cat_meas <- data.frame(
  category = c("Education"),
  measure = c("median_read_pass_rate", 
              "health_literacy_estimate", 
              "norm_2sefca", 
              "norm_2sefca", 
              "perc_post_hs_edu",
              "median_drive_time_top5",
              "median_drive_time_top5",
              "median_drive_time_top5"),
  measure_table = c("dc_education_training.va_hdct_vdoe_2019_2021_3rd_grade_median_read_score", 
                    "dc_education_training.va_hdcttr_sdad_2019_health_literacy_estimates",
                    "dc_education_training.va_hdcttr_sdad_2019_2year_colleges_access_scores",
                    "dc_education_training.va_hdcttr_sdad_2019_trade_schools_access_scores",
                    "dc_education_training.va_hdcttr_acs_2015_2019_post_hs_education",
                    "dc_education_training.va_hdcttr_osrm_2021_drive_times_nearest_2year_colleges",
                    "dc_education_training.va_hdcttr_osrm_2021_drive_times_nearest_trade_schools",
                    "dc_education_training.va_hdcttr_osrm_2021_drive_times_nearest_daycares")
)
category_measures <- rbind(category_measures, new_cat_meas)
category_measures <- category_measures[order(category_measures$category),]
write_csv(category_measures, "data/dc_webapp/category_measures.csv")


con <- get_db_conn()
DBI::dbSendQuery(con, "DROP TABLE dc_webapp.category_measures")
dc_dbWriteTable(con, "dc_webapp", "category_measures", category_measures)
DBI::dbDisconnect(con)


