
## Black-Scholes Model for call and put option 
# s : Asset price 
# x : Strike Price 
# tau = time to maturity
# sigma : volatility
# rf : risk-free rate
# y : dividend yield, default value is 0
# option_type : "c" ~ call price, "p" ~ put price. default value is "c"


bs_model = function(s,x,rf,tau,sigma,y=0,show_price = FALSE,option_type = "c"){
  
  tau = tau/365 #dividend 365 days
  d1 = (log(s/x) + (rf + (sigma^2)/2)*tau)/(sigma*sqrt(tau))
  d2 = d1 - sigma*sqrt(tau)
  
  call_price = s*pnorm(d1)*exp(-y*tau) - x*exp(-rf*tau)*pnorm(d2)
  put_price = x*exp(-rf*tau)*pnorm(-d2) - s*pnorm(-d1)*exp(-y*tau)

  if(show_price == TRUE) {
    cat("===============================================\n")
    cat("Call price is", round(call_price, digits = 3), "\n","\n")
    cat("Put price is", round(put_price, digits = 3), "\n")
    cat("===============================================\n")
  }

  value = ifelse(option_type == "c",
    list(call_price),ifelse(option_type == "p",
    list(put_price),cat("option_type = c or p")))
  
  return(value[[1]])
}

## Example

s = 182.28
x = 180
tau = 2
sigma = .7369
rf  = .0435
y = 0

bs_model(s,x,rf,tau,sigma,option_type = "c")
bs_model(s,x,rf,tau,sigma,option_type = "p")

