
d <- function(w){
  years = c(1,8,17)
  dispo = c(27,5 + w * 10,3+w)
  return(data.frame(x=years,y=dispo,xl=log(years),yl=log(dispo)))
}

weights = (1:100)/100

rlin = c()
rloglin = c()

for(w in weights){
  rlin = append(rlin,summary(lm(y~x,d(w)))$adj.r.squared)
  rloglin = append(rloglin,summary(lm(yl~xl,d(w)))$adj.r.squared)
}

