
library(raster)
library(rgdal)

#r=raster(nrows=floor((latmax-latmin)*2000),ncols=floor((lonmax-lonmin)*2000),xmn=lonmin,xmx=lonmax,ymn=latmin,ymx=latmax,crs=crs(densraster))
#densraster=r



densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/China/PopulationGrid_China2010/PopulationGrid_China2010.tif"))
#densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))

ext =extent(densraster)
xmin=ext@xmin;xmax=ext@xmax;ymin=ext@ymin;ymax=ext@ymax
wgs84=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
wgs84extent = extent(spTransform(SpatialPoints(matrix(data=c(xmin,ymin,xmax,ymax),ncol=2,byrow=T),crs(densraster)),wgs84))

r = raster(wgs84extent,nrow=nrow(densraster)*10,ncol=ncol(densraster)*10,crs=wgs84)
