library(rvest)
library(progress)
library(plotly)

#################get KRX stock table and create data frame ##################
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

stock_table = rbind(df_kospi,df_kosdaq) %>% 
  .[,c(1:2)] 
stock_table[[2]] = sprintf("%06d",stock_table[[2]]) 

stock_table[,3:10] = list(k_score_2015 = NA,
                          k_zone_2015 = NA,
                          k_score_2016 = NA,
                          k_zone_2016 = NA,
                          k_score_2017= NA,
                          k_zone_2017= NA,
                          k_score_2018 = NA,
                          k_zone_2018 = NA)
View(stock_table)
############################################################################
pb = progress_bar$new(total = nrow(stock_table))
Date = paste0(2015:2017,'/12') 
Date[4] = "2018/09"
for (i in 1:nrow(stock_table)) {
  try({
    for (j in 1:length(Date)) {
      
      Date[j]
      ticker = stock_table[i,2]
      url = paste0('http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=S7&gicode=A',ticker)
      incomestatement = url %>%
        read_html() %>%
        html_nodes(xpath = '//*[@id="divSonikY"]/table') %>%
        html_table(fill = TRUE) %>%
        .[[1]] %>%
        .[,-c(6:8)]
      balancesheet = url %>%
        read_html() %>%
        html_nodes(xpath = '//*[@id="divDaechaY"]/table') %>%
        html_table(fill = TRUE) %>%
        .[[1]] 
      cashflow = url %>%
        read_html() %>%
        html_nodes(xpath = '//*[@id="divCashY"]/table') %>%
        html_table(fill = TRUE) %>%
        .[[1]]
      
      REV = incomestatement[grep(pattern = '매출',x=incomestatement[,1]),
                            grep(pattern = Date[j],x=colnames(incomestatement))] %>%
        .[[1]] %>%
        gsub(pattern = ',',replacement = '',x=.) %>%
        as.numeric()
      
      ASSET = balancesheet[grep(pattern = '자산',x=balancesheet[,1]),
                           grep(pattern = Date[j],x=colnames(incomestatement))] %>%
        .[[1]] %>%
        gsub(pattern = ',',replacement = '',x=.) %>%
        as.numeric() 
      RE = balancesheet[grep(pattern = '이익잉여금',x=balancesheet[,1]),
                        grep(pattern = Date[j],x=colnames(incomestatement))] %>%
        .[[1]] %>%
        gsub(pattern = ',',replacement = '',x=.) %>%
        as.numeric()
      
      TE = balancesheet[grep(pattern = '자본',x=balancesheet[,1]),
                        grep(pattern = Date[j],x=colnames(incomestatement))] %>%
        .[[1]] %>%
        gsub(pattern = ',',replacement = '',x=.) %>%
        as.numeric()
      
      TL =  balancesheet[grep(pattern = '부채',x=balancesheet[,1]),
                         grep(pattern = Date[j],x=colnames(incomestatement))] %>%
        .[[1]] %>%
        gsub(pattern = ',',replacement = '',x=.) %>%
        as.numeric()
      
      x1 = log(ASSET)
      #workingcapital/Total Asset
      x2 = log(REV/ASSET)  #retained earnings/Total Asset
      x3 = RE/ASSET #EBIT / Total Asset
      x4 = TE/TL
      
      k_score = (-17.862 + 1.472*x1+3.041*x2+ 14.839*x3+1.516*x4) %>%
        round(digits = 3)
      stock_table[i,(2*j+1)] = k_score
      
      if (k_score > .75) {
        stock_table[i,(2*j+2)] = "Safe Zone"
      } else if (k_score > -2.00  & k_score <.752) {
        stock_table[i,(2*j+2)] = "Grey Zone"
      } else if(k_score < -2.00) {
        stock_table[i,(2*j+2)] = "Distress Zone"
      }
    }
  },silent = TRUE)
  pb$tick()
}

stock_table = stock_table[grep('[0-9]',x=stock_table[,3]),]

h1 = plot_ly(data = data.frame(stock_table[,3]),
             x=stock_table[,3],
             type = "histogram",
             name = "histogram : K-score(2015)") %>%
  layout(title = 'Histogram of K-score') 
h2 = plot_ly(data = data.frame(stock_table[,3]),
             x=stock_table[,5],
             type = "histogram",
             name = "histogram : K-score(2016)")
h3 = plot_ly(data = data.frame(stock_table[,3]),
             x=stock_table[,7],
             type = "histogram",
             name = "histogram : K-score(2017)") 
h4 = plot_ly(data = data.frame(stock_table[,3]),
             x=stock_table[,9],
             type = "histogram",
             name = "histogram : K-score(2018)") 

subplot(h1,h2,h3,h4,nrows = 4,shareX = TRUE)

plot_ly(data = stock_table,
        x=Date[1:4],
        y=c(length(stock_table[grep(pattern = 'Safe Zone',x=stock_table[,4]),3]),
            length(stock_table[grep(pattern = 'Safe Zone',x=stock_table[,6]),5]),
            length(stock_table[grep(pattern = 'Safe Zone',x=stock_table[,8]),7]),
            length(stock_table[grep(pattern = 'Safe Zone',x=stock_table[,10]),9])),
        type = 'scatter',
        mode = 'line',
        name = "Green Zone") %>%
  add_trace(y=c(length(stock_table[grep(pattern = 'Grey Zone',x=stock_table[,4]),3]),
                length(stock_table[grep(pattern = 'Grey Zone',x=stock_table[,6]),5]),
                length(stock_table[grep(pattern = 'Grey Zone',x=stock_table[,8]),7]),
                length(stock_table[grep(pattern = 'Grey Zone',x=stock_table[,10]),9])),
            name = "Grey Zone") %>%
  add_trace(y=c(length(stock_table[grep(pattern = 'Distress Zone',x=stock_table[,4]),3]),
                length(stock_table[grep(pattern = 'Distress Zone',x=stock_table[,6]),5]),
                length(stock_table[grep(pattern = 'Distress Zone',x=stock_table[,8]),7]),
                length(stock_table[grep(pattern = 'Distress Zone',x=stock_table[,10]),9])),
            name = "Distress Zone")
