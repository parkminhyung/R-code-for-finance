library(quantmod)
library(dplyr)
library(plotly)

su_trend = function(ticker,start_date,end_date,n,Multiplier) {
  n = n
  Multiplier = Multiplier
  ticker = ticker
  start_date = start_date
  end_date = end_date
  
  df = getSymbols(ticker,from = start_date,to = end_date) %>% 
    get()
  df = data.frame(df[,1:4])
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
}
