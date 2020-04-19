ls | awk -F"." '{print $1}' | awk -F"n" '{print "echo `cat "$0".csv |wc -l`\";"$2"\""}'|sh > counts.csv

