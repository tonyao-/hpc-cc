#!/bin/bash

NUM="$1"

if [ ! -d ~/examples/concorde/$NUM ]; then 
  mkdir -p ~/examples/concorde/$NUM; 
fi

cd ~/examples/concorde/$NUM

# Start calculations
time /usr/local/Concorde/concorde/TSP/concorde -s 99 -k $((NUM * 100))
