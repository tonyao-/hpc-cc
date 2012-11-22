#!/bin/bash

function printUsage {
  echo "Usage:   `basename $0` <nodes_num> <proc_num> <input_file> [output_file]"
  echo "Example: `basename $0` 2 4 ~/examples/test-gaussian ~/gaussian.log"; 
}

if [[ -z "$1" ]]; then echo "Error! Please specify number of nodes!"; printUsage;  exit 1; fi
if [[ -z "$2" ]]; then echo "Error! Please specify number of processes on each node!"; printUsage; exit 1; fi
if [[ -z "$3" ]]; then echo "Error! Please specify an input file!"; printUsage; exit 1; fi

NODES_NUM="$1"
PROC_NUM="$2"
INPUT_FILE="$3"
INPUT_DIR="$(dirname `readlink -m $INPUT_FILE`)"

OUTPUT_FILE="/dev/null"
if [[ -n "$4" ]]; then 
  OUTPUT_FILE="$4"
fi

# File for Gaussian properties
NODES_FILE="$INPUT_DIR/Default.Route"

qsub -q long -N Gaussian -l nodes=$NODES_NUM:ppn=$PROC_NUM <<< "
#!/bin/bash

cd $INPUT_DIR

NODES_STR=\`cat \$PBS_NODEFILE | uniq\`
NODES_STR=\`echo \$NODES_STR | sed 's/ /,/g'\`
 
# Write parameters to Default.Route file
echo \"-P- $PROC_NUM\" > $NODES_FILE
echo \"-W- \$NODES_STR\" >> $NODES_FILE

# If output file wasn't specified Gaussian will write to *.log file 
if [[ \"$OUTPUT_FILE\" != \"/dev/null\" ]]; then
  time g09 < $INPUT_FILE > $OUTPUT_FILE
else
  time g09 $INPUT_FILE
fi

rm $NODES_FILE"
