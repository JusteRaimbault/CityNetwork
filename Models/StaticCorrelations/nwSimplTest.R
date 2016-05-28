
# testing NW simplification

library(RPostgreSQL)
library(rgeos)

con = dbConnect(dbDriver("PostgreSQL"), dbname="osm_simpl",user="Juste",host="localhost" )

query = dbSendQuery(con,"SELECT ST_AsText(geography) AS geom FROM links;")
data = fetch(query,n=-1)
geoms = data$geom

roads=list()
for(i in 1:length(geoms)){
  r=readWKT(geoms[i])@lines[[1]];r@ID=as.character(i)
  roads[[i]]=r
}

splines = SpatialLines(LinesList = roads)

plot(splines)
