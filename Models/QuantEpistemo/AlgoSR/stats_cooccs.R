
# lexical statistics on results corpuses

setwd('/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR')

d1 <- read.csv('junk/refs_city+system+network_16_keywords.csv',header=TRUE,sep='\t')
d1[,1]
d1[,6] # score : 6th column (normilzed by doc frequency)
d1[,9]

# all files
files <- c('city+system+network_16','land+use+transport+interaction_8',
           'network+urban+modeling_17','population+density+transport_14',
           'transportation+network+urban+growth_14'
           )

kw <- c('city+system+network','land+use+transport+interaction',
           'network+urban+modeling','population+density+transport',
           'transportation+network+urban+growth'
)

# compute lexical distances
n=length(files)

# get data
d=list()
scores = matrix(0,100,n)
for(i in 1:n){
  m=read.csv(paste0('junk/refs_',files[i],'_keywords.csv'),header=TRUE,sep='\t')
  d[[i]]=m
  scores[,i]=as.numeric(gsub(",", ".",levels(m[,9])))[m[,9]]
}

# res
res=matrix(0,n,n)
count =matrix(0,n,n)

for(i in 1:n){
  for(j in 1:n){
    show(j)
    if(i != j){
    for(k in 1:100){
      for(l in 1:100){
        if(as.character(d[[i]][k,1])==as.character(d[[j]][l,1])){
          res[i,j] = res[i,j] +scores[k,i]+scores[l,j]
          count[i,j] = count[i,j]+1
        }
      }
      
    }
    }
    res[i,j] = res[i,j] / (sum(scores[,i]) + sum(scores[,j]))
  }
}


for(i in 1:n){
  show(sum(scores[,i]))
}

############
# QuickNDirty : histogram

par(mfrow=c(5,1))
for(c in  1:n){
  hist(as.numeric(gsub(",", ".",levels(d[[c]][,6]))),breaks=30,xlab= kw[c],main="")
}










###############
## QuickNDirty is back :: graph vizualization ?







