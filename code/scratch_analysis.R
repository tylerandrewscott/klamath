
require(data.table)



test = lapply(list.files(),fread(sep =),sep = '\t')

v1 = unique(test[[1]]$FIN..SCH.Number..duplicated.FIN..SCH.Number...)
v2 = unique(test[[2]]$MND..SCH.Number..duplicated.MND..SCH.Number...)
v3 = unique(test[[3]]$NEG..SCH.Number..duplicated.NEG..SCH.Number...)
v4 = unique(test[[4]]$NOE..SCH.Number..duplicated.NOE..SCH.Number...)

tt = Reduce(union,list(v1,v2,v3,v4))





v1


for(i in test){
  names(i)<<-c('index','SCH')
}



ceqa_mnd = fread('../../Box/klamath/input/ceqa_MND.csv')
ceqa_mnd = ceqa_mnd[!duplicated(ceqa_mnd),]
ceqa_neg = fread('../../Box/klamath/input/ceqa_NEG.csv')
ceqa_neg = ceqa_neg[!duplicated(ceqa_neg),]
ceqa_fin = fread('../../Box/klamath/input/ceqa_FIN.csv')
ceqa_fin = ceqa_fin[!duplicated(ceqa_fin),]
ceqa_noe = fread('../../Box/klamath/input/ceqa_NOE.csv')
ceqa_noe = ceqa_noe[!duplicated(ceqa_noe),]

tt = rbindlist(list(ceqa_fin,ceqa_mnd,ceqa_neg,ceqa_noe))
ff = tt[,.(`SCH Number`,`Document Type`)]
vv = dcast(ff,`SCH Number`~`Document Type`)
cc = vv[rowSums(vv[,-c('SCH Number')])>1,]


cc[rowSums(cc[,-c('SCH Number')]>1)>1,]



vv


dim(ceqa_noe)


ceqa_fin[duplicated(ceqa_fin),]

rbindlist(test,use.names = T)



test[,.N,by=.(SCH)]
unique(test$FIN..SCH.Number..duplicated.FIN..SCH.Number...)

mnd_dup = fread('mnd.duplicated.txt'
net_dup = fread('neg.duplicated.txt')

ceqa = rbind(ceqa_mnd,ceqa_neg,use.names = T,fill = T)

test = dcast(ceqa[,.N,by=.(`Document Type`,`SCH Number`)][order(-`SCH Number`),],`SCH Number` ~ `Document Type`)


test[!is.na(MND)&!is.na(NEG),]

ceqa[ceqa$`SCH Number`=='2017101045',]



ceqa = ceqa[!duplicated(ceqa),]

ceqa$dup = ceqa$`SCH Number` %in% mnd_dup$MND..SCH.Number..duplicated.MND..SCH.Number...|
  ceqa$`SCH Number` %in% net_dup$NEG..SCH.Number..duplicated.NEG..SCH.Number...
ceqa = ceqa[dup==T,]

cq = ceqa[,.(`SCH Number`,Received,`Document Type`)]
cq[order(`SCH Number`,Received),]

ceqa[ceqa$`SCH Number`=='1989052316',]



table(duplicated(ceqa))


table(ceqa$`Document Type`)

