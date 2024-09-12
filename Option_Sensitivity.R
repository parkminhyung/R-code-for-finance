#Sensitivity Analysis of Option Premium

library(stats)

option_greeks = function(s,k,rf,sigma,tau,y=0){
  tau = tau/365
  sigma = sigma/100
  rf = rf/100
  y = y/100
  
  d1 = (log(s/k)+(rf-y+sigma^2/2)*tau)/(sigma*sqrt(tau))
  d2 = d1-(sigma*sqrt(tau)) 
  
  nd1 = (1/(sqrt(2*pi)))*exp(-(d1^2/2))
  
  #delta
  call.Delta = pnorm(d1)
  put.Delta = pnorm(d1)-1
  
  #Gamma
  Gam = nd1/(s*sigma*sqrt(tau))
  
  #theta
  call.Th = (-((s*sigma)/(2*sqrt(tau)))*nd1-k*exp(-rf*tau)*rf*pnorm(d2))*(1/365)
  put.Th = (-((s*sigma)/(2*sqrt(tau)))*nd1-k*exp(-rf*tau)*rf*(pnorm(d2)-1))*(1/365)
  
  #rho
  call.rh = k*tau*exp(-rf*tau)*pnorm(d2)*(1/100)
  put.rh = k*tau*exp(-rf*tau)*(pnorm(d2)-1)*(1/100)
  
  #Vega
  Vega = s*sqrt(tau)*nd1*(1/100)
  
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


# Example

s = 222.66
k = 222.5
tau = 9 #days
sigma = 24.99 #percent
rf  = 4.12 #percent
y= 0.044 #percent

option_greeks(s,k,rf,sigma,tau)


# Outcomes: 
# =========== Sensitivity Analysis of Option =========== 

# ##### Delta ##### 
# Call Delta :  0.5254462 
# Put Delta : -0.4745538 

# ##### Gamma ##### 
# Call/Put Gamma : 0.04556613 

# ##### Vega ##### 
# Call/Put Vega : 0.139201 

# ##### Theta ##### 
# Call Theta : -0.2060483 
# Put Theta : -0.1809587 

# ##### Rho ##### 
# Call Rho : 0.02794118 
# Put Rho : -0.02686612 

# =============================================== 


