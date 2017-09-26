
# test of Chinese data.

d=data.frame()

for(j in 5:8){
  d=rbind(d,data.frame(sort(China[,j],decreasing = TRUE,na.last = TRUE),1:nrow(China),rep(colnames(China)[j],nrow(China))))
}

colnames(d)<-c("size","rank","year")

g=ggplot(d)
g+geom_point(aes(x=log(rank),y=log(size),colour=year))




