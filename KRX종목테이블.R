library(rvest)

KRX_data = function(save_csv_file = FALSE){
  
  df_kospi ="http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13&marketType=stockMkt" %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table') %>%
    html_table() %>%
    .[[1]]
  df_kospi$시장구분 = 'KOSPI'
  
  df_kosdaq = "http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13&marketType=kosdaqMkt" %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table') %>%
    html_table() %>%
    .[[1]]
  df_kosdaq$시장구분 = 'KOSDAQ'
  
  df_konex = "http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13&marketType=konexMkt" %>%
    read_html() %>%
    html_nodes(xpath = '/html/body/table') %>%
    html_table() %>%
    .[[1]]
  df_konex$시장구분 = 'KONEX'
  
  stock_table = rbind(df_kospi,df_kosdaq,df_konex)
  stock_table[[2]] = sprintf("%06d",stock_table[[2]]) 
  stock_table = stock_table[,c(1,2,10,3:9)]
  View(stock_table)
  
  if(save_csv_file == TRUE) {
    write.csv(stock_table,"KRX테이블.csv")
    print("csv파일로 저장되었습니다.파일명 : KRX테이블.csv")
  } else {
    print("csv파일로 저장하지 않고 바로 테이블을 띄웁니다.")
  }
  
}


