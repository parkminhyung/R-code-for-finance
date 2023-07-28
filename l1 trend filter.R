#L1 Trend Filter, R

l1tf = function(y,lambda){
  ifelse(!require(pacman),install.packages('pacman'),library("pacman"))
  pacman::p_load("CVXR")
  
  beta = Variable(length(y))
  p = Minimize(0.5 * p_norm(y - beta) + lambda * p_norm(diff(x = beta, differences = 2), 1)) %>%
    Problem(.)
  betaHat = solve(p)$getValue(beta)
  return(betaHat[,])
}
