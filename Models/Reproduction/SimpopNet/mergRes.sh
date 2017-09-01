# header
ls exploration | grep "GRIDLHS" | head -n 1 | awk '{print "head -n 1 "$0" > GRIDLHS_ALL.csv"}'| sh
# all files
ls exploration | grep "GRIDLHS" | awk '{print "tail -n +2 "$0" > GRIDLHS_ALL.csv"}'| sh

