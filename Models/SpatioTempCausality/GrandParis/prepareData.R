setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/GrandParis'))

library(dplyr)



#bien <- as.tbl(read.csv(file = paste0(Sys.getenv('CN_HOME'),'/Data/BIEN/BIEN_min-noquote.csv'),stringsAsFactors = F))
#bien$REQ_PRIX=as.numeric(bien$REQ_PRIX)
#bien$MTCRED=as.numeric(bien$MTCRED)

# a lot of transactions only after 2003, begin in 2003

#nrow(bien[bien$annee%in%years])
#length(unique(bien$IRIS)) -> 5417
# filter on existing iris
#bien=bien[sapply(bien$IRIS,nchar)==9&!is.na(bien$REQ_PRIX),]

#transactions <- bien[bien$annee%in%years,] %>% group_by(annee,IRIS) %>% summarise(price=mean(REQ_PRIX,na.rm=T),credit=mean(MTCRED,na.rm=T),count=length(which(!is.na(REQ_PRIX))))
#transactions$annee = sapply(as.character(transactions$annee),function(s){substr(s,3,4)})
#save(transactions,file='data/transactions.RData')



# population
popyears = c(paste0("0",c(1:2,4:9)),"10","11")
pops = data.frame();incomes=data.frame();ginis=data.frame()
for(year in popyears){
  currentdata = read.table(file=paste0('data/pop/revenus',year,'.csv'),sep=";",header=T,stringsAsFactors = F,dec = ',')
  pops=rbind(pops,data.frame(id=as.character(currentdata$IRIS),var=currentdata[,paste0("NBUC",year)],year = rep(year,nrow(currentdata))))
  incomes=rbind(incomes,data.frame(id=as.character(currentdata$IRIS),var=currentdata[,paste0("RFUCQ2",year)],year = rep(year,nrow(currentdata))))
  ginis=rbind(ginis,data.frame(id=as.character(currentdata$IRIS),var=currentdata[,paste0("RFUCGI",year)],year = rep(year,nrow(currentdata))))
}
pops$year=as.character(pops$year);incomes$year=as.character(incomes$year);ginis$year=as.character(ginis$year);
pops$id=as.character(pops$id);incomes$id=as.character(incomes$id);ginis$id=as.character(ginis$id);


# employments : communeBP -> EMP2006
communesBP <- readOGR('data/gis','communesBP')
employment <- data.frame(id=communesBP$INSEE_COM,var=communesBP$EMP2006)
employment$id=as.character(employment$id)

# iris
iris <- readOGR('data/gis','irisidf')
communes <- readOGR('data/gis','communes')

save(pops,incomes,ginis,communesBP,employment,iris,communes,file='data/socioeco.RData')


