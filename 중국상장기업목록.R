#https://docs.google.com/spreadsheets/d/1AxvMtxLIJUWyfXUgM_LLo5XV5Bj7ODqcu6JMEtBelE4/edit?usp=sharing

SHSZ_table = function(save_csv_file = FALSE){
  
  library(rvest)
  library(httr)
  library(progress)
  
  url = "https://hq.gucheng.com/gpdmylb.html" %>%
    read_html() %>%
    html_nodes("#stock_index_right > div > section > a")
  
  name = url %>% html_text() %>% substr(.,1,(nchar(.))-8) %>% gsub(" ","",x=.)
  code = url %>% html_text() %>% substr(.,(nchar(.))-6,(nchar(.))-1)
  url2 = url %>% html_attr("href")
  
  table = data.frame("회사명"= name,
                     "종목코드" = code,
                     "시장구분" = NA,
                     "소재지"=NA,
                     "업종"=NA,
                     "유통주식수" = NA,
                     "기준일" = NA,
                     "매출액(억위안)" = NA,
                     "순이익(억위안)" = NA,
                     "매출총이익률" =NA,
                     "순자산(억위안)" = NA,
                     "ROE" = NA,
                     "BPS" = NA,
                     "EPS" = NA,
                     "PER" = NA,
                     "PBR" = NA,
                     "CPS" = NA)
  
  for (i in 1:nrow(table)) {
    if(substr(table[i,2],1,2)=='00'){
      table[i,3] = "SZ-A"
    } else if(substr(table[i,2],1,3)=="200") {
      table[i,3] = "SZ-B"
    } else if(substr(table[i,2],1,3)=="002") {
      table[i,3] = "SZ-ZXB"
    } else if(substr(table[i,2],1,2)=="30") {
      table[i,3] = "SZ-CYB"
    } else if(substr(table[i,2],1,2)=="60"){
      table[i,3] = "SH-A"
    } else if(substr(table[i,2],1,2)=="90"){
      table[i,3] = "SH-B"
    } else if(substr(table[i,2],1,3)=="399"){
      table[i,3] = "SZ-INDEX"
    } else if(substr(table[i,2],1,3)=="010"){
      table[i,3] = "BOND"
    } else if(substr(table[i,2],1,3)=="019"){
      table[i,3] = "BOND"
    } else {
      table[i,3] = "INDEX"
    }
  }
  
  pb = progress_bar$new(total = nrow(table))
  View(table)
  
  for (i in 1:nrow(table)) {
    try({
      uu = GET(url2[i])
      
      tb = uu %>%
        read_html() %>%
        html_nodes(css = 'div.hq_wrap_right > section:nth-child(9) > div > table')
      
      cominfo = uu %>%
        read_html() %>%
        html_nodes(css='#hq_wrap > div.hq_wrap_right > section.stock_company > div > div.stock_company_info.clearfix')
      
      table[i,4] = cominfo %>%
        html_nodes('p:nth-child(2)') %>%
        html_text(trim = TRUE) %>%
        substr(.,6,nchar(.))
      
      table[i,5] = cominfo %>%
        html_nodes('p:nth-child(3)') %>%
        html_text(trim = TRUE) %>%
        substr(.,6,nchar(.))
      
      table[i,6] = cominfo %>%
        html_nodes('p:nth-child(8)') %>%
        html_text(trim = TRUE) %>%
        substr(.,6,nchar(.))
      
      table[i,7] = tb %>%
        html_node(css = 'tbody > tr.stock_table_tr > td:nth-child(2) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,8] = tb %>%
        html_node(css = 'tbody > tr:nth-child(7) > td:nth-child(5) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,9] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(2) > td:nth-child(6) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,10] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(3) > td:nth-child(4) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,11] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(7) > td:nth-child(2) > div') %>% 
        html_text(trim = TRUE) 
      
      table[i,12] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(2) > td:nth-child(3) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,13] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(3) > td:nth-child(2) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,14] = tb %>%
        html_node(css = 'tbody > tr:nth-child(2) > td:nth-child(3) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,15] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(6) > td:nth-child(3) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,16] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(4) > td:nth-child(5) > div') %>% 
        html_text(trim = TRUE)
      
      table[i,17] = tb %>% 
        html_node(css = 'tbody > tr:nth-child(5) > td:nth-child(4) > div') %>% 
        html_text(trim = TRUE)
      
    },silent = T)
    pb$tick()
  }
  
  table[,6] = table[,6] %>%
    gsub("股","주",x=.)
  
  table[,7] = table[,7] %>%
    gsub("年","년",x=.) %>%
    gsub("月","월",x=.)
  
  if(save_csv_file == TRUE){
    write.csv(table,"SH_SZ_Table.csv")
    print("csv파일로 저장되었습니다. 파일명:SH_SZ_Table.csv")
    View(table)
  } else {
    print("파일을 저장하지 않습니다.")
    View(table)
  }
}
