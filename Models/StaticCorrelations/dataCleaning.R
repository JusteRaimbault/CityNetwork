
load('res/res/20160826_parallcorrs_corrTest_unlisted.RData')

show('data loaded...')

rows=apply(allcorrs[,1:6],1,function(r){prod(as.numeric(!is.na(r)))>0})
allcorrs=allcorrs[rows,]

save(allcorrs,file='res/res/20160826_parallcorrs_corrTest_unlisted_nona.RData')



