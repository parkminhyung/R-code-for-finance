# R-code-for-finance
R code for finance <br>
주식, 재무표, 데이터를 위해 만든 repo입니다. <br>
https://bookdown.org/allenpark88/rport2/ 사이트에 접속하시면 세계 마감시황을 열람하실 수 있습니다. source : market-report.rmd <br>

# 2021.02.04 UPDATE
1.옵션민감도 측정도구를 추가하였습니다..
- 콜옵션과 풋옵션에 대한 델타, 감마, 쎄타, 베가, 로 의 값을 도출합니다.<br>

# 2021.01.11 UPDATE
1.market report의 마켓데이터를 변경하였습니다.
- 중국사이트인 시나재경에서 제공하던 intraday 마켓데이터를 야후 파이낸스 데이터로 변경하여 크롤링 속도를 높였습니다. <br>
- 기존 나눔 트레이더에서 제공하던 마감시황정보를 뉴스핌과 연합뉴스로 변경하였습니다 <br>
- fixed minor error <br>

2. 옵션가격결정모형인 블랙숄즈모형을 추가하였습니다. 
- 배당률과 배당, 배당이 없는 경우의 콜옵션과 풋옵션의 가격을 계산합니다.<br>

# 2020.09.24 UPDATE
1.마켓의 OPEN/CLOSE 방식이 변경되었습니다.
- dataframe의 양식을 따르던 개장/마감 방식이 크롤링으로 변경되어 보다 정확성을 높였습니다. <br>
- fixed minor error

# [코드 이용방법]

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

# k-score
- k-score는 알트만의 z-core를 본 떠 만든 한국형 모델 k-score입니다. 상장되어 있는 전 종목에 이 모델을 적용시키는 코드이며, 한눈에 기업의 부실정도를 측정가능하도록 하는 모델입니다.<br>
reference: <br>
[1] https://m.blog.naver.com/PostView.nhn?blogId=haan79&logNo=10158008764&proxyReferer=https%3A%2F%2Fwww.google.co.kr%2F<br>
[2] https://finata.blog.me/221191125946

- 한국상장기업 기업정보는 한국 상장기업에 대한 기본 정보를 제공합니다. 코드이용방법 : kr_get_st('6자리코드') 예) kr_get_st('005930')<br>

