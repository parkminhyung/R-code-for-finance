ifelse(!require('pacman'),install.packages('pacman'),library('pacman'))
pacman::p_load("dplyr","lubridate","tibble","readxl","plotly")

dir = getwd()
dir.create("./FFModel")
setwd("./FFModel")

#Famafrenchmodel : Size & Book to Market (5X5)
#download Fama-French 5X5 model from fnguide 

urls = c('http://www.fnindex.co.kr/factordetail/excel/3FM.5B5.B',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5B5.M',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5B5.MB',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5B5.MS',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5B5.S',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.5B5.X')

filelist = c("FFmodel(5X5)B.xlsx",
             "FFmodel(5X5)M.xlsx",
             "FFmodel(5X5)MB.xlsx",
             "FFmodel(5X5)MS.xlsx",
             "FFmodel(5X5)S.xlsx",
             "FFmodel(5X5)X.xlsx")

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

FF_model_5x5 = filelist[[1]] %>%
  rename_with(~paste0(., suff[1]), -일자)

for (i in 2:length(filelist)) {
  FF_model_5x5 = filelist[[i]] %>%
    rename_with(~paste0(., suff[i]), -일자) %>%
    merge(FF_model_5x5,.,by="일자")
}

FF_model_5x5 = FF_model_5x5 %>% 
  column_to_rownames("일자")

#visualize

fig = plot_ly()
for (i in 1:ncol(FF_model_5x5)) {
  fig = fig %>% 
    add_lines(data = FF_model_5x5,
              x = rownames(FF_model_5x5),
              y = FF_model_5x5[,i], 
              name = names(FF_model_5x5)[i])
}
fig %>% 
  layout(title = "<b> Fama-French Model (5x5) </b>",
         margin = list(t=50,b=100),
         xaxis = list(title = "Date"), yaxis = list(title = "Value"))

setwd(dir)
