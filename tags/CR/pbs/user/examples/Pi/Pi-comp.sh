#!/bin/sh
cd Pi
mpif77 Pi.f -o Pi.openmpi
~/submit-tp -f ~/tmp/Pi.comp-openmpi.sh -j Pi-comp -q short -d ~/tmp/
cd -