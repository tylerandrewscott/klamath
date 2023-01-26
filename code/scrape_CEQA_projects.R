### ln -s ~/Library/CloudStorage/Box-Box/klamath/ceqanet_raw/ .
# ^ this line to be run in terminal, creates symlink so that Box folder klamath/ceqanet_raw shows up as github folder ceqanet_raw
# files in ceqanet_raw are not tracked in github, only stored in Box

libs = c('tidyverse','data.table','rvest','lubridate','curl')
need = libs[!libs %in% installed.packages()[,'Package'] ]
lapply(need,install.packages)
lapply(libs,require,character.only = T)


current <- Sys.Date()
date_seq <- seq(ymd('2000-01-01'),current,by="1 months")
start_months <- date_seq[-length(date_seq)]
end_months = date_seq + months(1) - days(1)

base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months,suffix)

cvs_fls = paste0('ceqanet_raw/metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')
url_q = paste0(base,start_months,fill,end_months,suffix)

for(v in which(!file.exists(cvs_fls))){
  print(url_q[v])
  curl::curl_download(url = url_q[v],destfile = cvs_fls[v])
}



