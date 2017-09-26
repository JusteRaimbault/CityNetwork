cd exploration
# header
ls | grep "GRIDLHS" | head -n 1 | awk '{print "head -n 1 "$0" > GRIDLHS_ALL.csv"}'| sh
# all files
ls | grep "GRIDLHS"|grep -v "GRIDLHS_ALL" | awk '{print "tail -n +2 "$0" >> GRIDLHS_ALL.csv"}'| sh

