
### 네이버 증권 리포트 다운로더
### 네이버 증권에서 제공하는 리포트를 다운로드 합니다.
### REPORT 폴더를 만들고, 그 폴더 내 인더스트리, 경제, 채권 폴더를 만들어 해당 리포트를 다운합니다
### 리포트 형식은 pdf이며, 오늘 날짜를 기준으로 다운합니다.(주말에는 작동이 안될 수도 있습니다)
### 주말에 다운받으려면 date를 수정하세요
### 자동화를 하고 싶으시다면, crontab -e를 이용하여 vim을 수정하세요. (Mac & Linux 기준)

library(pacman)

p_load(
  rvest,
  dplyr
)

url = c("https://finance.naver.com/research/industry_list.naver",
        "https://finance.naver.com/research/economy_list.naver",
        "https://finance.naver.com/research/debenture_list.naver")

name = c("INDUSTRY", "ECONOMICS", "BONDS")

## date는 리포트의 기준일이며, 기본 값은 오늘 날짜를 기준으로 합니다. 
## 다운받고 싶은 리포트의 기준일이 있다면, date를 수정하세요.
date = Sys.Date() %>%
  format("%y.%m.%d")

# REPORT 디렉토리 생성
report_dir = "./REPORT" # REPORT 폴더가 생성 될  디렉토리 지정(수정필요)
if (!dir.exists(report_dir)) {
  dir.create(report_dir)
}

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
    
    category_folder = file.path(report_dir, paste0(Sys.Date(), "_", name[i]))
    
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
      category_folder_path = file.path(category_folder, paste0(Sys.Date(), "_", name[i], "_", category))
      if (!dir.exists(category_folder_path)) {
        dir.create(category_folder_path)
      }
      
      #산업 리포트PDF 다운로드
      for (link in category_links) {
        pdf_name = file.path(category_folder_path, basename(link))
        download.file(link, pdf_name, mode = "wb")
      }
    }
    
    # 'ECONOMICS'와 'BONDS' 는  별도로 처리
  } else {
    
    category_folder = file.path(report_dir, paste0(Sys.Date(), "_", name[i]))
    
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

