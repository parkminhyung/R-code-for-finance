ifelse(!require('pacman'),install.packages('pacman'),library('pacman'))
pacman::p_load("dplyr","lubridate","tibble","readxl","plotly")

#Famafrenchmodel : Size & Book to Market (2X3)
#download Fama-French 2X3 model from fnguide 
urls = c('http://www.fnindex.co.kr/factordetail/excel/3FM.2B3.B',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2B3.S',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2B3.X')
filenames = c("FFmodel(2X3)B.xlsx",
             "FFmodel(2X3)S.xlsx",
             "FFmodel(2X3)X.xlsx")
for (i in 1:length(urls)) {
  download.file(urls[i],
                destfile = filenames[i])
}

#load files and preprocess data
filelist = filenames %>%
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
FF_model_2x3 %>%
  plot_ly(
    x = rownames(.),
    y = ~HIGH_B ,
    type = 'scatter',
    mode = 'line',
    name = "HIGH_B"
  ) %>%
  add_lines(y = ~HIGH_S,name = "HIGH_S") %>%
  add_lines(y = ~MEDIUM_B,name = "MEDIUM_B") %>%
  add_lines(y = ~MEDIUM_S,name = "MEDIUM_S") %>%
  add_lines(y = ~LOW_B,name = "LOW_B") %>%
  add_lines(y = ~LOW_S,name = "LOW_S") %>%
  add_lines(y = ~HML,name = "HML") %>%
  add_lines(y = ~SMB,name = "SMB") %>%
  layout(title = "<b> Fama-French Model (2x3) </b>",
         xaxis = list(title = "Value"), yaxis = list(title = "Date"))
