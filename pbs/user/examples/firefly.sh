#/bin/sh!
cd firefly
~/submit-tp -i /usr/local/firefly/samples/condircbk.inp -n 4 -d /usr/local/firefly/mpich-dyn -f /usr/local/firefly/mpich-dyn/firefly -j firefly -v mpich
~/submit-tp -i ~/examples/firefly/exam01.inp -n 4 -d /usr/local/firefly/mpich-dyn -f /usr/local/firefly/mpich-dyn/firefly -j firefly -v mpich
cd -