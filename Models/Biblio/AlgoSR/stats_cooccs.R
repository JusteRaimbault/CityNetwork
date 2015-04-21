
# lexical statistics on results corpuses

setwd('/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR')

d1 <- read.csv('junk/refs_city+system+network_16_keywords.csv',header=TRUE,sep='\t')
d1[,1]
d1[,6] # score : 6th column (normilzed by doc frequency)


# all files
files <- c('city+system+network_16','land+use+transport+interaction_8',
           'network+urban+modeling_17','population+density+transport_14',
           'transportation+network+urban+growth_14'
           )

# compute lexical distances
n=length(files)

# get data
d=list()
for(i in 1:n){
  d[[i]]=read.csv(paste0('junk/refs_',files[i],'_keywords.csv'),header=TRUE,sep='\t')
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
          res[i,j] = res[i,j] + as.numeric(d[[i]][k,6])/as.numeric(d[[j]][k,6])
          count[i,j] = count[i,j]+1
        }
      }
    }
    }
  }
}

