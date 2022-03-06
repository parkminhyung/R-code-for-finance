#BETA

#############################################################

beta = function(ind,mkt){
  options(scipen = 100)
  IND.RET = round(diff(log(ind)),digits=5)
  MKT.RET = round(diff(log(mkt)),digits=5)
  BETA = round(cov(IND.RET,MKT.RET)/var(MKT.RET),digits = 3)
}


##############################################################

beta = function(ind,mkt){
  library(plotly)
  "%+%" = paste0
  options(scipen = 100)
  IND.RET = round(diff(log(ind)),digits=5)
  MKT.RET = round(diff(log(mkt)),digits=5)
  BETA = round(cov(IND.RET,MKT.RET)/var(MKT.RET),digits = 3)
  
  model = lm(MKT.RET~IND.RET)
  len = length(IND.RET)
  
  x_range = seq(min(IND.RET), max(IND.RET), length.out = len) 
  slope = model$coefficients[2]
  
  plot_ly(
    x=IND.RET,
    y=MKT.RET,
    type = "scatter",
    mode = "markers",
    name = "Market-Stock"
  ) %>%
    add_trace(
      x=x_range,
      y=slope*x_range,
      mode = "lines",alpha = 1,
      name = "linear reg") %>%
    layout(title = "BETA: " %+% BETA) %>%
    show()
  cat("==========================================","\n")
  cat(" BETA is " %+% BETA,"\n")
  cat("y= " %+% round(slope,digits = 4) %+% "*x " %+% round(model$coefficients[1],digits=4),"\n")
  cat("Adj.R-Squared: " %+% round(summary(model)$adj.r.squared,digits = 4),"\n")
  cat("==========================================","\n")
}




