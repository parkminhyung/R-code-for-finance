library(quantmod)

KOSPI_data = 'http://file.krx.co.kr/download.jspx?code=bcjUHosusuhCeTZ7PTcGJFNMIk9OjGjbrxR8CvR1KGcvr2ZsoP6wXUvtDyU22k1i%2BdMZwVlhVdM6O8V56SGQu8LEqQgdnVIeoxRWxZcb%2BOtFcuSUIczesUo3pVcvaVhlyPI0x2TVul%2F5VeMZ89KlMmrh2iYZh%2FdHJC5b9p78%2FVcQddBRMO3kIdbuMtq4yH0VsD19JZuZ1Mk%2Fm2pbBP%2BpiO%2BpNimj3gWDaJrgSUn9GcM1pqS5%2FhPkt6KCIT7X%2F1GVChRUk7ZdKmW%2BLxpZJtt66cNFLbS6%2F5%2FaAKS20YwbqI7c3G4hiqK8D8L4GjcLUvNTmlx9Iseuc8t98%2BJmhN5hFmCroiryVxC8FaUTRuR2%2Fie0bh%2FV5%2BV80IjG8k7KOQObjHBzbd3SU0Tx3MDg2%2Bx91Cj5BM9vsbzUxIJSLTVUP7J2a6KIa5z36JhrIas7JqT3L5CTU%2BsrzOAbE2Q4LahMhqh2kUvow9Q5cqCq%2B8j6Cy%2BG1xVoKwgU0xZloXUGLnsvvKnpfPADB6g5ml7d%2BBkvs0kx%2BdGXwAe0ReOa5rsbAKs31gMRGFF8adtiKzem6BV72u7mArrgN10keKW4T3CIbqoLXCbbXCFwK94yf9JSNU%2B5v4DHY7Zy1oFVxbtUd%2BL6' %>%
  read.csv() %>%
  data.frame() %>%
  .[,-c(1,4,8,9,12)]

KOSPI_data$시장구분 = 'KOSPI'
KOSPI_data = KOSPI_data[,c(1,2,8,3:7)]
KOSPI_data[1] = paste0(KOSPI_data[,1],'.KS')

KOSDAQ_data = 'http://file.krx.co.kr/download.jspx?code=bcjUHosusuhCeTZ7PTcGJC38TPPqKKB09AESXDD4eL47oh7rJE7ndr0T3NRPTVLMg%2FdSCe6NgzwkMNaMBIvSFNCN2OOwmyju9C0FZ4gC0QquWMzIwkCxx8TD6J7sLkb2nm0ZZMPcDwMGVqTLagu28pBbZ6OvacZwGYXdjvMLQpoYBVi1DyD9%2Fq2L9eXddgerEtfcTC33dscIXmC6YlCSWCWA2wXlLRK13qYK8VCF4qfNTR57Yaz%2BZFskw43%2BmVvpGDzeASR1V77CoH0JpjgyK2pRYNmjFaslkzR%2Fz0gf%2B%2BA8u5%2FxkdPJOUgm24F5FpFvLpFukbJ9LeIgp%2BmJs%2FVsvlM9%2Bb8YK3x%2FCJgORZeaNm0Kxrj6t%2BG0suznDjhwlfgCN96%2FIPgy6KAlKdU8SD7wiHgSBENS1r5GVUgYbb7PDHT11q%2FmMyGFhR%2FmmMili%2FctQyWWi5LPoK0CTRlil%2FMDax1Kjdl9HUq2eLDA5wF78dJHMZR0YAgRiZgpUiopl90tn8VfkGgKtX62F9Ni%2BnTcDeu7nMSyKSjvTxjZT4gQJNjPouK2mZfkHlYy1ecR7ur%2FI8GQLksfNEdw7DSS%2B26OnjTptyWaFOA4I%2FnNJCWN1hEo%2F0zOyYhFYA0mU%2FlBKsYS' %>%
  read.csv() %>%
  data.frame() %>%
  .[,-c(1,4,8,9,12)]
KOSDAQ_data$시장구분 = 'KOSDAQ'
KOSDAQ_data = KOSDAQ_data[,c(1,2,8,3:7)]
KOSDAQ_data[1] = paste0(KOSDAQ_data[,1],'.KQ')

KRX_DATA = rbind(KOSPI_data,KOSDAQ_data) 
KRX_DATA = KRX_DATA[grep(pattern = '[0-9]',x=KRX_DATA[,1]),]
KRX_DATA = KRX_DATA[-c(grep(pattern = '[가-힣]',x=KRX_DATA[,1])),]

View(KRX_DATA)


start_date = '2018-01-01'
end_date = Sys.Date()
stock_data = new.env()


for (i in 1:nrow(KRX_DATA)) {
  sapply(KRX_DATA[i,1], function(x){
    try(
      getSymbols(
        x,
        src ="yahoo",
        from = start_date,
        to = end_date,
        env = stock_data,
        auto.assign = TRUE),silent = FALSE)
  })
  cat(KRX_DATA[i,1],": download complete", "\n")
}
