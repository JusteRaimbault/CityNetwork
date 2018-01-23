options( java.parameters = "-Xmx128G" ) # to ensure large edge queries

##

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork'))

source('networkConstruction.R')

args <- commandArgs(trailingOnly = F)
task = args[4]
show(paste0('Running ',task,'...'))

#mongobase = 'nwterrit'
#mongobase='modelography'
#mongobase='urbangrowth'
mongobase='reflexivity'
#kwLimit = 10000
kwLimit=50000
eth = 5
#eth=10
#eth_graph = 10
eth_graph=10

if(task=='--semantic-construction'){
  #mongo <- mongoDbConnect('nwterrit','127.0.0.1',27017)
  #mongo <- mongoDbConnect('modelography','127.0.0.1',27017)
  mongo <- mongoDbConnect(mongobase,'127.0.0.1',27017)
  ####
  ## Construct the semantic nw
  #   mongo -> RData
  relevantcollection = paste0('relevant_',kwLimit)
  kwcollection = 'keywords'
  nwcollection = paste0('network_',kwLimit,'_eth',eth)
  dir.create('processed')
  target = paste0('processed/',mongobase,'_network_',kwLimit,'_eth',eth_graph,'_nonfiltdico')
  constructSemanticNetwork(relevantcollection,kwcollection,nwcollection,eth_graph,target,mongo)
}


if(task=='--semantic-sensitivity'){
  ####
  ## Sensitivity of the semantic nw

  source('semsensitivity.R')
  graphfile=paste0(mongobase,'_network_',kwLimit,'_eth',eth_graph,'_nonfiltdico')
  filters=c()#c('data/filter.csv','data/french.csv')
  freqmaxvals=c(10000)
  freqminvals=c(0,5)
  kmaxvals=seq(from=500,to=10000,by=500)
  ethvals=c(seq(from=5,to=100,by=10))#,seq(from=60,to=100,by=10))
  dir.create('sensitivity')
  outputfile=paste0('sensitivity/',graphfile,'.RData')

  networkSensitivity(graphfile,filters,freqmaxvals,freqminvals,kmaxvals,ethvals,outputfile)
  
}

# -> etablish the optimal parameters
# relevant_full_50000_eth50_nonfiltdico_kmin0_kmax1200_freqmin50_freqmax10000_eth100


if(task=='--semantic-probas'){
  
}




if(task=='--semantic-export'){

######
#  export

source('semexport.R')

  nkws='50000'
  eth_0 = '50'
  eth = '100'
  kmin = '0'
  kmax = '1200'
  freqmin = '50'
  freqmax = '10000'
  eth = '100'

  exportData(nkws,eth_0,eth,kmin,kmax,freqmin,freqmax,eth)

}




