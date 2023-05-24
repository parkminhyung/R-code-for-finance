ifelse(!require('pacman'),install.packages('pacman'),library('pacman'))
pacman::p_load("dplyr","lubridate","tibble","readxl","plotly")

#Famafrenchmodel : Size & Momentum (2X3)
#download Fama-French 2X3 model from fnguide 
urls = c('http://www.fnindex.co.kr/factordetail/excel/3FM.2M3.B',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2M3.S',
         'http://www.fnindex.co.kr/factordetail/excel/3FM.2M3.X')
filenames = c("FFmodel(2X3)MB.xlsx",
              "FFmodel(2X3)MS.xlsx",
              "FFmodel(2X3)MX.xlsx")
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
FF_model_2x3M = filelist[[1]]
for (i in 2:length(filelist)) FF_model_2x3M = merge(FF_model_2x3M, filelist[[i]], by="일자", suffixes = c("_B", "_S"))

FF_model_2x3M = FF_model_2x3M %>% 
  column_to_rownames("일자")

#visualize
FF_model_2x3M %>%
  plot_ly(
    x = rownames(.),
    y = ~UP_B ,
    type = 'scatter',
    mode = 'line',
    name = "UP_B"
  ) %>%
  add_lines(y = ~DOWN_B,name = "DOWN_B") %>%
  add_lines(y = ~MEDIUM_B,name = "MEDIUM_B") %>%
  add_lines(y = ~UP_S,name = "UP_S") %>%
  add_lines(y = ~DOWN_S,name = "DOWN_S") %>%
  add_lines(y = ~MEDIUM_S,name = "MEDIUM_S") %>%
  add_lines(y = ~MOM,name = "MOM") %>%
  add_lines(y = ~SMB,name = "SMB") %>%
  layout(title = "<b> Fama-French Model (2x3) MoM </b>",
         xaxis = list(title = "Value"), yaxis = list(title = "Date"))
