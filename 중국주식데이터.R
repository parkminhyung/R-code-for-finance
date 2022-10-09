cn_fin_data = function(ticker,start_date=NULL,end_date=NULL){
  
  library(rvest); library(qdapRegex)
  options(warn = -1)
  '%+%' = paste0
  df = data.frame()
  start_date = ifelse(is.null(start_date), 
                      ifelse(format(Sys.Date(),"%m")==01,
                             (format(Sys.Date(),"%Y") %>% as.numeric() -1) %+% '0101',
                             format(Sys.Date(),"%Y") %+% "0101"),
                      start_date)
  
  end_date = ifelse(
    is.null(end_date),
    format(Sys.Date(),'%Y%m%d'),
    end_date
  )
  
  
  ls ='https://q.stock.sohu.com/hisHq?code=cn_' %+% ticker %+% '&start=' %+% start_date %+% '&end=' %+% end_date %+% '&stat=1&order=D&period=d&callback=historySearchHandler' %>% 
    read_html() %>% 
    html_nodes('body') %>% 
    rm_between('[{','}]',extract = TRUE) %>% .[[1]] %>% 
    rm_between('[',']',extract = TRUE) %>% .[[1]]
  for (i in 1:length(ls)){
    lss = ls[i] %>% gsub(x=.,'\"','') %>% .[1] %>% strsplit(x=.,",") %>% .[[1]]
    df[i,1:6] = lss  %>% 
      .[c(2,7,6,3,9,5)]
    rownames(df)[i] = lss %>% .[1]
  }
  
  rownames(df)[1] = rownames(df)[1] %>% gsub(x=.,'[','',fixed = TRUE)
  colnames(df) = c("Open","High","Low","Close","Vol","Chg%")
  df = df[nrow(df):1,] %>% .[-1,]
  df[,1:5] = sapply(df[,1:5], as.numeric)
  df
}

