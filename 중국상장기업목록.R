pacman::p_load("rvest","dplyr")

markets = c("hs","ss","bj","cyb","kcb")
'%+%' = paste0
data = data.frame()

for (market in markets) {
 
  len = 'http://q.10jqka.com.cn/index/index/board/' %+% market %+% '/field/zdf/order/desc/page/1'  %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="m-page"]/span') %>%
    html_text(trim = TRUE) %>%
    gsub(x=.,pattern = "1/","")
  
  df = data.frame()
  
  for (i in 1:len) {
    
    df = 'http://q.10jqka.com.cn/index/index/board/' %+% market %+% '/field/zdf/order/desc/page/' %+% i  %>%
      read_html() %>%
      html_table() %>% .[[1]] %>%
      `colnames<-`(c("x","종목코드","회사명","현재주가","등락률","등락","x",
                     "x","x","x","거래량","유통주식수","유통시가","PER","x")) %>%
      select(-x) %>% 
      mutate(종목코드 = sprintf("%06d", 종목코드)) %>%
      mutate(등락률 = 등락률 %+% "%") %>%
      mutate(시장 = ifelse(market == "hs","상해A",
                         ifelse(market == "ss","심천A",
                                ifelse(market == "bj","북경A",
                                       ifelse(market == "cyb","창업판",
                                              ifelse(market == "kcb","과창판",NA)))))) %>%
      rbind(df,.)
  }
  
  data = data %>% rbind(.,df)
}

data = data[c(2,1,10,3:9)]
