
# employment datapreprocessing

library(dplyr)
library(readODS)

areas <- as.tbl(read.csv(file=paste0(Sys.getenv('CN_HOME'),'/Models/Governance/MetropolSim/Lutecia/setup/gis/guangdong/stylized/data.csv'),sep=";",stringsAsFactors=F))

guangdong <- as.tbl(read.csv(file=paste0(Sys.getenv('CN_HOME'),'/Data/China/guangdong.csv'),sep=";",stringsAsFactors = F))

joined = left_join(areas,guangdong[,c(1,9,10)],by=c("code"="Code.Agglo2010"))
joined$totalEmp = joined$Primary.Secondary+joined$Tertiary

# extrapolate missing cities

# scaling law of pib.hab or employments ?
plot(log(joined$pop2010),log(joined$totalEmp))

summary(lm(totalEmp~pop2010,data = joined))
summary(lm(log(totalEmp)~log(pop2010),data = joined))
#summary(lm(totalEmp~log(pop2010),data = joined))
summary(lm(Primary.Secondary~pop2010,data = joined))
summary(lm(Tertiary~pop2010,data = joined))
summary(lm(log(Primary.Secondary)~log(pop2010),data = joined))
summary(lm(log(Tertiary)~log(pop2010),data = joined))


loglm = lm(log(Primary.Secondary)~log(pop2010),data = joined)
summary(loglm)
joined$Primary.Secondary[is.na(joined$Primary.Secondary)] =exp(loglm$coefficients[1]+ loglm$coefficients[2]*log(joined$pop2010[is.na(joined$Primary.Secondary)]))

loglm = lm(log(Tertiary)~log(pop2010),data = joined)
summary(loglm)
joined$Tertiary[is.na(joined$Tertiary)] =exp(loglm$coefficients[1]+ loglm$coefficients[2]*log(joined$pop2010[is.na(joined$Tertiary)]))

# export
write.table(joined,file=paste0(Sys.getenv('CN_HOME'),'/Models/Governance/MetropolSim/Lutecia/setup/gis/guangdong/stylized/data.csv'),sep = ";",quote=F,row.names = F,col.names = T)







