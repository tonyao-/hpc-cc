#!/bin/bash

DIRECTORY="$1"
shift
COMMAND_WITH_OPTIONS="$*"

cd $DIRECTORY
NP=`cat $PBS_NODEFILE | wc -l`
time ${FOAM_INST_DIR}/mpi/bin/mpirun --hostfile $PBS_NODEFILE -np $NP $COMMAND_WITH_OPTIONS -parallel

