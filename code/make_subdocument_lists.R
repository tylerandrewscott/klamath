libs = c('tidyverse','data.table','rvest','lubridate','pbapply')
need = libs[!libs %in% installed.packages()[,'Package'] ]
lapply(need,install.packages)
lapply(libs,require,character.only = T)



system('ln -s ~/Box/klamath/input/ ~/Documents/GitHub/klamath/')
fls = list.files('input/ceqa_month_csvs/',full.names = T,recursive = T)
flist = pblapply(fls,fread,cl = 6)

temp_dt = rbindlist(flist,use.names = T, fill = T)
temp_docs = dcast(temp_dt[,.(`SCH Number`,`Document Type`)][,.N,by=.(`SCH Number`,`Document Type`)],`SCH Number` ~ `Document Type`,fill = 0)
fwrite(temp_docs,'input/project_doctype_incidence_matrix.csv')


#rownames(temp_docs) <- temp_docs$`SCH Number`
#check out co-occurence
crossprod(as.matrix(temp_docs[,.(EIR,FIN,MND,NEG,NOD,NOE)]))

fin = temp_dt[`Document Type`=='EIR']
fin[,`NOC Project Issues`:=NULL]
fin[,`NOC Local Action`:=NULL]
saveRDS(fin,'input/ceqa_EIR.rds')


mnd = temp_dt[`Document Type`=='MND']
mnd[,`NOC Project Issues`:=NULL]
mnd[,`NOC Local Action`:=NULL]
saveRDS(mnd,'input/ceqa_MND.rds')

neg = temp_dt[`Document Type`=='NEG']
neg[,`NOC Project Issues`:=NULL]
neg[,`NOC Local Action`:=NULL]
saveRDS(neg,'input/ceqa_NEG.rds')

noe = temp_dt[`Document Type`=='NOE']
noe[,`NOC Project Issues`:=NULL]
noe[,`NOC Local Action`:=NULL]
saveRDS(noe,'input/ceqa_NOE.rds')


temp = temp[`Document Type` %in% c('NEG','MND','NOD')]
temp$`SCH Number`[temp$`Document Type`=='NOD']

table(temp$`Document Type`)

base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months)
fls = paste0('metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')
