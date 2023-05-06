#components of df must be followed as "open", "high","low","close" 

super_trend = function(df,n=NULL,Multiplier=NULL){
  options(warn=-1)
  n = ifelse(is.null(n),10,n); Multiplier =  ifelse(is.null(Multiplier),3,Multiplier)
  
  ifelse(!require(pacman),install.packages('pacman'),library(pacman))
  pacman::p_load("dplyr","quantmod")
  df$TR = NA
  for (i in 1:(nrow(df)-1)) {
    df$TR[i+1] = max(abs(df$high[i+1] - df$low[i+1]), 
                     abs(df$high[i+1] - df$close[i]),
                     abs(df$low[i+1] - df$close[i])) %>%
      round(.,digits = 2)
  }
  
  df = df %>% as.data.frame() %>%
    mutate(ATR = SMA(.$TR, n=n)) %>%
    mutate(UPPER_ATR_CLOSE = .$close + Multiplier*.$ATR) %>%
    mutate(LOWER_ATR_CLOSE = .$close - Multiplier*.$ATR) %>%
    mutate(UPPER_ATR_HIGH = .$low + Multiplier*.$ATR) %>%
    mutate(LOWER_ATR_HIGH = .$high - Multiplier*.$ATR) %>% 
    mutate(UPPER_ATR_CLOSE = .$close + Multiplier*.$ATR) %>% 
    mutate(LOWER_ATR_CLOSE = .$close - Multiplier*.$ATR) %>% 
    mutate(UPPER_ATR_HIGH = .$low + Multiplier*.$ATR) %>% 
    mutate(LOWER_ATR_HIGH = .$high - Multiplier*.$ATR) %>%
    mutate(UPPER_SUPERTREND = round(0.5*(.$high + .$low) + Multiplier*.$ATR,digits=2)) %>%
    mutate(LOWER_SUPERTREND = round(0.5*(.$high + .$low) - Multiplier*.$ATR,digits=2)) %>%
    mutate(FINAL_UPPERBAND = if_else(row_number() == n+1,.$UPPER_SUPERTREND[n+1],NA)) %>%
    mutate(FINAL_LOWERBAND = if_else(row_number() == n+1,.$LOWER_SUPERTREND[n+1],NA)) %>%
    mutate(SUPER_TREND = NA) %>%
    mutate(SIGNAL = NA) %>%
    mutate(SIGNAL2 = NA)
  
  df$SUPER_TREND[n+1] = ifelse((df$close[n+1] <= df$FINAL_UPPERBAND[n+1]),df$FINAL_UPPERBAND[n+1],df$FINAL_LOWERBAND[n+1])
  
  for (i in n:(nrow(df)-2)) {
    df$FINAL_UPPERBAND[i+2] = ifelse((df$UPPER_SUPERTREND[i+2] < df$FINAL_UPPERBAND[i+1] | df$close[i+1] > df$FINAL_UPPERBAND[i+1]),df$UPPER_SUPERTREND[i+2],df$FINAL_UPPERBAND[i+1])
    df$FINAL_LOWERBAND[i+2] = ifelse((df$LOWER_SUPERTREND[i+2] > df$LOWER_ATR_HIGH[i+1] | df$close[i+1] < df$FINAL_LOWERBAND[i+1]),df$LOWER_SUPERTREND[i+2],df$FINAL_LOWERBAND[i+1])
    df$SUPER_TREND[i+2] = ifelse((df$FINAL_UPPERBAND[i+1] == df$SUPER_TREND[i+1] & df$close[i+2] <= df$FINAL_UPPERBAND[i+2]),df$FINAL_UPPERBAND[i+2],
                                 ifelse((df$FINAL_UPPERBAND[i+1] == df$SUPER_TREND[i+1] & df$close[i+2] >= df$FINAL_UPPERBAND[i+2]),df$FINAL_LOWERBAND[i+2],
                                        ifelse((df$FINAL_LOWERBAND[i+1] == df$SUPER_TREND[i+1] & df$close[i+2] <= df$FINAL_LOWERBAND[i+2]),df$FINAL_UPPERBAND[i+2],
                                               ifelse((df$FINAL_LOWERBAND[i+1] == df$SUPER_TREND[i+1] & df$close[i+2] >= df$FINAL_LOWERBAND[i+2]),df$FINAL_LOWERBAND[i+2],0))))
    
  }
  
  df$SIGNAL = ifelse((df$close<= df$SUPER_TREND),"SELL","BUY")
  df$SIGNAL2 = ifelse(df$SIGNAL != df$SIGNAL[-1],paste0(df$SIGNAL[-1]," Signal"),NA) %>% lag()
  df %>%
    select(open,high,low,close,SIGNAL,SIGNAL2) 
}
