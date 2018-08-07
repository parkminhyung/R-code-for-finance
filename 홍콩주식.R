library(rvest)
library(RSelenium)

pjs = wdman::phantomjs(port = 1111L, version = "2.1.1") # need to install 'wdman' package
remDr = remoteDriver(remoteServerAddr = 'localhost',
                     browserName ='phantomjs',
                     port = 1111L)

remDr$open(silent = T)
remDr$navigate("http://quote.eastmoney.com/center/gridlist.html#hk_stocks")

hk_url = remDr$findElement(using = 'xpath', value = '//*[@id="main-table_next"]')

hk_st = list()
hk_table = list()
for (i in 1:115) {
    hk_url$clickElement()
    
    hk_table = remDr$getPageSource()[[1]] %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="main-table"]') %>%
      html_table(fill = TRUE) %>%
      .[[1]]
    
    hk_st[[i]] = hk_table
    
  cat(i/115*100,"% :crawling in progress","\n")
}

hk_table = do.call("rbind",hk_st) 
hk_table = hk_table[,-c(1,4,14)]
View(hk_table)

remDr$close()
pjs$stop()
