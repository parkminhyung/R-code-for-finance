library(rvest)
library(quantmod)

############ creating KRX data frame ############
KRX_list = 'http://bigdata-trader.com/itemcodehelp.jsp' %>%
  read_html %>%
  html_nodes('table') %>%
  .[1] %>%
  html_table() %>%
  .[[1]]
colnames(KRX_list) = c("종목코드", "종목이름","종류")  
######################################################

############ separate KOSPI and KOSDAQ data ############
KOSPI = data.frame()
KOSDAQ = data.frame()
KRX_list[grep(pattern = 'KOSDAQ',x= KRX_list[,3]),1] = paste0(KRX_list[grep(pattern = 'KOSDAQ',x= KRX_list[,3]),1],'.KQ')
KRX_list[grep(pattern = 'KOSPI',x= KRX_list[,3]),1] = paste0(KRX_list[grep(pattern = 'KOSPI',x= KRX_list[,3]),1],'.KS')

KOSDAQ = KRX_list[grep(pattern = 'KOSDAQ',x= KRX_list[,3]),]
KOSPI = KRX_list[grep(pattern = 'KOSPI',x= KRX_list[,3]),]

View(rbind(KOSPI,KOSDAQ)) 

############ set up ticker, date and new environ ############
KOSPI_tickers = paste(KOSPI[,1],sep = ',',collapse = NULL)
KOSDAQ_tickers = paste(KOSDAQ[,1],sep = ',',collapse = NULL)

start_date = '2015-01-01'
end_date = Sys.Date()
KOS_data = new.env()
KOD_data = new.env()
############################################################

########### KOSPI data ###########
for (i in 1:length(KOSPI_tickers)) {
  sapply(KOSPI_tickers[i], function(x){
    try(
      getSymbols(
        x,
        src ="yahoo",
        from = start_date,
        to = end_date,
        env=KOS_data,
        auto.assign = TRUE),silent = FALSE)
  })
  cat(KOSPI_tickers[i],": download complete", "\n")
}
View(KOS_data)

########### KOSDAQ data ###########
for (i in 1:length(KOSDAQ_tickers)) {
  sapply(KOSDAQ_tickers[i], function(x){
    try(
      getSymbols(
        x,
        src ="yahoo",
        from = start_date,
        to = end_date,
        env=KOD_data,
        auto.assign = TRUE),silent = FALSE)
  })
  cat(KOSDAQ_tickers[i],": download complete", "\n")
}
View(KOD_data)

