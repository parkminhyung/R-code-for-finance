ifelse(!require(pacman),
       install.packages('pacman'),
       library(pacman))
p_load('quantmod','tidyquant','timetk','rvest','dplyr','frenchdata','stringr',
       'tidyr','broom','gtools','purrr','rlist','plotly','pipeR')

options(scipen=999, warn=-1)

start_date = '2016-01-01'; end_date = '2019-11-15'
url = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
symbols = url %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="constituents"]') %>% 
  html_table() %>% 
  .[[1]] %>% 
  filter(!str_detect(Security, "Class A|Class B|Class C")) %>%  
  sample_n(20) %>% 
  pull(Symbol)

#포트폴리오 
asset_returns = tq_get(
  symbols,
  from = start_date,
  to = end_date
) %>% 
  group_by(symbol) %>% 
  tq_transmute(
    select = adjusted,
    mutate_fun = periodReturn,
    period = "daily",
    type = 'arithmetic'
  ) %>% 
  select(symbol, date, daily.returns) %>% 
  pivot_wider(names_from = symbol, values_from = daily.returns) %>% .[-1,]


#ETF 목록
myETFs = c("SPY", "IVV", "VTI", "VOO", "QQQ", "VEA", "IEFA", "AGG", "VWO",
           "EFA","IEMG","VTV", "IJH", "IWF","BND", "IJR", "IWM", "VUG", 
           "GLD", "IWD", "VIG", "VNQ", "USMV", "LQD", "VO", "VYM", "EEM",
           "VB", "VCSH", "XLF", "VCIT", "VEU", "XLK", "ITOT", "IVW", "BNDX",
           "VGT", "DIA", "BSV", "SHV", "IWB", "IWR", "TIP", "SCHF", "MBB", "SDY",
           "MDY", "SCHX", "IEF", "HYG", "DVY", "XLV", "SHY", "IXUS", "TLT", "IVE",
           "PFF", "IAU", "VXUS", "RSP", "SCHB", "VV", "GOVT", "EMB", "MUB", "QUAL",
           "XLY", "VBR", "EWJ", "XLP", "VGK", "SPLV", "MINT", "BIV", "IGSB", "EFAV",
           "VT", "GDX", "XLU", "IWS", "XLI", "SCHD", "IWP", "ACWI", "VMBS", "XLE", "JNK",
           "VOE", "FLOT", "IWV", "JPST", "SCZ", "IEI", "IWN", "DGRO", "VBK", "IGIB", "IWO")

etf_returns = tq_get(
  myETFs,
  from = start_date,
  to = end_date
) %>% 
  group_by(symbol) %>% 
  tq_transmute(
    select = adjusted,
    mutate_fun = periodReturn,
    period = "daily",
    type = "arithmetic"
  ) %>% 
  select(symbol, date, daily.returns) %>% 
  pivot_wider(names_from = symbol, values_from = daily.returns) %>% 
  .[-1, ]

#포트폴리오 return계산
portfolio_and_etfs = asset_returns %>% 
  mutate(myPortfolio = rowMeans(select(.,-date),na.rm = TRUE)) %>% 
  select(date, myPortfolio) %>% 
  inner_join(etf_returns,by="date") %>% 
  tk_xts(date_var = date)

#Fama-French 3 factors model 
ff3 = download_french_data('Fama/French 3 Factors [Daily]')$subsets$data[[1]] %>% 
  mutate(date = ymd(date)) %>% 
  na.omit() %>% 
  dplyr::rename(
    Mkt_Rf = `Mkt-RF`,
    SMB_3 = SMB,
    HML_3 = HML
  ) %>% 
  select(-RF) %>% 
  mutate_at(dplyr::vars(c(Mkt_Rf,SMB_3,HML_3)),funs(./100)) %>% 
  tk_xts(date_var = date)

joint.date = as.Date(intersect(index(ff3),index(portfolio_and_etfs)))
ff3new = ff3[joint.date]
portfolio_and_etfs_new = portfolio_and_etfs[joint.date]

FF_3Factors = cbind(alpha = 1, ff3new)
Gamma = t(solve(t(FF_3Factors) %*% FF_3Factors, t(FF_3Factors) %*% portfolio_and_etfs_new))


#regression analysis
regdata = cbind(FF_3Factors,portfolio_and_etfs_new) 
regdata$JPST = NULL

myportfolioReg = lm(myPortfolio ~ Mkt_Rf + SMB_3 + HML_3,data = regdata,na.action = na.exclude)
tidy(myportfolioReg)

#apply all ETF in data
regressionLists = apply(regdata, 2, function(y) lm(y ~ Mkt_Rf + SMB_3 + HML_3,data = regdata,na.action = na.exclude))

tidy(regressionLists$myPortfolio) %>% 
  mutate(p.value =stars.pval(p.value))

tidy(regressionLists$VTV)%>% 
  mutate(p.value = stars.pval(p.value))

tidy(regressionLists$LQD) %>% 
  mutate(p.value = stars.pval(p.value))

summary(regressionLists$myPortfolio)

mytidyregressions = lapply(regressionLists[4:length(regressionLists)], tidy) %>% 
  map(.,~mutate(.,p.value = stars.pval(p.value)))

list.sample(mytidyregressions,5)  

regress.df = data.frame()
for (i in 5:length(regressionLists)) {
  df = regressionLists[[i]]$coefficients[2:4] %>% 
    as.data.frame() %>% t()
  regress.df = rbind(regress.df,df)
}

rownames(regress.df) = names(regressionLists)[5:length(regressionLists)]

#클러스터링 clustering
kmeans_model = kmeans(regress.df,
                      centers = 3,
                      iter.max = 10,
                      nstart = 1)
regress.df %>% 
  plot_ly(
    x = .$Mkt_Rf,
    y = .$SMB_3,
    z = .$HML_3,
    color = kmeans_model$cluster,
    name = rownames(.)
  ) %>% 
  add_markers() %>% 
  layout(
    scene = list(xaxis = list(title = "MKT-RF"),
                 yaxis = list(title = "SMB"),
                 zaxis = list(title = "HML")),
    title = "Fama-French beta 3D plot",
    showlegend = FALSE
  )




