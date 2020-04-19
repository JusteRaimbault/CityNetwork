


summarize_nwcormat <- function(d){
  return(
    d %>% summarise(
      cor12 = cor(meanBwCentrality,meanPathLength),
      cor13 = cor(meanBwCentrality,meanRelativeSpeed),
      cor14 = cor(meanBwCentrality,nwDiameter),
      cor23 = cor(meanPathLength,meanRelativeSpeed),
      cor24 = cor(meanPathLength,nwDiameter),
      cor34 = cor(meanRelativeSpeed,nwDiameter)
    )
  )
}


summarize_nwcormatmin <- function(d){
  return(
    d %>% summarise(
      cor12min = cor.test(meanBwCentrality,meanPathLength,method="pearson",conf.level=0.95)$conf.int[1],
      cor13min = cor.test(meanBwCentrality,meanRelativeSpeed,method="pearson",conf.level=0.95)$conf.int[1],
      cor14min = cor.test(meanBwCentrality,nwDiameter,method="pearson",conf.level=0.95)$conf.int[1],
      cor23min = cor.test(meanPathLength,meanRelativeSpeed,method="pearson",conf.level=0.95)$conf.int[1],
      cor24min = cor.test(meanPathLength,nwDiameter,method="pearson",conf.level=0.95)$conf.int[1],
      cor34min = cor.test(meanRelativeSpeed,nwDiameter,method="pearson",conf.level=0.95)$conf.int[1]
    )
  )
}


summarize_nwcormatmax <- function(d){
  return(
    d %>% summarise(
      cor12max = cor.test(meanBwCentrality,meanPathLength,method="pearson",conf.level=0.95)$conf.int[2],
      cor13max = cor.test(meanBwCentrality,meanRelativeSpeed,method="pearson",conf.level=0.95)$conf.int[2],
      cor14max = cor.test(meanBwCentrality,nwDiameter,method="pearson",conf.level=0.95)$conf.int[2],
      cor23max = cor.test(meanPathLength,meanRelativeSpeed,method="pearson",conf.level=0.95)$conf.int[2],
      cor24max = cor.test(meanPathLength,nwDiameter,method="pearson",conf.level=0.95)$conf.int[2],
      cor34max = cor.test(meanRelativeSpeed,nwDiameter,method="pearson",conf.level=0.95)$conf.int[2]
    )
  )
}


summarize_denscormat <- function(d){
  return(
    d %>% summarise(
      cor12 = cor(moran,distance),
      cor13 = cor(moran,entropy),
      cor14 = cor(moran,slope),
      cor23 = cor(distance,entropy),
      cor24 = cor(distance,slope),
      cor34 = cor(entropy,slope)
    ) 
  )
}

summarize_denscormatmin <- function(d){
  return(
   d %>% summarise(
      cor12min = cor.test(moran,distance,method="pearson",conf.level=0.95)$conf.int[1],
      cor13min = cor.test(moran,entropy,method="pearson",conf.level=0.95)$conf.int[1],
      cor14min = cor.test(moran,slope,method="pearson",conf.level=0.95)$conf.int[1],
      cor23min = cor.test(distance,entropy,method="pearson",conf.level=0.95)$conf.int[1],
      cor24min = cor.test(distance,slope,method="pearson",conf.level=0.95)$conf.int[1],
      cor34min = cor.test(entropy,slope,method="pearson",conf.level=0.95)$conf.int[1]
    ) 
  )
}



summarize_denscormatmax <- function(d){
  return(
   d %>% summarise(
  cor12max = cor.test(moran,distance,method="pearson",conf.level=0.95)$conf.int[2],
  cor13max = cor.test(moran,entropy,method="pearson",conf.level=0.95)$conf.int[2],
  cor14max = cor.test(moran,slope,method="pearson",conf.level=0.95)$conf.int[2],
  cor23max = cor.test(distance,entropy,method="pearson",conf.level=0.95)$conf.int[2],
  cor24max = cor.test(distance,slope,method="pearson",conf.level=0.95)$conf.int[2],
  cor34max = cor.test(entropy,slope,method="pearson",conf.level=0.95)$conf.int[2]
 ) 
  )
}


summarize_crosscorrmat <- function(d){
 return( 
 d%>% summarise(
   cor15 = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$estimate,cor15min = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$conf.int[1],cor15max = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor16 = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$estimate,cor16min = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$conf.int[1],cor16max = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor17 = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$estimate,cor17min = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor17max = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor18 = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$estimate,cor18min = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$conf.int[1],cor18max = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor25 = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$estimate,cor25min = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$conf.int[1],cor25max = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor26 = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$estimate,cor26min = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$conf.int[1],cor26max = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor27 = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$estimate,cor27min = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor27max = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor28 = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$estimate,cor28min = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$conf.int[1],cor28max = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor35 = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$estimate,cor35min = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$conf.int[1],cor35max = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor36 = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$estimate,cor36min = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$conf.int[1],cor36max = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor37 = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$estimate,cor37min = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor37max = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor38 = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$estimate,cor38min = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$conf.int[1],cor38max = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor45 = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$estimate,cor45min = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$conf.int[1],cor45max = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor46 = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$estimate,cor46min = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$conf.int[1],cor46max = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor47 = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$estimate,cor47min = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor47max = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor48 = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$estimate,cor48min = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$conf.int[1],cor48max = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$conf.int[2]
  )
 )
}



rotated_intervals <- function(cormat,corrCols,cormatmin,cormatmax,rotation){
  rcormatmin=matrix(data = 0,nrow=nrow(cormat),ncol=ncol(rotation))
  for(j in 1:ncol(rotation)){rcormatmin[,j]=as.matrix(cormat[,corrCols+ifelse(rotation[,j]>0,1,2)])%*%as.matrix(rotation[,j])}
  rcormatmax=matrix(data = 0,nrow=nrow(cormat),ncol=ncol(rotation))
  for(j in 1:ncol(rotation)){rcormatmax[,j]=as.matrix(cormat[,corrCols+ifelse(rotation[,j]>0,2,1)])%*%as.matrix(rotation[,j])}
  return(list(
    rcormatmin=rcormatmin,
    rcormatmax=rcormatmax
  ))
}




