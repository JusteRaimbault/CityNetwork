ps -ef | grep /opt/local/bin/tor | grep -v grep | awk -F" " '{print "kill -9 "$2}' | sh
