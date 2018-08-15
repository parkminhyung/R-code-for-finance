library(rvest)
library(RSelenium)
library(progress)
library(plyr)
library(plotly)


##################create data frame##################
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
########################################################################
########################################################################

hk_fs = function(x) {
  hk_df1 = paste0('http://stock.finance.sina.com.cn/hkstock/finance/',x,'.html') %>%
    read_html(encoding = 'GBK') %>%
    html_nodes(xpath = '/html/body/div/div[9]/div/div[2]/div/table') %>%
    .[[1]] %>%
    html_table(fill=TRUE) %>%
    .[c(1,3,20,4:6,11),] 
  
  hk_df2 = paste0('http://stock.finance.sina.com.cn/hkstock/finance/',x,'.html') %>%
    read_html(encoding = 'GBK') %>%
    html_nodes(xpath = '/html/body/div/div[7]/div/div[2]/div/table') %>%
    .[[1]] %>%
    html_table(fill=TRUE) %>%
    .[c(1,18,19,4,3,24,5,7,25,9),]
  
  hk_df3 = paste0('http://stock.finance.sina.com.cn/hkstock/finance/',x,'.html') %>%
    read_html(encoding = 'GBK') %>%
    html_nodes(xpath = '/html/body/div/div[8]/div/div[2]/div/table') %>%
    .[[1]] %>%
    html_table(fill=TRUE) %>%
    .[c(1,7,3:6,8),]
  
  hk_table2 = list()
  hk_table2 = rbind.fill(hk_df1,hk_df2,hk_df3) 
  rownames(hk_table2) = c('===손익계산서:보고날짜',
                          '매출액',
                          '영업이익',
                          '세전영업이익',
                          '법인세비용',
                          '세후영업이익',
                          '주당손익',
                          '===재무상태표:보고날짜',
                          '매출채권',
                          '재고자산',
                          '유동자산',
                          '비유동자산',
                          '총자산',
                          '유동부채',
                          '비유동부채',
                          '총부채',
                          '총자본',
                          '===현금흐름표:보고날짜',
                          '기초현금흐름',
                          '경영활동현금흐름',
                          '투자활동으로인한현금흐름',
                          '재무활동으로인한현금흐름',
                          '현금및현금등가물증가액',
                          '기말현금흐름')
  hk_table2 = hk_table2[,-1]
  
  date = as.Date(as.character(hk_table2[1,]))
  p1 = plot_ly(data=as.data.frame(hk_table2),
               x = date,
               y= as.numeric(gsub(',','',x=hk_table2[2,])),
               type = 'bar', name = '매출액')
  p2 = plot_ly(data=data.frame(hk_table2), 
               x= date,
               y= as.numeric(gsub(',','',x=hk_table2[6,])), 
               type = 'bar', name = '당기순이익')
  p3 = plot_ly(data=data.frame(hk_table2), 
               x= date,
               y= as.numeric(gsub(',','',x=hk_table2[7,])), 
               type = 'bar', name = '주당손익')
  subplot(p1,p2,p3,nrows = 3,shareX = TRUE) %>%
    print()
  colnames(hk_table2) = NA
  View(x=hk_table2,title = paste0("B/S:",x))
}

