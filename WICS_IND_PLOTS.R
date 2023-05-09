ifelse(!require(pacman),install.packages('pacman'),library(pacman))
pacman::p_load("jsonlite","dplyr","plotly","lubridate","quantmod")

options(scipen=999)

predate = (Sys.Date() - years(1)) %>% format(.,"%Y%m%d")
curdate = Sys.Date()  %>% format(.,"%Y%m%d")

'%+%' = paste0

WI_list ='https://www.wiseindex.com/API/Tree/Get?id=4' %>%
  fromJSON() %>%
  .$children %>% .[[4]] %>%
  .$children %>% .[[2]] %>%
  select(key,title)

plot_list = list()
for (i in 1:nrow(WI_list)) {
  head = 'https://www.wiseindex.com/Index/GetIndexPerformanceChart?ceil_yn=0&dt=' %+% curdate %+% '&fromdt=' %+% predate %+%'&sec_cd=' %+% WI_list[i,1] %+% '&term=3' %>%
    fromJSON() 
  
  data = head %>% .$data %>% as.data.frame() %>%
    mutate(Date = as.Date(as.POSIXct((.$V1/1000),origin = '1970-01-01'))) %>%
    rename(value = V2) %>%
    select(Date,value)  %>%
    mutate(SMA9 = SMA(value,n=9)) %>%
    mutate(SMA25 = SMA(value,n=25))
  
  percent =  round(((data$value[nrow(data)]/data$value[nrow(data)-1])-1)*100,digits = 3) %>%
    paste0(.,"%")
  plot_list[[i]] = data %>% plot_ly(
    x = ~Date,
    y = ~value,
    type = 'scatter',
    mode = "line") %>% 
    add_lines(.,y=~SMA9) %>% 
    add_lines(.,y=~SMA25) %>% 
    layout(
    annotations =  list(x = 0.2,  
                        y = 1.1,  
                        text = paste0(head$idx_nm," (",percent,")"),
                        xref = "paper",  
                        yref = "paper",  
                        xanchor = "center",  
                        yanchor = "top",  
                        showarrow = FALSE ))
}
subplot(plot_list,nrows = 6)  %>% 
  layout(title = paste0(format(Sys.Date(),"%Y.%m.%d"),' WICS 산업'),
         margin = list(t=50,b=100),
         showlegend = F)
