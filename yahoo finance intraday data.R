#data : yf_data_intra(ticker)[[1]]
#info: yf_data_intra(ticker)[[2]]
#example, 上证日间价格数据 : yf_data_intra("000001.SS")[[1]], ticker是基本上基于yahoo finance的
#example, if you want to extract S&P500 intraday data, yf_data_intra("^GSPC")[[1]], ticker is based on yahoo-finance 

yf_data_intra = function(ticker) {
  pacman::p_load("jsonlite","dplyr")
  
  options(scipen = 999)
  ticker= toupper(ticker)
  
  base = 'https://query1.finance.yahoo.com/v8/finance/chart/' %+% ticker %+% '?region=US&lang=en-US&includePrePost=false&interval=2m&useYfid=true&range=1d&corsDomain=finance.yahoo.com&.tsrc=finance' %>%
    fromJSON()
  
  data = data.frame(
    format(as.POSIXct(base$chart$result$timestamp[[1]],origin = "1970-01-01",tz = base$chart$result$meta$exchangeTimezoneName),"%H:%M"),
    base$chart$result$indicators$quote[[1]]$open,
    base$chart$result$indicators$quote[[1]]$high,
    base$chart$result$indicators$quote[[1]]$low,
    base$chart$result$indicators$quote[[1]]$close,
    base$chart$result$indicators$quote[[1]]$volume
  ) %>% 
    setNames(c('time','open','high','low','close','vol')) %>%
    na.omit()
  
  list(data,base)
}


#### intraday and 6month price Plot ####
pacman::p_load("plotly","quantmod","tibble","lubridate")

'%+%' = paste0
ticker = "^ks11"

data1 = yf_data_intra(ticker)[[1]]
data1$vol[which.max(data1$vol)] = 0

base = yf_data_intra(ticker)[[2]]

data2 = getSymbols(
  ticker,
  from = (Sys.Date() - months(6)),
  to = Sys.Date(),
  auto.assign = FALSE
) %>% as.data.frame() %>%
  rownames_to_column(var = "date") %>%
  `colnames<-`(c("date","open","high","low","close","vol","adjcl")) 

preprice = base$chart$result$meta$previousClose

{
  p1 = data1 %>% 
    plot_ly(
      x = ~time,
      y = ~close,
      type = "scatter",
      mode = "line",
      name = "price",
      line = list(color = "#25b076")
    ) %>%
    add_lines(
      y = preprice,
      line = list(color = 'rgb(22, 96, 167)', width = 2, dash = 'dot'),
      name = "pre.price") 
  
  p2 = data1 %>% 
    plot_ly(
      x=~time,
      y = ~vol ,
      type = "bar",
      name = "volume"
    )
  
  f2 = data2 %>% 
    plot_ly(
      x = ~date,
      open =~open,
      high = ~high,
      low = ~low,
      close = ~close,
      increasing = list(line = list(color = '#db1d49')),
      decreasing = list(line = list(color = '#3687b3')),
      type = "candlestick",
      name = "Candle stick"
    ) %>% 
    add_lines(
      y = EMA(data2$close,14),
      name = "14-line",
      line = list(color = '#eb8934')
    ) %>% 
    add_lines(
      y = EMA(data2$close,25),
      name = "25-line",
      line = list(color = '#348feb')
    ) %>%
    add_annotations(
      text = (" Ticker info: " %+% toupper(ticker) %+% " <br>" %+% 
                " Price: " %+% round(data1$close[nrow(data1)],digits = 3) %+% "pt" %+% "<br>" %+%
                " Chg(%): " %+% paste0(round(((data1$close[nrow(data1)]/preprice)-1)*100,digits=3),"%")),
      align='left',
      showarrow= FALSE,
      xref='paper',
      yref='paper',
      x= 0.03,
      y= 0.95,
      bordercolor='black',
      borderwidth=.5
    )
  
  f1 = subplot(p1,p2,nrows = 2,heights =  c(.85,.15),shareX = TRUE) %>% 
    layout(title = toupper(ticker)  %+% "(" %+% as.character(base$chart$result$meta$exchangeName) %+% ") Price Chart",
           margin = list(r=50,t=30))
  
  subplot(f2,f1,nrows = 2,heights = c(.4,.6),shareX = FALSE) %>%
    layout(xaxis = list(rangeslider = list(visible = FALSE))) 
}

