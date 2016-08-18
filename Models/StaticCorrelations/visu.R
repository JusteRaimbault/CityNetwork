

gg = ggplot(v)
gg+geom_raster(aes(x=lonmin,y=latmin,fill=vcount))+scale_color_continuous(low='yellow',high='red')



#################

library(rasterVis)

layers = list()
for(j in 3:ncol(v)){
  r=raster(SpatialPixels(SpatialPoints(v[,c(1,2)])))
  layers[[colnames(v)[j]]] = setValues(r,(v[,j]-min(v[,j]))/(max(v[,j])-min(v[,j])),index=cellFromXY(r,v[,c(1,2)]))
}

levelplot(stack(layers))



