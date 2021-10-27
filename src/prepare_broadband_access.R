options(scipen = 999)
con <- get_db_conn()
digital_equity_idx <- DBI::dbGetQuery(con, "SELECT * FROM dc_digital_communications.va_tr_sdad_2019_2021_dei_index_and_factors WHERE measure_type = 'index'
                                            UNION
                                            SELECT * FROM dc_digital_communications.va_ct_sdad_2019_2021_dei_index_and_factors WHERE measure_type = 'index'
                                            UNION
                                            SELECT * FROM dc_digital_communications.va_hd_sdad_2019_2021_dei_index_and_factors WHERE measure_type = 'index'")
dc_dbWriteTable(con, "dc_digital_communications", "va_hdcttr_sdad_2019_2021_dei_index", digital_equity_idx)

pct_w_broadband <- DBI::dbGetQuery(con, "SELECT * FROM dc_digital_communications.va_tr_acs_2017_2019_perc_pop_with_broadband WHERE measure = 'perc_w_broadband'
                                         UNION
                                         SELECT * FROM dc_digital_communications.va_ct_acs_2017_2019_perc_pop_with_broadband WHERE measure = 'perc_w_broadband'
                                         UNION
                                         SELECT * FROM dc_digital_communications.va_hd_acs_2017_2019_perc_pop_with_broadband WHERE measure = 'perc_w_broadband'")
dc_dbWriteTable(con, "dc_digital_communications", "va_hdcttr_acs_2017_2019_pct_pop_broadband", pct_w_broadband)

pct_w_cable_fiber_dsl <- DBI::dbGetQuery(con, "SELECT * FROM dc_digital_communications.va_tr_acs_2017_2019_perc_pop_with_broadband WHERE measure = 'perc_w_cable_fiber_DSL'
                                               UNION
                                               SELECT * FROM dc_digital_communications.va_ct_acs_2017_2019_perc_pop_with_broadband WHERE measure = 'perc_w_cable_fiber_DSL'
                                               UNION
                                               SELECT * FROM dc_digital_communications.va_hd_acs_2017_2019_perc_pop_with_broadband WHERE measure = 'perc_w_cable_fiber_DSL'")
dc_dbWriteTable(con, "dc_digital_communications", "va_hdcttr_acs_2017_2019_pct_pop_cable_fiber_dsl", pct_w_cable_fiber_dsl)

avg_download_speed <- DBI::dbGetQuery(con, "SELECT * FROM dc_digital_communications.va_tr_ookla_2019_2021_internet_characteristics WHERE measure = 'download'
                                            UNION
                                            SELECT * FROM dc_digital_communications.va_ct_ookla_2019_2021_internet_characteristics WHERE measure = 'download'
                                            UNION
                                            SELECT * FROM dc_digital_communications.va_hd_ookla_2019_2021_internet_characteristics WHERE measure = 'download'")
dc_dbWriteTable(con, "dc_digital_communications", "va_hdcttr_ookla_2019_2021_download_speeds", avg_download_speed)
DBI::dbDisconnect(con)

write_csv(digital_equity_idx, "data/dc_webapp/va_hdcttr_sdad_2019_2021_dei_index.csv")
write_csv(pct_w_broadband, "data/dc_webapp/va_hdcttr_acs5_2017_2019_pct_pop_broadband.csv")
write_csv(pct_w_cable_fiber_dsl, "data/dc_webapp/va_hdcttr_acs5_2017_2019_pct_pop_cable_fiber_dsl.csv")
write_csv(avg_download_speed, "data/dc_webapp/va_hdcttr_ookla_2019_2021_download_speeds.csv")


category_measures <- read.csv("data/dc_webapp/category_measures.csv")
new_cat_meas <- data.frame(
  category = c("Broadband"),
  measure = c("norm_dei", "perc_w_broadband", "perc_w_cable_fiber_DSL", "download"),
  measure_table = c("dc_digital_communications.va_hdcttr_sdad_2019_2021_dei_index", 
                    "dc_digital_communications.va_hdcttr_acs_2017_2019_pct_pop_broadband",
                    "dc_digital_communications.va_hdcttr_acs_2017_2019_pct_pop_cable_fiber_dsl",
                    "dc_digital_communications.va_hdcttr_ookla_2019_2021_download_speeds")
)
category_measures <- rbind(category_measures, new_cat_meas)
write_csv(category_measures, "data/dc_webapp/category_measures.csv")


con <- get_db_conn()
have_internet <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_digital_communications.va_tr_acs_2019_dei_ses_characteristics
                   WHERE measure = 'perc_have_internet_access'
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_digital_communications.va_ct_acs_2019_dei_ses_characteristics
                   WHERE measure = 'perc_have_internet_access'
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_digital_communications.va_hd_acs_2019_dei_ses_characteristics
                   WHERE measure = 'perc_have_internet_access';")
dc_dbWriteTable(con, "dc_digital_communications", "va_hdcttr_acs5_2019_have_internet", have_internet)
write_csv(have_internet, "data/dc_webapp/va_hdcttr_acs5_2019_have_internet.csv")
DBI::dbDisconnect(con)

con <- get_db_conn()
have_computer <- 
  DBI::dbGetQuery(con,
                  "SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_digital_communications.va_tr_acs_2019_dei_ses_characteristics
                   WHERE measure = 'perc_have_computer'
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_digital_communications.va_ct_acs_2019_dei_ses_characteristics
                   WHERE measure = 'perc_have_computer'
                   UNION
                   SELECT geoid::text, region_type, region_name, year::integer, measure, value, measure_type 
                   FROM dc_digital_communications.va_hd_acs_2019_dei_ses_characteristics
                   WHERE measure = 'perc_have_computer';")
dc_dbWriteTable(con, "dc_digital_communications", "va_hdcttr_acs5_2019_have_computer", have_computer)
write_csv(have_computer, "data/dc_webapp/va_hdcttr_acs5_2019_have_computer.csv")
DBI::dbDisconnect(con)




