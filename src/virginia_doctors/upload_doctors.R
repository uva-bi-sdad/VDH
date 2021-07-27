source("src/helper_functions.R")
library(data.table)

file_paths <- list.files("src/tmp", full.names = T)

con <- get_db_conn(db_host = "localhost", db_port = 5434)
dbSendQuery(con, "TRUNCATE TABLE data_commons.virginia_primary_care_doctors")

for (i in 1:length(file_paths)) {
  dt <- fread(file_paths[i])
  dbWriteTable(con, c("data_commons", "virginia_primary_care_doctors"), dt, overwrite = F, append = T, row.names = F)
}

dbDisconnect(con)

con <- get_db_conn(db_host = "localhost", db_port = 5434)
dbSendQuery(con, "SELECT DISTINCT * INTO data_commons.virginia_primary_care_doctors_unq FROM data_commons.virginia_primary_care_doctors")
dbSendQuery(con, "DROP TABLE data_commons.virginia_primary_care_doctors")
dbSendQuery(con, "ALTER TABLE data_commons.virginia_primary_care_doctors_unq RENAME TO virginia_primary_care_doctors")
dbSendQuery(con, "ALTER TABLE data_commons.virginia_primary_care_doctors OWNER TO data_commons")
dbDisconnect(con)
