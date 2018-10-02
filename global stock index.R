library(quantmod)
library(rvest)

world_indi = 'https://finance.yahoo.com/world-indices' %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="yfin-list"]/div[2]/div/div/table') %>%
  html_table(fill = TRUE) %>%
  .[[1]] %>%
  .[,-c(6:9)] 

world_indi$CODE = NA 
world_indi$COUNTRY = NA
world_indi = world_indi[,c(1,6:7,2:5)]
try({
  world_indi[grep(pattern = "\\^GSPC|\\^DJI|\\^IXIC|\\^NYA|\\^XAX|\\^RUT|\\^VIX",x=world_indi[,1]),c(2:3)] = list("USA","United States")
  world_indi[grep(pattern = '\\^BUK100P|\\^FTSE',x=world_indi[,1]),c(2:3)] = list("GBR","United Kingdom")
  world_indi[grep(pattern = '\\^GDAXI',x=world_indi[,1]),c(2:3)] = list("DEU","GERMANY")
  world_indi[grep(pattern = '\\^FCHI',x=world_indi[,1]),c(2:3)] = list("FRA","FRANCE")
  world_indi[grep(pattern = '\\^STOXX50E|\\^AXJO|\\^AORD',x=world_indi[,1]),c(2:3)] = list("AUS","Australia")
  world_indi[grep(pattern = '\\^N100',x=world_indi[,1]),c(2:3)] = list("NLD","Nederland")
  world_indi[grep(pattern = '\\^BFX',x=world_indi[,1]),c(2:3)] = list("BEL","Belgium")
  world_indi[grep(pattern = '\\IMOEX.ME',x=world_indi[,1]),c(2:3)] = list("RUS","Russia")
  world_indi[grep(pattern = '\\^N225',x=world_indi[,1]),c(2:3)] = list("JPN","Japan")
  world_indi[grep(pattern = '\\000001.SS',x=world_indi[,1]),c(2:3)] = list("CHN","China")
  world_indi[grep(pattern = '\\^STI',x=world_indi[,1]),c(2:3)] = list("SGP","Singapore")
  world_indi[grep(pattern = '\\^BSESN',x=world_indi[,1]),c(2:3)] = list("IND","India")
  world_indi[grep(pattern = '\\^JKSE',x=world_indi[,1]),c(2:3)] = list("IDN","Indonesia")
  world_indi[grep(pattern = '\\^KLSE',x=world_indi[,1]),c(2:3)] = list("MYS","Malaysia")
  world_indi[grep(pattern = '\\^NZ50',x=world_indi[,1]),c(2:3)] = list("NZL","New Zealand")
  world_indi[grep(pattern = '\\^KS11',x=world_indi[,1]),c(2:3)] = list("KOR","South Korea")
  world_indi[grep(pattern = '\\^TWII',x=world_indi[,1]),c(2:3)] = list("TWN","Taiwan")
  world_indi[grep(pattern = '\\^GSPTSE',x=world_indi[,1]),c(2:3)] = list("CAN","CANADA")
  world_indi[grep(pattern = '\\^BVSP',x=world_indi[,1]),c(2:3)] = list("BRA","BRAZIL")
  world_indi[grep(pattern = '\\^MXX',x=world_indi[,1]),c(2:3)] = list("MEX","MEXICO")
  world_indi[grep(pattern = '\\^IPSA',x=world_indi[,1]),c(2:3)] = list("CHL","CHILE")
  world_indi[grep(pattern = '\\^MERV',x=world_indi[,1]),c(2:3)] = list("ARG","Argentina")
  world_indi[grep(pattern = '\\^TA125.TA',x=world_indi[,1]),c(2:3)] = list("ISR","Israel")
  world_indi[grep(pattern = '\\^CASE30',x=world_indi[,1]),c(2:3)] = list("EGY","Egypt")
  world_indi[grep(pattern = '\\^HSI',x=world_indi[,1]),c(2:3)] = list("HKG","HONGKONG")
})
View(world_indi)

global_tickers = paste(world_indi[[1]],sep = ',',collapse = NULL)
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
  cat(global_tickers[i],": download complete", "\n")
}

