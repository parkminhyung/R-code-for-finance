# R-code-for-finance
R code for finance <br>
주식, 재무표, 데이터를 위해 만든 repo입니다. <br>
https://bookdown.org/allenpark88/rport/R+port.html 사이트에 접속하시면 세계 마감시황을 열람하실 수 있습니다. source : market-report.rmd <br>
# 2022.10.09 UPDATE
1. 중국주식데이터를 추가하였습니다
- 중국 상장기업의 주가데이터를 이용할 수 있습니다. 기본 정보는 Open, High, Low, Close, Volume, Change 값 입니다.

# 2022.12.30 UPDATE
1. portfolio_assets 함수를 추가하였습니다.
- function의 정보는 portfolio_assets(tickers,start_date,end_date,num_port)이며, tickers는 주식티커, start_date와 end_date는 각각 주식데이터의 시작시점과 끝시점을 나타냅니다. num_port는 포트폴리오 개수를 의미합니다.
- 예 : 
tickers = c("TXN","RTX","AAPL","T","BABA","SPG","F","NGG")
start_date='2013-01-01'; end_date = '2022-11-30'
num_port = 5000
portfolio_assets(tickers,start_date,end_date,num_port)

- 콘솔에 weight와 포트폴리오 수익률, 리스크 및 샤프비율을 제공합니다. plotly를 이용하여 weight와 Efficient Frontier 플롯을 제공합니다.

# 2022.02.02 UPDATE
1. 네이버주가데이터(Integrated)에 환율데이터를 추가하였습니다.
   - ticker부분에 환율ticker를 입력하시면 됩니다. 기본환율은 "달러기준(USD)" 이며, 한국원화기준(KRW)으로 보고 싶으시면 exusd=FALSE를 입력하시면 됩니다
   - 예 : 중국ticker = CNY, 위안달러환율 : fin_data("CNY"), 위안한국환율 : fin_data("CNY",exusd=FALSE)
   - datetype과 timelength는 기존것과 동일합니다. 디폴트 값은 1년데이터의 일일환율데이터를 제공합니다. 

# 2022.01.23 UPDATE
1. 네이버주가데이터(Integrated) 를 추가하였습니다.
- 국내외 시장 주가데이터 및 국내기업 주가데이터를 제공합니다 (추후 해외주가데이터도 추가할 예정)
- 디폴트 값은 ticker, datetype = "month", time_length="1년" 으로 되어 있습니다.
- ticker 값에 국내기업의 ticker, 혹은 마켓이름을 넣으시면 됩니다
- datetype은 "day","month","year" 로 제공합니다. day는 하루동안의 주가변동을 나타내며, month는 n개월 동안의 주가변동을 나타내며, year은 n년 동안의 주가데이터를 나타냅니다.
- **주의, 1년 동안의 전 영업일 주가데이터를 보고 싶으시면 ticker만 입력하시면 됩니다. ex. fin_data('005930') 디폴트로 되어있음 fin_data('005930','year','1')로 입력 시 주가는 1일이 아닌, 1주단위의 주가를 제공합니다
- 코스피 주가를 보고 싶으시면 fin_data('kospi')를 입력하시면 됩니다. 해외 마켓도 마찬가지로 입력하시면 됩니다. 
- 주가를 추출하고 싶으시면 fin_data(ticker)[해당주가의colnumber] 를 입력하시면 됩니다. 예를 들어 Close값은 colnum이 4, 이며, 삼성전자 1년 종가만 추출할 시 fin_data('005930')[4] 를 입력하시면 됩니다. OHLC가 필요하시면 fin_data('005930')[1:4]
- 해외 개별주식의 데이터는 추후에 처리할 예정입니다. 해외 마켓 데이터는 선물과 지수만 제공합니다.
- ticker는 대소문자 구분하지 않습니다. 자동으로 대문자로 변환되니 소문자로 입력하셔도 됩니다. 
- 데이터프레임을 윈도우창에 띄우고 보시고 싶으시면 View()를 이용하시면 됩니다. 예 : View(fin_data('005930'))

## 국내외 마켓 Ticker

- 아래표는 fin_data 함수가 지원하는 국내 및 해외 시장 ticker 입니다. 만약 필라델피아반도체 1년 주가를 보고 싶으시면 fin_data('SOX') 을 입력하시면 됩니다. datetype과 time_length는 기존의 것과 동일합니다. 예, 나스닥 3년 주가 데이터 : fin_data('IXIC','year',3)

|**아시아**|
|------|
|한국 : 코스피(kospi), 코스피200(KPI200), 코스닥(KOSDAQ),
중국 : 상해(SSEC), 심천(SZSC), 상해A(SSEA), 심천A(SZSA), 상해B(SSEB), 심천B(SZSB), CSI(CSI100), CSI300(CSI300), 항셍(HSI),홍콩H(HSCE)
기타 : 일본니케이(N225), 일본토픽스(TOPX), 대만가권(TWII), 베트남호치민(VNI), 베트남하노이(HNXI), 말레이시아(KLSE), 인도(BSESN), 인도네시아(JKSE)|

|**미국**|
|------|
|다우(DJI), 나스닥(IXIC), 다우운송(DJT), 나스닥100(NDX), S&P500(INX), 필라델피아반도체(SOX), VIX(VIX), 브라질(BVSP), 멕시코(MXX), 아르헨티나(MERV)|

|**유럽**|
|------|
|유로스톡스(STOXX50E), 독일DAX(GDAXI), 영국FTSE(FTSE), 프랑스CAC(FCHI), 이탈리아FTSEMIB(FTMIB), 네덜란드(AEX), 벨기에(BFX), 스페인(IBEX), 포르투갈(PSI20), 아일랜드(ISEQ), 덴마크(OMXC20), 스웨덴(OMXS30), 핀란드(OMXH25), 그리스(ATG), 헝가리(BUX), 러시아RTS(IRTS)|

|**선물**|
|------|
|코스피200선물(FUT), 나스닥100선물(NQcv1), S&P500선물(EScv1), 러셀200선물(RTYcv1), FTSEChina A50선물(SFCc1), 홍콩H선물(HCEIc1), 니케이선물(SSIcm1), 유로스톡스선물(STXEc1), 독일DAX선물(FDXc1), Niffy선물(SINc1), 금(GCcv1),은(SIcv1),WTI유(CLcv1)|

|**환율**|
|------|
|중국위안화(CNY),한국달러(KRW),일본엔화(JPY),대만(TWD),홍콩달러(HKD),유로(EUR).. 그밖의 환율ticker는 네이버금융 기준을 따릅니다.|


# 2022.01.17 UPDATE
1.다이나믹 헤지전략,KRX 리스트를 추가하였습니다.
- 다이나믹 헤지전략에 선물이론가, Protective의 Floor, 풋델타와 선물델타 그리고 동적헤지에 필요한 선물수량을 계산합니다.<br>
- KRX List를 추가하였습니다. KRX상장된 전 종목의 OHLC정보를 제공할 뿐만 아니라 화살표를 이용한 시각화도 추가하였습니다 <br>
- KRX 섹터를 추가하였습니다. 상장된 주식을 대상으로 이루어진 섹터의 일별 등락정보를 제공합니다 <br>

# 2021.02.04 UPDATE
1.옵션민감도 측정도구를 추가하였습니다..
- 콜옵션과 풋옵션에 대한 델타, 감마, 쎄타, 베가, 로 의 값을 도출합니다.<br>

# [코드 이용방법]

# 중국주식데이터
- 기본 합수는 cn_fin_data(ticker,start_date,end_date) 입니다.
- ticker 값에는 주식코드를 입력하시면 됩니다,
- start_date와 end_date의 기본 디폴트 값은 NULL이며, 입력하지 않으시면 올해년도의 1월 1일부터 당일 까지 주가를 제공합니다.
- 주가 데이터의 날짜 end_date가 1월일 시 작년 1월 1일부터 데이터 값을 제공합니다.

# 옵션민감도측정
- 기본함수는 option_sens(s,x,r,std,t,y=NULL) 입니다. <br>
- s : 기초자산가격, x:행사가격, r:무위험이자율, std: 변동성, t: 잔존기간(반드시 소수점으로 환산 해 주세요, 예: 3개월 일 경우, 3/12  = 0.25) <br>
- y 는 배당률(%) 입니다 <br>
- 각 행사가와 기초자산가격에 대한 델타, 감마, 로, 베가, 쎄타를 계산하여 값을 도출합니다. <br>

# 블랙숄즈모형
- 기본함수는 black_scholes(s,x,rf,std,t,y=NULL,D=NULL,r=NULL) 입니다. <br>
- s : 기초자산가격, x:행사가격, rf:무위험이자율, std: 변동성, t: 잔존기간(반드시 소수점으로 환산 해 주세요, 예: 3개월 일 경우, 3/12  = 0.25) <br>
- y 는 배당률(%) 입니다 <br>
- D는 배당금액이며, 배당금 입력시 할인율이 있다면 r항목에 입력 해 주시기 바랍니다.(현재가치로 환산 시 필요). 할인율이 없다면 그냥 두시면 됩니다. <br>
- 콘솔창에 콜 가격과 풋 가격이 보이는 것 외에 직접 콜 가격과 풋 가격을 이용할 수 있도록 했습니다. 예: 콜가격 이용시 black_scholes(s,x,rf,std,t)[1], 풋가격 이용시 black_scholes(s,x,rf,std,t)[2] <br>

# MARKET REPORT.rmd
- 따로 사용법 없이 rmd파일을 import시켜 도큐형태 혹은 html로 export하시면 됩니다. <br>
- 1분단위 가격을 이용하여 그래프(intraday chart)를 나타냅니다. <br>
- 장마감, 장오픈 정보를 제공합니다. <br>
- https://bookdown.org/allenpark88/rport  링크를 클릭하시면 market-report.Rmd를 이용하여 만든 사이트에 접속하실 수 있습니다. 미국, 유럽시황은 실시간으로 제공되게끔 하였으며, 아시아주요국의 시황은 우리나라 시간 기준 4시반 전후로 순차적으로 마켓이 끝날 경우 시황이 나타납니다. 장중에는 준비중이라는 문구와 함께 마감시황은 제공되지 않습니다. <br>
- 주말에는 금요일 시황이 제공됩니다 <br>

# 한경컨센서스
- 함수는 hk_consensus(categ, start_date, end_date) 로 구성되어 있습니다. <br>
- categ 는 산업, 파생, 시장 등을 구성하는 요소이며, input은 다음과 같습니다. <br>
- categ input: 파생상품:'d', 산업:'i', 경제:'e', 시장:'m', 기업:'b'  <br>
- 만일 2020년 02월 14일 부터 2020년 02월 17일 까지 "경제" 리포트를 보길 원하신다면 hk_consensus("e",'2020-02-14','2020-02-17')을 입력해주시면 됩니다. <br>
- 오늘 "경제" 리포트를 보길 원하신다면 start_date와 end_date를 입력하지 않고 hk_consensus("e")만 입력 해 주시면 됩니다. <br>
- console창에 함수를 입력해 주시면 해당 날짜와 해당 카테고리의 목록이 테이블 형태로 나타나며, 열람하고 싶은 리포트 맨 앞 숫자를 입력하시면 브라우져의 새 창 형식으로 pdf가 띄어집니다. <br>
- 열람 후 '계속 열람하시겠습니까?'라는 질문이 뜰 y를 입력할 시 계속해서 해당 업종에 대한 리포트를 열람하실 수 있습니다. <br>


# 중국상장기업목록
- 중국상장기업목록은 중국 본토 내 상장되어 있는 전 기업의 간단한 정보를 제공합니다. <br>
- function화 시켜 SHSZ_table()로 작동하고, csv파일로 저장하고 싶으면 SHSZ_table(save_csv_file=TRUE)를 입력하시면 됩니다 <br>
- 시간이 오래걸리므로 sheet만 참고하고 싶으시면 https://docs.google.com/spreadsheets/d/1AxvMtxLIJUWyfXUgM_LLo5XV5Bj7ODqcu6JMEtBelE4/edit?usp=sharing 를 보시면 됩니다.

- 중국상장기업 기업정보는 중국 A주에 상장되어있는 기업의 정보를 제공합니다. 이용방법 : 예)cn_get_st('000002') <br>
- A주종목을 대상으로 하였으므로 "2" 혹은 "9"로 시작하는 B주 종목코드는 실행이 불가합니다 <br>
- 홍콩상장기업 재무제표와 중국상장기업 제무제표는 홍콩재무제표, 중국재무제표를 나타냅니다. <br>

- 홍콩상장기업 재무제표와 중국상장기업 재무제표 내 주식코드 테이블은 그냥 참고용이지, function과는 독립적이므로 원치 않으신 분들은 function만 import해도 됩니다. <br>

- 중국상장기업 재무제표 이용방법 : cn_fs('코드번호') ex) cn_fs('000002') <br>
