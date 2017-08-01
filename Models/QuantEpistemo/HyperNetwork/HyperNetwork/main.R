
##

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork'))

source('networkConstruction.R')

args <- commandArgs(trailingOnly = F)
task = args[4]
show(paste0('Running ',task,'...'))

#mongobase = 'nwterrit'
mongobase='modelography'
#kwLimit = 10000
kwLimit=1000
#eth = 5
eth=0
#eth_graph = 10
eth_graph=5

if(task=='--semantic-construction'){
  #mongo <- mongoDbConnect('nwterrit','127.0.0.1',27017)
  options( java.parameters = "-Xmx4G" ) # to ensure large edge queries
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
  kmaxvals=seq(from=500,to=7000,by=500)
  ethvals=c(seq(from=10,to=50,by=5),seq(from=60,to=100,by=10))
  dir.create('sensitivity')
  outputfile=paste0('sensitivity/',graphfile,'.RData')

  networkSensitivity(db,filters,freqmaxvals,freqminvals,kmaxvals,ethvals,outputfile)
  
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




