library(rvest)
library(RSelenium)
library(progress)

pjs = wdman::phantomjs(port = 1111L, version = "2.1.1") # need to install 'wdman' package
remDr = remoteDriver(remoteServerAddr = 'localhost',
                     browserName ='phantomjs',
                     port = 1111L)

remDr$open(silent = T)
remDr$navigate("http://quote.eastmoney.com/center/gridlist.html#hk_stocks")

hk_url = remDr$findElement(using = 'xpath', value = '//*[@id="main-table_next"]')

hk_st = list()
hk_table = list()
pb = progress_bar$new(total = 115)
for (i in 1:115) {
  
    Sys.sleep(2)
    
    hk_url$clickElement()
    
    hk_table = remDr$getPageSource()[[1]] %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="main-table"]') %>%
      html_table(fill = TRUE) %>%
      .[[1]]
    
    hk_st[[i]] = hk_table
    
    pb$tick()
}

hk_table = do.call("rbind",hk_st) %>%
  .[,-c(1,4,14)]

hk_table[[1]] = sprintf("%05d",as.integer(hk_table[[1]]))
View(hk_table)

remDr$close()
pjs$stop()
