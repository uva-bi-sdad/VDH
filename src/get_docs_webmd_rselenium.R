# library(RSelenium)
# library(rvest)
# rD <- rsDriver(browser="firefox", port=4599L, verbose=F)
# remDr <- rD[["client"]]
# remDr$navigate("https://datadryad.org/stash/dataset/doi:10.5061/dryad.mn058n7")
# Sys.sleep(5) # give the page time to fully load
# html <- remDr$getPageSource()[[1]]
# page <- read_html(html)
# metrics<-html_nodes(page,"div.o-metrics__number")
# metrics
# 
# 
# #dataONE
# rD <- rsDriver(browser="firefox", port=4591L, verbose=F)
# remDr <- rD[["client"]]
# url<-"https://search.dataone.org/view/doi%3A10.5063%2FR78CMB"
# remDr$navigate(url)
# Sys.sleep(10) # give the page time to fully load
# html <- remDr$getPageSource()[[1]]
# page<-read_html(html)
# metrics<-html_nodes(page,"span.metric-value.badge")
# metrics


"https://doctor.webmd.com/results?q=Primary%20Care&sids=29277,29264,29259&pagenumber=1&d=161&rd=161&sortby=bestmatch&medicare=false&medicaid=false&newpatient=false&isvirtualvisit=false&minrating=0&pt=37.2709,-79.9414&city=Roanoke&state=VA"
"pt=37.5537,-77.4602&city=Richmond&state=VA"
"pt=37.2709,-79.9414&city=Roanoke&state=VA"
"pt=36.9533,-81.0872&city=Wytheville&state=VA"
"pt=36.6929,-77.5444&city=Emporia&state=VA"
"pt=37.2557,-76.0084&city=Cape Charles&state=VA"
"pt=38.3031,-77.4605&city=Fredericksburg&state=VA"
"pt=38.4495,-78.8689&city=Harrisonburg&state=VA"

library(RSelenium)
library(rvest)
library(data.table)

# user <- "aschroed" # Your Sauce Labs username
# pass <- "Iwnftp$$2" # Your Sauce Labs access key 
# port <- 4444
# ip <- paste0(user, ':', pass, "@104.248.112.16")
# rdBrowser <- "firefox"
# 
# remDr <- remoteDriver$new(
#   remoteServerAddr = ip,
#   port = port,
#   browserName = rdBrowser
# )
# 
# remDr$open()
# remDr$setTimeout(type = "page load", milliseconds = 20000)
# remDr$navigate("http://www.google.com/ncr")
# remDr$navigate("http://www.r-project.org")


rD <- rsDriver(browser="firefox", port=4599L, verbose=F)
remDr <- rD[["client"]]
remDr$setTimeout(type = "page load", milliseconds = 20000)

get_page <- function(page_num = 1) {
  remDr$navigate(paste0("https://doctor.webmd.com/results?q=Primary%20Care&sids=29277,29264,29259&pagenumber=", page_num, "&d=161&rd=161&sortby=bestmatch&medicare=false&medicaid=false&newpatient=false&isvirtualvisit=false&minrating=0&pt=38.4495,-78.8689&city=Harrisonburg&state=VA"))
}

get_dr_cards <- function(remDr) {
  page <- remDr$findElements(using = "xpath", value = "//*[@class = 'card-info-wrap']")
  data.frame(link = unlist(sapply(page, function(x){x$getElementAttribute('innerHTML')[[1]]})))
}

get_dr_info <- function(html) {
  dr_name <- html %>% rvest::html_nodes(css = "h2") %>% rvest::html_text()
  dr_specs <- html %>% rvest::html_nodes(css = ".prov-specialty") %>% rvest::html_text()
  dr_addr <- html %>% rvest::html_nodes(css = ".addr-text") %>% rvest::html_text() %>% trimws(., "both")
  data.table(name = dr_name, specialties = dr_specs, address = dr_addr)
}


dr_info_dt <- data.table(name = character(), specialties = character(), address = character())
for (p in 601:1278) {
  Sys.sleep(1)
  print(p)
  get_page(page_num = p)
  dr_cards <- get_dr_cards(remDr)
  if (!is.null(dr_cards)) {
    for (i in 1:nrow(dr_cards)) {
      if (!is.null(dr_cards$link[i])) {
        html <- read_html(dr_cards$link[i])
        dr_info <- get_dr_info(html)
        dr_info_dt <- rbindlist(list(dr_info_dt, dr_info))
      }
    }
  }
}

readr::write_csv(dr_info_dt, "src/tmp/doctor_pages_harrisonburg_601_1278.csv")






remDr$close()









