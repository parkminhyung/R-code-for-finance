normaltest_plot = function(ticker){
  ifelse(!require('pacman'), install.packages('pacman'),library('pacman'))
  pacman::p_load(dplyr,quantmod,plotly,moments,qqplotr)
  
  end_date = Sys.Date()
  start_date = (end_date - 365*2) %>% as.Date()
  
  asset = getSymbols(
    ticker,
    from = start_date,
    to = end_date,
    auto.assign = FALSE) %>% 
    Cl() %>% log() %>% diff() %>% na.omit() %>%
    as.data.frame() %>% setNames("Return") %>% .$Return
  
  
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
    type = "box")
  
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
  
  fig = fig %>% layout(annotations = annotations)
  fig %>% print()
  
  cat(" ##### Skewness & Kurtosis #####","\n",
      "Kurtosis is: " %+% round(kurtosis(asset),digits = 4) %+% ifelse(kurtosis(asset) >0, " [Leptokurtic]", " [Platykurtic]"),"\n",
      "Skewness is :" %+% round(skewness(asset),digits = 4) %+% ifelse(skewness(asset) >0, " [Right-Skewness]"," [Left-Skewness]")
  ,"\n")
}
