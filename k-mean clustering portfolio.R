ifelse(!require("pacman"),install.packages('pacman'),library('pacman'))
pacman::p_load("rvest","quantmod","cluster","NbClust","plotly","dplyr","tibble","factoextra","gridExtra")

#extract tickers from wikipeida
snp500url = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies" %>%
  read_html() %>%
  html_table() %>% .[[1]] %>% 
  select(Symbol) %>% .$Symbol %>%
  c()

start_date = "2019-01-01" ; end_date = '2023-01-01'

#obtain close price 
df = data.frame()
for (ticker in snp500url) {
  try({
    df = getSymbols(
      ticker,
      from = start_date,
      to = end_date,
      auto.assign = FALSE
    ) %>% Cl() %>% 
      cbind(.,df)
  })
} 

#calc return of each tickers
df = df %>% 
  `colnames<-`(gsub(x=colnames(.),pattern = ".Close",replacement = "")) %>% 
  ROC() %>%
  .[-1,] %>% as.data.frame() 

#normalize function
normalize <- function(x) {
  return((x-min(x))/(max(x)-min(x)))
}

df_cleaned = data.frame(
  Return = df %>%
    summarise(across(everything(),mean)) %>%
    mutate_all(~.*252) %>% t(),
  STD = df %>%
    summarise(across(everything(),sd)) %>%
    mutate_all(~.*sqrt(252)) %>% t()
) %>% na.omit() %>% normalize()

#Optimization method1 - Elbow Curve
p1=fviz_nbclust(df_cleaned, kmeans,method = "wss")

#Optimization method2 - silhouette
p2=fviz_nbclust(df_cleaned, kmeans,method = "silhouette")

#Optimization method3 - GAP 
p3=fviz_nbclust(df_cleaned, kmeans,method = "gap_stat")

grid.arrange(p1,p2,p3,nrow=2)

##Optimization method4- NBcluster 
nc = NbClust(df_cleaned, min.nc = 2, max.nc = 15, method= "kmeans")
table(nc$Best.nc[1,]) %>% as.data.frame() %>%
  plot_ly(
    x=~Var1,
    y=~Freq,
    type = "bar"
  ) %>% layout(title = "The best number of clusters : ")

#fit model & visualize
fit.model = kmeans(df_cleaned,3,nstart = 25)
fit.model$size
fviz_cluster(fit.model,data = df_cleaned)

#arrange tickers by cluster
tc = fit.model$cluster %>% 
  as.data.frame() %>% 
  `colnames<-`("Cluster") %>%
  rownames_to_column(var = "Ticker")

#S&P cumulative return
snp = getSymbols(
  "^GSPC",
  from = start_date,
  to = end_date,
  auto.assign = FALSE
) %>% Cl() %>% ROC() %>% as.data.frame() %>%
  na.omit() %>% 
  `colnames<-`("Return") %>%
  mutate(Return = cumprod(1+Return)-1)

fig = plot_ly()

for (i in 1:3) {
  df_list = tc %>%
    filter(Cluster== i) %>%
    .$Ticker %>%
    df[.] %>% 
    mutate(Return  = cumprod(1+(rowSums(.)/ncol(.)))-1) %>%
    select(Return) #portfolio return is calculated using equal-weights method 
  
  fig = fig %>% 
    add_lines(data = df_list,
              x = rownames(df_list),
              y = df_list$Return,
              name = paste0("portfolio_cluster: ",i)) 
}
fig %>% add_lines(data = snp,
                  x = rownames(snp),
                  y = snp$Return,
                  name = "S&P500") %>%
  layout(title = "<b> Performance: Clsuter portfolio & SNP500 </b>",
         margin = list(t=50,b=100),
         xaxis = list(title = "Date"),yaxis = list(title = "Cumulative Return")) %>%
  print()
