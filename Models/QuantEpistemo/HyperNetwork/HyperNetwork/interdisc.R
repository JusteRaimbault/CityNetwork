

# (following sensitivity)

sub<-extractSubGraphCommunities(raw,kminopt,kmaxopt,freqminopt,freqmaxopt,ethopt)
coms=sub$com

load(paste0('processed/',mongobase,'_probas_',kwLimit,'_eth',eth_graph,'_nonfiltdico_kmin',kminopt,'_kmax',kmaxopt,'_freqmin',freqminopt,'_freqmax',freqmaxopt,'_eth',ethopt))

# content of communities










