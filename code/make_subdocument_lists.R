require(data.table)
require(rvest)
require(lubridate)
require(pbapply)
start_months = mdy('01/01/2020') - months(1:(20 * 12))
end_months = start_months + months(1)

system('ln -s ~/Box/klamath/input/ ~/Documents/GitHub/klamath/')
fls = list.files('input/ceqa_month_csvs/',full.names = T,recursive = T)
flist = pblapply(fls,fread,cl = 6)

temp_dt = rbindlist(flist,use.names = T, fill = T)
temp_docs = dcast(temp_dt[,.(`SCH Number`,`Document Type`)][,.N,by=.(`SCH Number`,`Document Type`)],`SCH Number` ~ `Document Type`)

fin = temp_dt[`Document Type`=='FIN']
fin[,`NOC Project Issues`:=NULL]
fin[,`NOC Local Action`:=NULL]
fwrite(fin,'input/ceqa_FIN.csv')

mnd = temp_dt[`Document Type`=='MND']
mnd[,`NOC Project Issues`:=NULL]
mnd[,`NOC Local Action`:=NULL]
fwrite(mnd,'input/ceqa_MND.csv')

neg = temp_dt[`Document Type`=='NEG']
neg[,`NOC Project Issues`:=NULL]
neg[,`NOC Local Action`:=NULL]
fwrite(neg,'input/ceqa_NEG.csv')

noe = temp_dt[`Document Type`=='NOE']
noe[,`NOC Project Issues`:=NULL]
noe[,`NOC Local Action`:=NULL]
fwrite(noe,'input/ceqa_NOE.csv')

table(temp_dt$`Document Type`)


focal_projects = temp_docs[!is.na(FIN),][,.(`SCH Number`,EIR,FIN,NOD,MND,NEG)]
focal_projects = merge(focal_projects,temp_dt)

focal_projects


colSums(!is.na(temp_docs[!is.na(FIN)]))



temp = temp[`Document Type` %in% c('NEG','MND','NOD')]
temp$`SCH Number`[temp$`Document Type`=='NOD']

table(temp$`Document Type`)

base = 'https://ceqanet.opr.ca.gov/Search?StartRange='
fill = '&EndRange='
suffix = '&OutputFormat=CSV'
rl = paste0(base,start_months,fill,end_months)
fls = paste0('metadata/ceqa_month_csvs/ceqa_',start_months,'.csv')
