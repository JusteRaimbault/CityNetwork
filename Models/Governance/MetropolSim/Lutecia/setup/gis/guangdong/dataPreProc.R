
# employment datapreprocessing

library(dplyr)
library(readODS)
library(rgdal)

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



####
# join with gis layer

data <- as.tbl(read.csv(file=paste0(Sys.getenv('CN_HOME'),'/Models/Governance/MetropolSim/Lutecia/setup/gis/guangdong/stylized/data.csv'),sep = ";",header=T))
data$nameZH <- c("深圳","斗门","香洲","广州","诰命","江门","信汇","开平","河山",
                 "肇庆","撕毁","会城","会养","徽州","中山","东莞")


areas <- readOGR(paste0(Sys.getenv('CN_HOME'),'/Models/Governance/MetropolSim/Lutecia/setup/gis/guangdong/stylized'),'areas')
areas$id <- as.numeric(as.character(areas$id))

areas@data <- left_join(areas@data,data,by=c("id"="id"))

writeOGR(obj = areas,dsn = paste0(Sys.getenv('CN_HOME'),'/Models/Governance/MetropolSim/Lutecia/setup/gis/guangdong/stylized'),layer = 'areas_data',driver = "ESRI Shapefile")






