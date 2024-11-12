pacman::p_load('tidyverse',
               'tidyquant',
               'gt',
               'purrr',
               'reticulate',
               'palettes',
               'scales')

pal <- function(x) {
  f_neg <- scales::col_numeric(
    palette = c('#fc7ea4', '#ffffff'),
    domain = c(min(x, 0), 0)
  )
  
  f_pos <- scales::col_numeric(
    palette = c('#ffffff', '#40bbc2'),
    domain = c(0, max(x, 0))
  )
  ifelse(x < 0, f_neg(x), f_pos(x))
}

mdf = read.csv('https://raw.githubusercontent.com/parkminhyung/R-code-for-finance/refs/heads/master/Market%20list/Marketlist.csv')


kdf = tq_get(
  x=mdf$ticker,
  from = Sys.Date()-years(1),
  to = Sys.Date()
) %>% 
  select(symbol,date,adjusted) %>% 
  group_by(symbol) %>% 
  mutate(
    "1d" = last(adjusted)/nth(adjusted,n()-1)-1,
    "5d" = last(adjusted)/nth(adjusted,n()-5)-1,
    "1M" = last(adjusted)/nth(adjusted,n()-25)-1,
    "3M" = last(adjusted)/nth(adjusted,n()-50)-1,
    "6M" = last(adjusted)/nth(adjusted,n()-132)-1,
    "YTD" = last(adjusted) / first(adjusted[year(date) == year(last(date))]) - 1,
    "1Yr" = last(adjusted)/first(adjusted)-1
  ) %>% 
  slice_tail(n=1) %>% 
  rename(ticker = symbol) %>% 
  ungroup()%>% 
  mutate(
    across(-c(ticker,date,adjusted), ~ round(.x, 4)*100),
    across(-c(ticker, date), ~ round(.x, 2))) %>% 
  right_join(mdf,.,by="ticker") %>% 
  drop_na()


kdf %>%
  mutate(Countries = countries) %>%
  select(type, countries, Countries, name, everything()) %>%
  select(-ticker) %>%
  rename(" " = countries,
         "Price" = adjusted,
         "Date" = date) %>% 
  gt(
    groupname_col = "type",
    rowname_col = "name"
  ) %>% 
  tab_style(
    style = list(
      cell_text(
        transform = "uppercase",
        weight = "bold",
        size = px(17)
      )
    ),
    locations = cells_row_groups()
  ) %>%
  cols_width(
    name ~ px(120),
    Date ~ px(100),
    Price ~ px(100),
    Countries ~ px(70),
    everything() ~ px(50)
  ) %>%
  cols_align(
    align = "center"
  ) %>%
  cols_align(
    align = "left",
    columns = name
  ) %>%
  fmt_flag(columns = " ") %>% 
  tab_style(
    style = cell_text(color = "black",weight = "bold"),
    locations = list(
      cells_row_groups(),
      cells_column_labels(everything())
    )
  ) %>%
  data_color(columns = 7:13, colors = pal) %>%
  tab_options(
    table.font.size = px(15),
    table.width = px(700),
    table.background.color = "white"
  )
