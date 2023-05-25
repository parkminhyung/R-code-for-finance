ifelse(!require('pacman'),install.packages('pacman'),library('pacman'))
pacman::p_load("dplyr","lubridate","tibble","readxl","plotly")

#Famafrenchmodel : Size & Book to Market (2X3)
#download Fama-French 2X3 model from fnguide 
urls = c('http://www.fnindex.co.kr/factordetail/excel/3FM.2B3.B',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2B3.S',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2B3.X')
filelist = c("FFmodel(2X3)B.xlsx",
              "FFmodel(2X3)S.xlsx",
              "FFmodel(2X3)X.xlsx")

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

# merge 
FF_model_2x3 = filelist[[1]]
for (i in 2:length(filelist)) FF_model_2x3 = merge(FF_model_2x3, filelist[[i]], by="일자", suffixes = c("_B", "_S"))

FF_model_2x3 = FF_model_2x3 %>% 
  column_to_rownames("일자")

#visualize
pig = plot_ly()
for (i in 1:ncol(FF_model_2x3)) {
  pig = pig %>% 
    add_lines(data = FF_model_2x3,
              x = rownames(FF_model_2x3),
              y = FF_model_2x3[,i], 
              name = names(FF_model_2x3)[i])
}
pig %>% 
  layout(title = "<b> Fama-French Model (2x3) </b>",
         margin = list(t=50,b=100),
         xaxis = list(title = "Date"), yaxis = list(title = "Value"))
