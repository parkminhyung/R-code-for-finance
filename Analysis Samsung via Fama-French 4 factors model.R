
## reference : http://henryquant.blogspot.com/2019/02/fama-french-handa-partners.html
## HenryQuant 

ifelse(!require(pacman),install.packages('pacman'),library(pacman))
pacman::p_load('PerformanceAnalytics','quantmod','plotly','HenryQuant','tibble','broom','stargazer')
options(scipen = 999)
Sys.setenv(TZ = 'UTC')
'%=%' = zeallot::`%<-%`

#fama-french factors models including momentum (Korea)
c(idff5,id_mom,idff3) %=% list('1phGP57z5QW4VjhAXZSMAvY6EYFbuCMc5',
                               '1ICsw0Ar-egopA8PvjvlXAtD8W063mklO',
                               '10VLyoL0YO7Q_jPW_TjXf4LC2ZLt5FQtU')

c(ff5kr,ff3kr,ffmom) %=% list(read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",idff5)),
                              read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",idff3)),
                              read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",id_mom)))

data = data.frame(ff3kr,ffmom[2])
factor_data = data %>% 
  rename(Date = X, MKT = Mkt.Rf,MOM = Mom) %>% #column이름 변경
  select(Date,MKT,SMB,HML,MOM,Rf) %>% #전처리 할 column selection
  column_to_rownames(var = 'Date') %>% #rowname으로 들어갈 column선택 
  as.xts() #xts format으로 변경

plot_cumulative(factor_data,ylog = TRUE)
plot_cumulative(factor_data['2002::'],ylog = TRUE)

factor_data = factor_data['2002::']
start = index(factor_data)[1] %>% as.Date()
end = index(factor_data) %>% tail(.,n=1) %>% as.Date()

#Samsung data
ss = getSymbols(
  Symbols = '005930.KS',
  from = start,
  to = end,
  verbose = FALSE
) %>% get() %>% Cl() %>% na.locf() %>% 
  `colnames<-`("Samsung")

ss.ret = Return.calculate(ss) %>% na.omit()
plot_cumulative(ss.ret)

data.df = merge(ss.ret, factor_data) %>% na.omit()  #merge로 rowname이 겹치는 data 합치기

#팩터 수익률 데이터 합치기
data.lm = lm((Samsung-Rf)~MKT + SMB + HML + MOM,
             data = data.df)

broom::tidy(data.lm)
stargazer(data.lm,
          type = 'text',
          report = ('vc*t'), #t-value 출력
          out = 'regression_table.html')



