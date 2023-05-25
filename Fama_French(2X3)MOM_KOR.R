ifelse(!require('pacman'),install.packages('pacman'),library('pacman'))
pacman::p_load("dplyr","lubridate","tibble","readxl","plotly")

#Famafrenchmodel : Size & Momentum (2X3)
#download Fama-French 2X3 model from fnguide 
urls = c('http://www.fnindex.co.kr/factordetail/excel/3FM.2M3.B',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2M3.S',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2M3.X')
filelist = c("FFmodel(2X3)MB.xlsx",
             "FFmodel(2X3)MS.xlsx",
             "FFmodel(2X3)MX.xlsx")
for (i in 1:length(urls)) {
  download.file(urls[i],
                destfile = filelist[i])
}

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
FF_model_2x3M = filelist[[1]]
for (i in 2:length(filelist)) FF_model_2x3M = merge(FF_model_2x3M, filelist[[i]], by="일자", suffixes = c("_B", "_S"))

FF_model_2x3M = FF_model_2x3M %>% 
  column_to_rownames("일자")

#visualize
fig = plot_ly()
for (i in 1:ncol(FF_model_2x3M)) {
  fig = fig %>% 
    add_lines(data = FF_model_2x3M,
              x = rownames(FF_model_2x3M),
              y = FF_model_2x3M[,i], 
              name = names(FF_model_2x3M)[i])
}
fig %>% 
  layout(title = "<b> Fama-French Model (2x3) MOM </b>",
         margin = list(t=50,b=100),
         xaxis = list(title = "Date"), yaxis = list(title = "Value"))
