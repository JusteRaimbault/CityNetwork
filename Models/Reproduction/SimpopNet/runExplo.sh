
if [ "$1" == "--test" ]
then
  for i in $(seq 0 1 1); do openmole --password-file omlpsswd --script ExploTest.oms; done
  #./mergRes.sh
fi

if [ "$1" == "--run" ]
then
  for i in $(seq 0 1 24); do openmole --password-file omlpsswd --script Exploration.oms; done
  ./mergRes.sh
fi
