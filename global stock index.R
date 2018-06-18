library(quantmod)
library(rvest)

global_url = 'https://in.finance.yahoo.com/world-indices/'
global_txt <- read_html(global_url)
global_table <- html_nodes(global_txt,xpath='//*[@id="yfin-list"]/div[2]/div/div/table')
global_table = html_table(global_table)[[1]]
global_table = global_table[,-c(7:9)]
global_table["Country"] <- NA
global_table = global_table[,c(1:2,7,3:6)]
global_table[3] <- c("India","India","United States","United States","Japan","Hongkong",
                     "Australia","Taiwan","Singapore","China","Indonesia","South Korea",
                     "United States","United States","Australia","Malaysia",
                     "United States","United States","United States","United States","Canada",
                     "United Kingdom","Germany","France","Eurozone","Eurozone","Eurozone",
                     "Russia","Brazil","Mexico","Chile","Buenos Aires","Israel","Egypt","United Kingdom",
                     "New Zealand")
View(global_table)

global_tickers = paste(global_table[[1]],sep = ',',collapse = NULL)
start_date = '2015-01-01'
end_date = Sys.Date()
global_data = new.env()

for (i in 1:length(global_tickers)) {
  sapply(global_tickers[i], function(x){
    try(
      getSymbols(
        x,
        src ="yahoo",
        from = start_date,
        to = end_date,
        env=global_data,
        auto.assign = TRUE),silent = FALSE)
  })
  cat(global_tickers[i],": download complete, Data will save into global_data", "\n")
}

