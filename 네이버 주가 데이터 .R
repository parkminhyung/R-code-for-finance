

fin_data = function(ticker){
  if(!require(rvest)) install.packages('rvest'); library(rvest)
  if(!require(qdapRegex)) install.packages('qdapRegex'); library(qdapRegex)
  if(!require(lubridate)) install.packages('lubridate'); library(lubridate)
  
  df1 = data.frame()
  df = data.frame()
  for (i in 1:12) {
    
    ind = paste0('https://m.stock.naver.com/api/item/getPriceDayList.nhn?code=',ticker,'&pageSize=20&page=',i)%>%
      read_html() %>%
      html_nodes('body') %>%
      html_text(trim = TRUE) %>%
      rm_between(., "[", "]", extract=TRUE) %>%
      rm_between(., "{", "}", extract=TRUE) %>% .[[1]] %>%
      strsplit(x=.,split = ",") 
    
    for (i in 1:length(ind)) {
      df1[i,1] = parse_number(ind[[i]])[1]
      df1[i,1] = parse_number(ind[[i]])[6]
      df1[i,2] = parse_number(ind[[i]])[7]
      df1[i,3] = parse_number(ind[[i]])[8]
      df1[i,4] = parse_number(ind[[i]])[2]
      df1[i,5] = parse_number(ind[[i]])[9]
      df1[i,6] = round(parse_number(ind[[i]])[5],digits=2) %>% paste0(.,"%")
      rownames(df1)[i] = ymd(parse_number(ind[[i]][1])) %>% as.character()
    }
    df1 = df1[nrow(df1):1,]
    df = rbind(df1,df) 
  }
  
  colnames(df) = c("Open","High","Low","Close","Vol","Chg")
  View(df)
  df
}

