#!/bin/sh
cd Pi
~/submit-tp -f ~/examples/Pi/Pi.comp-openmpi.sh -d ~/examples/Pi
~/submit-tp -v openmpi -j Pi -n 16 -f ~/examples/Pi/Pi.openmpi
cd -