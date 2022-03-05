fin_data = function(ticker,datetype=NULL,time_length=NULL,exusd = TRUE){
  
  options(warn = -1)
  
  if(!require(rvest)) install.packages('rvest')
  if(!require(qdapRegex)) install.packages('qdapRegex')
  if(!require(lubridate)) install.packages('lubridate')
  if(!require(readr)) install.packages('readr')
  library(rvest);library(qdapRegex); library(lubridate); library(readr)
  
  '%+%' <- paste0
  
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
  
  ############################## FX  ##############################
  list  = 'https://api.stock.naver.com/marketindex/exchangeWorld' %>%
    read_html() %>%
    html_nodes('body') %>%
    html_text(trim = TRUE) %>%
    rm_between(., "[", "]", extract=TRUE) %>%
    rm_between(., "{", "}", extract=TRUE)  %>% .[[1]] %>%
    strsplit(x=.,split = ",")
  
  FX = c()
  for (i in 1:length(list)) {
    FX = c(FX,list %>% .[[i]] %>%
             .[grep("symbolCode",x=.)] %>%
             rm_between(.,'\"','\"',extract = TRUE) %>% .[[1]] %>% .[2] %>% 
             gsub(x=.,"USD","")) 
  }
  ##############################FX  ##############################
  
  datetype = ifelse(is.null(datetype),'month',datetype)
  time_length = ifelse(is.null(time_length),'12',time_length)
  if(datetype=="year" & time_length>10) time_length = 10
  if(datetype=="day") time_length = NA
  '%ni%' = Negate('%in%'); ticker = ifelse(ticker %ni%  c(FTINDEX,FX), toupper(ticker),ticker)
  
  lub = ifelse(ticker %in% INDEX,'domestic/index/',
               ifelse(ticker %in% FINDEX,'foreign/index/.',
                      ifelse(ticker %in% FTINDEX,'foreign/futures/',
                             ifelse(ticker == "FUT",'domestic/futures/',
                                    ifelse((ticker %in% FX) & (exusd==TRUE),'foreign/exchange/USD',
                                           ifelse((ticker %in% FX) & (exusd==FALSE),'domestic/marketindex/FX_',
                                                  ifelse(ticker == "KRW",'domestic/marketindex/FX_USD','domestic/item/')))))))
  
  url = 'https://api.stock.naver.com/chart/' %+% lub %+% ticker %+% ifelse(exusd==FALSE,"KRW","") %+% '?periodType=' %+% ifelse(datetype=="day",'day',datetype %+% '&range=' %+% time_length)
  
  if(datetype!="day"){
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
      df[i,6] = ifelse(i==1,NA,
                       round(df[i,4]-df[i-1,4],digits = 2))
      df[i,7] = paste0(round((df[i,4]/df[i-1,4]-1)*100,digits = 2),"%")
      rownames(df)[i] = ind[[i]][1] %>% parse_number() %>% ymd() %>% as.character()
    }
    colnames(df) = c("Open","High","Low","Close","ACC.Vol","Chg","%Chg")
    
  } else if(datetype=="day"){
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
