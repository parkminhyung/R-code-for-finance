library(rvest)

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
stock_table = stock_table[,c(1,2,10)]
View(stock_table)
stock_table[,4:20] = NA
colnames(stock_table) = c("회사명",
                          "종목코드",
                          "시장구분",
                          "기준일",
                          "매출액",
                          "영업이익",
                          "영업이이률",
                          "당기순이익",
                          "당기순이익률",
                          "총자산",
                          "총부채",
                          "총자본",
                          "ROE",
                          "PER",
                          "PBR",
                          "PSR",
                          "IC;백만원",
                          "WACC",
                          "EVA;백만원",
                          "EVEBITDA")

##
for (i in 1:nrow(stock_table)) {
  try({
    
    tb = paste0('http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A',stock_table[i,2]) %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="divSonikY"]/table') %>%
      html_table(fill = TRUE) %>%
      .[[1]] 
    
    col = grep("전년동기",colnames(tb))[1]
    
    stock_table[i,4] = colnames(tb)[grep("전년동기",colnames(tb))[1]-1] %>% gsub(x=.,"/",".")
    
    #매출액
    p1 = tb[1,(col-1)]
    p2 = tb[1,col] %>%  gsub(x=.,',','') %>% as.numeric()
    stock_table[i,5] = paste0(p1 %>% paste0(.,"억원")," ","(",round(((p1 %>% gsub(x=.,',','') %>% as.numeric()-p2)/abs(p2))*100,digits = 2) %>%
                                paste0(.,"%"),")")
    
    #영업이익
    p3 = tb[grep("영업이익",tb[,1])[1],(col-1)]
    p4 = tb[grep("영업이익",tb[,1])[1],col] %>%  gsub(x=.,',','') %>% as.numeric()
    stock_table[i,6] = paste0(p3 %>% paste0(.,"억원")," ","(",round(((p3 %>% gsub(x=.,',','') %>% as.numeric()-p4)/abs(p4))*100,digits = 2) %>%
                                paste0(.,"%"),")")
    
    #영업이익률
    stock_table[i,7] = round((p3 %>% gsub(x=.,",","") %>% gsub(x=.,"억원","") %>% as.numeric()/p1 %>% gsub(x=.,",","") %>% gsub(x=.,"억원","") %>% as.numeric())*100,digits = 2) %>%
      paste0(.,"%")
    
    #당기순이익
    p5 = tb[grep("당기순이익",tb[,1])[1],(col-1)]
    p6 = tb[grep("당기순이익",tb[,1])[1],col] %>%  gsub(x=.,',','') %>% as.numeric()
    stock_table[i,8] = paste0(p5 %>% paste0(.,"억원")," ","(",round(((p5 %>% gsub(x=.,',','') %>% as.numeric()-p6)/abs(p6))*100,digits = 2) %>%
                                paste0(.,"%"),")")
    
    #당기순이익률
    stock_table[i,9] =round((p5 %>% gsub(x=.,",","") %>% gsub(x=.,"억원","") %>% as.numeric()/p1 %>% gsub(x=.,",","") %>% gsub(x=.,"억원","") %>% as.numeric())*100,digits = 2) %>%
      paste0(.,"%")
    
    tb2 = paste0('http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A',stock_table[i,2]) %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="divDaechaY"]/table') %>%
      html_table(fill = TRUE) %>%
      .[[1]] 
    
    #총자산
    stock_table[i,10] = tb2[grep("자산",tb2[,1])[1],(col-1)] %>% paste0(.,"억원")
    
    #총부채
    stock_table[i,11] = tb2[grep("부채",tb2[,1])[1],(col-1)] %>% paste0(.,"억원")
    
    #총자본
    stock_table[i,12] = tb2[grep("자본",tb2[,1])[1],(col-1)] %>% paste0(.,"억원")
    
    #ROE
    stock_table[i,13] = paste0('http://media.kisline.com/highlight/mainHighlight.nice?paper_stock=',stock_table[i,2],'&nav=1') %>%
      read_html() %>%
      html_node(xpath = '//*[@id="summarytp1"]/table[1]/tbody/tr[10]/td[3]') %>%
      html_text()
    
    
    #PER
    stock_table[i,14] = paste0('http://media.kisline.com/highlight/mainHighlight.nice?paper_stock=',stock_table[i,2],'&nav=1') %>%
      read_html() %>%
      html_node(xpath = '//*[@id="summarytp0"]/table[2]/tbody/tr[11]/td[5]') %>%
      html_text()
    
    #PBR
    stock_table[i,15] = paste0('http://media.kisline.com/highlight/mainHighlight.nice?paper_stock=',stock_table[i,2],'&nav=1') %>%
      read_html() %>%
      html_node(xpath = '//*[@id="summarytp0"]/table[2]/tbody/tr[12]/td[5]') %>%
      html_text()
    
    #PSR
    stock_table[i,16] = paste0('http://media.kisline.com/highlight/mainHighlight.nice?paper_stock=',stock_table[i,2],'&nav=1') %>%
      read_html() %>%
      html_node(xpath = '//*[@id="summarytp0"]/table[2]/tbody/tr[13]/td[5]') %>%
      html_text()
    
    #IC
    stock_table[i,17] = paste0('http://media.kisline.com/investinfo/mainInvestinfo.nice?paper_stock=',stock_table[i,2],'&nav=3') %>%
      read_html() %>%
      html_node(xpath = '//*[@id="i1701"]/table/tbody/tr[1]/td[9]') %>%
      html_text() 
    
    #WACC
    stock_table[i,18] = paste0('http://media.kisline.com/investinfo/mainInvestinfo.nice?paper_stock=',stock_table[i,2],'&nav=3') %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="i1701"]/table/tbody/tr[4]/td[9]') %>%
      html_text()
    
    #EVA
    stock_table[i,19] = paste0('http://media.kisline.com/investinfo/mainInvestinfo.nice?paper_stock=',stock_table[i,2],'&nav=3') %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="i1701"]/table/tbody/tr[5]/td[9]') %>%
      html_text()
    
    #EVEBITDA
    stock_table[i,20] = paste0('http://media.kisline.com/investinfo/mainInvestinfo.nice?paper_stock=',stock_table[i,2],'&nav=3') %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="i1801"]/table/tbody/tr[5]/td[5]') %>%
      html_text()
  },silent = TRUE)
}