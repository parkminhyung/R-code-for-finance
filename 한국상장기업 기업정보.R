kr_get_st = function(ticker){
  library(rvest)
  library(plotly)
  
  df = paste0('http://www.thinkpool.com/itemanal/i/pop_6week.jsp?code=',ticker) %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '/html/body/table[2]') %>%
    html_table() %>%
    .[[1]]
  colnames(df) = df[1,] 
  rownames(df) = df[,1]
  df = df[-1,] %>%
    .[,c(5:7,2,3,4,8)] %>%
    .[sort(rownames(df),decreasing = FALSE),] %>%
    .[-nrow(.),]
  
  for(i in 1:4){
    df[,i] = gsub(',','',x=df[,i])
  }
  df[,5] = gsub(pattern = '▼',replacement = '-',x=df[,5]) %>%
    gsub(pattern = '▲',replacement = '+',x=.)
  
  DATE = as.Date(rownames(df))
  
  name = paste0('http://www.thinkpool.com/itemanal/i/index.jsp?mcd=Q0&code=',ticker,'&Gcode=000_002') %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '//*[@id="wrap"]/div[16]/div[1]/span/a[1]') %>%
    html_text()
  
  plot_ly(x = DATE,
          type = "candlestick",
          open = df[,1],
          high = df[,2],
          low = df[,3],
          close = df[,4]) %>%
    layout(title = paste(name,"주가차트")) %>%
    print()
  
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
  url = paste0('http://thinkpool.com/itemanal/i/news/newsView.jsp?code=',ticker) %>%
    read_html("EUC-KR") %>%
    html_nodes(xpath = '//*[@id="content"]/div[2]/ul') %>%
    as.character() %>%
    strsplit('"subject\">') %>%
    .[[1]] %>%
    .[-1]
  news = data.frame(new = NA)
  for (i in 1:5) {
    news[i,1] = substr(url[i],1,gregexpr('</a>',url[i])[[1]][1]-1)
  }
  
  cat('=============================',"기본정보",'=============================','\n',
      "[",name,"]",'\n',
      tb[1,1:2] %>% as.character(),"|",tb[1,3:4] %>% as.character(),"|",tb[1,5:6] %>% as.character(),'\n',
      tb[2,1:2] %>% as.character(),"|",tb[2,3:4] %>% as.character(),"|",tb[2,5:6] %>% as.character(),'\n',
      tb[3,1:2] %>% as.character(),"|",tb[3,3:4] %>% as.character(),"|",tb[3,5:6] %>% as.character(),'\n',
      tb[4,1:2] %>% as.character(),"|",tb[4,3:4] %>% as.character(),"|",tb[4,5:6] %>% as.character(),'\n',
      '\n',
      '=============================',"재무정보",'=============================','\n')
      tb1 %>% print()
  cat('===========================',"뉴스 및 공시",'===========================','\n')
  news[,1] %>% print()
  
  cat('===========================',"PRICE INFO",'===========================','\n')
      tail(df) %>% print()
  cat('===================================================================')
}

