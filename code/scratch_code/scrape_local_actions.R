require(data.table)
require(rvest)
require(lubridate)
require(pbapply)
current = paste(month(Sys.Date()),'01',year(Sys.Date()),sep = '/')
start_months = mdy(current) - months(1:(20 * 12))
end_months = start_months + months(1)

base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months)
fls = paste0('metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')

local_actions ='https://ceqanet.opr.ca.gov/Search/Advanced' %>% read_html() %>% html_nodes('#LocalAction') %>% html_nodes('option') %>% html_text(trim = T)
result_file = 'input/sch_local_action.csv'
local_actions = local_actions[local_actions!='(Any)']

if(file.exists(result_file)){full_tdf = fread(result_file);full_tdf[!duplicated(full_tdf),]}else{full_tdf = data.table()}
if(nrow(full_tdf)>0){
local_actions = local_actions[!local_actions%in%full_tdf$`Local Action`]
}

for(i in seq_along(local_actions)){
print(local_actions[i])
u_encodes = sapply(paste(rl,'&LocalAction=',local_actions[i],sep = ''),URLencode)
tab_list = pblapply(u_encodes,function(x) x %>% read_html() %>% html_nodes('table') %>% html_table(trim = T),cl = 6)
tab_list = tab_list[sapply(tab_list,function(x) length(x))>0]
if(length(tab_list)==0){next}
tdf = rbindlist(lapply(tab_list,function(x) x[[1]]),fill = T)[,.(`SCH Number`)]
tdf$`Local Action` <- local_actions[i]
tdf = tdf[!duplicated(tdf),]
if(file.exists(result_file)){fwrite(tdf,result_file,append = T)}else{fwrite(tdf,result_file)}
}

