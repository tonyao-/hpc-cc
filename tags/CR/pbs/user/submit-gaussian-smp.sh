#!/bin/bash

function printUsage {
  echo "Usage:   `basename $0` <nodes_num> <proc_num> <input_file>"
  echo "Example: `basename $0` 2 4 ~/examples/test-gaussian"; 
}

if [[ -z "$1" ]]; then echo "Error! Please specify number of nodes!"; printUsage;  exit 1; fi
if [[ -z "$2" ]]; then echo "Error! Please specify number of processes on each node!"; printUsage; exit 1; fi
if [[ -z "$3" ]]; then echo "Error! Please specify an input file!"; printUsage; exit 1; fi

NODES_NUM="$1"
PROC_NUM="$2"
INPUT_FILE="$3"
INPUT_NAME="`basename $INPUT_FILE`"

GAUSSIAN_DIR="$HOME/Gaussian/"
if [[ ! -d "$GAUSSIAN_DIR" ]]; then mkdir $GAUSSIAN_DIR; fi

JOB_DIR="${GAUSSIAN_DIR}/${INPUT_NAME%.*}-`date +%Y%m%d`-`date +%H%M%S`-`date +%3N`"
mkdir $JOB_DIR
if [[ ! -d "$JOB_DIR" ]]; then echo "Error! Job dir '$JOB_DIR' doesn't exist!"; exit 2; fi

# Copy input file to $JOB_DIR
JOB_FILE="${JOB_DIR}/${INPUT_NAME}"
cp $INPUT_FILE $JOB_FILE
# File with result
OUTPUT_FILE="${JOB_DIR}/${INPUT_NAME%.*}.log"
# File for Gaussian properties
NODES_FILE="${JOB_DIR}/Default.Route"

echo "Working directory: $JOB_DIR"

qsub -q long -N Gaussian -l nodes=$NODES_NUM:ppn=$PROC_NUM <<< "
#!/bin/bash

cd $JOB_DIR

NODES_STR=\`cat \$PBS_NODEFILE | uniq\`
NODES_STR=\`echo \$NODES_STR | sed 's/ /,/g'\`
 
# Write parameters to Default.Route file
echo \"-P- $PROC_NUM\" > $NODES_FILE
echo \"-W- \$NODES_STR\" >> $NODES_FILE

echo \"Working directory: $JOB_DIR\"
echo \"Parallel settings:\"
echo \"Nodes: \$NODES_STR\"
echo \"Number of processes on each node: $PROC_NUM\"

# Start calculations
time g09 < $JOB_FILE > $OUTPUT_FILE

rm $NODES_FILE"
