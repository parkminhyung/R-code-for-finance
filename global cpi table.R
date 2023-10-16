
pacman::p_load("rvest","dplyr","lubridate","tibble","kableExtra")

North_America = c("united-states", "canada", "mexico")
Europe = c("germany", "united-kingdom", "france", "italy", "austria",
           "poland", "sweden", "switzerland")
Asia = c("china", "japan", "india", "south-korea", "indonesia",
         "turkiye")
South_America = c("brazil")
africa_countries = c("south-africa")

countries = c(North_America,Europe,Asia,South_America,africa_countries)

url = 'https://www.global-rates.com/en/inflation/cpi/' %>%
  read_html() %>%
  html_nodes('table') %>%
  html_nodes('a') %>%
  html_attr("href") %>% 
  .[sapply(.,function(x) any(sapply(countries, grepl, x)))] %>%
  unique() %>%
  paste0("https://www.global-rates.com",.)

url = url %>% 
  strsplit(.,"/") %>%
  sapply(., function(x) tail(x,n=1)) %>%
  match(countries,.) %>%
  url[.]

data = data.frame(
  Date = as.POSIXct(paste0(format(Sys.Date(),"%Y"),"-",rep(1:12),"-01")) %>%
    format(.,"%b %y"))

for (i in 1:length(url)) {
  try({
    df = url[i] %>%
      read_html() %>%
      html_nodes(xpath = "/html/body/div[1]/div/section[2]/div/div/div[1]/div/table") %>%
      html_table(trim = TRUE) %>% .[[1]] %>%
      subset(.,grepl("2023",Month)) %>%
      setNames(c("Date",countries[i])) %>% 
      mutate(Date = Date %>%
               parse_date_time(., orders = "B Y") %>%
               format(., "%b %y")) %>%
      .[nrow(.):1,]
    
    data = data %>%
      left_join(df,by="Date")
    
  },silent = TRUE)
}

data = data %>%
  mutate(across(-Date,~if_else(is.na(.),"-",.))) %>%
  setNames(gsub(x=colnames(data),"-"," ") %>%
             toupper())

data %>% 
  kbl(.,align = "c") %>%
  kable_paper() %>%
  add_header_above(c(" ",
                     "North America" = length(North_America),
                     "Europe" = length(Europe),
                     "Asia" = length(Asia),
                     "South America" = length(South_America),
                     "Africa" = length(africa_countries)
  ))

