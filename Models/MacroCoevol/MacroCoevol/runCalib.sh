cat periods| awk '{print "head -n 50 CalibPeriod.oms > Calib"$0".oms ; echo '\''val currentperiod = \""$0"\"'\'' >> Calib"$0".oms ; tail -n 60 CalibPeriod.oms >> Calib"$0".oms ; openmole --script Calib"$0".oms --password-file omlpsswd --mem 128G"}'|sh
