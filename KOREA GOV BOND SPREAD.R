pacman::p_load("jsonlite","plotly","tibble","dplyr","quantmod")

kr10y = 'https://markets.tradingeconomics.com/chart?s=gvsk10yr:gov&interval=1d&span=1y&securify=new&url=/south-korea/government-bond-yield&AUTH=H%2BS0mB2HTKw8CkctjSrHtxu2lV1YzTnpRpcZsgGSxFgUfeKPaRBVuhzYsytV17fZarCZoXQi78uYLTXVFBGNig%3D%3D&ohlc=0' %>%
  jsonlite::fromJSON() %>%
  .$series %>%
  .$data %>%
  as.data.frame() %>%
  mutate(date = as.Date(date)) %>%
  select(-"x") 

kr1y = 'https://markets.tradingeconomics.com/chart?s=gvsk1y:gov&span=1y&securify=new&url=/south-korea/government-bond-yield&AUTH=H%2BS0mB2HTKw8CkctjSrHtxu2lV1YzTnpRpcZsgGSxFgUfeKPaRBVuhzYsytV17fZarCZoXQi78uYLTXVFBGNig%3D%3D&ohlc=0' %>%
  jsonlite::fromJSON() %>%
  .$series %>%
  .$data %>%
  as.data.frame() %>%
  mutate(date = as.Date(date)) %>%
  select(-"x") 

kr2y = 'https://markets.tradingeconomics.com/chart?s=gvsk2y:gov&span=1y&securify=new&url=/south-korea/government-bond-yield&AUTH=H%2BS0mB2HTKw8CkctjSrHtxu2lV1YzTnpRpcZsgGSxFgUfeKPaRBVuhzYsytV17fZarCZoXQi78uYLTXVFBGNig%3D%3D&ohlc=0' %>%
  jsonlite::fromJSON() %>%
  .$series %>%
  .$data %>%
  as.data.frame() %>%
  mutate(date = as.Date(date)) %>%
  select(-"x") 

ksp = getSymbols("^KS11",
                 from = "2022-01-01",
                 to = Sys.Date()) %>% get() %>%
  as.data.frame() %>%
  rownames_to_column(var="date") %>%
  mutate(date = as.Date(date)) %>% 
  select(c("date","KS11.Close")) 

kr_spread = merge(kr10y,kr2y,by='date') %>%
  merge(.,kr1y,by="date") %>%
  merge(.,ksp,by="date") %>%
  select(date,y.x,y.y,y,KS11.Close) %>%
  rename("year10" = y.x,
         "year2" = y.y,
         "year1" = y,
         "kspcl" = KS11.Close) %>%
  mutate(`spread10.2` = year10-year2,
         `spread10.1` = year10-year1)

f1= kr_spread %>%
  plot_ly(x=.$date,
          y=.$spread10.1,
          type = "scatter",
          mode = "line",
          name = "10y-1y spread") 
f2 = kr_spread %>%
  plot_ly(x=.$date,
          y=.$spread10.2,
          type = "scatter",
          mode = "line",
          name = "10y-2y spread") 
f3 = kr_spread %>%
  plot_ly(x=.$date,
          y=.$kspcl,
          type = "scatter",
          mode = "line",
          name = "KOSPI") 


f4= plot_ly() %>%
  add_trace(x = kr_spread$date,
            y = kr_spread$spread10.2,
            name = "spread 10y-2y",
            type ="scatter",
            mode ="line") %>%
  add_trace(x = kr_spread$date,
            y = kr_spread$kspcl,
            name = "KOSPI",
            type ="scatter",
            mode ="line",
            yaxis = "y2") %>%
  layout(yaxis2 = list(overlaying = "y", side = "right"))

subplot(f1,f2,f3,nrows = 3,margin = 0.05)

