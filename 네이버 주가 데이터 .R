library(rvest)
ticker = "005930"

##########################################################################################
################################### price per minute info ################################

{
  '%ni%' = Negate('%in%')
  
  if(weekdays(Sys.Date()) %ni% c("Saturday", "Sunday","Monday") & ("00:00:00" < format(Sys.time(), "%X")) & (format(Sys.time(), "%X") < "09:00:00")==TRUE) {
    Date.time = format(Sys.Date()-1,"%Y%m%d")
  } else if(weekdays(Sys.Date())=="Saturday"){
    Date.time = format(Sys.Date()-1,"%Y%m%d")
  } else if(weekdays(Sys.Date())=="Sunday"){
    Date.time = format(Sys.Date()-2,"%Y%m%d")
  } else if(weekdays(Sys.Date()) == "Monday" & ("00:00:00" < format(Sys.time(), "%X")) & (format(Sys.time(), "%X") < "09:00:00") == TRUE){
    Date.time = format(Sys.Date()-3,"%Y%m%d")
  } else {
    Date.time = format(Sys.Date(),"%Y%m%d")
  }
  
  df = data.frame()
  
  num = paste0('https://finance.naver.com/item/sise_time.nhn?code=',ticker,'&thistime=',Date.time,'1600&page=',1) %>%
    read_html(encoding = 'EUC-KR') %>%
    html_nodes(xpath = '/html/body/table[2]') %>%
    as.character() %>%
    substr(.,gregexpr("맨뒤",.)[[1]][1]-4,gregexpr("맨뒤",.)[[1]][1]-3)
  
  for (i in 1:num) {
    url = paste0('https://finance.naver.com/item/sise_time.nhn?code=',ticker,'&thistime=',Date.time,'1600&page=',i) %>%
      read_html(encoding = 'EUC-KR') %>%
      html_nodes(xpath = '/html/body/table[1]') %>%
      html_table() %>%
      .[[1]]
    df = rbind(df,url)
  }
  
  df = df[-which(df[,1]==""),] %>%
    .[nrow(.):1,]
  rownames(df) = df[,1] 
  df = df[,-1] 
  
  for(i in 1:ncol(df)) df[,i] = gsub(',','',x=df[,i]) %>%  as.numeric()
  
  View(df)
  
}

##########################################################################################
################################### Daily price info ####################################

{
  df = data.frame()
  
  for (i in 1:10) {
    url = paste0('https://finance.naver.com/item/sise_day.nhn?code=',ticker,'&page=',i) %>%
      read_html() %>%
      html_nodes(xpath = '/html/body/table[1]') %>%
      html_table() %>%
      .[[1]] 
    
    df = rbind(df,url)
  }
  
  df = df[-which(df[,1]==""),] %>%
    .[nrow(.):1,]
  
  df[,1] = gsub("\\.","/",df[,1])
  rownames(df) = df[,1]
  
  df = df[,-1] %>%
    .[,c(3:5,1,6,2)]
  
  for(i in 1:5) df[,i] = gsub(',','',x=df[,i]) %>%  as.numeric()
  
  df[1,6] = NA
  for (i in 2:nrow(df)) df[i,6] = paste0(round(((df[i,4]-df[i-1,4])/df[i-1,4])*100,digits=2),"%") 
  
  View(df)
}

