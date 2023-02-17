#### note: the big reason this scraper is silly is because of return restrictions on CEQAnet queries
# namely, the way to make sure we get everything is to chop up by local action and small date chunks
### CEQAnet will return up to a 10k csv

libs = c('tidyverse','data.table','rvest','lubridate','curl','pbapply')
need = libs[!libs %in% installed.packages()[,'Package'] ]
lapply(need,install.packages)
lapply(libs,require,character.only = T)

overwrite = F
local_actions ='https://ceqanet.opr.ca.gov/Search/Advanced' %>% read_html() %>% html_nodes('#LocalAction') %>% html_nodes('option') %>% html_text(trim = T)
result_file = 'ceqanet_raw/metadata/sch_local_actions.csv'
local_actions = local_actions[local_actions!='(Any)']

if(file.exists(result_file)){full_tdf = fread(result_file);full_tdf[!duplicated(full_tdf),]}else{full_tdf = data.table()}
if(nrow(full_tdf)>0){
  local_actions = local_actions[!local_actions%in%full_tdf$`Local Action`]
}

id_vars <- c('SCH Number','Received','Document Type')


current = paste(month(Sys.Date()),'01',year(Sys.Date()),sep = '/')
start_months = mdy(current) - months(1:(45 * 12))
end_months = start_months + months(1)
base = 'https://ceqanet.opr.ca.gov/Search?'

start_date = 'StartRange='
fill = '&EndRange='
add_year <- function(url,start,end){paste0(url,'&StartRange=',start,'&EndRange=',end)}

suffix = '&OutputFormat=CSV'

start_year <- 1975
start_date <- as.Date(paste0(start_year,"-01-01"))
end_date <- Sys.Date()

for(i in seq_along(local_actions)){
  print(local_actions[i])
  u_encode = URLencode(paste(base,'LocalAction=',local_actions[i],sep = ''))
  ht <- read_html(u_encode)
  docs_found <- ht %>% html_nodes('p+ p') %>% html_text(trim = T) 
  total_docs <- as.numeric(str_remove_all(str_extract(docs_found,'^.*document'),'[^0-9]'))
  print(paste(total_docs, 'documents found'))
  if(total_docs<=10e3){
    tab <- fread(paste0(u_encode,"&OutputFormat=CSV"))
    tab <- tab[,id_vars,with = F]
  }else{
    print(paste('creating date grid for action:',local_actions[i]))
    init_grid <- data.table(start = start_date,end = end_date,elements = total_docs)
    while(any(init_grid$elements>10e3)){
      shorten <- which(init_grid$elements>=10e3)
      fix <- init_grid[shorten[1],]
      init_grid <- init_grid[-shorten[1],]
      #seconds_long <- interval(fix$start,fix$end) %/% seconds(2)
      start <- seq(fix$start,fix$end,length.out = 3)
      new_seq = data.frame(start = start[1:2],end = start[2:3],elements = NA)
      #print(new_seq)
      year_filters <- add_year(start = new_seq$start,end = new_seq$end,url = u_encode)
      year_filters <- URLencode(year_filters)
      totals <- unlist(lapply(year_filters,function(x) {
        ht <- read_html(x)
        docs_found <- ht %>% html_nodes('p+ p') %>% html_text(trim = T) 
        total_docs <- as.numeric(str_remove_all(str_extract(docs_found,'^.*document'),'[^0-9]'))
        total_docs}))
      new_seq$elements <- totals
      init_grid <- rbind(init_grid,new_seq)
      init_grid <- init_grid[order(start),]
    }
    year_filters <- add_year(start = init_grid$start,end = init_grid$end,url = u_encode)
    year_filters <- URLencode(year_filters)
    tab_list <- lapply(year_filters,function(x) {
      print(x)
      tab <- fread(paste0(x,"&OutputFormat=CSV"))
      tab <- tab[,id_vars,with = F]
      tab})
    tab <- rbindlist(tab_list)
  }
  #if(length(tab_list)==0){tdf = data.table(`SCH Number`=NA,local_action =local_actions[i])}else{
  if(nrow(tab)>0){
    tab$local_action <- local_actions[i]
    tab = tab[!duplicated(tab),]
    if(file.exists(result_file)&!overwrite){fwrite(tab,result_file,append = T)}else{if(i ==1){fwrite(tab,result_file)}else{fwrite(tab,result_file,append = T)}}
  }
  rm(tab)
  Sys.sleep(5)
}

