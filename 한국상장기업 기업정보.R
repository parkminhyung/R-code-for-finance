kr_get_st = function(ticker){
  
  library(rvest)
  library(plotly)
  library(quantmod)
  
  name = paste0('http://www.thinkpool.com/itemanal/i/index.jsp?mcd=Q0&code=',ticker,'&Gcode=000_002') %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '//*[@id="wrap"]/div[17]/div[1]/span/a[1]') %>%
    html_text(trim = TRUE)
  
  n = 10
  Multiplier = 1
  ticker = ticker
  df = paste0('http://www.thinkpool.com/itemanal/i/pop_6week.jsp?code=',ticker) %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table[2]') %>%
    html_table() %>%
    .[[1]]
  colnames(df) = df[1,] 
  rownames(df) = df[,1]
  df = df[-1,] %>%
    .[,c(5:7,2)] %>%
    .[sort(rownames(df),decreasing = FALSE),] %>%
    .[-nrow(.),]
  for(i in 1:4){
    df[,i] = gsub(',','',x=df[,i]) %>%
      as.numeric()
  }
  df = data.frame(df[,1:4])
  url = paste0('http://thinkpool.com/itemanal/i/index.jsp?code=',ticker) %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '//*[@id="itemcontainer"]/div/div[2]/div[2]/table') %>%
    html_table() %>%
    .[[1]] %>%
    .[,2] %>%
    .[-1] %>%
    gsub(',','',x=.) %>% strsplit(" ") 
  
  price = paste0('http://thinkpool.com/itemanal/i/index.jsp?code=',ticker) %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '//*[@id="itemcontainer"]/div/div[1]/span[1]/strong') %>%
    html_text() %>%
    gsub(',','',x=.) %>%
    as.numeric()
  
  cdf = data.frame("시가"=NA,
                   "고가"=NA,
                   "저가"=NA,
                   "종가"=NA)
  for (i in 1:3) {
    cdf[1,i] = url[[i]][1] %>% as.numeric()
    cdf[1,4] = price %>% as.numeric()
  }
  
  rownames(cdf) = format(Sys.Date(),"%Y/%m/%d")
  if(rownames(df)[nrow(df)] == rownames(cdf)){
    df = df
  } else {
    df[(nrow(df)+1),] = cdf
  }
  
  df$TR = NA
  
  for (i in 1:(nrow(df)-1)) {
    k = cbind(abs(df[i+1,2]-df[i+1,3]),abs(df[i+1,2]-df[i,4]),abs(df[i+1,3]-df[i,4]))
    df[i+1,5] = apply(k,1,max) %>%
      round(digits = 2)
  }
  
  df$ATR = SMA(df$TR,n=n) %>%
    round(digits = 2)
  df[n,6] = NA
  df$UPPER_ATR_CLOSE = df[,4] + Multiplier*df$ATR
  df$LOWER_ATR_CLOSE = df[,4] - Multiplier*df$ATR
  df$UPPER_ATR_HIGH = df[,3] + Multiplier*df$ATR
  df$LOWER_ATR_HIGH = df[,2] - Multiplier*df$ATR
  
  df$UPPER_SUPERTREND = ((df[,2]+df[,3])/2 + Multiplier*df$ATR) %>%
    round(digits = 2)
  
  df$LOWER_SUPERTREND = ((df[,2]+df[,3])/2 - Multiplier*df$ATR) %>%
    round(digits = 2)
  
  df$FINAL_UPPERBAND = NA
  df$FINAL_LOWERBAND = NA
  df$SUPER_TREND = NA
  df$SIGNAL = NA
  
  df[n+1,13] = df[n+1,11]
  df[n+1,14] = df[n+1,12]
  
  if(df[n+1,4] <= df[n+1,13]) {
    df[n+1,15] = df[n+1,13]
  } else {
    df[n+1,15] = df[n+1,14]
  }
  
  for (i in n:(nrow(df)-2)) {
    if(df[i+2,11] < df[i+1,13] | df[i+1,4] > df[i+1,13]) {
      df[i+2,13] = df[i+2,11]
    } else {
      df[i+2,13] = df[i+1,13]
    } 
    if(df[i+2,12] > df[i+1,14] | df[i+1,4] < df[i+1,14]) {
      df[i+2,14] = df[i+2,12]
    } else {
      df[i+2,14] = df[i+1,14]
    }
  }
  
  for (i in n:(nrow(df)-2)) {
    if(df[i+1,13] == df[i+1,15] & df[i+2,4] <= df[i+2,13]) {
      df[i+2,15] = df[i+2,13]
    } else if(df[i+1,13] == df[i+1,15] & df[i+2,4] >= df[i+2,13]) {
      df[i+2,15] = df[i+2,14]
    } else if(df[i+1,14] == df[i+1,15] & df[i+2,4] <= df[i+2,14]) {
      df[i+2,15] = df[i+2,13]
    } else if(df[i+1,14] == df[i+1,15] & df[i+2,4] >= df[i+2,14]) {
      df[i+2,15] = df[i+2,14]
    }
  }
  
  for (i in n:(nrow(df)-1)) {
    if(df[i+1,4] <= df[i+1,15]) {
      df[i+1,16] = "SELL"
    } else {
      df[i+1,16] = "BUY"
    }
  }
  
  Date = as.Date(rownames(df))
  df1 = data.frame(row.names = Date)
  df1$y1 = NA
  df1$y2 = NA
  df1[grep(pattern = "BUY", x= df[,16]),1] = df[grep(pattern = "BUY", x= df[,16]),15]
  
  for (i in (n+1):(nrow(df1)-1)) {
    if(df[i,16] == df[i+1,16]) {
      df1[i+1,2] = NA
    } else if(df[i,16]=="SELL" & df[i+1,16] == "BUY"){
      df1[i+1,2] = "BUY signal"
    } else if(df[i,16]=="BUY" & df[i+1,16] == "SELL"){
      df1[i+1,2] = "SELL signal"
    }
  }
  
  try({
    plot_ly(x = Date,
            type = "candlestick",
            open = df[,1],
            high = df[,2],
            low = df[,3],
            close = df[,4],
            name = paste0(ticker,":CHART"))  %>%
      layout(title = paste0(name,"[",ticker,"]"," : 주가차트")) %>%
      add_trace(data = df,
                x= Date,
                y= df[,15],
                type = "scatter",
                mode = "lines",
                line = list(color = "red"),
                name = "SELL") %>%
      add_trace(data = df,
                x= Date,
                y = df1$y1,
                type = "scatter",
                mode = 'lines',
                line = list(color = "green"),
                name = "BUY") %>% 
      add_annotations(x=Date[grep(pattern = "BUY signal|SELL signal",x=df1[,2])],
                      y=df[grep(pattern = "BUY signal|SELL signal",x=df1[,2]),15],
                      text = df1[grep(pattern = "BUY signal|SELL signal",x=df1[,2]),2],
                      xref = "x",
                      yref = "y",
                      showarrow=TRUE,
                      arrowsize = .5,
                      ax = 20,
                      ay = -40,
                      type = 'scatter',
                      mode = 'markers',
                      marker=list(size=10)) %>%
      print()
  },silent = T)
  
  tb = paste0('http://www.thinkpool.com/itemanal/i/index.jsp?mcd=Q0&code=',ticker,'&Gcode=000_002') %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '//*[@id="itemcontainer"]/div/div[2]/div[2]/table') %>%
    html_table(fill = TRUE) %>%
    .[[1]]
  
  tb1 = paste0('http://media.kisline.com/highlight/mainHighlight.nice?nav=1&paper_stock=',ticker) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="summarytp1"]/table[1]') %>%
    html_table(fill = TRUE) %>%
    .[[1]] 
  rownames(tb1) = tb1[,1]
  colnames(tb1) = tb1[1,]
  tb1 = tb1[-1,-1]
  cat('=============================',"기본정보",'=============================','\n',
      "[",name,"]",'\n',
      tb[1,1:2] %>% as.character(),"|",tb[1,3:4] %>% as.character(),"|",tb[1,5:6] %>% as.character(),'\n',
      tb[2,1:2] %>% as.character(),"|",tb[2,3:4] %>% as.character(),"|",tb[2,5:6] %>% as.character(),'\n',
      tb[3,1:2] %>% as.character(),"|",tb[3,3:4] %>% as.character(),"|",tb[3,5:6] %>% as.character(),'\n',
      tb[4,1:2] %>% as.character(),"|",tb[4,3:4] %>% as.character(),"|",tb[4,5:6] %>% as.character(),'\n',
      '\n')
  cat('=============================',"재무정보",'=============================','\n')
  format(tb1,justify = "left") %>% print()
  
  cat('===========================',"뉴스 및 공시",'===========================','\n')
  cat("[뉴스]",'\n')
  news = paste0('http://thinkpool.com/itemanal/i/news/newsView.jsp?code=',ticker) %>%
    read_html("EUC-KR") %>%
    html_nodes(xpath = paste0('//*[@id="content"]/div[2]/ul/li[',i,']/div/a')) %>%
    html_text(trim = TRUE)
  
  news = list()
  for (i in 1:5) {
    news[[i]] = paste0('http://thinkpool.com/itemanal/i/news/newsView.jsp?code=',ticker) %>%
      read_html("EUC-KR") %>%
      html_nodes(xpath = paste0('//*[@id="content"]/div[2]/ul/li[',i,']/div/a')) %>%
      html_text(trim = TRUE)
    if((length(news[[i]]) !=0)){
      cat(paste0("[",i,"]"," ",news[[i]]),'\n')
    }
  }
  
  if(length(unlist(news))==0){
    cat("뉴스가 없습니다.","\n")
  }
  cat('\n')
  cat("[공시]",'\n')
  gd = paste0('http://thinkpool.com/itemanal/i/news/noticeView.jsp?code=',ticker,'&mcd=Q0K') %>%
    read_html('EUC-KR') %>%
    html_nodes(xpath = '//*[@id="content"]/div[2]/table') %>%
    html_table(fill = TRUE) %>%
    .[[1]]
  for (i in 1:5) {
    cat(paste0("(",gd[i,3],")"," ",gd[i,2]),"\n")
  }
  cat('\n')
  cat('===========================',"PRICE INFO",'===========================','\n')
  tail(df[,1:4]) %>% print()
  cat('===================================================================')
  
}
