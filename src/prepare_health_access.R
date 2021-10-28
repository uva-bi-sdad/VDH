options(scipen = 999)

# PREAPRE COUNTY LEVEL
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


# PREPARE TRACT LEVEL
health_access_tract <- setDT(readRDS("data/catchment_areas/db/health_access_tract.rds"))

va_tr_sdad_2021_primary_care_acccess_scores <- health_access_tract[,.(geoid = as.character(GEOID), 
                                                                      region_type = "tract", 
                                                                      region_name = ctract, 
                                                                      "year" = year,
                                                                      primcare_cnt = round(as.numeric(prim_care_num)),
                                                                      primcare_pop_cnt = pop,
                                                                      primcare_fca = fca_primcare,
                                                                      primcare_2sfca = `2sfca_primcare`,
                                                                      primcare_e2sfca = `2sfca_primcare`,
                                                                      primcare_3sfca = `3sfca_primcare`)]


va_tr_sdad_2021_primary_care_acccess_scores <-
  melt(
    va_tr_sdad_2021_primary_care_acccess_scores,
    id.vars = c("geoid", "region_type", "region_name", "year"),
    measure.vars = c(
      "primcare_cnt",
      "primcare_pop_cnt",
      "primcare_fca",
      "primcare_2sfca",
      "primcare_e2sfca",
      "primcare_3sfca"
    ),
    variable.name = "measure",
    variable.factor = FALSE
  )

va_tr_sdad_2021_primary_care_acccess_scores[, value := round(value, 6)]
va_tr_sdad_2021_primary_care_acccess_scores[, measure_type := ""]
va_tr_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_tr_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_tr_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_tr_sdad_2021_primary_care_acccess_scores[, year := as.integer(year)]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_tr_sdad_2021_primary_care_acccess_scores", va_tr_sdad_2021_primary_care_acccess_scores)
DBI::dbDisconnect(con)

va_tr_sdad_2021_obgyn_acccess_scores <- health_access_tract[,.(geoid = as.character(GEOID), 
                                                               region_type = "tract", 
                                                               region_name = ctract, 
                                                               "year" = year,
                                                               obgyn_cnt = round(as.numeric(obgyn_num)),
                                                               obgyn_pop_cnt = pop_obgyn,
                                                               obgyn_fca = fca_obgyn,
                                                               obgyn_2sfca = `2sfca_obgyn`,
                                                               obgyn_e2sfca = `2sfca_obgyn`,
                                                               obgyn_3sfca = `3sfca_obgyn`)]

va_tr_sdad_2021_obgyn_acccess_scores <-
  melt(
    va_tr_sdad_2021_obgyn_acccess_scores,
    id.vars = c("geoid", "region_type", "region_name", "year"),
    measure.vars = c(
      "obgyn_cnt",
      "obgyn_pop_cnt",
      "obgyn_fca",
      "obgyn_2sfca",
      "obgyn_e2sfca",
      "obgyn_3sfca"
    ),
    variable.name = "measure",
    variable.factor = FALSE
  )

va_tr_sdad_2021_obgyn_acccess_scores[, value := round(value, 6)]
va_tr_sdad_2021_obgyn_acccess_scores[, measure_type := ""]
va_tr_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_tr_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_tr_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_tr_sdad_2021_obgyn_acccess_scores[, year := as.integer(year)]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_tr_sdad_2021_obgyn_acccess_scores", va_tr_sdad_2021_obgyn_acccess_scores)
DBI::dbDisconnect(con)


va_tr_sdad_2021_dentist_acccess_scores <- health_access_tract[,.(geoid = as.character(GEOID), 
                                                                 region_type = "tract", 
                                                                 region_name = ctract, 
                                                                 "year" = year,
                                                                 dent_cnt = round(as.numeric(dent_num)),
                                                                 dent_pop_cnt = pop_dent,
                                                                 dent_fca = fca_dent,
                                                                 dent_2sfca = `2sfca_dent`,
                                                                 dent_e2sfca = `2sfca_dent`,
                                                                 dent_3sfca = `3sfca_dent`)]

va_tr_sdad_2021_dentist_acccess_scores <-
  melt(
    va_tr_sdad_2021_dentist_acccess_scores,
    id.vars = c("geoid", "region_type", "region_name", "year"),
    measure.vars = c(
      "dent_cnt",
      "dent_pop_cnt",
      "dent_fca",
      "dent_2sfca",
      "dent_e2sfca",
      "dent_3sfca"
    ),
    variable.name = "measure",
    variable.factor = FALSE
  )

va_tr_sdad_2021_dentist_acccess_scores[, value := round(value, 6)]
va_tr_sdad_2021_dentist_acccess_scores[, measure_type := ""]
va_tr_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_tr_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_tr_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_tr_sdad_2021_dentist_acccess_scores[, year := as.integer(year)]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_tr_sdad_2021_dentist_acccess_scores", va_tr_sdad_2021_dentist_acccess_scores)
DBI::dbDisconnect(con)

no_hlth_insur_19_64_2019 <- setDT(tidycensus::get_acs(year = 2019, geography = "tract", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2019 <- dcast(no_hlth_insur_19_64_2019, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2019[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2019[, year := 2019]

no_hlth_insur_19_64_2018 <- setDT(tidycensus::get_acs(year = 2018, geography = "tract", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2018 <- dcast(no_hlth_insur_19_64_2018, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2018[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2018[, year := 2018]

no_hlth_insur_19_64_2017 <- setDT(tidycensus::get_acs(year = 2017, geography = "tract", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2017 <- dcast(no_hlth_insur_19_64_2017, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2017[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2017[, year := 2017]

no_hlth_insur_19_64_2016 <- setDT(tidycensus::get_acs(year = 2016, geography = "tract", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2016 <- dcast(no_hlth_insur_19_64_2016, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2016[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2016[, year := 2016]

no_hlth_insur_19_64_2015 <- setDT(tidycensus::get_acs(year = 2015, geography = "tract", state = "VA", variables = c("B18135_013", "C27001I_007")))
no_hlth_insur_19_64_2015 <- dcast(no_hlth_insur_19_64_2015, GEOID+NAME ~ variable, value.var = "estimate")
no_hlth_insur_19_64_2015[, no_hlth_ins_pct := round((C27001I_007/B18135_013)*100, 2)]
no_hlth_insur_19_64_2015[, year := 2015]

va_tr_acs5_2015_2019_no_health_insurance_19_to_64 <- rbindlist(list(no_hlth_insur_19_64_2019,
                                                                    no_hlth_insur_19_64_2018,
                                                                    no_hlth_insur_19_64_2017,
                                                                    no_hlth_insur_19_64_2016,
                                                                    no_hlth_insur_19_64_2015))
va_tr_acs5_2015_2019_no_health_insurance_19_to_64[, region_type := "tract"]

va_tr_acs5_2015_2019_no_health_insurance_19_to_64 <- va_tr_acs5_2015_2019_no_health_insurance_19_to_64[, .(geoid = as.character(GEOID),
                                                                                                           region_type,
                                                                                                           region_name = NAME,
                                                                                                           "year" = year,
                                                                                                           no_hlth_ins_pct)]

va_tr_acs5_2015_2019_no_health_insurance_19_to_64[, measure := "no_hlth_ins_pct"]
va_tr_acs5_2015_2019_no_health_insurance_19_to_64[, measure_type := "percent"]
va_tr_acs5_2015_2019_no_health_insurance_19_to_64 <- 
  va_tr_acs5_2015_2019_no_health_insurance_19_to_64[, .(geoid, region_type, region_name, year, measure, "value" = no_hlth_ins_pct, measure_type)]
va_tr_acs5_2015_2019_no_health_insurance_19_to_64[, year := as.integer(year)]

dc_dbWriteTable(con, "dc_health_behavior_diet", "va_tr_acs5_2015_2019_no_health_insurance_19_to_64", va_tr_acs5_2015_2019_no_health_insurance_19_to_64)

# CREATE VIEWS

sql <- "DROP VIEW IF EXISTS dc_webapp.health__primary_care_acccess_scores;
        CREATE VIEW dc_webapp.health__primary_care_acccess_scores AS 
        SELECT * FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_sdad_2021_primary_care_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_sdad_2021_primary_care_acccess_scores
        ) t
        WHERE measure IN ('primcare_cnt', 'primcare_e2sfca')
        ORDER BY region_name;"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__primary_care_acccess_scores OWNER TO data_commons")
DBI::dbDisconnect(con)

sql <- "DROP VIEW IF EXISTS dc_webapp.health__obgyn_acccess_scores;
        CREATE VIEW dc_webapp.health__obgyn_acccess_scores AS
        SELECT * FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_sdad_2021_obgyn_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_sdad_2021_obgyn_acccess_scores
        ) t
        WHERE measure IN ('obgyn_cnt', 'obgyn_e2sfca') 
        ORDER BY region_name;"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__obgyn_acccess_scores OWNER TO data_commons")
DBI::dbDisconnect(con)

sql <- "DROP VIEW IF EXISTS dc_webapp.health__dentist_acccess_scores;
        CREATE VIEW dc_webapp.health__dentist_acccess_scores AS
        SELECT * FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_sdad_2021_dentist_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_sdad_2021_dentist_acccess_scores
        ) t
        WHERE measure IN ('dent_cnt', 'dent_e2sfca') 
        ORDER BY region_name"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__dentist_acccess_scores OWNER TO data_commons")
DBI::dbDisconnect(con)

sql <- "DROP VIEW IF EXISTS dc_webapp.health__no_health_insurance_19_to_64;
        CREATE VIEW dc_webapp.health__no_health_insurance_19_to_64 AS 
        SELECT * FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_acs5_2015_2019_no_health_insurance_19_to_64
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_acs5_2015_2019_no_health_insurance_19_to_64
        ) t
        WHERE measure IN ('no_hlth_ins_pct') 
        ORDER BY region_name, year"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__no_health_insurance_19_to_64 OWNER TO data_commons")
DBI::dbDisconnect(con)

# Write CSVs
con <- get_db_conn()
df <- DBI::dbReadTable(con, c("dc_webapp", "health__primary_care_acccess_scores"))
write.csv(df, "data/dc_webapp/health__primary_care_acccess_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_webapp", "health__obgyn_acccess_scores"))
write.csv(df, "data/dc_webapp/health__obgyn_acccess_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_webapp", "health__dentist_acccess_scores"))
write.csv(df, "data/dc_webapp/health__dentist_acccess_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_webapp", "health__no_health_insurance_19_to_64"))
write.csv(df, "data/dc_webapp/health__no_health_insurance_19_to_64.csv", row.names = FALSE)
DBI::dbDisconnect(con)


# PREPARE HEALTH DISTRICT LEVEL
health_access_district <- setDT(readRDS("data/catchment_areas/db/health_access_health_district.rds"))

con <- get_db_conn()
va_hd_counties <- st_read(con, c("dc_health_behavior_diet", "va_hd_vhd_2021_virginia_health_districts"))
va_hd <- setDT(unique(va_hd_counties[, c("health_district", "fid")]))
va_hd[health_district == "Pittsylvania-Danville", health_district := "Pittsylvania/Danville"]
va_hd[health_district == "Rappahannock Rapidan", health_district := "Rappahannock/Rapidan"]



va_hd_sdad_2021_primary_care_acccess_scores <- health_access_district[,.(geoid = "", 
                                                                         region_type = "health district", 
                                                                         region_name = HealthDistrict, 
                                                                         "year" = year,
                                                                         primcare_cnt = round(as.numeric(num_primcare)),
                                                                         primcare_fca = fca_primcare,
                                                                         primcare_2sfca = `2sfca_primcare`,
                                                                         primcare_e2sfca = `2sfca_primcare`,
                                                                         primcare_3sfca = `3sfca_primcare`)]

va_hd_sdad_2021_primary_care_acccess_scores[region_name=="Rappahannock Area", region_name := "Rappahannock"]
va_hd_sdad_2021_primary_care_acccess_scores[region_name=="Roanoke City", region_name := "Roanoke"]

va_hd_sdad_2021_primary_care_acccess_scores <- merge(va_hd_sdad_2021_primary_care_acccess_scores, va_hd, by.x = "region_name", by.y = "health_district", all.x = TRUE)

va_hd_sdad_2021_primary_care_acccess_scores[, geoid := fid]

va_hd_sdad_2021_primary_care_acccess_scores <-
  melt(
    va_hd_sdad_2021_primary_care_acccess_scores,
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

va_hd_sdad_2021_primary_care_acccess_scores[, value := round(value, 6)]
va_hd_sdad_2021_primary_care_acccess_scores[, measure_type := ""]
va_hd_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_hd_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_hd_sdad_2021_primary_care_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_hd_sdad_2021_primary_care_acccess_scores[, year := as.integer(year)]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_hd_sdad_2021_primary_care_acccess_scores", va_hd_sdad_2021_primary_care_acccess_scores)
DBI::dbDisconnect(con)


va_hd_sdad_2021_obgyn_acccess_scores <- health_access_district[,.(geoid = "", 
                                                                  region_type = "health district", 
                                                                  region_name = HealthDistrict, 
                                                                  "year" = year,
                                                                  obgyn_cnt = round(as.numeric(num_obgyn)),
                                                                  obgyn_fca = fca_obgyn,
                                                                  obgyn_2sfca = `2sfca_obgyn`,
                                                                  obgyn_e2sfca = `2sfca_obgyn`,
                                                                  obgyn_3sfca = `3sfca_obgyn`)]

va_hd_sdad_2021_obgyn_acccess_scores[region_name=="Rappahannock Area", region_name := "Rappahannock"]
va_hd_sdad_2021_obgyn_acccess_scores[region_name=="Roanoke City", region_name := "Roanoke"]

va_hd_sdad_2021_obgyn_acccess_scores <- merge(va_hd_sdad_2021_obgyn_acccess_scores, va_hd, by.x = "region_name", by.y = "health_district", all.x = TRUE)

va_hd_sdad_2021_obgyn_acccess_scores[, geoid := fid]

va_hd_sdad_2021_obgyn_acccess_scores <-
  melt(
    va_hd_sdad_2021_obgyn_acccess_scores,
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

va_hd_sdad_2021_obgyn_acccess_scores[, value := round(value, 6)]
va_hd_sdad_2021_obgyn_acccess_scores[, measure_type := ""]
va_hd_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_hd_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_hd_sdad_2021_obgyn_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_hd_sdad_2021_obgyn_acccess_scores[, year := as.integer(year)]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_hd_sdad_2021_obgyn_acccess_scores", va_hd_sdad_2021_obgyn_acccess_scores)
DBI::dbDisconnect(con)


va_hd_sdad_2021_dentist_acccess_scores <- health_access_district[,.(geoid = "", 
                                                                    region_type = "health district", 
                                                                    region_name = HealthDistrict, 
                                                                    "year" = year,
                                                                    dent_cnt = round(as.numeric(num_dent)),
                                                                    dent_fca = fca_dent,
                                                                    dent_2sfca = `2sfca_dent`,
                                                                    dent_e2sfca = `2sfca_dent`,
                                                                    dent_3sfca = `3sfca_dent`)]

va_hd_sdad_2021_dentist_acccess_scores[region_name=="Rappahannock Area", region_name := "Rappahannock"]
va_hd_sdad_2021_dentist_acccess_scores[region_name=="Roanoke City", region_name := "Roanoke"]

va_hd_sdad_2021_dentist_acccess_scores <- merge(va_hd_sdad_2021_dentist_acccess_scores, va_hd, by.x = "region_name", by.y = "health_district", all.x = TRUE)

va_hd_sdad_2021_dentist_acccess_scores[, geoid := fid]

va_hd_sdad_2021_dentist_acccess_scores <-
  melt(
    va_hd_sdad_2021_dentist_acccess_scores,
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

va_hd_sdad_2021_dentist_acccess_scores[, value := round(value, 6)]
va_hd_sdad_2021_dentist_acccess_scores[, measure_type := ""]
va_hd_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "cnt", measure_type := "count"]
va_hd_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "fca", measure_type := "index"]
va_hd_sdad_2021_dentist_acccess_scores[substr(measure, nchar(measure)-2, nchar(measure)) == "pct", measure_type := "percent"]
va_hd_sdad_2021_dentist_acccess_scores[, year := as.integer(year)]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_hd_sdad_2021_dentist_acccess_scores", va_hd_sdad_2021_dentist_acccess_scores)
DBI::dbDisconnect(con)


# va_hd_cts <- fread("src/va_health_district_counties.csv")
# va_hd_cts[!locality %like% "city$", locality := paste0(locality, " County")]
# va_hd_cts[, locality := paste0(locality, ", Virginia")]

library(data.table)
con <- get_db_conn()
va_hd_cts <- setDT(DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hd_vhd_2021_virginia_health_districts"), row.names = FALSE))
va_ct_acs5_2015_2019_no_health_insurance_19_to_64 <- setDT(DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_ct_acs5_2015_2019_no_health_insurance_19_to_64"), row.names = FALSE))
DBI::dbDisconnect(con)

va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, region_name := tools::toTitleCase(region_name)]

va_hd_cts[name_county %in% c("Alexandria", "Salem","Covington", "Charlottesville","Buena Vista", "Lexington","Staunton", "Waynesboro",
                             "Harrisonburg", "Lynchburg","Chesapeake", "Emporia","Petersburg", "Colonial Heights","Hopewell", "Falls Church",
                             "Hampton", "Winchester", "Bristol", "Galax", "Radford", "Norfolk", "Williamsburg", "Newport News", "Poquoson",
                             "Manassas Park", "Fredericksburg", "Virginia Beach", "Martinsville", 
                             "Portsmouth", "Norton", "Danville", "Suffolk"), name_county := paste0(name_county, " city")]

va_hd_cts[name_county == "James City", name_county := "James City County"]
va_hd_cts[name_county == "Charles City", name_county := "Charles City County"]
va_hd_cts[!name_county %like% "County$" & !name_county %ilike% "city", name_county := paste0(name_county, " County")]
va_hd_cts[name_county %ilike% "city$", name_county := tools::toTitleCase(name_county)]
va_hd_cts[, name_county := paste0(name_county, ", Virginia")]
va_hd_cts$geometry <- NULL


mrg <- merge(va_hd_cts, va_ct_acs5_2015_2019_no_health_insurance_19_to_64, by.x = "name_county", by.y = "region_name")
va_hd_acs5_2015_2019_no_health_insurance_19_to_64 <- mrg[, .(no_hlth_ins_pct = mean(value)), c("health_district", "fid", "year")]

va_hd_acs5_2015_2019_no_health_insurance_19_to_64 <- 
  va_hd_acs5_2015_2019_no_health_insurance_19_to_64[, .(geoid = fid, 
                                                        region_type = "health district", 
                                                        region_name = health_district, 
                                                        year = as.integer(year), 
                                                        measure = "no_hlth_ins_pct", 
                                                        value = no_hlth_ins_pct,
                                                        measure_type = "percent")]

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_hd_acs5_2015_2019_no_health_insurance_19_to_64", va_hd_acs5_2015_2019_no_health_insurance_19_to_64)
DBI::dbDisconnect(con)


# con <- get_db_conn()
# va_hd_cts <- setDT(DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hd_vhd_2021_virginia_health_districts"), row.names = FALSE))
# va_ct_acs5_2015_2019_no_health_insurance_19_to_64 <- setDT(DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_ct_acs5_2015_2019_no_health_insurance_19_to_64"), row.names = FALSE))
# DBI::dbDisconnect(con)
# 
# va_ct_acs5_2015_2019_no_health_insurance_19_to_64[, region_name := tools::toTitleCase(region_name)]
# 
# va_hd_cts[name_county %in% c("Alexandria", "Salem","Covington", "Charlottesville","Buena Vista", "Lexington","Staunton", "Waynesboro",
#                              "Harrisonburg", "Lynchburg","Chesapeake", "Emporia","Petersburg", "Colonial Heights","Hopewell", "Falls Church",
#                              "Hampton", "Winchester", "Bristol", "Galax", "Radford", "Norfolk", "Williamsburg", "Newport News", "Poquoson",
#                              "Manassass Park", "Fredericksburg", "Virginia Beach", "Martinsville"), name_county := paste0(name_county, " city")]
# 
# va_hd_cts[name_county == "James City", name_county := "James City County"]
# va_hd_cts[!name_county %like% "County$" & !name_county %ilike% "city", name_county := paste0(name_county, " County")]
# va_hd_cts[name_county %ilike% "city$", name_county := tools::toTitleCase(name_county)]
# va_hd_cts[name_county %ilike% "city$", name_county := paste0(name_county, ", Virginia")]
# va_hd_cts$geometry <- NULL
# 
# 
# mrg <- merge(va_hd_cts, va_ct_acs5_2015_2019_no_health_insurance_19_to_64, by.x = "name_county", by.y = "region_name")
# va_hd_acs5_2015_2019_no_health_insurance_19_to_64 <- mrg[, .(no_hlth_ins_pct = mean(value)), c("health_district", "fid", "year")]
# 
# va_hd_acs5_2015_2019_no_health_insurance_19_to_64 <- 
#   va_hd_acs5_2015_2019_no_health_insurance_19_to_64[, .(geoid = fid, 
#                                                       region_type = "health district", 
#                                                       region_name = health_district, 
#                                                       year = as.integer(year), 
#                                                       measure = "no_hlth_ins_pct", 
#                                                       value = no_hlth_ins_pct,
#                                                       measure_type = "percent")]
# 
# con <- get_db_conn()
# dc_dbWriteTable(con, "dc_health_behavior_diet", "va_hd_acs5_2015_2019_no_health_insurance_19_to_64", va_hd_acs5_2015_2019_no_health_insurance_19_to_64)
# DBI::dbDisconnect(con)


# CREATE VIEWS

sql <- "DROP VIEW IF EXISTS dc_webapp.health__primary_care_acccess_scores;
        CREATE VIEW dc_webapp.health__primary_care_acccess_scores AS 
        SELECT * FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_sdad_2021_primary_care_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_sdad_2021_primary_care_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_hd_sdad_2021_primary_care_acccess_scores
        ) t
        WHERE measure IN ('primcare_cnt', 'primcare_e2sfca')
        ORDER BY region_name;"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__primary_care_acccess_scores OWNER TO data_commons")
DBI::dbDisconnect(con)

sql <- "DROP VIEW IF EXISTS dc_webapp.health__obgyn_acccess_scores;
        CREATE VIEW dc_webapp.health__obgyn_acccess_scores AS
        SELECT * FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_sdad_2021_obgyn_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_sdad_2021_obgyn_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_hd_sdad_2021_obgyn_acccess_scores
        ) t
        WHERE measure IN ('obgyn_cnt', 'obgyn_e2sfca') 
        ORDER BY region_name;"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__obgyn_acccess_scores OWNER TO data_commons")
DBI::dbDisconnect(con)

sql <- "DROP VIEW IF EXISTS dc_webapp.health__dentist_acccess_scores;
        CREATE VIEW dc_webapp.health__dentist_acccess_scores AS
        SELECT * FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_sdad_2021_dentist_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_sdad_2021_dentist_acccess_scores
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_hd_sdad_2021_dentist_acccess_scores
        ) t
        WHERE measure IN ('dent_cnt', 'dent_e2sfca') 
        ORDER BY region_name"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER VIEW dc_webapp.health__dentist_acccess_scores OWNER TO data_commons")
DBI::dbDisconnect(con)



sql <- "DROP TABLE IF EXISTS dc_health_behavior_diet.va_hdcttr_acs5_2015_2019_no_health_insurance_19_to_64;
        SELECT *
        INTO dc_health_behavior_diet.va_hdcttr_acs5_2015_2019_no_health_insurance_19_to_64
        FROM
        (SELECT * 
        FROM dc_health_behavior_diet.va_ct_acs5_2015_2019_no_health_insurance_19_to_64
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_tr_acs5_2015_2019_no_health_insurance_19_to_64
        UNION
        SELECT * 
        FROM dc_health_behavior_diet.va_hd_acs5_2015_2019_no_health_insurance_19_to_64
        ) t
        WHERE measure IN ('no_hlth_ins_pct') 
        ORDER BY region_name, year"
con <- get_db_conn()
DBI::dbSendQuery(con, sql)
DBI::dbSendQuery(con, "ALTER TABLE dc_health_behavior_diet.va_hdcttr_acs5_2015_2019_no_health_insurance_19_to_64 OWNER TO data_commons")
DBI::dbDisconnect(con)


# Write new CSVs
con <- get_db_conn()
df <- DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hdcttr_sdad_2021_primary_care_access_scores"))
write.csv(df, "data/dc_webapp/va_hdcttr_sdad_2021_primary_care_access_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hdcttr_sdad_2021_obgyn_access_scores"))
write.csv(df, "data/dc_webapp/va_hdcttr_sdad_2021_obgyn_access_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hdcttr_sdad_2021_dentist_access_scores"))
write.csv(df, "data/dc_webapp/va_hdcttr_sdad_2021_dentist_access_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hdcttr_sdad_2021_pediatrics_access_scores"))
write.csv(df, "data/dc_webapp/va_hdcttr_sdad_2021_pediatrics_access_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_hdcttr_acs5_2015_2019_no_health_insurance_19_to_64"))
write.csv(df, "data/dc_webapp/va_hdcttr_acs5_2015_2019_no_health_insurance_19_to_64.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_health_behavior_diet", "va_ct_chr_2015_2021_preventable_hospitalizations"))
write.csv(df, "data/dc_webapp/va_ct_chr_2015_2021_preventable_hospitalizations.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_education_training", "va_hdcttr_sdad_2021_daycare_services_access_scores"))
write.csv(df, "data/dc_webapp/va_hdcttr_sdad_2021_daycare_services_access_scores.csv", row.names = FALSE)

df <- DBI::dbReadTable(con, c("dc_webapp", "category_measures"))
write.csv(df, "data/dc_webapp/category_measures.csv", row.names = FALSE)

DBI::dbDisconnect(con)



con <- get_db_conn()
category_measures <- DBI::dbReadTable(con, c("dc_webapp", "category_measures"))
DBI::dbDisconnect(con)

category_measures[category_measures$measure=="primcare_e2sfca",]$measure <- "prim_e2sfca"
category_measures[category_measures$measure=="primcare_cnt",]$measure <- "prim_cnt"
category_measures[category_measures$measure_table=="dc_health_behavior_diet.va_hdcttr_sdad_2021_primary_care_acccess_scores",]$measure_table <- "dc_health_behavior_diet.va_hdcttr_sdad_2021_primary_care_access_scores"

new_cat_meas <- data.frame(
  category = c("Health", "Health", "Broadband", "Broadband"),
  measure = c("ped_e2sfca", "ped_cnt", "perc_have_computer", "perc_have_internet_access"),
  measure_table = c("dc_health_behavior_diet.va_hdcttr_sdad_2021_pediatrics_access_scores", 
                    "dc_health_behavior_diet.va_hdcttr_sdad_2021_pediatrics_access_scores",
                    "dc_digital_communications.va_hdcttr_acs5_2019_have_computer",
                    "dc_digital_communications.va_hdcttr_acs5_2019_have_internet")
)
category_measures <- rbind(category_measures, new_cat_meas)
category_measures <- category_measures[order(category_measures$category),]

con <- get_db_conn()
DBI::dbSendQuery(con, "DROP TABLE dc_webapp.category_measures")
dc_dbWriteTable(con, "dc_webapp", "category_measures", category_measures)
DBI::dbDisconnect(con)

write.csv(category_measures, "data/dc_webapp/category_measures.csv")



