kr_get_st = function(ticker){
  
  options(warn = -1)
  library(rvest)
  library(plotly)
  library(quantmod)
  
  name = paste0('http://www.thinkpool.com/itemanal/i/index.jsp?mcd=Q0&code=',ticker,'&Gcode=000_002') %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '//*[@id="wrap"]/div[17]/div[1]/span/a[1]') %>%
    html_text(trim = TRUE)
  
  n = 10
  Multiplier = 1
  
  df = paste0('http://www.thinkpool.com/itemanal/i/pop_6week.jsp?code=',ticker) %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table[2]') %>%
    html_table() %>%
    .[[1]]
  
  colnames(df) = df[1,] 
  rownames(df) = df[,1]
  df = df[-1,] %>%
    .[,c(5:7,2,8,4)] %>%
    .[sort(rownames(df),decreasing = FALSE),] %>%
    .[-nrow(.),]
  
  
  for(i in 1:5){
    df[,i] = gsub(',','',x=df[,i]) %>%
      as.numeric()
  }
  
  '%ni%' = Negate('%in%')

if(weekdays(Sys.Date()) %ni% c("Saturday", "Sunday","Monday") & ("00:00:00" < format(Sys.time(), "%X")) & (format(Sys.time(), "%X") < "09:00:00")==TRUE) {
  Date.time = format(Sys.Date()-1,"%Y/%m/%d")
} else if(weekdays(Sys.Date())=="Saturday"){
  Date.time = format(Sys.Date()-1,"%Y/%m/%d")
} else if(weekdays(Sys.Date())=="Sunday"){
  Date.time = format(Sys.Date()-2,"%Y/%m/%d")
} else if(weekdays(Sys.Date()) == "Monday" & ("00:00:00" < format(Sys.time(), "%X")) & (format(Sys.time(), "%X") < "09:00:00") == TRUE){
  Date.time = format(Sys.Date()-3,"%Y/%m/%d")
} else {
  Date.time = format(Sys.Date(),"%Y/%m/%d")
}
  
  if(rownames(df)[nrow(df)] == Date.time){
    df = df
  } else {
    df[nrow(df)+1,] = NA
    
    rownames(df)[length(rownames(df))] =format(Sys.Date(),"%Y/%m/%d")
    
    url = paste0('http://thinkpool.com/itemanal/i/index.jsp?code=',ticker) %>%
      read_html(encoding = 'EUC-KR') %>%
      html_nodes(xpath = '//*[@id="itemcontainer"]/div/div[2]/div[2]/table') %>%
      html_table() %>%
      .[[1]] 
    url[5,] = url[1,6]
    url = url[,2]%>%
      .[-1] %>%
      gsub(',','',x=.) %>% strsplit(" ") 
    
    for (i in 1:3) {
      df[nrow(df),i] = url[[i]][1] %>% as.numeric()
    }
    
    df[nrow(df),4] =  paste0('http://thinkpool.com/itemanal/i/index.jsp?code=',ticker) %>%
      read_html(encoding = 'EUC-KR') %>%
      html_nodes(xpath = '//*[@id="itemcontainer"]/div/div[1]/span[1]/strong') %>%
      html_text() %>%
      gsub(',','',x=.) %>%
      as.numeric()
    
    df[nrow(df),5] = url[[4]][1] %>% 
      substr(.,1,gregexpr("\\(",.)[[1]][1]-1) %>%
      as.numeric()
    
    df[nrow(df),6] = paste0(round(((df[nrow(df),4]-df[nrow(df)-1,4])/df[nrow(df)-1,4])*100,digits = 2),"%")
  }
  
  df$TR = NA
  
  for (i in 1:(nrow(df)-1)) {
    k = cbind(abs(df[i+1,2]-df[i+1,3]),abs(df[i+1,2]-df[i,4]),abs(df[i+1,3]-df[i,4]))
    df[i+1,7] = apply(k,1,max) %>%
      round(digits = 2)
  }
  
  df$ATR = SMA(df$TR,n=n) %>%
    round(digits = 2)
  df[n,8] = NA
  df$UPPER_ATR_CLOSE = df[,4] + Multiplier*df$ATR
  df$LOWER_ATR_CLOSE = df[,4] - Multiplier*df$ATR
  df$UPPER_ATR_HIGH = df[,3] + Multiplier*df$ATR
  df$LOWER_ATR_HIGH = df[,2] - Multiplier*df$ATR
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
  
  df[n+1,15] = df[n+1,13]
  df[n+1,16] = df[n+1,14]
  
  if(df[n+1,4] <= df[n+1,15]) {
    df[n+1,17] = df[n+1,15]
  } else {
    df[n+1,17] = df[n+1,16]
  }
  ##+2
  for (i in n:(nrow(df)-2)) {
    if(df[i+2,13] < df[i+1,15] | df[i+1,4] > df[i+1,15]) {
      df[i+2,15] = df[i+2,13]
    } else {
      df[i+2,15] = df[i+1,15]
    } 
    if(df[i+2,14] > df[i+1,12] | df[i+1,4] < df[i+1,16]) {
      df[i+2,16] = df[i+2,14]
    } else {
      df[i+2,16] = df[i+1,16]
    }
  }
  
  for (i in n:(nrow(df)-2)) {
    if(df[i+1,15] == df[i+1,17] & df[i+2,4] <= df[i+2,15]) {
      df[i+2,17] = df[i+2,15]
    } else if(df[i+1,15] == df[i+1,17] & df[i+2,4] >= df[i+2,15]) {
      df[i+2,17] = df[i+2,16]
    } else if(df[i+1,16] == df[i+1,17] & df[i+2,4] <= df[i+2,16]) {
      df[i+2,17] = df[i+2,15]
    } else if(df[i+1,16] == df[i+1,17] & df[i+2,4] >= df[i+2,16]) {
      df[i+2,17] = df[i+2,16]
    }
  }
  
  for (i in n:(nrow(df)-1)) {
    if(df[i+1,4] <= df[i+1,17]) {
      df[i+1,18] = "SELL"
    } else {
      df[i+1,18] = "BUY"
    }
  }
  
  Date = as.Date(rownames(df))
  df1 = data.frame(row.names = Date)
  df1$y1 = NA
  df1$y2 = NA
  df1[grep(pattern = "BUY", x= df[,18]),1] = df[grep(pattern = "BUY", x= df[,18]),17]
  
  for (i in (n+1):(nrow(df1)-1)) {
    if(df[i,18] == df[i+1,18]) {
      df1[i+1,2] = NA
    } else if(df[i,18]=="SELL" & df[i+1,18] == "BUY"){
      df1[i+1,2] = "BUY signal"
    } else if(df[i,18]=="BUY" & df[i+1,18] == "SELL"){
      df1[i+1,2] = "SELL signal"
    }
  }
  
  
  n.n = 14
  df$SMA = SMA(df[,4],n=n.n)
  df[,20:21]=NA
  
  for (i in n.n:nrow(df)) {
    df[i,20] = df[i,19] + sd(df[(i-(n.n-1)):i,4])*2
    df[i,21] = df[i,19] - sd(df[(i-(n.n-1)):i,4])*2
  }
  
  ### Vol.Pro
  df2 = df[nrow(df):1,1:5]
  end = nrow(df2)-13
  
  
  tick_size = round((max(df2[1:end,4]) - min(df2[1:end,4]))/n,digits = 0)
  
  for (i in 1:nrow(df2)) {
    df2[i,6] = df2[i,5]/(df2[i,2]-df2[i,3]+tick_size)*tick_size 
  }
  df2[,6] = df2[,6] %>% round(.,digits = 2)
  
  df2$value_length = NA
  
  for (i in 1:end) {
    df2[i,7] = (max(df2[1:end,2])-tick_size*(i-1))
    if(df2[i,7] < 0){
      df2[i,7] = 0
    }
  }
  
  df2[,7] = round(df2[,7],digits = 2)
  
  df2$value = NA
  
  for (i in 1:nrow(df2)) {
    df2[i,8] = sum(df2[which(df2[1:end,2]>=df2[i,7]),6]) - 
      sum(df2[which(df2[1:end,3]>df2[i,7]),6])
  }
  
  #plot
  Date = as.Date(rownames(df))
  p = plot_ly(x=Date,
              open = df[,1],
              high = df[,2],
              low = df[,3],
              close = df[,4],
              type = "candlestick",
              name = "CandleStick")  %>%
    add_trace(x=df2[1:(which(df2[,8]==0)[1]-1),8],
              y=df2[1:(which(df2[,8]==0)[1]-1),7],
              type = 'bar',
              orientation = 'h',xaxis = "x2",
              name = "Vol.p",
              marker = list(color = 'rgba(234,104,61,0.3)',
                            line = list(color = 'rgb(8,48,107)'))) %>%
    layout(title = paste0(name,"[",ticker,"]"," : 현재가 ",df[nrow(df),4],"(",df[nrow(df),6],")"),
           xaxis = list(rangeslider = list(visible = F), 
                        side = "bottom",
                        showgrid = TRUE),
           xaxis2 = list(overlaying = "x",
                         side= "top",
                         autotick = FALSE,
                         tickmode = "array")) %>% 
    add_ribbons(ymax = df[,20],
                ymin = df[,21],
                line = list(color = 'rgba(7, 164, 181, 0.05)'),
                fillcolor = 'rgba(100, 110, 210, 0.2)',
                name = "BBand") %>%
    add_lines(y=df[,19],line = list(color = 'rgb(199, 99, 125)',width = 1),
              name = paste0(n.n,"-SMA")) %>%
    add_trace(data = df,
              x= Date,
              y= df[,17],
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
                    y=df[grep(pattern = "BUY signal|SELL signal",x=df1[,2]),17],
                    text = df1[grep(pattern = "BUY signal|SELL signal",x=df1[,2]),2],
                    xref = "x",
                    yref = "y",
                    showarrow=TRUE,
                    arrowsize = .5,
                    ax = 20,
                    ay = -40,
                    type = 'scatter',
                    mode = 'markers',
                    marker=list(size=10))
  
  pp = plot_ly(x=Date,
               y=df[,5],
               name = "Vol",
               marker = list(color = 'rgb(49, 193, 160)'),type = 'bar') %>%
    layout(yaxis = list(title = "Vol"))
  
  subplot(p,pp,shareX = TRUE,nrows = 2,heights = c(0.8,0.2)) %>% print()
  
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
  tail(df[,c(1:4,6,5)]) %>% print()
  cat('===================================================================')
  
}
