#Sensitivity Analysis of Option Premium

option_sens = function(s,x,r,std,t,y=NULL){
  y=ifelse(is.null(y)!=TRUE,y,0)
  
  d1 = (log(s/x)+(r-y+std^2/2)*t)/(std*sqrt(t))
  d2 = d1-(std*sqrt(t)) 
  
  nd1 = (1/(sqrt(2*pi)))*exp(-(d1^2/2))
  
  #delta
  call.Delta = pnorm(d1)
  put.Delta = pnorm(d1)-1
  
  #Gamma
  Gam = nd1/(s*std*sqrt(t))
  
  #theta
  call.Th = -((s*std)/(2*sqrt(t)))*nd1-x*exp(-r*t)*r*pnorm(d2)
  put.Th = -((s*std)/(2*sqrt(t)))*nd1-x*exp(-r*t)*r*(pnorm(d2)-1)
  
  #rho
  call.rh = x*t*exp(-r*t)*pnorm(d2)
  put.rh = x*t*exp(-r*t)*(pnorm(d2)-1)
  
  #Vega
  Vega = s*sqrt(t)*nd1
  
  cat("=========== Sensitivity Analysis of Option ===========","\n")
  cat("\n")
  cat("##### Delta #####","\n")
  cat("Call Delta : ",call.Delta,"\n")
  cat("Put Delta :",put.Delta,"\n")
  cat("\n")
  cat("##### Gamma #####","\n")
  cat("Call/Put Gamma :",Gam,"\n")
  cat("\n")
  cat("##### Vega #####","\n")
  cat("Call/Put Vega :",Vega,"\n")
  cat("\n")
  cat("##### Theta #####","\n")
  cat("Call Theta :",call.Th,"\n")
  cat("Put Theta :",put.Th,"\n")
  cat("\n")
  cat("##### Rho #####","\n")
  cat("Call Rho :",call.rh,"\n")
  cat("Put Rho :",put.rh,"\n")
  cat("\n")
  cat("===============================================","\n")
}
