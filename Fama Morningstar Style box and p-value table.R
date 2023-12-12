install.packages('pacman')
pacman::p_load(frenchdata,purrr,tidyr,dplyr,tidyquant,broom,gtools,ggplot2,kableExtra)

ETFs = c("IVV", "VTI", "VOO", "QQQ", "VEA", "IEFA", "AGG", "VWO",
         "EFA","IEMG","VTV", "IJH", "IWF","BND", "IJR", "IWM", "VUG",
         "GLD", "IWD", "VIG", "VNQ", "USMV", "LQD", "VO", "VYM", "EEM",
         "VB", "VCSH", "XLF", "VCIT", "VEU", "XLK", "ITOT", "IVW", "BNDX",
         "VGT", "DIA", "BSV", "SHV", "IWB", "IWR", "TIP", "SCHF", "MBB", "SDY",
         "MDY", "SCHX", "IEF", "HYG", "DVY", "XLV", "SHY", "IXUS", "TLT", "IVE",
         "PFF", "IAU", "VXUS", "RSP", "SCHB", "VV", "GOVT", "EMB", "MUB", "QUAL",
         "XLY", "VBR", "EWJ", "XLP", "VGK", "SPLV", "MINT", "BIV", "IGSB", "EFAV",
         "VT", "GDX", "XLU", "IWS", "XLI", "SCHD", "IWP", "ACWI", "VMBS", "XLE", "JNK",
         "VOE", "FLOT", "IWV", "JPST", "SCZ", "IEI", "IWN", "DGRO", "VBK", "IGIB", "IWO")

start = "2012-01-01" ; end = "2019-01-01"


frenchdata::get_french_data_list()$files_list %>% head

ff3_data = frenchdata::download_french_data("Fama/French 3 Factors")$subsets$data[[1]] %>%
  mutate(date = rollback(ymd(parse_date_time(date, "%Y%m") + months(1)))) %>%
  mutate_if(is.numeric, function(x) (x/100)) %>%
  rename(ExR = `Mkt-RF`) %>%
  filter(date >= start & date <= end)

data = tq_get(
  ETFs,
  from = start,
  to = end
) %>%
  group_by(symbol) %>%
  tq_transmute(
    select = adjusted,
    mutate_fun = to.monthly,
    indexAt = "lastof"
  ) %>%
  tq_transmute(
    select = adjusted,
    mutate_fun = periodReturn,
    type = "log"
  ) %>%
  pivot_wider(
    names_from = symbol,
    values_from = monthly.returns
  ) %>%
  slice(-1) %>%
  right_join(ff3_data,., by="date")


#### morning star style box plot
plot_df = tibble(
  ETFs = ETFs,
  model = map(ETFs, ~lm(get(.x) ~ ExR + SMB + HML + RF, data = data) %>%
                tidy)
) %>% 
  unnest(model) %>%
  select(ETFs,term,estimate) %>%
  mutate(estimate = round(estimate,digits=4)) %>%
  pivot_wider(
    names_from = term,
    values_from = estimate
  ) %>%
  select(ETFs, SMB,HML) %>%
  mutate(
    class = case_when(
      SMB > 0 & HML > 0 ~ "Smallcap + Value",
      SMB > 0 & HML < 0 ~ "Smallcap + Growth" , 
      SMB < 0 & HML > 0 ~ "Largecap + Value",
      SMB < 0 & HML < 0 ~ "Largecap + Growth",
      TRUE ~ "else"
    )
  )

theme_set(theme_minimal())

ggplot(plot_df) +
  aes(x = HML, y = SMB, color = class) +
  geom_point() + 
  geom_smooth(method = "lm", se = TRUE, 
              color = "red", aes(group = 1),,
              size = 0.5,
              linetype = "dashed") +
  geom_text(aes(label=ETFs),
            family = "nanumgothic", vjust = 0, hjust = -0.08,
            check_overlap = T)  + 
  geom_vline(aes(xintercept = 0), color = "black", linetype = "dashed") +
  geom_hline(aes(yintercept = 0), color = "black", linetype = "dashed") +
  ggtitle("Morningstar Style Box : Risk Factor Exposure") +  
  annotate("text", x = 0, y = min(plot_df$SMB)-0.125, label = "Large Cap", angle = 0, hjust = 0.5) +  
  annotate("text", x = 0, y = max(plot_df$SMB)+0.125, label = "Small Cap", angle = 0,hjust = 0.5) +  
  annotate("text", x = max(plot_df$HML)+0.125, y = 0, label = "Value", angle = 270, hjust = 0.5) +  
  annotate("text", x = min(plot_df$HML)-0.125, y = 0, label = "Growth", angle = 90,hjust = 0.5) 


### p-value table
factor_p_table = tibble(
  ETFs = ETFs,
  model = map(ETFs, ~ lm(get(.x) ~ ExR + SMB + HML + RF, data = data) %>%
                tidy %>%
                mutate(pvalue = stars.pval(p.value)))
) %>%
  unnest(model) %>%
  mutate(value = paste0(round(estimate, digits=3), " ", pvalue)) %>%
  select(ETFs,term,value) %>%
  pivot_wider(
    names_from = term,
    values_from = value
  )

factor_p_table$ETFs = cell_spec(factor_p_table$ETFs, bold = T)

factor_p_table %>%
  kable("html", escape = F) %>%
  kable_styling() %>% 
  add_footnote(c(paste0("Date from: ",data$date[1]," to: ",data$date[nrow(data)]), 
                 "p*** < 0.001 | p** < 0.01 | p* < 0.05 | p. < 0.1"))

