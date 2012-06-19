#!/bin/bash

i=1
for node in `cat $PBS_NODEFILE`; do
  echo node=$node i=$i
  ssh $node "~/examples/concorde-script.sh $i" &
  let i=i+1
done
wait

