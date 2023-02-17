#### note: the big reason this scraper is silly is because of return restrictions on CEQAnet queries
# namely, the way to make sure we get everythign is to chop up by reviewing agency and small date chunks

libs = c('tidyverse','data.table','rvest','lubridate','curl','pbapply')
need = libs[!libs %in% installed.packages()[,'Package'] ]
lapply(need,install.packages)
lapply(libs,require,character.only = T)

overwrite = F

reviewing_agencies ='https://ceqanet.opr.ca.gov/Search/Advanced' %>% read_html() %>% html_nodes('#StateReviewAgency') %>% html_nodes('option') %>% html_text(trim = T)
result_file = 'ceqanet_raw/metadata/sch_reviewing_agencies.csv'
reviewing_agencies = reviewing_agencies[reviewing_agencies!='(Any)']

if(file.exists(result_file)&!overwrite){full_tdf = fread(result_file);full_tdf <- full_tdf[!duplicated(full_tdf),]}else{full_tdf = data.table()}
if(nrow(full_tdf)>0){
reviewing_agencies = reviewing_agencies[!reviewing_agencies%in%full_tdf$`Reviewing Agency`]
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
rl = paste0(base,start_months,fill,end_months)
fls = paste0('ceqanet_raw/metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')

start_year <- 1975
start_date <- as.Date(paste0(start_year,"-01-01"))
end_date <- Sys.Date()

for(i in seq_along(reviewing_agencies)){
  print(reviewing_agencies[i])
  u_encode = URLencode(paste(base,'StateReviewAgency=',reviewing_agencies[i],sep = ''))
  ht <- read_html(u_encode)
  docs_found <- ht %>% html_nodes('p+ p') %>% html_text(trim = T) 
  total_docs <- as.numeric(str_remove_all(str_extract(docs_found,'^.*document'),'[^0-9]'))
  print(paste(total_docs, 'documents found'))
  if(total_docs<=10e3){
    tab <- fread(paste0(u_encode,"&OutputFormat=CSV"))
    tab <- tab[,id_vars,with = F]
  }else{
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
  #if(length(tab_list)==0){tdf = data.table(`SCH Number`=NA,`Reviewing Agency` =reviewing_agencies[i])}else{
  if(nrow(tab)>0){
    tab$`Reviewing Agency` <- reviewing_agencies[i]
    tab = tab[!duplicated(tab),]
    if(file.exists(result_file)&!overwrite){fwrite(tab,result_file,append = T)}else{if(i ==1){fwrite(tab,result_file)}else{fwrite(tab,result_file,append = T)}}
  }
  rm(tab)
  Sys.sleep(5)
}

