libs = c('tidyverse','data.table','rvest','lubridate','curl','pbapply')
need = libs[!libs %in% installed.packages()[,'Package'] ]
lapply(need,install.packages)
lapply(libs,require,character.only = T)

current <- Sys.Date()
date_seq <- seq(ymd('2000-01-01'),current,by="1 months")
start_months <- date_seq
end_months = date_seq + months(1) - days(1)

base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months)
fls = paste0('ceqanet_raw/metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')

project_issues ='https://ceqanet.opr.ca.gov/Search/Advanced' %>% read_html() %>% html_nodes('#ProjectIssue') %>% html_nodes('option') %>% html_text(trim = T)
result_file = 'ceqanet_raw/metadata/sch_project_issues.csv'
project_issues = project_issues[project_issues!='(Any)']
id_vars <- c('SCH Number','Received','Type')

if(file.exists(result_file)){full_tdf = fread(result_file);full_tdf[!duplicated(full_tdf),]}else{full_tdf = data.table()}
if(nrow(full_tdf)>0){
project_issues = project_issues[!project_issues%in%full_tdf$`Project Issue`]
}

for(i in seq_along(project_issues)){
print(project_issues[i])
u_encodes = sapply(paste(rl,'&ProjectIssue=',project_issues[i],sep = ''),URLencode)
tab_list = pblapply(u_encodes,function(x) x %>% read_html() %>% html_nodes('table') %>% html_table(trim = T),cl = 6)
tab_list = tab_list[sapply(tab_list,function(x) length(x))>0]
if(length(tab_list)==0){next}
tdf = rbindlist(lapply(tab_list,function(x) x[[1]]),fill = T)
tdf <- tdf[,(id_vars),with = F]
tdf$`Project Issue` <- project_issues[i]
tdf = tdf[!duplicated(tdf),]
if(file.exists(result_file)){fwrite(tdf,result_file,append = T)}else{fwrite(tdf,result_file)}
}

