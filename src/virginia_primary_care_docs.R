library(RPostgreSQL)
library(data.table)
source("src/helper_functions.R")

file_paths <- list.files("data/virginia_primary_care_docs", full.names = T)

dt <- fread(file_paths[1])
con <- get_db_conn()
dbWriteTable(con, c("data_commons", "virginia_primary_care_doctors"), dt)

for (i in 2:length(file_paths)) {
  dt <- fread(file_paths[i])
  dbWriteTable(con, c("data_commons", "virginia_primary_care_doctors"), dt, overwrite = F, append = T)
}
dbDisconnect(con)
