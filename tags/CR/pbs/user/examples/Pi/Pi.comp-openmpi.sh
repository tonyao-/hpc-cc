#!/bin/sh
export prefix="/usr/lib64/openmpi/1.4-gcc"

export PATH=$prefix/bin:$PATH
export LD_LIBRARY_PATH=$prefix/lib:$LD_LIBRARY_PATH
mpif77 Pi.f -o Pi.openmpi

