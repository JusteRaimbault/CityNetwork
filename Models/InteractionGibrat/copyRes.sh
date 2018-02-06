
# copy last file from calibration to calibres
# ALL folders in calibration, to simplify

# ls calibration/20171122_calibperiod_island_abstractnw_grid/1831-1851/ | awk -F"." '{print $1}' | awk -F"n" '{print $2}'|sort -n | tail -n 10 | awk '{print "calibration"$0".csv"}'

#TARGET=$1
#mkdir calibres/$TARGET

#ls calibration | awk '{print "ls calibration/"$0}' | sh

ls -d -1 $PWD/calib/* > dirs

# create target dirs
cat dirs | awk -F"/" '{print "mkdir calibration/"$NF}' | sh

# copy files

while read p; do
  echo $p
  IFS='/' read -r -a array <<< "$p"
  DIR="${array[-1]}"
  echo $DIR
  ls $p | awk -F"." '{print $1}' | awk -F"n" '{print $2}'|sort -n | tail -n 1 | awk '{print "cp '$p'/population"$0".csv calibration/'$DIR'"}' | sh
done < dirs

rm dirs

