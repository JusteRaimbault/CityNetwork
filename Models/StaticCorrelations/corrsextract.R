setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

purpose='chinacoupled_areasize100_offset50_factor0.1_temp'

rhoasizes=seq(from=4,to=20,by=4)

load(paste0('res/res/20170727_parallcorrs_',purpose,'.RData'))

corrs = parallcorrs[[3]]$corrs
save(corrs,file=paste0('res/res/20170727_parallcorrs_',purpose,'_rhoasize12.RData'))

