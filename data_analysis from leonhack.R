ifelse(!require('pacman'), install.packages('pacman'),library('pacman'))
pacman::p_load(dplyr,quantmod,plotly,frenchdata,moments,qqplotr)
options(scipen=999) 
options(warn=-1) #eliminate warnings messages on the console window

data_list = c("NVDA","PG","PFE","PEP","BAC","^GSPC") #market and stock tickers

#setting date
end_date = Sys.Date()
start_date = (end_date - 365*20) %>% as.Date()

#render empty dataframe
df = data.frame()

for (ticker in data_list) {
  data = getSymbols(
    Symbols = ticker,
    from = start_date,
    to = end_date,
    src = "yahoo",
    auto.assign = F,
    verbose = F
  ) %>% .[,6] #Extract adj.price
  df = cbind(data,df)
}

#calculate returns
returns = apply(df, 2, function(x){
  ret = x/lag(x) -1
  return(ret)
}) %>% na.omit() %>% as.data.frame() 


#compute portfolio returns 
#Equal weights split portfolio
returns$'Porfolio' = NA
x = 1:nrow(returns)
returns[x,7] = x %>% sapply(.,function(x){
  sum(returns[x,2:6])/5
})

summary(returns)

#Fama-French 5 factors model, data start from "start_date"
# you can see the list of factors model via "get_french_data_list()"

ff5 = download_french_data("Fama/French 5 Factors (2x3) [Daily]")$subsets$data[[1]] %>% 
  as.data.frame() %>% 
  .[which(.[,1]==format(start_date,"%Y%m%d")):nrow(.),] %>% 
  {.[1:7] = data.frame(.[1],.[2:7]/100)} 

normaltest_plot_factors = function(asset){
  
  '%+%' = paste0
  p1 = asset %>% 
    plot_ly(
      x= 1:length(asset),
      y = .,
      type = 'scatter',
      mode = 'lines')
  
  #Boxplot
  p2= plot_ly(
    x= scale(asset)[,1],
    type = "box", name ="")
  
  #Density
  df1 = data.frame(scale(asset),"Asset") %>%
    `colnames<-` (c("x","Group"))
  
  df2 = data.frame(rnorm(length(asset)),"Normal")%>%
    `colnames<-` (c("x","Group"))
  
  df = rbind(df1,df2) %>%
    `colnames<-` (c("x","Group"))
  
  gg = ggplot(data = df ) +  
    geom_histogram(aes(x=x, y = ..density.., fill=Group),bins = 29, alpha = 0.7) + 
    geom_density(aes(x=x, color=Group)) + geom_rug(aes(x=x, color=Group))+ 
    ylab("") + 
    xlab("")
  
  p3 = ggplotly(gg)%>% 
    layout(plot_bgcolor='#e5ecf6',   
           xaxis = list(
             zerolinecolor = '#ffff',   
             zerolinewidth = 2,   
             gridcolor = 'ffff'),   
           yaxis = list(
             zerolinecolor = '#ffff',   
             zerolinewidth = 2,   
             gridcolor = 'ffff')) 
  
  #prob
  p4 = scale(asset) %>%
    {
      ggplot(mapping = aes(sample = .)) + 
        stat_qq_point(size = 1.5,color = "blue") + 
        stat_qq_line(color="red") + 
        xlab("Theoretical quantiles") + ylab("Ordered Values")
    } %>% ggplotly()
  
  fig = subplot(p3, p2, p1, p4, nrows = 2, titleY = TRUE, titleX = TRUE, margin = 0.1 )
  fig = fig %>% layout(plot_bgcolor='#e5ecf6', 
                       xaxis = list( 
                         zerolinecolor = '#ffff', 
                         zerolinewidth = 2, 
                         gridcolor = 'ffff'), 
                       yaxis = list( 
                         zerolinecolor = '#ffff', 
                         zerolinewidth = 2, 
                         gridcolor = 'ffff'))
  
  # Update title
  annotations = list( 
    list( 
      x = 0.2,  
      y = 1.0,  
      text = "Density",  
      xref = "paper",  
      yref = "paper",  
      xanchor = "center",  
      yanchor = "bottom",
      showarrow = FALSE 
    ),  
    list( 
      x = 0.8,  
      y = 1,  
      text = "Box plot",  
      xref = "paper",  
      yref = "paper",  
      xanchor = "center",  
      yanchor = "bottom",  
      showarrow = FALSE 
    ),  
    list( 
      x = 0.2,  
      y = 0.4,  
      text = "Simple Returns",  
      xref = "paper",  
      yref = "paper",  
      xanchor = "center",  
      yanchor = "bottom",  
      showarrow = FALSE 
    ),
    list( 
      x = 0.8,  
      y = 0.4,  
      text = "Probability Plot",  
      xref = "paper",  
      yref = "paper",  
      xanchor = "center",  
      yanchor = "bottom",  
      showarrow = FALSE 
    ))
  
  fig = fig %>% layout(annotations = annotations, xaxis = list(tickmode = "auto"), yaxis = list(tickmode = "auto"))
  fig %>% print()
  
  cat(" ##### Skewness & Kurtosis #####","\n",
      "Kurtosis is: " %+% round(kurtosis(asset),digits = 4) %+% ifelse(kurtosis(asset) >0, "  [Leptokurtic]", "  [Platykurtic]"),"\n",
      "Skewness is :" %+% round(skewness(asset),digits = 4) %+% ifelse(skewness(asset) >0, "  [Right-Skewness]","  [Left-Skewness]")
  )
}
normaltest_plot_factors(returns$PG.Adjusted)
normaltest_plot_factors(returns$BAC.Adjusted)
normaltest_plot_factors(returns$NVDA.Adjusted)
normaltest_plot_factors(ff5$Mkt.RF)
normaltest_plot_factors(ff5$SMB)
normaltest_plot_factors(ff5$HML)
