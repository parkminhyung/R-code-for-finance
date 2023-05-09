library(rvest)
library(plotly)

df = 'https://finance.naver.com/sise/sise_group.naver?type=upjong' %>%
  read_html(encoding = "EUC-KR") %>%
  html_nodes(xpath = '//*[@id="contentarea_left"]/table') %>%
  html_table(fill = TRUE) %>% .[[1]] %>% as.data.frame() %>%
  .[-c(1,which(.[1]=="")),] 
df$전일대비 = df$전일대비 %>% gsub(x=.,"%","") %>% as.numeric

df %>% plot_ly(
  x = paste0(.$업종명," (",.$전일대비,"%",")"),
  y = .$전일대비,
  type = 'bar',
  marker = list(color = ifelse(.$전일대비>0,"red","blue"))
) %>% layout(title = "WI26 업종별 등락",
             margin = list(t=50,b=100),
             xaxis = list(categoryorder = "total descending")) 


