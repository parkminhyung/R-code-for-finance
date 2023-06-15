ifelse(!require(pacman),
       install.packages("pacman"),
       library(pacman))
pacman::p_load("networkD3","dplyr","igraph","quantmod")

world_data = data.frame(
  'Name' = c('SNP500','NASDAQ','Tokyo','Shanghai',
             'HongKong','London','EuronextParis',
             'Frankfurt','Toronto','KOSPI','AustralianSecurities',
             'Bombay','BMFBovespa','Moscow','Johannesburg',
             'Singapore','BolsadeMadrid','Taiwan',
             'Swiss','BursaMalaysia','ofThailand',
             'Indonesia','Saudi','TelAviv',
             'BuenosAires'),
  
  'Ticker' = c('^GSPC', '^IXIC', '^N225', '000001.SS', '0388.HK', '^FTSE', '^FCHI',
               '^GDAXI', '^GSPTSE', '^KS11', '^AXJO', '^BSESN', '^BVSP', 'IMOEX.ME',
               'JSE.JO', '^STI', 'IGBM.MA', '0050.TW', '^SSMI', '^KLSE', '^SET.BK',
               '^JKSE', '^TASI.SR', 'TASE.TA', '^MERV'),
  
  'Continent' = c('North America', 'North America', 'Asia', 'Asia', 'Asia', 'Europe',
                  'Europe', 'Europe', 'North America', 'Asia', 'Oceania', 'Asia', 'South America',
                  'Europe', 'Africa', 'Asia', 'Europe', 'Asia', 'Europe', 'Asia', 'Asia',
                  'Asia', 'Asia', 'Asia', 'South America'),
  
  "lat" = c("40.67","40.67","35.67","31.23","22.27","51.52","48.86","50.12",
            "43.65","37.56","-35.31","18.96","-15.78","55.75","-26.19","1.3","40.42","25.02","46.95",
            "3.16","13.73","-6.18","24.65","32.07","-34.61"),
  
  "long" = c("-73.94","-73.94","139.77","121.47","114.14","-7.33","2.34","8.68",
             "-79.38","126.99","149.13","72.82","-47.91","37.62","28.04","103.85","-3.71","121.45","7.44",
             "101.71","100.50","106.83","46.77","34.77","-58.37")
)

data = data.frame()

start_date = '2021-01-01'; end_date = Sys.Date()

for (i in 1:nrow(world_data)) {
  try({
    data = getSymbols(
      world_data$Ticker[i],
      from = start_date,
      to = end_date,
      auto.assign = FALSE
    ) %>% Cl() %>% log() %>% diff() %>%
      setNames(world_data$Name[i]) %>% 
      cbind(.,data)
  })
}

data[is.na(data)]=0

cor_data = cor(data)

edges_df = cor_data %>% as.matrix() %>%
  graph_from_adjacency_matrix(.,mode = "undirected", weighted = TRUE, diag = FALSE) %>%
  get.edgelist(.,names= TRUE) %>%
  as.data.frame() %>%
  mutate(value = cor_data[as.matrix(t(apply(., 1, sort)))])

nodes_df = data.frame(id = unique(c(edges_df[,1], edges_df[,2])), stringsAsFactors = FALSE) %>%
  mutate(index = 0:(nrow(.)-1)) %>%
  mutate(group = setNames(world_data$Continent, world_data$Name)[.$id])

edges_df = edges_df %>%
  mutate(from = setNames(nodes_df$index, nodes_df$id)[edges_df[,1]]) %>%
  mutate(to = setNames(nodes_df$index, nodes_df$id)[edges_df[,2]])

#3D Network Plot

forceNetwork(
  Links = edges_df,
  Nodes = nodes_df,
  Source = "from",
  Target = "to",
  Value = "value",
  NodeID = "id",
  Group = "group",
  fontSize = 14, 
  fontFamily = "Arial Black", 
  zoom = TRUE,
  legend = TRUE,
  opacity = 0.8,
  bounded = TRUE,
  opacityNoHover = TRUE,
  linkDistance = 450,
  linkWidth = JS("function(d) { return Math.abs(d.value) * 5; }"),
)
