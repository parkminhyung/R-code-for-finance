
hk_consensus = function(categ){
  
  library(rvest)
  
  if(categ == "d") {
    categ = "derivative"
  } else if (categ == "e"){
    categ = "economy"
  } else if (categ == "m"){
    categ = "market"
  } else if (categ == "i"){
    categ = "industry"
  } else if (categ == "b"){
    categ = "business"
  } else {
    
    cat("잘못입력하셨습니다. 리포트를 보시려면 categ를 다음과 같이 설정해주세요","\n",
        "\n",
        "파생상품: d","\n",
        "산업 : i","\n",
        "경제 : e","\n",
        "시장 : m","\n",
        "기업 : b","\n")
  }
  
  url = paste0('http://consensus.hankyung.com/apps.analysis/analysis.list?skinType=',categ) %>%
    read_html(encoding = "EUC-KR") 
  
  url %>%
    html_nodes(xpath = '//*[@id="contents"]/div[2]/table') %>%
    html_table(fill = TRUE) %>%
    .[[1]] %>%
    .[,1:5] %>%
    View(title = "Contents")
  
  pdf = url %>%
    html_nodes('div') %>%
    html_nodes('a') %>%
    html_attr('href') %>%
    .[grep("downpdf",.)] %>%
    paste0("http://consensus.hankyung.com",.)
  
  number = function() {
    i = readline("열람하고 싶은 리포트 number을 기입 해 주세요 num : ")
    browseURL(pdf[as.integer(i)])
  }
  print(number())
}






