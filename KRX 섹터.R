library(rvest); library(httr); library(readr); library(plotly); library(formattable)


Sys.setenv(TZ = "Asia/Seoul")
'%ni%' = Negate('%in%')
if(weekdays(Sys.Date()) %ni% c("Saturday", "Sunday","Monday") & ("00:00:00" < format(Sys.time(), "%X")) & (format(Sys.time(), "%X") < "09:00:00")==TRUE) {
  DT = format(Sys.Date()-1,"%Y%m%d",tz = "Asia/Seoul")
} else if(weekdays(Sys.Date())=="Saturday"){
  DT = format(Sys.Date()-1,"%Y%m%d",tz = "Asia/Seoul")
} else if(weekdays(Sys.Date())=="Sunday"){
  DT = format(Sys.Date()-2,"%Y%m%d",tz = "Asia/Seoul")
} else if(weekdays(Sys.Date()) == "Monday" & ("00:00:00" < format(Sys.time(), "%X")) & (format(Sys.time(), "%X") < "09:00:00") == TRUE){
  DT = format(Sys.Date()-3,"%Y%m%d",tz = "Asia/Seoul")
} else {
  DT = format(Sys.Date(),"%Y%m%d",tz = "Asia/Seoul")
}
LastDT =  paste0(as.numeric(format(Sys.Date(),"%Y"))-1,format(Sys.Date(),"%m%d"))



##################OTP LIST#################

otp_list = list(
  list(
    tboxindIdx_finder_equidx0_1= 'KRX 자동차',
    indIdx= '5',
    indIdx2= '043',
    codeNmindIdx_finder_equidx0_1= 'KRX 자동차',
    param1indIdx_finder_equidx0_1= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2= 'KRX 반도체',
    indIdx= '5',
    indIdx2= '044',
    codeNmindIdx_finder_equidx0_2= 'KRX 반도체',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 = 'KRX 헬스케어',
    indIdx= '5',
    indIdx2= '045',
    codeNmindIdx_finder_equidx0_2= 'KRX 헬스케어',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 = 'KRX 은행',
    indIdx= '5',
    indIdx2= '046',
    codeNmindIdx_finder_equidx0_2= 'KRX 은행',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 = 'KRX 에너지화학',
    indIdx ='5',
    indIdx2 = '048',
    codeNmindIdx_finder_equidx0_2 = 'KRX 에너지화학',
    param1indIdx_finder_equidx0_2 = '',
    strtDd= LastDT,
    endDd= DT,
    share = '2',
    money = '3',
    csvxls_isNo = 'false',
    name = 'fileDown',
    url = 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 철강',
    indIdx= '5',
    indIdx2= '049',
    codeNmindIdx_finder_equidx0_2= 'KRX 철강',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 방송통신',
    indIdx= '5',
    indIdx2= '051',
    codeNmindIdx_finder_equidx0_2= 'KRX 방송통신',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 건설',
    indIdx= '5',
    indIdx2= '052',
    codeNmindIdx_finder_equidx0_2= 'KRX 건설',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 증권',
    indIdx= '5',
    indIdx2= '054',
    codeNmindIdx_finder_equidx0_2= 'KRX 증권',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 기계장비',
    indIdx= '5',
    indIdx2= '055',
    codeNmindIdx_finder_equidx0_2= 'KRX 기계장비',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 보험',
    indIdx= '5',
    indIdx2= '056',
    codeNmindIdx_finder_equidx0_2= 'KRX 보험',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 운송',
    indIdx= '5',
    indIdx2= '057',
    codeNmindIdx_finder_equidx0_2= 'KRX 운송',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 경기소비재',
    indIdx= '5',
    indIdx2= '061',
    codeNmindIdx_finder_equidx0_2= 'KRX 경기소비재',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 필수소비재',
    indIdx= '5',
    indIdx2= '062',
    codeNmindIdx_finder_equidx0_2= 'KRX 필수소비재',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 미디어&엔터테인먼트',
    indIdx= '5',
    indIdx2= '063',
    codeNmindIdx_finder_equidx0_2= 'KRX 미디어&엔터테인먼트',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 정보기술',
    indIdx= '5',
    indIdx2= '064',
    codeNmindIdx_finder_equidx0_2= 'KRX 정보기술',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  ),
  list(
    tboxindIdx_finder_equidx0_2 ='KRX 유틸리티',
    indIdx= '5',
    indIdx2= '065',
    codeNmindIdx_finder_equidx0_2= 'KRX 유틸리티',
    param1indIdx_finder_equidx0_2= '',
    strtDd= LastDT,
    endDd= DT,
    share= '2',
    money= '3',
    csvxls_isNo= 'false',
    name= 'fileDown',
    url= 'dbms/MDC/STAT/standard/MDCSTAT00301'
  )
)


#################SectorDF###################
i = 1

otp_url = "http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd"
otp_from_data = otp_list[[i]]

otp = POST(otp_url,query = otp_from_data) %>%
  read_html() %>%
  html_text()

csv_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'

df = POST(csv_url,
             query = list(code = otp)) %>%
  read_html(encoding = "EUC-KR") %>%
  html_text() %>%
  read_csv() %>%
  as.data.frame() %>%
  .[,c(1,5:7,2:4,8:10)] %>%
  .[nrow(.):1,]

Date = as.Date(df[,1])
p = df %>% plot_ly(
  x=Date,
  y = df[,5],
  type="scatter",
  mode = "line",
  name = "Close Price") %>%
  layout(title = paste0(as.character(otp_list[[i]][1])," [",df[nrow(df),5],'pt (',df[nrow(df),6],'pt, ',df[nrow(df),7],'%)',"]"))

pp = plot_ly(x=Date,
             y=df[,8],
             name = "Vol",
             marker = list(color = 'rgb(49, 193, 160)'),type = 'bar') %>%
  layout(yaxis = list(title = "Vol"))

subplot(p,pp,shareX = TRUE,nrows = 2,heights = c(0.8,0.2)) %>% print()



################# KRX data Frame #################### 

otp_krx_url = 'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
otp_krx_from_data = list(
  idxIndMidclssCd= '01',
  trdDd= DT,
  share= '2',
  money= '3',
  csvxls_isNo= 'false',
  name= 'fileDown',
  url= 'dbms/MDC/STAT/standard/MDCSTAT00101'
)

otp = POST(otp_krx_url,query = otp_krx_from_data) %>%
  read_html() %>%
  html_text()
csv_krx_url = 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'

df_krx = POST(csv_krx_url,
                  query = list(code = otp)) %>%
  read_html(encoding = "EUC-KR") %>%
  html_text() %>%
  read_csv() %>%
  as.data.frame() 

df_krx[4] = df_krx[,4] %>% paste0(.,"%")

df_krx_form = formattable(df_krx, align = c("l","c","l","l",rep("c",3),rep("r",3)), list(
  '지수명' = formatter("span",style = x~style(font.weight = "bold")),
  '대비' = formatter("span",
                   style = x ~ style(color = ifelse(grepl(x=df_krx[,4],"-")==TRUE , "red", "green")),
                   x ~ icontext(ifelse(grepl(x=df_krx[,4],"-")==TRUE, "arrow-down", "arrow-up"), x)),
  '종가' = formatter("span",style = x~style(font.weight = "bold",
                                          color = ifelse(grepl(x=df_krx[,4],"-")==TRUE , "red", "green"))),
  '등락률' = formatter("span",
                    style = x ~ style(font.weight = "bold",
                                      color = ifelse(grepl(x=df_krx[,4],"-")==TRUE , "red", "green")),
                    x ~ icontext(ifelse(grepl(x=df_krx[,4],"-")==TRUE, "arrow-down", "arrow-up"), x))
))

df_krx_form