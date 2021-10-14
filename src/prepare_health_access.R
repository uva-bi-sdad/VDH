options(scipen = 999)
health_access_county <- setDT(readRDS("data/catchment_areas/db/health_access_county.rds"))

va_ct_sdad_2021_primary_care_acccess_scores <- health_access_county[,.(geoid, 
                                                                       region_type = "county", 
                                                                       region_name = county, 
                                                                       "year" = year,
                                                                       primcare_cnt = round(as.numeric(num_primcare)),
                                                                       primcare_fca = fca_primcare,
                                                                       primcare_2sfca = `2sfca_primcare`,
                                                                       primcare_e2sfca = `2sfca_primcare`,
                                                                       primcare_3sfca = `3sfca_primcare`)]


va_ct_sdad_2021_primary_care_acccess_scores <-
  melt(
    va_ct_sdad_2021_primary_care_acccess_scores,
    id.vars = c("geoid", "region_type", "region_name", "year"),
    measure.vars = c(
      "primcare_cnt",
      "primcare_fca",
      "primcare_2sfca",
      "primcare_e2sfca",
      "primcare_3sfca"
    ),
    variable.name = "measure",
    variable.factor = FALSE
  )

va_ct_sdad_2021_primary_care_acccess_scores[, value := round(value, 6)]
va_ct_sdad_2021_primary_care_acccess_scores[, measure_type := ""]
va_ct_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_ct_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_ct_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_ct_sdad_2021_primary_care_acccess_scores[, year := as.integer(year)]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_ct_sdad_2021_primary_care_acccess_scores", va_ct_sdad_2021_primary_care_acccess_scores)

va_ct_sdad_2021_obgyn_acccess_scores <- health_access_county[,.(geoid, 
                                                                region_type = "county", 
                                                                region_name = county, 
                                                                "year" = year,
                                                                obgyn_cnt = num_obgyn,
                                                                obgyn_fca = fca_obgyn,
                                                                obgyn_2sfca = `2sfca_obgyn`,
                                                                obgyn_e2sfca = `2sfca_obgyn`,
                                                                obgyn_3sfca = `3sfca_obgyn`)]

va_ct_sdad_2021_obgyn_acccess_scores <-
  melt(
    va_ct_sdad_2021_obgyn_acccess_scores,
    id.vars = c("geoid", "region_type", "region_name", "year"),
    measure.vars = c(
      "obgyn_cnt",
      "obgyn_fca",
      "obgyn_2sfca",
      "obgyn_e2sfca",
      "obgyn_3sfca"
    ),
    variable.name = "measure",
    variable.factor = FALSE
  )

va_ct_sdad_2021_obgyn_acccess_scores[, value := round(value, 6)]
va_ct_sdad_2021_obgyn_acccess_scores[, measure_type := ""]
va_ct_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_ct_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_ct_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_ct_sdad_2021_obgyn_acccess_scores[, year := as.integer(year)]

dc_dbWriteTable(con, "dc_health_behavior_diet", "va_ct_sdad_2021_obgyn_acccess_scores", va_ct_sdad_2021_obgyn_acccess_scores)

va_ct_sdad_2021_dentist_acccess_scores <- health_access_county[,.(geoid, 
                                                                region_type = "county", 
                                                                region_name = county, 
                                                                "year" = year,
                                                                dent_cnt = num_dent,
                                                                dent_fca = fca_dent,
                                                                dent_2sfca = `2sfca_dent`,
                                                                dent_e2sfca = `2sfca_dent`,
                                                                dent_3sfca = `3sfca_dent`)]

va_ct_sdad_2021_dentist_acccess_scores <-
  melt(
    va_ct_sdad_2021_dentist_acccess_scores,
    id.vars = c("geoid", "region_type", "region_name", "year"),
    measure.vars = c(
      "dent_cnt",
      "dent_fca",
      "dent_2sfca",
      "dent_e2sfca",
      "dent_3sfca"
    ),
    variable.name = "measure",
    variable.factor = FALSE
  )

va_ct_sdad_2021_dentist_acccess_scores[, value := round(value, 6)]
va_ct_sdad_2021_dentist_acccess_scores[, measure_type := ""]
va_ct_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_ct_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_ct_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_ct_sdad_2021_dentist_acccess_scores[, year := as.integer(year)]

dc_dbWriteTable(con, "dc_health_behavior_diet", "va_ct_sdad_2021_dentist_acccess_scores", va_ct_sdad_2021_dentist_acccess_scores)




no_hlth_insur_19_64_2019 <- setDT(tidycensus::get_acs(year = 2019, geography = "county", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2019 <- dcast(no_hlth_insur_19_64_2019, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2019[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2019[, year := 2019]

no_hlth_insur_19_64_2018 <- setDT(tidycensus::get_acs(year = 2018, geography = "county", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2018 <- dcast(no_hlth_insur_19_64_2018, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2018[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2018[, year := 2018]

no_hlth_insur_19_64_2017 <- setDT(tidycensus::get_acs(year = 2017, geography = "county", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2017 <- dcast(no_hlth_insur_19_64_2017, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2017[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2017[, year := 2017]

no_hlth_insur_19_64_2016 <- setDT(tidycensus::get_acs(year = 2016, geography = "county", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2016 <- dcast(no_hlth_insur_19_64_2016, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2016[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2016[, year := 2016]

no_hlth_insur_19_64_2015 <- setDT(tidycensus::get_acs(year = 2015, geography = "county", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2015 <- dcast(no_hlth_insur_19_64_2015, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2015[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2015[, year := 2015]

va_ct_acs5_2015_2019_no_health_insurance_19_to_64 <- rbindlist(list(no_hlth_insur_19_64_2019,
                                                                    no_hlth_insur_19_64_2018,
                                                                    no_hlth_insur_19_64_2017,
                                                                    no_hlth_insur_19_64_2016,
                                                                    no_hlth_insur_19_64_2015))
va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, region_type := "county"]

va_ct_acs5_2015_2019_no_health_insurance_19_to_64 <- va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, .(geoid = GEOID,
                                                      region_type,
                                                      region_name = NAME,
                                                      "year" = year,
                                                      no_hlth_ins_pct)]

va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, measure := "no_hlth_ins_pct"]
va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, measure_type := "percent"]
va_ct_acs5_2015_2019_no_health_insurance_19_to_64 <- 
  va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, .(geoid, region_type, region_name, year, measure, "value" = no_hlth_ins_pct, measure_type)]
va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, year := as.integer(year)]

dc_dbWriteTable(con, "dc_health_behavior_diet", "va_ct_acs5_2015_2019_no_health_insurance_19_to_64", va_ct_acs5_2015_2019_no_health_insurance_19_to_64)


# CREATE VIEWS

sql <- "CREATE VIEW dc_webapp.health__primary_care_acccess_scores AS 
        SELECT * FROM dc_health_behavior_diet.va_ct_sdad_2021_primary_care_acccess_scores
        WHERE measure IN ('primcare_cnt', 'primcare_e2sfca') ORDER BY region_name"
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__primary_care_acccess_scores OWNER TO data_commons")

sql <- "CREATE VIEW dc_webapp.health__obgyn_acccess_scores AS 
        SELECT * FROM dc_health_behavior_diet.va_ct_sdad_2021_obgyn_acccess_scores
        WHERE measure IN ('obgyn_cnt', 'obgyn_e2sfca') ORDER BY region_name"
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__obgyn_acccess_scores OWNER TO data_commons")

sql <- "CREATE VIEW dc_webapp.health__dentist_acccess_scores AS 
        SELECT * FROM dc_health_behavior_diet.va_ct_sdad_2021_dentist_acccess_scores
        WHERE measure IN ('dent_cnt', 'dent_e2sfca') ORDER BY region_name"
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__dentist_acccess_scores OWNER TO data_commons")

sql <- "CREATE VIEW dc_webapp.health__no_health_insurance_19_to_64 AS 
        SELECT * FROM dc_health_behavior_diet.va_ct_acs5_2015_2019_no_health_insurance_19_to_64
        WHERE measure IN ('no_hlth_ins_pct') ORDER BY region_name, year"
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__no_health_insurance_19_to_64 OWNER TO data_commons")

# Write CSVs
df <- DBI::dbReadTable(con, c("dc_webapp", "health__primary_care_acccess_scores"))
write.csv(df, "data/dc_webapp/health__primary_care_acccess_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_webapp", "health__obgyn_acccess_scores"))
write.csv(df, "data/dc_webapp/health__obgyn_acccess_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_webapp", "health__dentist_acccess_scores"))
write.csv(df, "data/dc_webapp/health__dentist_acccess_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_webapp", "health__no_health_insurance_19_to_64"))
write.csv(df, "data/dc_webapp/health__no_health_insurance_19_to_64.csv", row.names = FALSE)


