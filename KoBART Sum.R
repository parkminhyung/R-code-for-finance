#원문 : https://github.com/seujung/KoBART-summarization

ifelse(!require(pacman),install.packages('pacman'),library('pacman'))
pacman::p_load("dplyr","reticulate","zeallot")

'%=%' = zeallot::`%<-%`

c(PreTrainedTokenizerFast,BartForConditionalGeneration) %=% list(
  import("transformers")$PreTrainedTokenizerFast,
  import("transformers")$BartForConditionalGeneration
)

tokenizer = PreTrainedTokenizerFast$from_pretrained('digit82/kobart-summarization')
model = BartForConditionalGeneration$from_pretrained('digit82/kobart-summarization')

text = "
1일 오후 9시까지 최소 20만3220명이 코로나19에 신규 확진됐다. 또다시 동시간대 최다 기록으로, 사상 처음 20만명대에 진입했다.
방역 당국과 서울시 등 각 지방자치단체에 따르면 이날 0시부터 오후 9시까지 전국 신규 확진자는 총 20만3220명으로 집계됐다.
국내 신규 확진자 수가 20만명대를 넘어선 것은 이번이 처음이다.
동시간대 최다 기록은 지난 23일 오후 9시 기준 16만1389명이었는데, 이를 무려 4만1831명이나 웃돌았다. 전날 같은 시간 기록한 13만3481명보다도 6만9739명 많다.
확진자 폭증은 3시간 전인 오후 6시 집계에서도 예견됐다.
오후 6시까지 최소 17만8603명이 신규 확진돼 동시간대 최다 기록(24일 13만8419명)을 갈아치운 데 이어 이미 직전 0시 기준 역대 최다 기록도 넘어섰다. 역대 최다 기록은 지난 23일 0시 기준 17만1451명이었다.
17개 지자체별로 보면 서울 4만6938명, 경기 6만7322명, 인천 1만985명 등 수도권이 12만5245명으로 전체의 61.6%를 차지했다. 서울과 경기는 모두 동시간대 기준 최다로, 처음으로 각각 4만명과 6만명을 넘어섰다.
비수도권에서는 7만7975명(38.3%)이 발생했다. 제주를 제외한 나머지 지역에서 모두 동시간대 최다를 새로 썼다.
부산 1만890명, 경남 9909명, 대구 6900명, 경북 6977명, 충남 5900명, 대전 5292명, 전북 5150명, 울산 5141명, 광주 5130명, 전남 4996명, 강원 4932명, 충북 3845명, 제주 1513명, 세종 1400명이다.
집계를 마감하는 자정까지 시간이 남아있는 만큼 2일 0시 기준으로 발표될 신규 확진자 수는 이보다 더 늘어날 수 있다. 이에 따라 최종 집계되는 확진자 수는 21만명 안팎을 기록할 수 있을 전망이다.
한편 전날 하루 선별진료소에서 이뤄진 검사는 70만8763건으로 검사 양성률은 40.5%다. 양성률이 40%를 넘은 것은 이번이 처음이다. 확산세가 계속 거세질 수 있다는 얘기다.
이날 0시 기준 신규 확진자는 13만8993명이었다. 이틀 연속 13만명대를 이어갔다.
"

text = text %>% 
  gsub(x=.,pattern="\n",replace="")

input_ids = tokenizer$encode(text,return_tensors = 'pt') 

summary_ids = model$generate(
  input_ids,
  bos_token_id = as.integer(tokenizer$bos_token_id),
  eos_token_id = as.integer(tokenizer$eos_token_id),
  num_beams = as.integer(4),
  max_length = as.integer(512),
  min_length = as.integer(32)
)

tokenizer$decode(
  summary_ids[0],
  skip_special_tokens = TRUE
)
