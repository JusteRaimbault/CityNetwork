cat data/20170522_174903_grid_realnonw.csv | awk -F"," '{if(NF==229){print $0}}' > data/20170522_174903_grid_realnonw_full.csv 

