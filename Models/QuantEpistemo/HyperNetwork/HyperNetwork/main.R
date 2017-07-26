
##

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork'))

source('networkConstruction.R')

args <- commandArgs(trailingOnly = F)
task = args[4]
show(paste0('Running ',task,'...'))

mongobase = 'nwterrit'
kwLimit = 10000
eth = 5
eth_graph = 10

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
  target = paste0('processed/relevant_full_',kwLimit,'_eth',eth_graph,'_nonfiltdico')
  constructSemanticNetwork(relevantcollection,kwcollection,nwcollection,eth_graph,target,mongo)
}


if(task=='--semantic-sensitivity'){
  ####
  ## Sensitivity of the semantic nw

  source('semsensitivity.R')
  db='relevant_full_50000_eth50_nonfiltdico'
  filters=c('data/filter.csv','data/french.csv')
  freqmaxvals=c(5000,10000,20000)
  freqminvals=c(50,75,100,125,200)
  kmaxvals=seq(from=300,to=1500,by=50)
  ethvals=seq(from=140,to=300,by=20)
  outputfile=paste0('sensitivity/',db,'_ext_local.RData')

  networkSensitivity(db,filters,freqmaxvals,freqminvals,kmaxvals,ethvals,outputfile)

  load('sensitivity/relevant_full_50000_eth50_nonfiltdico_ext_local.RData')
  names(d)[ncol(d)-2]="balance"
  g = ggplot(d) + scale_fill_gradient(low="yellow",high="red")#+ geom_raster(hjust = 0, vjust = 0) 
  plots=list()
  for(indic in c("modularity","communities","components","vertices","density","balance")){
    plots[[indic]] = g+geom_raster(aes_string("degree_max","edge_th",fill=indic))+facet_grid(freqmax~freqmin)
  }
  multiplot(plotlist = plots,cols=3)
}

# -> etablish the optimal parameters
# relevant_full_50000_eth50_nonfiltdico_kmin0_kmax1200_freqmin50_freqmax10000_eth100


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




