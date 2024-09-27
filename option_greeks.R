option_greeks <- function(s, k, rf, sigma, tau, y) {

  T = T
  tau <- tau / T
  sigma <- sigma / 100
  rf <- rf / 100
  y <- y / 100

  d1 <- (log(s / k) + (rf - y + sigma^2 / 2) * tau) / (sigma * sqrt(tau))
  d2 <- d1 - (sigma * sqrt(tau))

  nd1 <- (1 / (sqrt(2 * pi))) * exp(-(d1^2 / 2))

  # delta
  call_delta <- pnorm(d1) 
  put_delta <- (pnorm(d1) - 1) 

  # Gamma
  gamma <- (nd1 ) / (s * sigma * sqrt(tau))

  # theta
  call_theta <- (-((s * sigma ) / (2 * sqrt(tau))) * nd1 - k * exp(-rf * tau) * rf * pnorm(d2)) * (1 / T)
  put_theta <- (-((s * sigma ) / (2 * sqrt(tau))) * nd1 - k * exp(-rf * tau) * rf * (pnorm(d2) - 1)) * (1 / T)

  # rho
  call_rho <- k * tau * exp(-rf * tau) * pnorm(d2) * (1 / 100)
  put_rho <- k * tau * exp(-rf * tau) * (pnorm(d2) - 1) * (1 / 100)

  # Vega
  vega <- s * sqrt(tau) * nd1 * (1 / 100)

  return(list(
    call.Delta = call_delta,
    put.Delta = put_delta,
    Gamma = gamma,
    Vega = vega,
    call.Theta = call_theta,
    put.Theta = put_theta,
    call.Rho = call_rho,
    put.Rho = put_rho
  ))
}
