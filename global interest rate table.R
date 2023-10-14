
pacman::p_load("rvest","formattable","dplyr","reactablefmtr","kableExtra")

"%+%" = paste0

North_America = c("united-states", "canada", "mexico")
Europe = c("germany", "united-kingdom", "france", "italy", "austria",
           "poland", "sweden", "switzerland")
Asia = c("china", "japan", "india", "south-korea", "russia", "indonesia", 
         "saudi-arabia", "turkey", "taiwan", "singapore", "thailand")
South_America = c("brazil", "argentina")
africa_countries = c("south-africa")

countries = c(North_America,Europe,Asia,South_America,africa_countries)

data = data.frame(
  Date = as.POSIXct(paste0(format(Sys.Date(),"%Y"),"-",rep(1:12),"-01")) %>%
    format(.,"%b %y"))

for (i in 1:length(countries)) {
  try({
    id = 'https://take-profit.org/en/statistics/interest-rate/' %+% countries[i] %>%
      read_html() %>%
      html_nodes('table') %>% .[[2]] %>%
      html_table(fill = TRUE) %>% 
      select(X1,X2) %>%
      setNames(c(countries[i],"Date")) %>%
      mutate(Date = gsub(x=.$Date, pattern="/",replacement = " ")) %>%
      mutate(`countries[i]` = countries[i] %+% "%") %>% 
      .[c(2,1)] %>%
      .[nrow(.):1,]
    
    data = data %>%
      left_join(id,by="Date")
  })
}

insttable = data %>%
  mutate(across(-Date,~if_else(is.na(.),"-",paste0(.,"%")))) %>%
  setNames(gsub(x=colnames(data),"-"," ") %>%
             toupper())

insttable %>%
  kbl(.,align = "c") %>%
  kable_paper() %>%
  add_header_above(c(" ", 
                     "North America" = length(North_America),
                     "Europe" = length(Europe),
                     "Asia" = length(Asia),
                     "South America" = length(South_America),
                     "Africa" = length(africa_countries)
  ))  
