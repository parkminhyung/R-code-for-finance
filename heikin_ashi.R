#normally data is from "quantmod"
#Example
# df = quantmod::getSymbols("AAPL") %>% heikin_ashi()

heikin_ashi = function(data) {
  
  if(!quantmod::is.OHLC(data)) stop("data must contain OHLC columns")
  
  heikin_close = xts::xts(Matrix::rowMeans(quantmod::OHLC(data)), order.by = index(data))
  heikin_open  = quantmod::Op(data)
  
  # need a loop: heiki ashi open is dependent on the previous value
  for(i in 2:nrow(data)) {
    heikin_open[i] = (heikin_open[i-1] + heikin_close[i-1]) / 2
  }
  
  heikin_high = xts::xts(apply(cbind(quantmod::Hi(data), heikin_open, heikin_close), 1, max), order.by = index(data))
  heikin_low = xts::xts(apply(cbind(quantmod::Lo(data), heikin_open, heikin_close), 1, min), order.by = index(data))
  
  out = merge(heikin_open, heikin_high, heikin_low, heikin_close)
  out = setNames(out, c("Open", "High", "Low", "Close"))
}
