
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


con <- get_db_conn()
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


