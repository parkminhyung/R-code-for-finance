library(quantmod)

rtp = function(ticker,length) {
  rtp_df = data.frame(Trade_Time = NA,
                  Last = NA,
                  change = NA,
                  chg_percent = NA,
                  Open = NA,
                  High = NA,
                  Low = NA,
                  Volume = NA)
  
  class(rtp_df[,1]) = c('POSIXt','POSIXct')
  
  for (i in 1:length) {
    rtp_df[i,1] = Sys.time()
    rtp_df[i,2:8]= getQuote(ticker,src='yahoo')[2:8]
    plot(x=c(1:i),
         y=rtp_df[1:i,2],
         type = 'l',
         col = 'blue',
         xlab = 'Time',
         ylab = 'Price',lwd=1.5)
    grid(col = 'lightgray',lty=1)
    title(main=paste0(ticker,":Chart"))
    legend("topright",legend = c(paste0("Price:",rtp_df[i,2]),paste0("Chg",":",round(rtp_df[i,4],digits = 2),"%")))
    print(paste0('current_price:',rtp_df[i,2]))
  }
  View(rtp_df)
}


