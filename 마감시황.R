########IMAGE SOURCE : NAVER
########NEWS SOURCE : PAXNET/INFOSTOCK/SAMSUNGGOLD

{
  if(!require(rvest)){
    install.packages('rvest')
  }
  if(!require(EBImage)) {
    install.packages('devtools')
    devtools::install_github('aoles/EBImage',force = TRUE)
  } 
}

{
  library(rvest)
  library(EBImage)
}

world_mkt_repo = function() {
  
 DATE = c(Sys.Date()+1,Sys.Date())
  
  if(weekdays(Sys.Date())=="Friday") {
    DATE[1] = Sys.Date()+3
  } else if(weekdays(Sys.Date())=="Saturday"){
    DATE[1] = Sys.Date()+2
    DATE[2] = Sys.Date()-1
  } else if(weekdays(Sys.Date())=="Sunday"){
    DATE[1] = Sys.Date()+1
    DATE[2] = Sys.Date()-2
  }
  
  month = c(paste0(format(Sys.Date(),"%m"),'월',format(Sys.Date(),"%d"),'일'),paste0(format(Sys.Date()-1,"%m"),'월',format(Sys.Date()-1,"%d"),'일'))

  par(mfrow = c(3,3))
  
  table = 'https://finance.yahoo.com/world-indices'  %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="yfin-list"]/div[2]/div/div/table') %>%
    html_table(fill = TRUE) %>%
    .[[1]] %>%
    .[c(1:3,16:18,26,27),] %>%
    .[,-c(7:9)]
  rownames(table) = c(1:nrow(table))
  
  korea_table = 'https://www.investing.com/markets/south-korea' %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="market_overview_default"]') %>%
    html_table(fill = TRUE) %>%
    .[[1]] 
  
  curr = 'https://www.investing.com/currencies/single-currency-crosses' %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="cr1"]') %>%
    html_table(fill = TRUE) %>%
    .[[1]] %>%
    .[,-1]
  curr= curr[grep('USD/KRW',curr[,1]),]
  
  commo = 'https://finance.yahoo.com/commodities' %>%
    read_html() %>%
    html_nodes(xpath='//*[@id="yfin-list"]/div[2]/div/div/table') %>%
    html_table(fill = TRUE) %>%
    .[[1]] %>%
    .[,-c(1,9)] %>%
    .[c(1,3,8),] 
  rownames(commo) = c(1:3)
  
  num = 'http://www.samsunggold.co.kr/bbs/board.php?bo_table=news' %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="fboardlist"]/div[1]/table') %>%
    html_table(fill = TRUE) %>%
    .[[1]] 
  num = (num[grep('국내 가격 동향',x=num[,2])[1],1]+1) %>%
    as.numeric()
  
  DOW = 'https://ssl.pstatic.net/imgfinance/chart/mobile/world/day/DJI@DJI_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("DOW30 index",'  ',table[2,5]), adj = c(0,1), col = "black", cex = 1) %>%
    text(x = 60, y = 20, label = table[2,3], adj = c(0,1), col = "black", cex = 1.5)
  
  NASDAQ = 'https://ssl.pstatic.net/imgfinance/chart/mobile/world/day/NAS@IXIC_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("NASDAQ",'  ',table[3,5]), adj = c(0,1), col = "black", cex = 1) %>%
    text(x = 60, y = 20, label = table[3,3], adj = c(0,1), col = "black", cex = 1.5)
  
  SNP = 'https://ssl.pstatic.net/imgfinance/chart/mobile/world/day/SPI@SPX_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("S&P500",'  ',table[1,5]), adj = c(0,1), col = "black", cex = 1) %>%
    text(x = 60, y = 20, label = table[1,3], adj = c(0,1), col = "black", cex = 1.5)
  
  SSEC = 'https://ssl.pstatic.net/imgfinance/chart/mobile/world/day/SHS@000001_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("SHANGHAI",'  ',table[6,5]), adj = c(0,1), col = "black", cex = 1)  %>%
    text(x = 60, y = 20, label = table[6,3], adj = c(0,1), col = "black", cex = 1.5)
  
  HANG = 'https://ssl.pstatic.net/imgfinance/chart/mobile/world/day/HSI@HSI_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("HANGSENG",'  ',table[5,5]), adj = c(0,1), col = "black", cex = 1)  %>%
    text(x = 60, y = 20, label = table[5,3], adj = c(0,1), col = "black", cex = 1.5)
  
  NIKKEI = 'https://ssl.pstatic.net/imgfinance/chart/mobile/world/day/NII@NI225_search.png' %>%
    readImage() %>%
    display(method = 'raster')  %>%
    text(x = 60, y = 5, label = paste0("NIKKEI 225",'  ',table[4,5]), adj = c(0,1), col = "black", cex = 1)  %>%
    text(x = 60, y = 20, label = table[4,3], adj = c(0,1), col = "black", cex = 1.5)
  
  TSEC = 'https://ssl.pstatic.net/imgfinance/chart/mobile/world/day/TWS@TI01_search.png' %>%
    readImage() %>%
    display(method = 'raster')  %>%
    text(x = 60, y = 5, label = paste0("TWII",'  ',table[8,5]), adj = c(0,1), col = "black", cex = 1)  %>%
    text(x = 60, y = 20, label = table[8,3], adj = c(0,1), col = "black", cex = 1.5) 
  
  KOSPI = 'https://ssl.pstatic.net/imgfinance/chart/mobile/day/KOSPI_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("KOSPI",'  ',korea_table[1,4]), adj = c(0,1), col = "black", cex = 1) %>%
    text(x = 60, y = 20, label = korea_table[1,2], adj = c(0,1), col = "black", cex = 1.5)
  
  kosdaq = 'https://ssl.pstatic.net/imgfinance/chart/mobile/day/KOSDAQ_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("KOSDAQ",'  ',korea_table[2,4]), adj = c(0,1), col = "black", cex = 1)  %>%
    text(x = 60, y = 20, label = korea_table[2,2], adj = c(0,1), col = "black", cex = 1.5)
  
  currency = 'https://ssl.pstatic.net/imgfinance/chart/mobile/marketindex/month3/FX_USDKRW_search.png' %>%
    readImage() %>%
    display(method = 'raster')  %>%
    text(x = 60, y = 5, label = paste0("USD/KRW",'  ',curr[1,7]), adj = c(0,1), col = "black", cex = 1)  %>%
    text(x = 60, y = 20, label = paste0('Bid:',curr[1,2]), adj = c(0,1), col = "black", cex = 1.2) %>%
    text(x = 60, y = 35, label = paste0("Ask:",curr[1,3]), adj = c(0,1), col = "black", cex = 1.2)
  
  GOLD = 'https://ssl.pstatic.net/imgfinance/chart/mobile/marketindex/month3/CMDT_GC_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("GOLD",'  ',commo[1,5]), adj = c(0,1), col = "black", cex = 1) %>%
    text(x = 60, y = 20, label = commo[1,2], adj = c(0,1), col = "black", cex = 1.5)
  
  SILVER = 'https://ssl.pstatic.net/imgfinance/chart/mobile/marketindex/month3/CMDT_SI_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("SILVER",'  ',commo[2,5]), adj = c(0,1), col = "black", cex = 1) %>%
    text(x = 60, y = 20, label = commo[2,2], adj = c(0,1), col = "black", cex = 1.5)
  
  WTI = 'https://ssl.pstatic.net/imgfinance/chart/mobile/marketindex/month3/OIL_CL_search.png' %>%
    readImage() %>%
    display(method = 'raster') %>%
    text(x = 60, y = 5, label = paste0("WTI",'  ',commo[3,5]), adj = c(0,1), col = "black", cex = 1) %>%
    text(x = 60, y = 20, label = commo[3,2], adj = c(0,1), col = "black", cex = 1.5)
  
  ################################################################
  ############################################################NEWS 
  
  US = paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=F&market=US&sendDate=',DATE[2]) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>') 
  if(length(grep(month[2],x=US)) == 0){
    US[1] = '마감시황을 아직 이용하실 수 없습니다'
    US = US[[1]]
  }else {
    US = US[[grep(month[2],x=US)]] %>%
      gsub(pattern = '<p>|</p>|<br>','',x=.)
  }
  
  CHINA = paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=F&market=CH&sendDate=',DATE[1]) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>')
  if(length(grep(month[1],x=CHINA)) == 0){
    CHINA[1] = '마감시황을 아직 이용하실 수 없습니다'
    CHINA = CHINA[[1]]
  }else {
    CHINA = CHINA[[grep(month[1],x=CHINA)]] %>%
      gsub(pattern = '<p>|</p>|<br>','',x=.)
  }
  
  JAPAN = paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=F&market=JP&sendDate=',DATE[1]) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>')
  if(length(grep(month[1],x=JAPAN)) == 0){
    JAPAN[1] = '마감시황을 아직 이용하실 수 없습니다'
    JAPAN = JAPAN[[1]]
  }else {
    JAPAN = JAPAN[[grep(month[1],x=JAPAN)]] %>%
      gsub(pattern = '<p>|</p>|<br>','',x=.)
  }
  
  TAIWAN = paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=F&market=TW&sendDate=',DATE[1]) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>') 
  if(length(grep(month[1],x=TAIWAN)) == 0){
    TAIWAN[1] = '마감시황을 아직 이용하실 수 없습니다'
    TAIWAN = TAIWAN[[1]]
  }else {
    TAIWAN = TAIWAN[[grep(month[1],x=TAIWAN)]] %>%
      gsub(pattern = '<p>|</p>|<br>','',x=.)
  }
  
  CRUDEOIL = paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=F&market=PE&sendDate=',DATE[2]) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>')  
  if(length(grep(month[2],x=CRUDEOIL)) == 0){
    CRUDEOIL[1] = '마감시황을 아직 이용하실 수 없습니다'
    CRUDEOIL = CRUDEOIL[[1]]
  }else {
    CRUDEOIL = CRUDEOIL[[grep(month[2],x=CRUDEOIL)]] %>%
      gsub(pattern = '<p>|</p>|<br>','',x=.)
  }
  
  KOSPI =paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=D&market=KS1&sendDate=',DATE[1]) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>') 
  if(!grepl('[가-힣]',KOSPI[1])==TRUE){
    KOSPI[1] = '마감시황을 아직 이용하실 수 없습니다'
    KOSPI = KOSPI[[1]]
  } else {
    KOSPI = KOSPI[[1]]
    KOSPI[1] = gsub(pattern = '<p>','',x=KOSPI[1])
    KOSPI[length(KOSPI)] = gsub(pattern = '</p>','',x=KOSPI[length(KOSPI)])
  }
  
  KOSDAQ = paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=D&market=KS2&sendDate=',DATE[1]) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>') 
  if(!grepl('[가-힣]',KOSDAQ[1])==TRUE){
    KOSDAQ[1] = '마감시황을 아직 이용하실 수 없습니다'
    KOSDAQ = KOSDAQ[[1]]
  } else {
    KOSDAQ = KOSDAQ[[1]]
    KOSDAQ[1] = gsub(pattern = '<p>','',x=KOSDAQ[1])
    KOSDAQ[length(KOSDAQ)] = gsub(pattern = '</p>','',x=KOSDAQ[length(KOSDAQ)])
  }
  
  CURRENCY = paste0('http://www.paxnet.co.kr/stock/infoStock/marketView?type=D&market=KE&sendDate=',DATE[1]) %>%
    read_html() %>%
    html_nodes(xpath='//*[@id="span_article_content"]/p') %>%
    as.character() %>%
    strsplit('<br><br>') 
  if(length(grep(month[1],x=CURRENCY)) == 0){
    CURRENCY[1] = '마감시황을 아직 이용하실 수 없습니다'
    CURRENCY = CURRENCY[[1]]
  }else {
    CURRENCY = CURRENCY[[grep(month[1],x=CURRENCY)]] %>%
      gsub(pattern = '<p>|</p>|<br>','',x=.)
  }
  
  gs = paste0('http://www.samsunggold.co.kr/bbs/board.php?bo_table=news&wr_id=',num) %>%
    read_html() %>%
    html_nodes('div') %>%
    .[73] %>%
    html_text() %>%
    strsplit('\t|\n|\r') 
  gs = gs[[1]][127:grep(pattern = '은 현물',gs[[1]])]
  
  gs1 = gs[c(1:2)]
  gs2 = gs[c(3:(grep(pattern = '금 현물',gs)-1))] %>%
    paste(collapse = '')
  gs3 = gs[c(grep(pattern = '금 현물',gs):length(gs))]
  GnS = c(gs1,gs2,gs3)
  
  WOD_MKT = list(US,CHINA,JAPAN,TAIWAN,KOSPI,KOSDAQ,CURRENCY,GnS,CRUDEOIL)
  names(WOD_MKT) = c("US","CHINA","JAPAN","TAIWAN","KOSPI","KOSDAQ","CURRENCY","GOLD and SILVER","CRUDEOIL")
  WOD_MKT %>% print()
}

