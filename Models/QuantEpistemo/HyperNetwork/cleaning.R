
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork'))

file <- read.csv('data/UrbanGrowth/urbangrowth_depth2.csv',sep=';',quote = '"')

# fail to correct : quote plus delimiters in strings, must be done by hand...


