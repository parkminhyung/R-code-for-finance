krx_stock_table = function (market = NULL,save_csv_file = FALSE){
  library(rvest)
  list  = c("konexMkt","kosdaqMkt","stockMkt")
  url = "http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13&marketType="
  
  if(is.null(market)){
    dfkl = data.frame()
    for (i in 1:length(list)) {
      dfk = paste0(url,list[i]) %>%
        read_html() %>%
        html_nodes(xpath = "/html/body/table") %>%
        html_table() %>%
        .[[1]]
      
      if(i==1) dfk$"시장구분" = "KONEX"
      if(i==2) dfk$"시장구분" = "KOSDAQ"
      if(i==3) dfk$"시장구분" = "KOSPI"
      dfkl = rbind(dfk,dfkl)
    }
    dfkl[2] = sprintf("%06d",dfkl[[2]])
    dfkl = dfkl[,c(1,2,10,3:9)]
    View(dfkl,title = "상장목록")
    
  } else if(market == "kospi"){
    dfkl = paste0(url,list[3]) %>%
      read_html() %>%
      html_nodes(xpath = "/html/body/table") %>%
      html_table() %>%
      .[[1]]
    dfkl$"시장구분" = "KOSPI"
    dfkl[2] = sprintf("%06d",dfkl[[2]])
    dfkl = dfkl[,c(1,2,10,3:9)]
    View(dfkl,title = paste0(toupper(market),"_상장목록"))
    
  } else if(market == "kosdaq"){
    dfkl = paste0(url,list[2]) %>%
      read_html() %>%
      html_nodes(xpath = "/html/body/table") %>%
      html_table() %>%
      .[[1]]
    dfkl$"시장구분" = "KOSDAQ"
    dfkl[2] = sprintf("%06d",dfkl[[2]])
    dfkl = dfkl[,c(1,2,10,3:9)]
    View(dfkl,title = paste0(toupper(market),"_상장목록"))
    
  } else if(market =="konex"){
    dfkl = paste0(url,list[1]) %>%
      read_html() %>%
      html_nodes(xpath = "/html/body/table") %>%
      html_table() %>%
      .[[1]]
    dfkl$"시장구분" = "KONEX"
    dfkl[2] = sprintf("%06d",dfkl[[2]])
    dfkl = dfkl[,c(1,2,10,3:9)]
    View(dfkl,title = paste0(toupper(market),"_상장목록"))
    
  } else {
    print("market 값을 잘못 입력하셨습니다.")
  }
  
  if(save_csv_file == TRUE) {
    write.csv(dfkl,paste0("KRX_",market,"_테이블.csv"))
    print(paste0("csv파일로 저장되었습니다.파일명 :KRX_",market,"_테이블.csv"))
  } else {
    print("csv파일로 저장하지 않고 바로 테이블을 띄웁니다.")
  }
}
