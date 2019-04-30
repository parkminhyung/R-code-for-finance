cn_get_st = function(ticker){
  
  tryCatch({
    library(rvest)
    library(plotly)
    
    ####### 기본정보 
    if(substr(ticker,1,1)== 0){
      urlcn = paste0('http://quotes.money.163.com/1',ticker,'.html#9b01')
    } else if(substr(ticker,1,1)== 3){
      urlcn = paste0('http://quotes.money.163.com/1',ticker,'.html#9b01')
    } else if(substr(ticker,1,1)== 6){
      urlcn = paste0('http://quotes.money.163.com/0',ticker,'.html#9b01')
    }
    
    url = urlcn %>%
      read_html() %>%
      html_nodes(xpath = '/html/body/div[2]/div[1]/div[3]/table') %>%
      html_table(fill = TRUE) %>%
      .[[1]]
    
    name = url[1,1] %>% gsub("\r|\n|\t| ","",x=.)
    wezg = url[1,12] %>% gsub("周最高","주 최고",x=.)
    wezd = url[1,13] %>% gsub("周最低","주 최저",x=.)
    
    ####### 재무정보
    ct = paste0('http://quotes.money.163.com/f10/zycwzb_',ticker,',year.html') %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="scrollTable"]/div[8]/table') %>%
      html_table() %>%
      .[[1]] %>%
      .[,1:4]
    rownames(ct) = c("EPS",
                     "BPS",
                     "주당경영활동현금흐름",
                     "매출액",
                     "매출총이익",
                     "영업이익",
                     "투자수익",
                     "영업외이익",
                     "법인세차감전순이익",
                     "당기순이익",
                     "당기순이익(비경영활동제외) ",
                     "경영활동현금흐름",
                     "현금및현금등가물증가액",
                     "총자산",
                     "유동자산",
                     "총부채",
                     "유동부채",
                     "자본(소액주주제외)",
                     "ROE(%)")
    ct = ct[c(4:11,3,12:nrow(ct),1,2),c(3:1)]
    
    ####### 주가정보
    k = quarters(Sys.Date()) %>% gsub("Q","",x=.) %>% as.numeric()
    season = c(1:k)
    gp = data.frame()
    for (i in 1:length(season)) {
      gpk = paste0('https://quotes.money.163.com/trade/lsjysj_',ticker,'.html?year=',format(Sys.Date(),"%Y"),'&season=',season[i]) %>%
        read_html() %>%
        html_nodes(xpath = '/html/body/div[2]/div[4]/table') %>%
        html_table() %>%
        .[[1]] %>%
        .[order(.[,1],decreasing = FALSE),]
      gp = rbind(gp,gpk)
    }
    
    rownames(gp) = gp[,1]
    colnames(gp) = c("일","시가","고가","저가","종가","등락","등략률(%)","거래량","거래금액","진폭","거래회전율")
    gpt = gp[,-c(1,10)] %>% tail() 
    gp = gp[,-c(1,10)]
    
    Date = rownames(gp) %>% as.Date()
    cd = gp %>%
      plot_ly(x= Date,
              type = 'candlestick',
              open = gp[,1],
              high = gp[,2],
              low = gp[,3],
              close = gp[,4],
              name = paste0(name,":candle")) %>%
      layout(title = paste0(name," : Candle Chart"," [","Q",season[1]," ~ ","Q",length(season),"]")) %>%
      print()
    
    ####### 10대주주 
    if(substr(ticker,"1","1")==0){
      url2 = paste0('http://quotes.money.163.com/1',ticker,".html#01a01")
      urlpe = paste0('https://eniu.com/gu/sz',ticker)
    } else if(substr(ticker,"1","1")==3){
      url2 = paste0('http://quotes.money.163.com/1',ticker,".html#01a01")
      urlpe = paste0('https://eniu.com/gu/sz',ticker)
    } else if(substr(ticker,"1","1")==6){
      url2= paste0('http://quotes.money.163.com/0',ticker,".html#01a01")
      urlpe = paste0('https://eniu.com/gu/sh',ticker)
    }
    
    gd = url2 %>%
      read_html() %>%
      html_nodes(xpath = '/html/body/div[2]/div[21]/div[2]/table') %>%
      html_table() %>%
      .[[1]]
    colnames(gd) = c("10대주주","지분울","금주보유주","지분변동상황")
    gd[,4] = gd[,4] %>%
      gsub("不变","변동없음",x=.) %>%
      gsub("新进","새로진입",x=.) %>%
      gsub("减持","감소:",x=.) %>%
      gsub("增持","증가:",x=.)
    
    ##### 뉴스 및 공시
    news = data.frame()
    for (i in 1:2) {
      nurl = c(paste0('http://quotes.money.163.com/f10/gsgg_',ticker,',zjgg.html'),
               paste0('http://quotes.money.163.com/f10/gsxw_',ticker,'.html#01e03'))
      k= nurl[i] %>%
        read_html() %>%
        html_nodes(xpath = '//*[@id="newsTabs"]/div/table') %>%
        html_table(fill=TRUE) %>%
        .[[1]] 
      k[,1] = paste0(k[,2],' ',k[,1])
      k = k[1:3,1] %>% data.frame()
      news = rbind(news,k)
    }
    
    ##### info
    info = list()
    try({
      for (i in 1:6) {
        info[i] = urlpe %>%
          read_html() %>%
          html_nodes(xpath = paste0('/html/body/div[2]/div/div[1]/div/div[1]/div/div[2]/div[1]/p[',i,']/a')) %>%
          as.character() %>%
          substr(.,gregexpr('self\">',.)[[1]][1]+6,gregexpr('</a>',.)[[1]][1]-1)
      }
    },silent = T)
    
    if(length(info) == 0){
      pe ="--"
      pbr ="--"
      dv ="--"
      tvm ="--"
      roe ="--"
    } else {
      pe = info[[2]][1]
      pbr = info[[3]][1]
      dv = info[[4]][1]
      tvm = info[[5]][1] %>%
        gsub(" 亿","억위안",x=.)
      roe = info[[6]][1]
    }
    
    cat('=============================',"기본정보",'=============================','\n',
        "[",name,"]",'\n',
        paste("전일 :",gpt[nrow(gpt)-1,4]),"|",paste("시가 :",gpt[nrow(gpt),1]),"|",paste("고가 :",gpt[nrow(gpt),2]),"|",paste("저가 :",gpt[nrow(gpt),3]),"|",'\n',
        paste("시가총액 :",tvm),"|",wezg,"|",wezd,"|",paste0("거래회전율 :",gpt[nrow(gpt),9],"%"),"\n",
        paste("배당성향 :",dv),"|",paste("PER :",pe),"|",paste("ROE :",roe),"|",paste("PBR :",pbr),"\n",
        '============================',"재무정보",'=============================','\n')
    cat('\n')
    cat("단위 : 만위안 (EPS/BPS는 위안단위)",'\n')
    ct %>% print()
    
    cat('===========================',"뉴스 및 공시",'===========================','\n')
    cat("[공시]",'\n')
    news[1:3,1] %>% format(.,justify = "left") %>% print()
    cat('\n')
    cat("[뉴스]","\n")
    news[4:6,1] %>% format(.,justify = "left") %>% print()
    cat("\n")
    cat('=============================',"주주정보",'============================','\n')
    format(gd,justify = 'left') %>% print()
    cat('===========================',"PRICE INFO",'===========================','\n')
    gpt %>% print()
    cat('===================================================================')},
    error = function(e) print("상장폐지종목 혹은 비상장종목이거나 종목코드를 확인해 주시기 바랍니다."))
}
