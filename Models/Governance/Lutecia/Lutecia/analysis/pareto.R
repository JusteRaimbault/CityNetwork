

paretoOptim <- function(a1,a2,b,c1,c2){
  f1 = function(p1,p2){a1*p1*p2 + b*p1 + c1}
  f2 = function(p1,p2){a2*p1*p2 + b*p2 + c2}
  x=c();y=c()
  for(p1 in seq(from=0.0,to=1.0,by=0.01)){
    for(p2 in seq(from=0.0,to=1.0,by=0.01)){
      x=append(x,f1(p1,p2));y=append(y,f2(p1,p2))
    }
  }
  return(data.frame(x,y))
}

d = paretoOptim(-1,-1,1,0.0,1.0)

plot(d$x,d$y)
