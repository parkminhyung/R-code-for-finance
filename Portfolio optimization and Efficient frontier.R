ifelse(!require('pacman'),
       install.packages('pacman'),
       library('pacman'))

pacman::p_load("tidyquant","plotly","timetk","tidyr",'zeallot')
'%=%' = zeallot::`%<-%`
'%+%' = paste0
options(scipen = 999, warn = -1)

tickers = c("AAPL",'AMZN',"NFLX","XOM","T")
log_ret_xts = tq_get(
  tickers,
  from = '2015-01-01',
  to = '2019-11-30',
  get = 'stock.prices'
) %>% 
  group_by(symbol) %>%
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = 'daily',
               col_rename = 'ret',
               type = 'log') %>%
  pivot_wider(names_from = symbol, values_from = ret) %>%
  tk_xts()

mean_return = colMeans(log_ret_xts) %>% round(.,digits = 5)
cov_mat = round(cov(log_ret_xts)*252,digits=4) #annualizing, multiply 252days

## random weights
wts = runif(n=length(tickers)) %>% {
  (./sum(.))
} #sum(wts) must be 1

portfolio_return = (sum(mean_return*wts)+1) ^ 252 -1
port_risk = sqrt(t(wts) %*% (cov_mat %*% wts))

#sharpe ratio
sharpe_ratio = portfolio_return/port_risk #risk-free rate is 0


#create 5000 random portfoilo
num_port = 5000
all_wts = matrix(nrow = num_port,
                 ncol = length(tickers))

c(portfolio_returns,portfolio_risk,sharpe_ratio) %=% rep(list(vector("numeric",length = num_port)),3)

# random weights and portfolio return, risk and sharpe ratio, hypothesis : risk-free rate is 0

for (i in 1:num_port) {
  all_wts[i,] = runif(length(tickers)) %>% 
    {./sum(.)}
  portfolio_returns[i] = (1+all_wts[i,] %*% mean_return)^252 -1
  portfolio_risk[i] = sqrt(t(all_wts[i,]) %*% (cov_mat %*% all_wts[i,]))
  sharpe_ratio[i] = portfolio_returns[i]/portfolio_risk[i]
}
all_wts = all_wts %>% tk_tbl() %>% 
  `colnames<-`(tickers %+% "_weights")

port_folio_values = tibble(return = portfolio_returns,
                           risk = portfolio_risk,
                           sharpe_ratio = sharpe_ratio) %>% 
  cbind(all_wts,.)
  

#Global Minimal Variance Portfolio
risk_min = port_folio_values[which.min(port_folio_values$risk),6:8]
risk_max = port_folio_values[which.max(port_folio_values$risk),6:8]
tang = port_folio_values[which.max(port_folio_values$sharpe_ratio),6:8]

ann = list(
  x = risk_min$risk,
  y = risk_min$return,
  text = "Minimum Variance Portfolio",
  xref = "x", yref = "y",
  showarrow = TRUE,
  arrowhead = 0)

ann2 = list(
  x = risk_max$risk,
  y = risk_max$return,
  text = "Maximum Variance Portfolio",
  xref = "x", yref = "y",
  showarrow = TRUE,
  arrowhead = 0)

ann3 = list(
  x = tang$risk,
  y = tang$return,
  text = "Tangency Portfolio",
  xref = "x", yref = "y",
  showarrow = TRUE,
  arrowhead = 0)

#### plot ####
fig1 = port_folio_values %>% 
  plot_ly(x=.$risk,
          y=.$return,
          type = 'scatter',
          mode = 'markers',
          color = .$sharpe_ratio,
          showlegend=FALSE) %>% 
  add_markers(x = risk_min$risk,
            y = risk_min$return,
            markers = list(color = "#A52929")) %>% 
  add_markers(x = risk_max$risk,
              y = risk_max$return,
              markers = list(color = "#A52929")) %>% 
  add_markers(x = tang$risk,
              y = tang$return,
              markers = list(color = "#A52929")) %>% 
  layout(title = "<b> Portfolio optimization and Efficient Frontier </b>",
         xaxis = list(size = 10, title = "\u03C3"),
         yaxis = list(fontsize = 10, title = "\u00B5"),
         annotations = list(ann,ann2,ann3)) %>% 
  colorbar(title = "Sharpe Ratio")

wmin = port_folio_values[which.min(port_folio_values$risk),1:5]
wmax = port_folio_values[which.max(port_folio_values$risk),1:5]
wtan = port_folio_values[which.max(port_folio_values$sharpe_ratio),1:5]

fig2 =  wmin %>% 
  round(x=.,digits=5) %>% {
    plot_ly(
      x = colnames(.),
      y = as.numeric(.[1:5]),
      type = 'bar',
      name = "Minimum Weights",
      marker = list(color = '#3246AB')) %>% 
      add_trace(
        y = as.numeric(wmax),
        name = "Maximum Weights",
        marker = list(color = '#E82712')) %>% 
      add_trace(
        y = as.numeric(wtan),
        name = "Tangency Weights",
        marker = list(color = '#12B7C3')) %>% 
      layout(
        yaxis = list(title = "Weights"),
        barmode = "group"
      )
  } 

subplot(fig1, fig2, nrows = 2)

