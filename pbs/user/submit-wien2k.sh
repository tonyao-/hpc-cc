#!/bin/bash
#PBS -N tessst
if [ -n "$1" ]; then
 
  SPECIFIED_DIR="$1"
 
  if [ ! -d /tmp/$USER ]; then
    mkdir /tmp/$USER
  fi
  if [ ! -d /tmp/$USER/wien2k ]; then
    mkdir /tmp/$USER/wien2k
  fi

  # Create and export SCRATCH directory
  export SCRATCH=`mktemp -d -p /tmp/$USER/wien2k/` 

  # Change dir to project dir
  cd "$SPECIFIED_DIR"
  
  # Create .machines file
  cat $PBS_NODEFILE > machines.LINUX
  cat machines.LINUX |uniq > nodes.par
  for i in `cat nodes.par | xargs`; do n=$(grep $i machines.LINUX|wc -l); echo 1:${i}:$n; done > .machines

  # Create SCRATCH dir on each node
  for n in `cat nodes.par`; do ssh $n "mkdir -p $SCRATCH;"; done  
  
  echo "Nodes:"
  cat .machines
  echo "Using WIEN2k: $WIENROOT"

  # Start calculations
  time $WIENROOT/run_lapw -p -NI -ec 0.0001

  # Remove SCRATCH dir
  for n in `cat nodes.par`; do ssh $n "rm -rf $SCRATCH"; done  

else
  echo "Please specify a working directory!"
fi
