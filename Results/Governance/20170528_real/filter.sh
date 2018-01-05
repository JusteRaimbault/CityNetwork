cat data/20170528_225855_grid_real.csv | awk -F"," '{if(NF==229){print $0}}' > data/20170528_grid_real_full.csv

