roll_corr = function(df,.x,.y,window_length = 10){
  
  ifelse(!require("pacman"),
         install.packages("pacman"),
         library("pacman"))
  pacman::p_load(rlang,tidyquant,tibbletime)
  
  rollingcor = rollify(~cor(.x,.y),
                       window = window_length)
  
  x = map2(.x,.y,~mutate(
    df,
    rolling_corr = rollingcor(!!quo(!! sym(.x)), 
                              !!quo(!! sym(.y))))) %>%
    setNames(., paste(.x, .y, sep = ":")) %>%  
    bind_rows(.id = "groups") %>% spread(groups, rolling_corr) 
  return(x)
}
