#!/bin/bash

function printUsage {
  echo "Usage:   `basename $0` <cores_num> <input_file>"
  echo "Example: `basename $0` 4 ~/examples/test-gaussian";
}

if [[ -z "$1" ]]; then echo "Error! Please specify the number of cores to use!"; printUsage; exit 1; fi
if [[ -z "$2" ]]; then echo "Error! Please specify an input file!"; printUsage; exit 1; fi

GAUSSIAN_DIR="$HOME/Gaussian/"
if [[ ! -d "$GAUSSIAN_DIR" ]]; then mkdir $GAUSSIAN_DIR; fi

CORES="$1"
INPUT_FILE="$2"
INPUT_NAME="`basename $INPUT_FILE`"
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

~/submit-tp -j Gaussian -n $CORES -f "
#!/bin/bash

cd $JOB_DIR

NODES_STR=\"\"
NODES_UNIQ=\"\`cat \$PBS_NODEFILE | uniq\`\"
for i in \$NODES_UNIQ; do 
   procNum=\$(grep \$i \$PBS_NODEFILE | wc -l); 
   NODES_STR=\"\${NODES_STR}\${i}:\${procNum},\"; 
done 
# Remove trailing comma
NODES_STR=\${NODES_STR%,}
# Rewrite \$NODES_FILE with \$NODES_STR
echo \"-W- \$NODES_STR\" > $NODES_FILE

echo \"Working directory: $JOB_DIR\"
echo \"Parallel settings (node:number_of_processes):\"
echo \"\$NODES_STR\"

# Start calculations
time g09 < $JOB_FILE > $OUTPUT_FILE

rm $NODES_FILE"
