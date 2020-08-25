require(data.table)
require(rvest)
require(lubridate)
require(pbapply)
start_months = mdy('01/01/2020') - months(1:(20 * 12))
end_months = start_months + months(1)
base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months)
fls = paste0('metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')

project_issues ='https://ceqanet.opr.ca.gov/Search/Advanced' %>% read_html() %>% html_nodes('#ProjectIssue') %>% html_nodes('option') %>% html_text(trim = T)
result_file = '../../../Box/klamath/input/sch_project_issues.csv'
project_issues = project_issues[project_issues!='(Any)']


if(file.exists(result_file)){full_tdf = fread(result_file);full_tdf[!duplicated(full_tdf),]}else{full_tdf = data.table()}
if(nrow(full_tdf)>0){
project_issues = project_issues[!project_issues%in%full_tdf$`Project Issue`]
}
full_tdf
for(i in seq_along(project_issues)){
print(project_issues[i])
u_encodes = sapply(paste(rl,'&ProjectIssue=',project_issues[i],sep = ''),URLencode)
tab_list = pblapply(u_encodes,function(x) x %>% read_html() %>% html_nodes('table') %>% html_table(trim = T),cl = 6)
tab_list = tab_list[sapply(tab_list,function(x) length(x))>0]
if(length(tab_list)==0){next}
tdf = rbindlist(lapply(tab_list,function(x) x[[1]]),fill = T)[,.(`SCH Number`)]
tdf$`Project Issue` <- project_issues[i]
tdf = tdf[!duplicated(tdf),]
if(file.exists(result_file)){fwrite(tdf,result_file,append = T)}else{fwrite(tdf,result_file)}
}

