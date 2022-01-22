fin_data = function(ticker,datetype=NULL,time_length=NULL){
  
  if(!require(rvest)) install.packages('rvest'); library(rvest)
  if(!require(qdapRegex)) install.packages('qdapRegex'); library(qdapRegex)
  if(!require(lubridate)) install.packages('lubridate'); library(lubridate)
  if(!require(readr)) install.packages('readr'); library(readr)
  
  INDEX = c('KOSPI','KOSPI200','KOSDAQ')
  
  FINDEX = c('DJI','IXIC','DJT','NDX','INX','SOX','VIX','SSEC','SZSC','SSEA','SZSA','SSEB','SZSB','CSI100','CSI300','HSI','HSCE','N225','TWII',
             'TOPX','VNI','AXJO','BSESN',
             'HNXI','STOXX50E','GDAXI','FTSE','FTMIB','AEX','FCHI',
             'IRTS','BFX','PSI20','IBEX','ISEQ','OMXC20','OMXS30','OMXH25','ATG','BUX',
             'KLSE','JKSE','BVSP','MXX','MERV')
  
  FTINDEX = c('NQcv1','EScv1','RTYcv1',
              'SFCc1','HCEIc1','SSIcm1',
              'STXEc1','FDXc1','SINc1')
  
  datetype = ifelse(is.null(datetype),'month',datetype)
  time_length = ifelse(is.null(time_length),'12',time_length)
  if(datetype=="year" & time_length>0) time_length = 10
  '%ni%' = Negate('%in%')
  ticker = ifelse(ticker %ni%  FTINDEX, toupper(ticker),ticker)
  
  if(datetype!="day"){
    
    #Domestic
    url = ifelse(ticker %in% INDEX, 
                 paste0('https://api.stock.naver.com/chart/domestic/index/',ticker,'?periodType=',datetype,'&range=',time_length),
                 paste0('https://api.stock.naver.com/chart/domestic/item/',ticker,'?periodType=',datetype,'&range=',time_length))
    
    #Foreign
    if(ticker %in% FINDEX) url = paste0('https://api.stock.naver.com/chart/foreign/index/.',ticker,'?periodType=',datetype,'&range=',time_length)
    
    #Future
    url = ifelse(ticker == "FUT",
                 paste0('https://api.stock.naver.com/chart/domestic/futures/FUT?periodType=',datetype,'&range=',time_length),
                 ifelse(ticker %in% FTINDEX,
                        paste0('https://api.stock.naver.com/chart/foreign/futures/',ticker,'?periodType=',datetype,'&range=',time_length)))
    
    ind = url %>%
      read_html() %>%
      html_nodes('body') %>%
      html_text(trim = TRUE) %>%
      rm_between(., "[", "]", extract=TRUE) %>%
      rm_between(., "{", "}", extract=TRUE) %>% .[[1]] %>%
      strsplit(x=.,split = ",") 
    
    df = data.frame()
    for (i in 1:length(ind)) {
      df[i,1] = parse_number(ind[[i]])[3]
      df[i,2] = parse_number(ind[[i]])[4]
      df[i,3] = parse_number(ind[[i]])[5]
      df[i,4] = parse_number(ind[[i]])[2]
      df[i,5] = parse_number(ind[[i]])[6]
      df[1,6] = NA
      df[i,6] = paste0(round((df[i,4]/df[i-1,4]-1)*100,digits = 2),"%")
      rownames(df)[i] = ind[[i]][1] %>% parse_number() %>% ymd() %>% as.character()
    }
    colnames(df) = c("Open","High","Low","Close","ACC.Vol","Chg")
    
  } else if(datetype=="day"){
    url = ifelse(ticker %in% INDEX, 
                 paste0('https://api.stock.naver.com/chart/domestic/index/',ticker,'?periodType=day'),
                 paste0('https://api.stock.naver.com/chart/domestic/item/',ticker,'?periodType=day'))
    url = ifelse(ticker == "FUT",
                 paste0('https://api.stock.naver.com/chart/domestic/futures/FUT?periodType=day'),
                 ifelse(ticker %in% FTINDEX,
                        paste0('https://api.stock.naver.com/chart/foreign/futures/',ticker,'?periodType=day')))
    
    ind = url %>%
      read_html() %>%
      html_nodes('body') %>%
      html_text(trim = TRUE) %>%
      rm_between(., "[", "]", extract=TRUE) %>% .[[1]] %>% .[1] %>%
      rm_between(., "{", "}", extract=TRUE) %>% .[[1]]  %>%
      strsplit(x=.,split = ",") 
    
    df = data.frame()
    for (i in 1:length(ind)) {
      df[i,1] = parse_number(ind[[i]])[2]
      df[i,2] = parse_number(ind[[i]])[3]
      row.names(df)[i] = format(ymd_hms(parse_number(ind[[i]])[1]),"%H:%M")
    }
    colnames(df) = c("InteradayPrice","ACC.Vol")
  }
  View(df)
  df
}





