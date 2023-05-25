ifelse(!require('pacman'),install.packages('pacman'),library('pacman'))
pacman::p_load("dplyr","lubridate","tibble","readxl","plotly")

dir = getwd()
dir.create("./FFModel")
setwd("./FFModel")

#Famafrenchmodel : Size & Momentum(5X5)
#download Fama-French 5X5 MOM model from fnguide 

urls = c('http://www.fnindex.co.kr/factordetail/excel/3FM.5M5.B',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5M5.M',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5M5.MB',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5M5.MS',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5M5.S',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5M5.X')

filelist = c("FFmodel(5X5)MB.xlsx",
             "FFmodel(5X5)MM.xlsx",
             "FFmodel(5X5)MMB.xlsx",
             "FFmodel(5X5)MMS.xlsx",
             "FFmodel(5X5)MS.xlsx",
             "FFmodel(5X5)MX.xlsx")

for (i in 1:length(urls)) download.file(urls[i],destfile = filelist[i])

#load files and preprocess data
filelist = filelist %>%
  sapply(.,function(x) {
    read_excel(x) %>%
      as.data.frame(.) %>%
      na.omit() %>%
      setNames(.[1,]) %>% .[-1,] %>%
      mutate(일자 = as_date(일자)) %>%
      mutate(across(-일자,~round(as.numeric(.),digits = 2))) 
  })
#Merge
suff = c("_B","_M","_MB","_MS","_S","")

FF_model_5x5M = filelist[[1]] %>%
  rename_with(~paste0(., suff[1]), -일자)

for (i in 2:length(filelist)) {
  FF_model_5x5M = filelist[[i]] %>%
    rename_with(~paste0(., suff[i]), -일자) %>%
    merge(FF_model_5x5M,.,by="일자")
}

FF_model_5x5M = FF_model_5x5M %>% 
  column_to_rownames("일자")

#visualize

fig = plot_ly()
for (i in 1:ncol(FF_model_5x5M)) {
  fig = fig %>% 
    add_lines(data = FF_model_5x5M,
              x = rownames(FF_model_5x5M),
              y = FF_model_5x5M[,i], 
              name = names(FF_model_5x5M)[i])
}
fig %>% 
  layout(title = "<b> Fama-French Model MOM (5x5) </b>",
         margin = list(t=50,b=100),
         xaxis = list(title = "Date"), yaxis = list(title = "Value"))

setwd(dir)
