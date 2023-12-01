install.packages("pacman")

pacman::p_load(frenchdata,purrr,tidyr,dplyr,tidyquant,broom,gtools,kableExtra)

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

factor_value = tibble(
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

factor_value$ETFs = cell_spec(factor_value$ETFs, bold = T)

factor_value %>%
  kable("html", escape = F) %>%
  kable_styling() %>% 
  add_footnote(c(paste0("Date from: ",data$date[1]," to: ",data$date[nrow(data)]), 
                 "P-value : *** if <0.001, ** if < 0.01, * if < 0.05"))
