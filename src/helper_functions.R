library(RPostgreSQL)

# connect to database function
get_db_conn <-
  function(db_name = Sys.getenv("db_nam"),
           db_host = Sys.getenv("db_hst"),
           db_port = Sys.getenv("db_prt"),
           db_user = Sys.getenv("db_usr"),
           db_pass = Sys.getenv("db_pwd")) {
    RPostgreSQL::dbConnect(
      drv = RPostgreSQL::PostgreSQL(),
      dbname = db_name,
      host = db_host,
      port = db_port,
      user = db_user,
      password = db_pass
    )
  }


