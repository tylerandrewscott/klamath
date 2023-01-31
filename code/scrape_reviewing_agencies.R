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
rl = paste0(base,start_months,fill,end_months)
fls = paste0('ceqanet_raw/metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')
reviewing_agencies ='https://ceqanet.opr.ca.gov/Search/Advanced' %>% read_html() %>% html_nodes('#StateReviewAgency') %>% html_nodes('option') %>% html_text(trim = T)
result_file = 'ceqanet_raw/metadata/sch_reviewing_agencies.csv'
reviewing_agencies = reviewing_agencies[reviewing_agencies!='(Any)']

if(file.exists(result_file)){full_tdf = fread(result_file);full_tdf <- full_tdf[!duplicated(full_tdf),]}else{full_tdf = data.table()}
if(nrow(full_tdf)>0){
reviewing_agencies = reviewing_agencies[!reviewing_agencies%in%full_tdf$`Reviewing Agency`]
}

id_vars <- c('SCH Number','Received','Type')

for(i in seq_along(reviewing_agencies)){
  print(reviewing_agencies[i])
  u_encodes = sapply(paste(rl,'&ReviewAgency=',reviewing_agencies[i],sep = ''),URLencode)
  tab_list = pblapply(u_encodes,function(x) x %>% read_html() %>% html_nodes('table') %>% html_table(trim = T),cl = 6)
  tab_list = tab_list[sapply(tab_list,function(x) length(x))>0]
#if(length(tab_list)==0){tdf = data.table(`SCH Number`=NA,`Reviewing Agency` =reviewing_agencies[i])}else{
  if(length(tab_list)>0){
    tdf = rbindlist(lapply(tab_list,function(x) x[[1]]),fill = T)[,id_vars,with = F]
    tdf$`Reviewing Agency` <- reviewing_agencies[i]
    tdf = tdf[!duplicated(tdf),]
    if(file.exists(result_file)){fwrite(tdf,result_file,append = T)}else{fwrite(tdf,result_file)}
  }
  Sys.sleep(5)
}

