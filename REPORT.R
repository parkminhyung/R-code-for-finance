
#### 네이버 리포트 다운로드
#### 네이버 증권 사이트에서 크롤링을 통해 오늘 날짜의 리포트를 자동적으로 다운합니다

library(pacman)
p_load(
  rvest,
  dplyr
)

url = c("https://finance.naver.com/research/industry_list.naver",
        "https://finance.naver.com/research/economy_list.naver",
        "https://finance.naver.com/research/debenture_list.naver",
        "https://finance.naver.com/research/invest_list.naver",
        "https://finance.naver.com/research/market_info_list.naver")

name = c("INDUSTRY", "ECONOMICS", "BONDS","INVEST","MARKETINFO")

date = case_when(
  weekdays(Sys.Date()) %in% c("Saturday","토요일") ~ (Sys.Date()-1) %>% format("%y.%m.%d"),
  weekdays(Sys.Date()) %in% c("Sunday","일요일") ~ (Sys.Date()-1) %>% format("%y.%m.%d"),
  TRUE ~ (Sys.Date()) %>% format("%y.%m.%d")
)

# REPORT 디렉토리 생성
report_dir = "./REPORT" #### edit your path.
if (!dir.exists(report_dir)) {
  dir.create(report_dir)
}

# URL을 순차적으로 처리
for (i in 1:length(url)) {
  
  main = url[i] %>%
    read_html(encoding = "EUC-KR") %>%
    html_table(fill = TRUE) %>%
    .[[1]] %>%
    filter(조회수 != "") %>% 
    filter(작성일 == date) 
  
  links = url[i] %>%
    read_html(encoding = "EUC-KR") %>%
    html_elements('a') %>%
    html_attr("href") %>%
    .[grepl("\\.pdf$", ., ignore.case = TRUE)] %>%
    .[1:nrow(main)] 
  
  # 'INDUSTRY'인 경우
  if (name[i] == "INDUSTRY") {
    
    category_folder = file.path(report_dir, paste0(date, "_", name[i]))
    
    if (!dir.exists(category_folder)) {
      dir.create(category_folder)
    }
    
    main = main %>%
      mutate(link = links) %>%
      group_by(분류) %>%
      arrange(분류)
    
    # 분류별 폴더 생성 및 PDF 다운로드
    for (j in 1:length(unique(main$분류))) {
      category = unique(main$분류)[j]
      category_links = main %>%
        filter(분류 == category) %>%
        pull(link)
      
      # 'INDUSTRY' 폴더 안에 분류별 폴더 생성
      category_folder_path = file.path(category_folder, paste0(date, "_", name[i], "_", category))
      if (!dir.exists(category_folder_path)) {
        dir.create(category_folder_path)
      }
      
      # PDF 다운로드
      for (link in category_links) {
        pdf_name = file.path(category_folder_path, basename(link))
        download.file(link, pdf_name, mode = "wb")
      }
    }
    
    # 'ECONOMICS'와 'BONDS'인 경우
  } else {
    
    category_folder = file.path(report_dir, paste0(date, "_", name[i]))
    
    if (!dir.exists(category_folder)) {
      dir.create(category_folder)
    }
    
    main = main %>%
      mutate(link = links)
    
    # PDF 다운로드
    for (link in main$link) {
      pdf_name = file.path(category_folder, basename(link))
      download.file(link, pdf_name, mode = "wb")
    }
  }
}





##### EXAMPLE
#### TERMINAL :: %Rscript "your path where saved REPORT.R"" /REPORT.R
## %Rscript ./REPORT.R 
## 터미널을 열고 Rscript를 기입한 후 한칸 띄우고 REPORT.R을 드래그 하셔도 됩니다.




