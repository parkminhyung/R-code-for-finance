
download_q_factor_model = function(files_name){
  ifelse(!require("pacman"),
         install.packages("pacman"),
         library(pacman))
  pacman::p_load("tibble")
  '%+%' = paste0
  data = read.csv("https://global-q.org/uploads/1/2/2/6/122679606/" %+% files_name %+% ".csv") %>%
    as_tibble() 
  return(data)
}

get_q_factor_model_list = function(only_view_factors_exp = FALSE){
  
  list_table = data.frame(
    Name = c("The q-factors and Expected Growth Factor (Daily)",
             "The q-factors and Expected Growth Factor (Weekly (calendar))",
             "The q-factors and Expected Growth Factor (Weekly (Wednesday-to-Wednesday))",
             "The q-factors and Expected Growth Factor (Monthly)",
             "The q-factors and Expected Growth Factor (Quarterly)",
             "The q-factors and Expected Growth Factor (Annual)",
             
             "18 (2X3X3) Benchmark Portfolios Underlying Q factors (Daily)",
             "18 (2X3X3) Benchmark Portfolios Underlying Q factors (Weekly (calendar))",
             "18 (2X3X3) Benchmark Portfolios Underlying Q factors (Weekly (Wednesday-to-Wednesday))",
             "18 (2X3X3) Benchmark Portfolios Underlying Q factors (Monthly)",
             "18 (2X3X3) Benchmark Portfolios Underlying Q factors (Quarterly)",
             "18 (2X3X3) Benchmark Portfolios Underlying Q factors (Annual)",
             
             "6 (2X3) Benchmark Portfolios Underlying the Expected Growth Factor (Daily)",
             "6 (2X3) Benchmark Portfolios Underlying the Expected Growth Factor (Weekly (calendar))",
             "6 (2X3) Benchmark Portfolios Underlying the Expected Growth Factor (Weekly (Wednesday-to-Wednesday))",
             "6 (2X3) Benchmark Portfolios Underlying the Expected Growth Factor (Monthly)",
             "6 (2X3) Benchmark Portfolios Underlying the Expected Growth Factor (Quarterly)",
             "6 (2X3) Benchmark Portfolios Underlying the Expected Growth Factor (Annual)" 
    ),
    files_name = c("q5_factors_daily_2022",
                   "q5_factors_weekly_2022",
                   "q5_factors_weekly_w2w_2022",
                   "q5_factors_monthly_2022",
                   "q5_factors_quarterly_2022",
                   "q5_factors_annual_2022",
                   
                   "benportf_me_ia_roe_daily_2022",
                   "benportf_me_ia_roe_weekly_2022",
                   "benportf_me_ia_roe_weekly_w2w_2022",
                   "benportf_me_ia_roe_monthly_2022",
                   "benportf_me_ia_roe_quarterly_2022",
                   "benportf_me_ia_roe_annual_2022",
                   
                   "benportf_me_eg_daily_2022",
                   "benportf_me_eg_weekly_2022",
                   "benportf_me_eg_weekly_w2w_2022",
                   "benportf_me_eg_monthly_2022",
                   "benportf_me_eg_quarterly_2022",
                   "benportf_me_eg_annual_2022")
  )
  

  if(!only_view_factors_exp) View(list_table)
  
  cat("Factors:","\n",
      "### The q-factors and Expected Growth Factor ###","\n",
      "* R_F : stands for the one-month Treasury bill rates","\n",
      "* R_MKT : the market excess returns","\n",
      "* R_ME : the size factor returns","\n",
      "* R_IA : the investment factor returns","\n",
      "* R_ROE : the return on equity factor returns","\n",
      "* R_EG : the expected growth factor returns","\n",
      "","\n",
      "### 18 (2X3X3) Benchmark Portfolios Underlying Q factors ###","\n",
      "* For size (ME), 1 means Small","\n",
      "* For size (ME), 2 means Big","\n",
      "* For Investment to asset (IA), 1 means Low","\n",
      "* For Investment to asset (IA), 2 means Median","\n",
      "* For Investment to asset (IA), 3 means High","\n",
      "* For Return on Equity (ROE), 1 means Low","\n",
      "* For Return on Equity (ROE), 2 means Median","\n",
      "* For Return on Equity (ROE), 3 means High","\n",
      "","\n",
      "### 6 (2X3) Benchmark Portfolios Underlying the Expected Growth Factor ###","\n",
      "* For size (ME), 1 means Small","\n",
      "* For size (ME), 2 means Big","\n",
      "* For Investment to asset (IA), 1 means Low","\n",
      "* For Investment to asset (IA), 2 means Median","\n",
      "* For Investment to asset (IA), 3 means High","\n",
      "* For Return on Equity (ROE), 1 means Low","\n",
      "* For Return on Equity (ROE), 2 means Median","\n",
      "* For Return on Equity (ROE), 3 means High","\n"
  )
}
