fin_data = function(ticker,datetype=NULL,time_length=NULL){
  
  if(!require(rvest)) install.packages('rvest'); library(rvest)
  if(!require(qdapRegex)) install.packages('qdapRegex'); library(qdapRegex)
  if(!require(lubridate)) install.packages('lubridate'); library(lubridate)
  if(!require(readr)) install.packages('readr'); library(readr)
  
  INDEX = c('KOSPI','KPI200','KOSDAQ')
  
  FINDEX = c('DJI','IXIC','DJT','NDX','INX','SOX','VIX','SSEC','SZSC','SSEA','SZSA','SSEB','SZSB','CSI100','CSI300','HSI','HSCE','N225','TWII',
             'TOPX','VNI','AXJO','BSESN',
             'HNXI','STOXX50E','GDAXI','FTSE','FTMIB','AEX','FCHI',
             'IRTS','BFX','PSI20','IBEX','ISEQ','OMXC20','OMXS30','OMXH25','ATG','BUX',
             'KLSE','JKSE','BVSP','MXX','MERV')
  
  FTINDEX = c('NQcv1','EScv1','RTYcv1',
              'SFCc1','HCEIc1','SSIcm1',
              'STXEc1','FDXc1','SINc1',
              'GCcv1','SIcv1','CLcv1')
  
  datetype = ifelse(is.null(datetype),'month',datetype)
  time_length = ifelse(is.null(time_length),'12',time_length)
  if(datetype=="year" & time_length>10) time_length = 10
  if(datetype=="day") time_length = NA
  '%ni%' = Negate('%in%'); ticker = ifelse(ticker %ni%  FTINDEX, toupper(ticker),ticker)
  
  if(datetype!="day"){
    
    if(ticker %in% INDEX){
      url = paste0('https://api.stock.naver.com/chart/domestic/index/',ticker,'?periodType=',datetype,'&range=',time_length)
    } else if(ticker %in% FINDEX){
      url = url = paste0('https://api.stock.naver.com/chart/foreign/index/.',ticker,'?periodType=',datetype,'&range=',time_length)
    } else if(ticker %in% FTINDEX){
      url = paste0('https://api.stock.naver.com/chart/foreign/futures/',ticker,'?periodType=',datetype,'&range=',time_length)
    } else if(ticker == "FUT"){
      url = paste0('https://api.stock.naver.com/chart/domestic/futures/FUT?periodType=',datetype,'&range=',time_length)
    } else {
      url = paste0('https://api.stock.naver.com/chart/domestic/item/',ticker,'?periodType=',datetype,'&range=',time_length)
    }
    
    ind = url %>%
      read_html() %>%
      html_nodes('body') %>%
      html_text(trim = TRUE) %>%
      rm_between(., "[", "]", extract=TRUE) %>%
      rm_between(., "{", "}", extract=TRUE) %>% .[[1]] %>%
      strsplit(x=.,split = ",") 
    
    df = data.frame()
    for (i in 1:length(ind)) {
      df[i,c(1:5)] = parse_number(ind[[i]])[c(3,4,5,2,6)]
      df[1,c(6,7)] = NA
      df[i,6] = ifelse(i==1,NA,df[i,4]-df[i-1,4])
      df[i,7] = paste0(round((df[i,4]/df[i-1,4]-1)*100,digits = 2),"%")
      rownames(df)[i] = ind[[i]][1] %>% parse_number() %>% ymd() %>% as.character()
    }
    colnames(df) = c("Open","High","Low","Close","ACC.Vol","Chg","%Chg")
    
  } else if(datetype=="day"){
    
    if(ticker %in% INDEX){
      url = paste0('https://api.stock.naver.com/chart/domestic/index/',ticker,'?periodType=day')
    } else if(ticker %in% FINDEX){
      url = paste0('https://api.stock.naver.com/chart/foreign/index/.',ticker,'?periodType=day')
    } else if(ticker %in% FTINDEX){
      url = paste0('https://api.stock.naver.com/chart/foreign/futures/',ticker,'?periodType=day')
    } else if(ticker == "FUT"){
      url = 'https://api.stock.naver.com/chart/domestic/futures/FUT?periodType=day'
    } else {
      url = paste0('https://api.stock.naver.com/chart/domestic/item/',ticker,'?periodType=day')
    }
    
    ik = url %>%
      read_html() %>%
      html_nodes('body') %>%
      html_text(trim = TRUE) 
    
    ind = ik %>%
      rm_between(., "[", "]", extract=TRUE) %>% .[[1]] %>% .[1] %>%
      rm_between(., "{", "}", extract=TRUE) %>% .[[1]] %>%
      strsplit(x=.,split = ",") 
    
    marketstatus = ik %>%
      rm_between(., "{", "}", extract=TRUE) %>% .[[1]] %>%
      strsplit(x=.,split = ",") %>% .[[1]] %>% .[grep("marketStatus",x=.)] %>% 
      rm_between(.,'\"', '\"', extract=TRUE) %>% .[[1]] %>% .[2]
    
    df = data.frame()
    for (i in 1:length(ind)) {
      df[i,c(1,2)] = parse_number(ind[[i]])[c(2,3)]
      df[i,3] = marketstatus
      row.names(df)[i] = format(ymd_hms(parse_number(ind[[i]])[1]),"%H:%M")
    }
    colnames(df) = c("InteradayPrice","ACC.Vol","MARKET")
  }
  df
}
