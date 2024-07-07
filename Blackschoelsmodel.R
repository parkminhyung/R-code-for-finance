
# Black_scholes model for call and put option 
# s : asset price 
# x : strike price 
# rf : risk-free rate 
# sigma : volatility of asset price 
# tau : time to maturity 
# y : dividend yield 
# D : dividend 
# r : interest rate 
# tyoe : "C" is call option , "p" is put option price

black_scholes = function(s, x, rf, sigma, tau, y = NULL, D = NULL, r = NULL,show_price = FALSE,type ="c") {
  calculate_d = function(s_adj) {
    d1 = (log(s_adj / x) + (rf + sigma^2 / 2) * tau) / (sigma * sqrt(tau))
    d2 = d1 - (sigma * sqrt(tau))
    list(d1 = d1, d2 = d2)
  }

  if (!is.null(y)) {
    # Dividend rate is y
    s_adj = s * exp(-y * tau)
    d = calculate_d(s_adj)
  } else if (!is.null(D)) {
    # Dividends is D
    k = if (is.null(r)) 1 else (1 + r)^tau
    s_adj = s - D / k
    d = calculate_d(s_adj)
  } else {
    # No dividends
    s_adj = s
    d = calculate_d(s_adj)
  }

  call_price = s_adj * pnorm(d$d1) - x * exp(-rf * tau) * pnorm(d$d2)
  put_price = x * exp(-rf * tau) * pnorm(-d$d2) - s_adj * pnorm(-d$d1)

  if(show_price == TRUE) {
    cat("===============================================\n")
    cat("Call price is", round(call_price, digits = 3), "\n","\n")
    cat("Put price is", round(put_price, digits = 3), "\n")
    cat("===============================================\n")
  }


  value = ifelse(type == "c",
    list(call_price),ifelse(type == "p",
    list(put_price),cat("type = c or p")))
  
  return(value[[1]])
}

## Example
# stock price: $50
# strike price: $45
# time to expiration: 80 days
# risk-free interest rate: 2%
# implied volatility: 30%

call = black_scholes(50,45,0.02,sigma = .3, tau = 80/365,type = "c")
put = black_scholes(50,45,0.02,sigma = .3, tau = 80/365,type = "p")

call 
put
