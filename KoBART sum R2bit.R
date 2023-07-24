## 원문 : https://r2bit.com/book_tm/view-text.html


ifelse(!require(pacman),install.packages('pacman'),library('pacman'))
pacman::p_load("rvest","reticulate","zeallot")

'%=%' = zeallot::`%<-%`

c(pipeline,AutoModelForSeq2SeqLM,AutoTokenizer) %=% list(
  import("transformers")$pipeline,
  import("transformers")$AutoModelForSeq2SeqLM,
  import("transformers")$AutoTokenizer
)

news_article = 'https://www.hani.co.kr/arti/economy/economy_general/1053167.html' %>%
  read_html() %>%
  html_node('div.text') %>%
  html_text(trim=TRUE) %>%
  gsub(x=.,pattern = "\n",replace = "")

summary_tokenizer = AutoTokenizer$from_pretrained("ainize/kobart-news")
summary_model = AutoModelForSeq2SeqLM$from_pretrained("ainize/kobart-news")

summarizer = pipeline("summarization", 
                      model = summary_model,
                      tokenizer = summary_tokenizer)

hani_news = summarizer(news_article, 
                       max_length=as.integer(100), 
                       min_length=as.integer(30), 
                       do_sample=FALSE)

hani_news[[1]]$summary_text
