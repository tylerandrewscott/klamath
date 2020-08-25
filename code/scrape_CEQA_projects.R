libs = c('tidyverse','data.table','rvest','lubridate')
need = libs[!libs %in% installed.packages()[,'Package'] ]
lapply(need,install.packages)
lapply(libs,require,character.only = T)

start_months = mdy('01/01/2020') - months(1:(20 * 12))
end_months = start_months + months(1)
base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months,suffix)

fls = paste0('metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')



mapply(function(start,end) {
  if(!file.exists(paste0('metadata/ceqa_month_csvs/ceqa_',start,'.csv'))){
  url = paste0(base,start,fill,end,suffix)
  print(url)
  download.file(url,destfile = paste0('metadata/ceqa_month_csvs/ceqa_',start,'.csv'))
}},start = start_months,end = end_months)



