library(rvest)
library(quantmod)

############ creating KRX data frame ############
KRX_data = 'http://bigdata-trader.com/itemcodehelp.jsp' %>%
  read_html %>%
  html_nodes('table') %>%
  .[1] %>%
  html_table() %>%
  .[[1]]
######################################################

KRX_data = KRX_data[grep(pattern = 'KOSDAQ|KOSPI',x=KRX_data[,3]),]
KRX_data[grep(pattern = 'KOSDAQ',x= KRX_data[,3]),1] = paste0(KRX_data[grep(pattern = 'KOSDAQ',x= KRX_data[,3]),1],'.KQ')
KRX_data[grep(pattern = 'KOSPI',x= KRX_data[,3]),1] = paste0(KRX_data[grep(pattern = 'KOSPI',x= KRX_data[,3]),1],'.KS')
colnames(KRX_data) = c("종목코드", "종목이름","종류")  
View(KRX_data)

start_date = '2018-01-01'
end_date = Sys.Date()
stock_data = new.env()
stock_data_kr = list()

for (i in 1:nrow(KRX_data)) {
  stock_data_kr[i] = sapply(KRX_data[i,1], function(x){
    try(
      getSymbols(
        x,
        src ="yahoo",
        from = start_date,
        to = end_date,
        env = stock_data,
        auto.assign = TRUE),silent = FALSE)
  })
  cat(KRX_data[i,1],": download complete", "\n")
}
