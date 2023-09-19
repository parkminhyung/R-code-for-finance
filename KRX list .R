library(httr); library(rvest); library(readr); library(formattable); library(sparkline)

options(scipen = 100)

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

otp_url = "http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd"
otp_from_data = list(
  mktId = 'ALL',
  trdDd = DT,
  share = '1',
  money = '1',
  csvxls_isNo = 'false',
  name = 'fileDown',
  url = 'dbms/MDC/STAT/standard/MDCSTAT01501'
)
otp = POST(otp_url,query = otp_from_data) %>%
  read_html() %>%
  html_text()


csv_url= 'http://data.krx.co.kr/comm/fileDn/download_csv/download.cmd'
data = POST(csv_url,
            query = list(code = otp)) %>%
  read_html(encoding = "EUC-KR") %>%
  html_text() %>%
  read_csv() %>%
  .[,c(2,1,3:ncol(.))] %>%
  .[c(which(.[3]=="KOSPI"),which(.[3]=="KOSDAQ"),which(.[3]=="KONEX")),] %>%
  as.data.frame()

data[7] = data[,7] %>% paste0(.,"%")
data[which(is.na(data[4])==TRUE),4] = "-"

dfst = formattable(data, align = c("l","c","c",rep("l",4),rep("c",4),rep("r",3)), list(
  '종목명' = formatter("span",style = x~style(font.weight = "bold")),
  '종목코드' = formatter("span",style = x~style(font.weight = "bold")),
  '시장구분' = formatter("span",style = x~style(font.weight = "bold")),
  '대비' = formatter("span",
                   style = x ~ style(color = ifelse(grepl(x=data[,6],"-")==TRUE , "red", "green")),
                   x ~ icontext(ifelse(grepl(x=data[,6],"-")==TRUE, "arrow-down", "arrow-up"), x)),
  '종가' = formatter("span",style = x~style(font.weight = "bold",
                                          color = ifelse(grepl(x=data[,6],"-")==TRUE , "red", "green"))),
  '등락률' = formatter("span",
                    style = x ~ style(font.weight = "bold",
                                      color = ifelse(grepl(x=data[,7],"-")==TRUE , "red", "green")),
                    x ~ icontext(ifelse(grepl(x=data[,6],"-")==TRUE, "arrow-down", "arrow-up"), x))
))

dfst
