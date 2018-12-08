library(rvest)
library(RSelenium)
library(plotly)

#################get KRX stock table and create data frame ##################
{
  df_kospi ="http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13&marketType=stockMkt" %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table') %>%
    html_table() %>%
    .[[1]]
  df_kospi$시장구분 = 'KOSPI'
  
  df_kosdaq = "http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13&marketType=kosdaqMkt" %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table') %>%
    html_table() %>%
    .[[1]]
  df_kosdaq$시장구분 = 'KOSDAQ'
  
  df_konex = "http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13&marketType=konexMkt" %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table') %>%
    html_table() %>%
    .[[1]]
  df_konex$시장구분 = 'KONEX'
  
  stock_table = rbind(df_kospi,df_kosdaq,df_konex)
  stock_table[[2]] = sprintf("%06d",stock_table[[2]]) 
  stock_table = stock_table[,c(1,2,10,3:9)]
  View(stock_table)
}
#############################################################################

pjs = wdman::phantomjs(port = 1111L, version = "2.1.1") # need to install 'wdman' package
remDr = remoteDriver(remoteServerAddr = 'localhost',
                     browserName ='phantomjs',
                     port = 1111L)
remDr$open(silent = T)

kr_fs = function(com) {
  ticker = stock_table[grep(pattern = com,x=stock_table[,1],ignore.case = TRUE),2] %>%
    .[[1]]
  remDr$navigate(paste0('https://companyinfo.stock.naver.com/v1/company/c1010001.aspx?cmp_cd=',ticker)) 
  
  kr_table = remDr$getPageSource()[[1]] %>%
    read_html() %>%
    html_nodes('table') %>%
    .[13] %>%
    html_table(fill=TRUE) %>%
    .[[1]]
  
  colnames(kr_table) = kr_table[1,] 
  kr_table = kr_table[-1,]
  rownames(kr_table) = kr_table[,1]
  kr_table = kr_table[,-1]
  View(kr_table,title = paste0(ticker,':Finance Summary'))
  
  date = gsub('\t|\r|\n','',x=colnames(kr_table)) 
  p1 = plot_ly(data = data.frame(gsub('\t|\r|','',x=kr_table[1,])),
               x= ~date ,
               y = as.numeric(gsub(',','',kr_table[1,])),
               type = 'bar',name = '매출액') 
  
  p2 = plot_ly(data = data.frame(gsub('\t|\r','',x=kr_table[2,])),
               x= ~date, 
               y = as.numeric(gsub(',','',kr_table[2,])),
               type = 'bar',name = '영업이익') 
  
  p3 = plot_ly(data = data.frame(gsub('\t|\r','',x=kr_table[6,])),
               x= ~date, 
               y = as.numeric(gsub(',','',kr_table[6,])),
               type = 'bar',name = '당기순이익') 
  subplot(p1,p2,p3,nrows = 3, shareX = TRUE)
}


remDr$close()
pjs$stop()
