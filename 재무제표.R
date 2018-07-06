library(rvest) #install.packages('rvest')
library(plotly)


#################get KRX stock table and create data frame ##################
stock_table ="http://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13" %>%
  read_html() %>%
  html_nodes(xpath = '/html/body/table') %>%
  html_table() %>%
  .[[1]]

stock_table[[2]] <- sprintf("%06d",stock_table[[2]])
#############################################################################


#### financial statement
fs <- function(z) {
  com = z
  code = grep(pattern = com,x = stock_table[,1],ignore.case = TRUE)
  code = stock_table[code[1],2]
  url2 = paste0('http://companyinfo.stock.naver.com/v1/company/ajax/cF1001.aspx?cmp_cd=',code,collapse = NULL)
  txt2 = read_html(url2)
  BS_table = txt2 %>% 
    html_nodes("table") %>%
    html_table(fill = TRUE) %>%
    data.frame()
  
  if(grepl(pattern = '해당 데이터가 존재하지 않습니다.', x=BS_table)){
    BS_table[1,] = '데이터가 존재하지 않습니다. 기업명을 다시 확인 해 주세요'
    BS_table = BS_table[,-c(2:9)]
  } else {
    rownames(BS_table) <- BS_table[,1]
    colnames(BS_table) <- BS_table[1,] 
    BS_table <- BS_table[-1,]
    BS_table <- BS_table[,-1]
  }
  
  if(grepl(pattern = '데이터가 존재하지 않습니다. 기업명을 다시 확인 해 주세요',x=BS_table)){
    print('잘못된 데이터입니다.csv파일로 저장되지 않습니다.기업명을 다시 확인 해 주세요')
  } else {
    write.csv(BS_table,paste0("경로를 지정하세요",paste0(com,".csv"))) #경로지정시 'computer/document/' 이런식으로 지정,경로 끝에 /반드시 첨부
    print('해당경로에 csv파일로 저장되었습니다')
    View(x=BS_table,title = paste0("B/S:",com)) #단위 : 억원
    date = gsub('\t|\r|\n','',x=colnames(BS_table)) 
    p1 = plot_ly(data = data.frame(gsub('\t|\r|','',x=BS_table[1,])),
                 x= ~date ,
                 y = as.numeric(gsub(',','',BS_table[1,])),
                 type = 'bar',name = '매출액') 
    
    p2 = plot_ly(data = data.frame(gsub('\t|\r','',x=BS_table[2,])),
                 x= ~date, 
                 y = as.numeric(gsub(',','',BS_table[2,])),
                 type = 'bar',name = '영업이익') 
    
    p3 = plot_ly(data = data.frame(gsub('\t|\r','',x=BS_table[6,])),
                 x= ~date, 
                 y = as.numeric(gsub(',','',BS_table[6,])),
                 type = 'bar',name = '당기순이익') 
    subplot(p1,p2,p3,nrows = 3, shareX = TRUE)
  }
}


#### export .csv file


View(stock_table)
