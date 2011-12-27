#/bin/sh!
cd firefly
~/submit-tp -q short -i /usr/local/firefly/samples/condircbk.inp -n 4 -d /usr/local/firefly/mpich2 -f /usr/local/firefly/mpich2/firefly -j ff_condircbk -v mpich2
~/submit-tp -q short -i ~/examples/firefly/exam01.inp -n 4 -d /usr/local/firefly/mpich2 -f /usr/local/firefly/mpich2/firefly -j ff_exam01 -v mpich2
cd -
