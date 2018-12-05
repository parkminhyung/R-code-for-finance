library(rvest)
library(progress)
library(plotly)

#################get KRX stock table and create data frame ##################
KOSPI_data = 'http://file.krx.co.kr/download.jspx?code=bcjUHosusuhCeTZ7PTcGJFNMIk9OjGjbrxR8CvR1KGcvr2ZsoP6wXUvtDyU22k1i%2BdMZwVlhVdM6O8V56SGQu8LEqQgdnVIeoxRWxZcb%2BOtFcuSUIczesUo3pVcvaVhlyPI0x2TVul%2F5VeMZ89KlMmrh2iYZh%2FdHJC5b9p78%2FVcQddBRMO3kIdbuMtq4yH0VsD19JZuZ1Mk%2Fm2pbBP%2BpiO%2BpNimj3gWDaJrgSUn9GcM1pqS5%2FhPkt6KCIT7X%2F1GVChRUk7ZdKmW%2BLxpZJtt66cNFLbS6%2F5%2FaAKS20YwbqI7c3G4hiqK8D8L4GjcLUvNTmlx9Iseuc8t98%2BJmhN5hFmCroiryVxC8FaUTRuR2%2Fie0bh%2FV5%2BV80IjG8k7KOQObjHBzbd3SU0Tx3MDg2%2Bx91Cj5BM9vsbzUxIJSLTVUP7J2a6KIa5z36JhrIas7JqT3L5CTU%2BsrzOAbE2Q4LahMhqh2kUvow9Q5cqCq%2B8j6Cy%2BG1xVoKwgU0xZloXUGLnsvvKnpfPADB6g5ml7d%2BBkvs0kx%2BdGXwAe0ReOa5rsbAKs31gMRGFF8adtiKzem6BV72u7mArrgN10keKW4T3CIbqoLXCbbXCFwK94yf9JSNU%2B5v4DHY7Zy1oFVxbtUd%2BL6' %>%
  read.csv() %>%
  data.frame() %>%
  .[,-c(1,4,8,9,12)]

KOSPI_data$시장구분 = 'KOSPI'
KOSPI_data = KOSPI_data[,c(1,2,8,3:7)]

KOSDAQ_data = 'http://file.krx.co.kr/download.jspx?code=bcjUHosusuhCeTZ7PTcGJC38TPPqKKB09AESXDD4eL47oh7rJE7ndr0T3NRPTVLMg%2FdSCe6NgzwkMNaMBIvSFNCN2OOwmyju9C0FZ4gC0QquWMzIwkCxx8TD6J7sLkb2nm0ZZMPcDwMGVqTLagu28pBbZ6OvacZwGYXdjvMLQpoYBVi1DyD9%2Fq2L9eXddgerEtfcTC33dscIXmC6YlCSWCWA2wXlLRK13qYK8VCF4qfNTR57Yaz%2BZFskw43%2BmVvpGDzeASR1V77CoH0JpjgyK2pRYNmjFaslkzR%2Fz0gf%2B%2BA8u5%2FxkdPJOUgm24F5FpFvLpFukbJ9LeIgp%2BmJs%2FVsvlM9%2Bb8YK3x%2FCJgORZeaNm0Kxrj6t%2BG0suznDjhwlfgCN96%2FIPgy6KAlKdU8SD7wiHgSBENS1r5GVUgYbb7PDHT11q%2FmMyGFhR%2FmmMili%2FctQyWWi5LPoK0CTRlil%2FMDax1Kjdl9HUq2eLDA5wF78dJHMZR0YAgRiZgpUiopl90tn8VfkGgKtX62F9Ni%2BnTcDeu7nMSyKSjvTxjZT4gQJNjPouK2mZfkHlYy1ecR7ur%2FI8GQLksfNEdw7DSS%2B26OnjTptyWaFOA4I%2FnNJCWN1hEo%2F0zOyYhFYA0mU%2FlBKsYS' %>%
  read.csv() %>%
  data.frame() %>%
  .[,-c(1,4,8,9,12)]
KOSDAQ_data$시장구분 = 'KOSDAQ'
KOSDAQ_data = KOSDAQ_data[,c(1,2,8,3:7)]

stock_table = rbind(KOSPI_data,KOSDAQ_data) %>%
  .[grep(pattern = '[0-9]',x=.[,1]),] %>%
  .[-c(grep(pattern = '[가-힣]',x=.[,1])),] %>%
  .[,c(2,1)]

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


