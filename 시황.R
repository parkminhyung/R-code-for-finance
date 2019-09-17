world_mkt_repo = function(market = NULL) {
  
  library(rvest)
  library(EBImage)
  
  if(weekdays(Sys.Date()) == "Saturday"){
    DATE = paste0(format(Sys.Date(),"%Y"),"/",format(Sys.Date(),"%m"),"/",format(Sys.Date()-1,"%d"))
  } else if(weekdays(Sys.Date())=="Sunday") {
    DATE = paste0(format(Sys.Date(),"%Y"),"/",format(Sys.Date(),"%m"),"/",format(Sys.Date()-2,"%d"))
  } else {
    DATE = paste0(format(Sys.Date(),"%Y"),"/",format(Sys.Date(),"%m"),"/",format(Sys.Date(),"%d"))
  }
  
  if(is.null(market)) {
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
    
    jnews = 'http://news.moneta.co.kr/Service/stock/ShellSection.asp?LinkID=370&wlog_News=JuyoNews' %>%
      read_html() %>%
      html_nodes('#contant2 > ul')
    
    wnews = 'http://news.moneta.co.kr/Service/stock/ShellSection.asp?LinkID=373&wlog_News=WorldNews' %>%
      read_html() %>%
      html_nodes('#contant2 > ul')
    
    cat("===============================[글로벌뉴스]=====================================",
        "\n")
    for (i in 1:10) {
      cat(paste0("[",i,"]"," ",wnews %>% 
                   html_nodes(paste0('li:nth-child(',i,') > a > strong')) %>%
                   html_text(trim = TRUE)),"\n")
      
    }
    cat("================================[주요뉴스]=====================================",
        "\n")
    for (i in 1:10) {
      cat(paste0("[",i,"]"," ",jnews %>% 
                   html_nodes(paste0('li:nth-child(',i,') > a > strong')) %>%
                   html_text(trim = TRUE)),"\n")
      
    }
    cat("==============================================================================",
        "\n",
        "\n")
    
    US = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=US' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    US[1] = US[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(US[grep("작성일자",US)[1]],gregexpr("작성일자",US[grep("작성일자",US)[1]])[[1]][1]+7,gregexpr("작성일자",US[grep("작성일자",US)[1]])[[1]][1]+16) != DATE){
      cat("[미국 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      US = US[1:grep("작성일자",US)[1]]
      cat("[미국 시황]")
      for (i in 1:(grep("작성일자",US)[1])-1){cat(" ",US[i],"\n")}
      cat("\n",
          "\n")
    }
    
    num = 'http://www.samsunggold.co.kr/bbs/board.php?bo_table=news' %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="fboardlist"]/div[1]/table') %>%
      html_table() %>%
      .[[1]] %>%
      .[grep('국내 가격 동향',.[,2])[1],1]
    
    gs = paste0('http://www.samsunggold.co.kr/bbs/board.php?bo_table=news&wr_id=',(num+3)) %>%
      read_html() %>%
      html_nodes('div') %>%
      .[73] %>%
      html_text() %>%
      strsplit('\t|\n|\r') %>%
      .[[1]] %>%
      .[grep("상품시황",.):grep("은 현물",.)]
    if(length(grep("은 현물",gs)) !=0) {
      cat("[상품 시황]","\n",
          gs[2:(length(gs)-2)],"\n",
          gs[(length(gs)-1)],"\n",
          gs[length(gs)],"\n",
          "\n")
    } else {
      cat("[상품시황]","\n",
          "상품시황을 아직 이용하실 수 없습니다","\n",
          "\n")
    }
    
    CRUDEOIL = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=PE' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>% 
      .[1:grep("작성일자",.)[1]]
    CRUDEOIL[1] = CRUDEOIL[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(CRUDEOIL[grep("작성일자",CRUDEOIL)[1]],gregexpr("작성일자",CRUDEOIL[grep("작성일자",CRUDEOIL)[1]])[[1]][1]+7,gregexpr("작성일자",CRUDEOIL[grep("작성일자",CRUDEOIL)[1]])[[1]][1]+16) != DATE){
      cat("[국제 유가]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      CRUDEOIL = CRUDEOIL[1:grep("작성일자",CRUDEOIL)[1]]
      cat("[국제 유가]")
      for (i in 1:(grep("작성일자",CRUDEOIL)[1])-1){cat(" ",CRUDEOIL[i],"\n")}
      cat("\n",
          "\n")
    }
    
    CN = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=CH' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    CN[1] = CN[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(CN[grep("작성일자",CN)[1]],gregexpr("작성일자",CN[grep("작성일자",CN)[1]])[[1]][1]+7,gregexpr("작성일자",CN[grep("작성일자",CN)[1]])[[1]][1]+16) != DATE){
      cat("[중국 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      CN = CN[1:grep("작성일자",CN)[1]]
      cat("[중국 시황]")
      for (i in 1:(grep("작성일자",CN)[1])-1){cat(" ",CN[i],"\n")}
      cat("\n",
          "\n")
    }
    
    JP = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=JP' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    JP[1] = JP[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(JP[grep("작성일자",JP)[1]],gregexpr("작성일자",JP[grep("작성일자",JP)[1]])[[1]][1]+7,gregexpr("작성일자",JP[grep("작성일자",JP)[1]])[[1]][1]+16) != DATE){
      cat("[일본 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      JP = JP[1:grep("작성일자",JP)[1]]
      cat("[일본 시황]")
      for (i in 1:(grep("작성일자",JP)[1])-1){cat(" ",JP[i],"\n")}
      cat("\n",
          "\n")
    }
    
    TW = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=TW' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    TW[1] = TW[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(TW[grep("작성일자",TW)[1]],gregexpr("작성일자",TW[grep("작성일자",TW)[1]])[[1]][1]+7,gregexpr("작성일자",TW[grep("작성일자",TW)[1]])[[1]][1]+16) != DATE){
      cat("[대만 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      TW = TW[1:grep("작성일자",TW)[1]]
      cat("[대만 시황]")
      for (i in 1:(grep("작성일자",TW)[1])-1){cat(" ",TW[i],"\n")}
      cat("\n",
          "\n")
    }
    
    KS = 'http://m.infostock.co.kr/daily/koreaIndex.asp?mode=w&STYPE=KS1' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    KS[1] = KS[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(KS[grep("작성일자",KS)[1]],gregexpr("작성일자",KS[grep("작성일자",KS)[1]])[[1]][1]+7,gregexpr("작성일자",KS[grep("작성일자",KS)[1]])[[1]][1]+16) != DATE){
      cat("[코스피 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      KS = KS[1:grep("작성일자",KS)[1]]
      cat("[코스피 시황]")
      for (i in 1:(grep("작성일자",KS)[1])-1){cat(" ",KS[i],"\n")}
      cat("\n",
          "\n")
    }
    
    KDQ = 'http://m.infostock.co.kr/daily/koreaIndex.asp?mode=w&STYPE=KS2' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    KDQ[1] = KDQ[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(KDQ[grep("작성일자",KDQ)[1]],gregexpr("작성일자",KDQ[grep("작성일자",KDQ)[1]])[[1]][1]+7,gregexpr("작성일자",KDQ[grep("작성일자",KDQ)[1]])[[1]][1]+16) != DATE){
      cat("[코스닥 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      KDQ = KDQ[1:grep("작성일자",KDQ)[1]]
      cat("[코스닥 시황]")
      for (i in 1:(grep("작성일자",KDQ)[1])-1){cat(" ",KDQ[i],"\n")}
      cat("\n",
          "\n")
    }
    
  } else if(market == "us"){
    US = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=US' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    US[1] = US[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(US[grep("작성일자",US)[1]],gregexpr("작성일자",US[grep("작성일자",US)[1]])[[1]][1]+7,gregexpr("작성일자",US[grep("작성일자",US)[1]])[[1]][1]+16) != DATE){
      cat("[미국 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      US = US[1:grep("작성일자",US)[1]]
      cat("[미국 시황]")
      for (i in 1:(grep("작성일자",US)[1])-1){cat(" ",US[i],"\n")}
      cat("\n",
          "\n")
    }
  } else if(market == "gs") {
    num = 'http://www.samsunggold.co.kr/bbs/board.php?bo_table=news' %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="fboardlist"]/div[1]/table') %>%
      html_table() %>%
      .[[1]] %>%
      .[grep('국내 가격 동향',.[,2])[1],1]
    
    gs = paste0('http://www.samsunggold.co.kr/bbs/board.php?bo_table=news&wr_id=',(num+3)) %>%
      read_html() %>%
      html_nodes('div') %>%
      .[73] %>%
      html_text() %>%
      strsplit('\t|\n|\r') %>%
      .[[1]] %>%
      .[grep("상품시황",.):grep("은 현물",.)]
    if(length(grep("은 현물",gs)) !=0) {
      cat("[상품 시황]","\n",
          gs[2:(length(gs)-2)],"\n",
          gs[(length(gs)-1)],"\n",
          gs[length(gs)],"\n",
          "\n")
    } else {
      cat("[상품 시황]","\n",
          "상품시황을 아직 이용하실 수 없습니다","\n",
          "\n")
    }
    
  } else if(market == "cl") {
    CRUDEOIL = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=PE' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>% 
      .[1:grep("작성일자",.)[1]]
    CRUDEOIL[1] = CRUDEOIL[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(CRUDEOIL[grep("작성일자",CRUDEOIL)[1]],gregexpr("작성일자",CRUDEOIL[grep("작성일자",CRUDEOIL)[1]])[[1]][1]+7,gregexpr("작성일자",CRUDEOIL[grep("작성일자",CRUDEOIL)[1]])[[1]][1]+16) != DATE){
      cat("[국제 유가]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      CRUDEOIL = CRUDEOIL[1:grep("작성일자",CRUDEOIL)[1]]
      cat("[국제 유가]")
      for (i in 1:(grep("작성일자",CRUDEOIL)[1])-1){cat(" ",CRUDEOIL[i],"\n")}
      cat("\n",
          "\n")
    }
    
  } else if(market == "cn") {
    CN = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=CH' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    CN[1] = CN[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(CN[grep("작성일자",CN)[1]],gregexpr("작성일자",CN[grep("작성일자",CN)[1]])[[1]][1]+7,gregexpr("작성일자",CN[grep("작성일자",CN)[1]])[[1]][1]+16) != DATE){
      cat("[중국 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      CN = CN[1:grep("작성일자",CN)[1]]
      cat("[중국 시황]")
      for (i in 1:(grep("작성일자",CN)[1])-1){cat(" ",CN[i],"\n")}
      cat("\n",
          "\n")
    }
    
  } else if(market == "jp") {
    JP = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=JP' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    JP[1] = JP[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(JP[grep("작성일자",JP)[1]],gregexpr("작성일자",JP[grep("작성일자",JP)[1]])[[1]][1]+7,gregexpr("작성일자",JP[grep("작성일자",JP)[1]])[[1]][1]+16) != DATE){
      cat("[일본 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      JP = JP[1:grep("작성일자",JP)[1]]
      cat("[일본 시황]")
      for (i in 1:(grep("작성일자",JP)[1])-1){cat(" ",JP[i],"\n")}
      cat("\n",
          "\n")
    }
    
  } else if(market == "tw") {
    TW = 'http://m.infostock.co.kr/daily/worldIndex.asp?mode=w&STYPE=TW' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    TW[1] = TW[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(TW[grep("작성일자",TW)[1]],gregexpr("작성일자",TW[grep("작성일자",TW)[1]])[[1]][1]+7,gregexpr("작성일자",TW[grep("작성일자",TW)[1]])[[1]][1]+16) != DATE){
      cat("[대만 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      TW = TW[1:grep("작성일자",TW)[1]]
      cat("[대만 시황]")
      for (i in 1:(grep("작성일자",TW)[1])-1){cat(" ",TW[i],"\n")}
      cat("\n",
          "\n")
    }
    
  } else if(market == "ks") {
    KS = 'http://m.infostock.co.kr/daily/koreaIndex.asp?mode=w&STYPE=KS1' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    KS[1] = KS[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(KS[grep("작성일자",KS)[1]],gregexpr("작성일자",KS[grep("작성일자",KS)[1]])[[1]][1]+7,gregexpr("작성일자",KS[grep("작성일자",KS)[1]])[[1]][1]+16) != DATE){
      cat("[코스피 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      KS = KS[1:grep("작성일자",KS)[1]]
      cat("[코스피 시황]")
      for (i in 1:(grep("작성일자",KS)[1])-1){cat(" ",KS[i],"\n")}
      cat("\n",
          "\n")
    }
    
    KDQ = 'http://m.infostock.co.kr/daily/koreaIndex.asp?mode=w&STYPE=KS2' %>%
      read_html(encoding = "EUC-KR") %>%
      html_nodes(.,xpath = '//*[@id="data"]') %>%
      as.character() %>%
      strsplit("<br><br>") %>%
      .[[1]] %>%
      .[1:grep("작성일자",.)[1]]
    KDQ[1] = KDQ[1] %>% 
      strsplit("\r\n\t") %>% 
      .[[1]] %>%
      .[3]
    if(substr(KDQ[grep("작성일자",KDQ)[1]],gregexpr("작성일자",KDQ[grep("작성일자",KDQ)[1]])[[1]][1]+7,gregexpr("작성일자",KDQ[grep("작성일자",KDQ)[1]])[[1]][1]+16) != DATE){
      cat("[코스닥 시황]",'\n')
      cat(' 마감시황을 아직 이용하실 수 없습니다.','\n')
      cat("\n",
          "\n")
    } else {
      KDQ = KDQ[1:grep("작성일자",KDQ)[1]]
      cat("[코스닥 시황]")
      for (i in 1:(grep("작성일자",KDQ)[1])-1){cat(" ",KDQ[i],"\n")}
      cat("\n",
          "\n")
    }
  } else {
    cat("시장 코드를 다시 확인해주세요","\n",
        "미국 : us","\n",
        "유가 : cl","\n",
        "골드 : gs","\n",
        "중국 : cn","\n",
        "일본 : jp","\n",
        "대만 : tw","\n",
        "한국 : ks","\n",
        "\n")
  }
}
