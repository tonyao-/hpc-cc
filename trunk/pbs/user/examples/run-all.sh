#/bin/sh!
~/submit-tp -f ~/examples/helloworld.sh
~/submit-tp -f ~/examples/intel.sh
~/submit-tp -f ~/examples/Pi/Pi.comp-openmpi.sh -d ~/examples/Pi
~/submit-tp -v openmpi -j Pi-6 -n 4 -f ~/examples/Pi/Pi.openmpi
~/examples/firefly.sh
~/examples/g03.sh
