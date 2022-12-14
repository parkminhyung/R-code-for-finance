# the portfolio is consisted of these tickers :: SPY, EFA... 
# Weights : SPY(25%), EFA(25%), IJS(20%), EEM(20%), AGG(10%)

ifelse(!require('pacman'),install.packages('pacman'),library('pacman'))
pacman::p_load('tidyquant','tidyverse','timetk','broom','frenchdata','plotly')
options(scipen = 999, warn = -1)
detach("package:<packageName>", unload=TRUE)

tickers = c("SPY",'EFA','IJS','EEM','AGG')

#rendering portfolio dataframe
df =xts()
for (symbol in tickers) {
  dff = getSymbols(
    Symbols = symbol,
    from = '2012-12-31',
    to = '2017-12-31',
    auto.assign = TRUE,
    warnings = FALSE
  ) %>% 
    get() %>% 
    Ad() #Extract Adj.prices
  df = cbind(dff,df) 
}
indexClass(df) = "Date"
df = df %>% 
  `colnames<-`(tickers) 

#portfolio weights
w = c(rep(.25,2),rep(.20,2),.1) #sum(w) must be 1 (100%)

#### Asset returns
asset_returns = df %>% 
  to.monthly(indexArt = "lastof",OHLC = FALSE) %>% 
  tk_tbl(preserve_index = TRUE, rename_index = "date") %>%  
  gather(asset, returns, -date) %>% # gathering values
  group_by(asset) %>% 
  mutate(returns = (log(returns)-log(lag(returns)))) %>% # change values in specific columns
  na.omit()

View(asset_returns)

#### Portfolio monthly balanced returns
portfolio_returns = asset_returns %>% 
  tq_portfolio(assets_col = asset, #column with asset 
               returns_col = returns, #column with returns
               weights = w,
               col_rename = "returns", #change the name of columns
               rebalance_on = "months") %>% 
  mutate_if(is.numeric,funs(round(.,4)))

##### Fama-french 3 factors model 
#you can get the list of fama french factors model via 'get_french_data_list()' function
frenchdata::get_french_data_list()$files_list %>% View()

ff3 = download_french_data('Fama/French 3 Factors [Daily]')$subsets$data[[1]] %>% 
  mutate_at("date",ymd) %>%  #convert character format into date format
  xts(,order.by = .$date) %>% 
  subset(.,select = -date) %>% #eliminate "date" column
  to.monthly(indexArt = "lastof",OHLC = FALSE) %>% #covert monthly data
  tk_tbl(preserve_index = TRUE, rename_index = "date") 

#merge two dataframes 
ff_portfolio_returns = merge(ff3,portfolio_returns,by="date") %>% 
  mutate(R_excess = round(returns-RF,4)) %>% 
  rename(MKT_RF = `Mkt-RF`) #change column name

#rendering regression model, y = excess rate  ~ x : factors
ff_band = ff_portfolio_returns %>% 
  lm(R_excess ~ MKT_RF + SMB + HML,data = .) %>% 
  tidy(.,conf.int = T, conf.level=.95) 

ff_band %>% mutate_if(is.numeric, funs(round(.,3))) %>% 
  select(-statistic) 

#plot
p1 = ff_band %>% 
  mutate_if(is.numeric, funs(round(.,4))) %>% 
  filter(term!="(Intercept)") %>% 
  plot_ly(
    x = list(.$term),
    y = list(.$estimate),
    type = 'scatter',
    mode = 'markers',
    error_y = list(
      array = list(.$conf.high),
      arrayminus = list(.$estimate-.$conf.low)
    ),name = .$term) 

logreturns = log(portfolio_returns$returns+1) %>% 
  cumsum()

p2 = portfolio_returns %>% 
  plot_ly(
    x= .$date,
    y= .$returns,
    type = 'scatter',
    mode = 'line',
    name = "simple returns"
  ) %>% 
  add_lines(y = logreturns,
            type = 'scatter',
            mode = 'line',
            line = list(dash = "dash"),name = "cumulative log returns") 

annotations = list( 
  list( 
    x = 0.5,  
    y = 1.0,  
    text = "portfolio returns and cumulative log returns",  
    xref = "paper",  
    yref = "paper",  
    xanchor = "center",  
    yanchor = "bottom",  
    showarrow = FALSE 
  ),  
  list( 
    x = 0.5,  
    y = 0.4,  
    text = "Fama French 3 Coefficient for Portfolio",  
    xref = "paper",  
    yref = "paper",  
    xanchor = "center",  
    yanchor = "bottom",  
    showarrow = FALSE 
  ))

subplot(p2,p1,nrows = 2, titleY = TRUE, titleX = TRUE, margin = .1) %>%
  layout(annotations = annotations) %>% 
  layout(plot_bgcolor='#e5ecf6', 
         xaxis = list( 
           zerolinecolor = '#ffff', 
           zerolinewidth = 2, 
           gridcolor = 'ffff'), 
         yaxis = list( 
           zerolinecolor = '#ffff', 
           zerolinewidth = 2, 
           gridcolor = 'ffff')) 

#optional :: portfolio weigths pie plot
p3 = data.frame(tickers,w) %>% 
  plot_ly(
    labels = ~ tickers,
    values = ~ w,
    type = "pie",
    textposition = "inside",
    textinfo = "label+percent",
    insidetextfont = list(color = '#FFFFFF'),
    hoverinfo = "text",
    marker = list(colors = colors,
                  line = list(color = '#FFFFFF', width = 1))) %>% 
  layout(title = "Portfolio Weigths")
p3 %>% print()
