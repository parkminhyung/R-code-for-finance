
## Black-Scholes Model for call and put option 
# s : Asset price 
# k : Strike Price 
# tau = time to maturity
# sigma : volatility
# rf : risk-free rate
# y : dividend yield, default value is 0
# option_type : "c" ~ call price, "p" ~ put price. default value is "c"
# ...$pofp : probability of profit 


bs_model <- function(s, k, rf, tau, sigma, y, option_type = "c") {
  
  T = 252    
  pct = 100  
  tau <- tau / T
  sigma <- sigma / pct
  rf <- rf / pct
  y <- y / pct
  
  if (tau == 0) {
    if (option_type == "c") {
      return(max(s - k, 0))  
    } else if (option_type == "p") {
      return(max(k - s, 0))  
    } else {
      return(list(call_price = max(s - k, 0), 
                  put_price = max(k - s, 0),
                  pofp = NA))  
    }
  }
  
  d1 <- (log(s/k) + (rf + (sigma^2)/2)*tau)/(sigma*sqrt(tau))
  d2 <- d1 - sigma*sqrt(tau)
  
  # probability of profit for each option
  if (option_type == "c") {
    pofp <- pnorm(d2)  
  } else if (option_type == "p") {
    pofp <- pnorm(-d2) 
  } else {
    pofp <- NA  
  }
  
  call_price = s*pnorm(d1)*exp(-y*tau) - k*exp(-rf*tau)*pnorm(d2)
  put_price = k*exp(-rf*tau)*pnorm(-d2) - s*pnorm(-d1)*exp(-y*tau)
  
  if (option_type == "c") {
    return(list(call_price = call_price, pofp = pofp)) 
  } else if (option_type == "p") {
    return(list(put_price = put_price, pofp = pofp))  
  } else {
    return(list(call_price = call_price, 
                put_price = put_price,
                pofp_call = pnorm(d2),  
                pofp_put = pnorm(-d2))) 
  }
  
}


k = bs_model(100,100,4,12,.25,.01,"c")
k$call_price
k$pofp

k = bs_model(100,100,4,12,.25,.01,"p")
k$put_price
k$pofp

