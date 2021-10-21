libs = c('tidyverse','data.table','rvest','lubridate','curl')
need = libs[!libs %in% installed.packages()[,'Package'] ]
lapply(need,install.packages)
lapply(libs,require,character.only = T)


current = paste(month(Sys.Date()),'01',year(Sys.Date()),sep = '/')
start_months = mdy(current) - months(1:(20 * 12))
end_months = start_months + months(1)

base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months,suffix)

cvs_fls = paste0('input/ceqa_month_csvs/ceqa_',start_months,'.csv')
url_q = paste0(base,start_months,fill,end_months,suffix)

for(v in which(!file.exists(cvs_fls))){
  print(url_q[v])
  curl::curl_download(url = url_q[v],destfile = cvs_fls[v])
}



