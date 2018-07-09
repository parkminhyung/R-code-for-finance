library(rvest)
library(rowr)
library(plotly)

##################create data frame##################
sh_url = 'http://www.cgedt.com/stockcode/hushi.asp' %>%
  read_html() %>%
  html_node(xpath = '//*[@id="stockcodelist"]/ul') %>%
  html_text() %>%
  as.character()

sh_table = sh_url %>%
  gsub(pattern = '\r\n',replacement = ',') %>%
  strsplit(',') %>%
  .[[1]] %>%
  data.frame() 
sh_table = sh_table[grep("[0-9]",x=sh_table[,1]),]

sz_url = 'http://www.cgedt.com/stockcode/shenshi.asp' %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="stockcodelist"]/ul') %>%
  html_text() %>%
  as.character()

sz_table = sz_url %>%
  gsub(pattern = '\r\n',replacement = ',') %>%
  strsplit(',') %>%
  .[[1]] %>%
  as.data.frame() 
sz_table = sz_table[grep("[0-9]",x=sz_table[,1]),]


cyb_url = 'http://www.cgedt.com/stockcode/chuangyeban.asp' %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="stockcodelist"]/ul') %>%
  html_text() %>%
  as.character()

cyb_table = cyb_url %>%
  gsub(pattern = '\r\n',replacement = ',') %>%
  strsplit(',') %>%
  .[[1]] %>%
  as.data.frame() 
cyb_table = cyb_table[grep("[0-9]",x=cyb_table[,1]),]

cngs_table = cbind.fill(sh_table,sz_table,cyb_table,fill= NA) 
colnames(cngs_table) = c('상해A','심천A','창업판') 
View(cngs_table)
########################################################################
########################################################################

cn_fs <- function(x) {
  cn_table = paste0('http://quotes.money.163.com/f10/cwbbzy_',x,'.html',collapse = NULL) %>%
    read_html() %>%
    html_nodes(xpath = '//*[@id="scrollTable"]/div[4]/table') %>%
    html_table(fill = TRUE) %>%
    .[[1]]
  rownames(cn_table) = c('===손익계산서(단위:만위안)',
                         '영업수익',
                         '영업비용',
                         '영업이익',
                         '법인세차감전순이익',
                         '법인세비용',
                         '당기순이익',
                         '주당손익',
                         '===재무상태표(단위:만위안)',
                         '현금성자산',
                         '매출채권',
                         '재고자산',
                         '유동자산',
                         '고정자산',
                         '자산총계',
                         '유동부채합계',
                         '비유동부채합계',
                         '부채총계',
                         '자본총계',
                         '===현금흐름표(단위:만위안)',
                         '기초현금흐름',
                         '경영활동현금흐름',
                         '투자활동으로인한현금흐름',
                         '재무활동으로인한현금흐름',
                         '현금및현금등가물증가액',
                         '기말현금흐름') 
  date = as.Date(colnames(cn_table))
  p1 = plot_ly(data=as.data.frame(cn_table),
               x = date,
               y= as.numeric(gsub(',','',x=cn_table[2,])),
               type = 'bar', name = '영업수익')
  p2 = plot_ly(data=data.frame(cn_table), 
               x= date,
               y= as.numeric(gsub(',','',x=cn_table[7,])), 
               type = 'bar', name = '당기순이익')
  p3 = plot_ly(data=data.frame(cn_table), 
               x= date,
               y= as.numeric(gsub(',','',x=cn_table[8,])), 
               type = 'bar', name = '주당손익')
  subplot(p1,p2,p3,nrows = 3,shareX = TRUE) %>%
    print()
  View(x=cn_table,title = paste0("B/S:",x))
}
