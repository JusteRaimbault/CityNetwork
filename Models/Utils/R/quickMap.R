

library(rgdal)
library(cartography)

# load data

dep <- readOGR(paste0(Sys.getenv('CS_HOME'),'/Misc/Anto/departements-20140306-100m-shp'),'departements-20140306-100m',stringsAsFactors = F)
data = read.csv(file=paste0(Sys.getenv('CS_HOME'),'/Misc/Anto/cd.csv'),sep=';',stringsAsFactors = F)
data$id = ifelse(sapply(as.character(data$dept),nchar)>=2,as.character(data$dept),paste0("0",as.character(data$dept)))

# select your deps (france métropolitaine ?)
#dep = dep[sapply(dep$code_insee,nchar)==2,]
dep = dep[dep$code_insee%in%data$id,]
# -> pas besoin de faire la jointure à la main, la primitive de carto le fait

# palette de couleur, nb de classes doit correspondre à celui dans le choroLayer
cols <- carto.pal(pal1 = "green.pal", n1 = 5, pal2 = "red.pal",n2 = 5) 

#plot(dep, border = NA, col = NA, bg = "#A6CAE0")
png(file=paste0(Sys.getenv('CS_HOME'),'/Misc/Anto/map.png'),width = 13,height=10,units='cm',res = 300)
par(mar=c(1.5,1.5,1.5,1.5))

choroLayer(spdf = dep,df = data,var = "CD_emp",
          spdfid = "code_insee",dfid="id",nclass = 10,
           col = cols,border = "grey40",lwd = 0.5, legend.pos = "left",
           legend.title.txt = "Legend Title",legend.values.rnd = 2,legend.nodata = "No Data"
          # ,add = TRUE
          )

plot(dep,border = "grey20", lwd=0.75, add=TRUE)

layoutLayer(title = "Map Title", author = "", 
            sources = "", frame = TRUE, 
            scale = NULL,coltitle = "white",
            south = F,north = T,col="black")

dev.off()
