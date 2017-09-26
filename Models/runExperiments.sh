
MODE=$1
BASEDIR=`pwd`
rm logexplo

# simpopnet
cd $CN_HOME/Models/Reproduction/SimpopNet
./runExplo.sh $MODE > logexplo
cd $BASEDIR
ls -lh $CN_HOME/Models/Reproduction/SimpopNet/exploration >> logexplo

# macro virtual
cd $CN_HOME/Models/MacroCoevol/MacroCoevol
if [ "$MODE" == "--test" ]
then
  openmole --password-file omlpsswd --script ExploVirtualTest.oms > logexplo
fi
if [ "$MODE" == "--run" ]
then
  openmole --password-file omlpsswd --script ExploVirtual.oms > logexplo
fi
cd $BASEDIR
ls -lh $CN_HOME/Models/MacroCoevol/MacroCoevol/exploration >> logexplo


# meso synthetic
