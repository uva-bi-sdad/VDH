library(data.table)
library(xlsx)

download.file("https://www.countyhealthrankings.org/sites/default/files/media/document/2021%20County%20Health%20Rankings%20Virginia%20Data%20-%20v1_0.xlsx", "data/dc_health_behavior_diet/va_county_health_rankings_2021.xlsx")
download.file("https://www.countyhealthrankings.org/sites/default/files/media/document/2020%20County%20Health%20Rankings%20Virginia%20Data%20-%20v1_0.xlsx", "data/dc_health_behavior_diet/va_county_health_rankings_2020.xlsx")
download.file("https://www.countyhealthrankings.org/sites/default/files/media/document/state/downloads/2019%20County%20Health%20Rankings%20Virginia%20Data%20-%20v1_0.xls", "data/dc_health_behavior_diet/va_county_health_rankings_2019.xlsx")
download.file("https://www.countyhealthrankings.org/sites/default/files/media/document/state/downloads/2018%20County%20Health%20Rankings%20Virginia%20Data%20-%20v3.xls", "data/dc_health_behavior_diet/va_county_health_rankings_2018.xlsx")
download.file("https://www.countyhealthrankings.org/sites/default/files/media/document/state/downloads/2017%20County%20Health%20Rankings%20Virginia%20Data%20-%20v2.xls", "data/dc_health_behavior_diet/va_county_health_rankings_2017.xlsx")
download.file("https://www.countyhealthrankings.org/sites/default/files/media/document/state/downloads/2016%20County%20Health%20Rankings%20Virginia%20Data%20-%20v3.xls", "data/dc_health_behavior_diet/va_county_health_rankings_2016.xlsx")
download.file("https://www.countyhealthrankings.org/sites/default/files/media/document/state/downloads/2015%20County%20Health%20Rankings%20Virginia%20Data%20-%20v3.xls", "data/dc_health_behavior_diet/va_county_health_rankings_2015.xlsx")




county_hlth_rnks_2021<- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2021.xlsx", sheetName = "Ranked Measure Data", header = TRUE, startRow = 2))
county_hlth_rnks_2021_additional <- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2021.xlsx", sheetName = "Additional Measure Data", header = TRUE, startRow = 2))

county_hlth_rnks_2020<- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2020.xlsx", sheetName = "Ranked Measure Data", header = TRUE, startRow = 2))
county_hlth_rnks_2020_additional <- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2020.xlsx", sheetName = "Additional Measure Data", header = TRUE, startRow = 2))

county_hlth_rnks_2019<- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2019.xlsx", sheetName = "Ranked Measure Data", header = TRUE, startRow = 2))
county_hlth_rnks_2019_additional <- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2019.xlsx", sheetName = "Additional Measure Data", header = TRUE, startRow = 2))

county_hlth_rnks_2018<- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2018.xlsx", sheetName = "Ranked Measure Data", header = TRUE, startRow = 2))
county_hlth_rnks_2018_additional <- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2018.xlsx", sheetName = "Additional Measure Data", header = TRUE, startRow = 2))

county_hlth_rnks_2017<- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2017.xlsx", sheetName = "Ranked Measure Data", header = TRUE, startRow = 2))
county_hlth_rnks_2017_additional <- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2017.xlsx", sheetName = "Additional Measure Data", header = TRUE, startRow = 2))

county_hlth_rnks_2016<- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2016.xlsx", sheetName = "Ranked Measure Data", header = TRUE, startRow = 2))
county_hlth_rnks_2016_additional <- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2016.xlsx", sheetName = "Additional Measure Data", header = TRUE, startRow = 2))

county_hlth_rnks_2015<- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2015.xlsx", sheetName = "Ranked Measure Data", header = TRUE, startRow = 2))
county_hlth_rnks_2015_additional <- setDT(xlsx::read.xlsx("data/dc_health_behavior_diet/va_county_health_rankings_2015.xlsx", sheetName = "Additional Measure Data", header = TRUE, startRow = 2))

dt2021 <- county_hlth_rnks_2021[!is.na(county_hlth_rnks_2021$County), .(geoid = FIPS, region_type = "county", year = "2021", measure = "prevent_hosp_rate", value = Preventable.Hospitalization.Rate, measure_type = "rate per 100k")]
dt2020 <- county_hlth_rnks_2020[!is.na(county_hlth_rnks_2020$County), .(geoid = FIPS, region_type = "county", year = "2020", measure = "prevent_hosp_rate", value = Preventable.Hospitalization.Rate, measure_type = "rate per 100k")]
dt2019 <- county_hlth_rnks_2019[!is.na(county_hlth_rnks_2019$County), .(geoid = FIPS, region_type = "county", year = "2019", measure = "prevent_hosp_rate", value = Preventable.Hosp..Rate, measure_type = "rate per 100k")]
dt2018 <- county_hlth_rnks_2018[!is.na(county_hlth_rnks_2018$County), .(geoid = FIPS, region_type = "county", year = "2018", measure = "prevent_hosp_rate", value = Preventable.Hosp..Rate, measure_type = "rate per 100k")]
dt2017 <- county_hlth_rnks_2017[!is.na(county_hlth_rnks_2017$County), .(geoid = FIPS, region_type = "county", year = "2017", measure = "prevent_hosp_rate", value = Preventable.Hosp..Rate, measure_type = "rate per 100k")]
dt2016 <- county_hlth_rnks_2016[!is.na(county_hlth_rnks_2016$County), .(geoid = FIPS, region_type = "county", year = "2016", measure = "prevent_hosp_rate", value = Preventable.Hosp..Rate, measure_type = "rate per 100k")]
dt2015 <- county_hlth_rnks_2015[!is.na(county_hlth_rnks_2015$County), .(geoid = FIPS, region_type = "county", year = "2015", measure = "prevent_hosp_rate", value = Preventable.Hosp..Rate, measure_type = "rate per 100k")]

dt <- rbindlist(list(dt2021, dt2020, dt2019, dt2018, dt2017, dt2016, dt2015))

con <- get_db_conn()
dc_dbWriteTable(con, "dc_health_behavior_diet", "va_ct_chr_2015_2021_preventable_hospitalizations", dt)
DBI::dbDisconnect(con)
