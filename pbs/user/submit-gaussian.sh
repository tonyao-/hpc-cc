#!/bin/bash

if [[ -z "$1" ]]; then echo "Error! Please specify an input file!"; exit 1; fi

INPUT_FILE="$1"
INPUT_DIR="$(dirname `readlink -m $INPUT_FILE`)"
OUTPUT_FILE=""
if [[ -n "$2" ]]; then 
  OUTPUT_FILE="$2"
fi

# File for Gaussian properties
NODES_FILE="$INPUT_DIR/Default.Route"

cd $INPUT_DIR

NODES_STR=""
cat $PBS_NODEFILE | uniq > $NODES_FILE
for i in `cat $NODES_FILE | xargs`; do 
   procNum=$(grep $i $PBS_NODEFILE | wc -l); 
   NODES_STR="${NODES_STR}${i}:${procNum},"; 
done 
# Remove trailing comma
NODES_STR=${NODES_STR%,}
# Rewrite $NODES_FILE with $NODES_STR
echo "-W- $NODES_STR" > $NODES_FILE

# If output file wasn't specified Gaussian will write to *.log file 
if [[ -n "$OUTPUT_FILE" ]]; then
  time g09 < $INPUT_FILE > $OUTPUT_FILE
else
  time g09 $INPUT_FILE
fi

rm $NODES_FILE
