#!/bin/sh

VORPAL_INPUT=$HOME/vorpal-in
VORPAL_OUTPUT=$HOME/vorpal-out

n=$1
shift
p=$1
shift
test_case=$1
shift
args=$*
if [ -z "$n" ] || [ -z "$p" ] || [ -z "$test_case" ]; then
	echo "USAGE: `basename $0` <nodes> <procs> <test-case> <vorpal-arguments>"
	echo "Example: `basename $0` 1 4 simpleWave"
	exit 1
fi


input_dir=$VORPAL_INPUT/$test_case
output_dir=$VORPAL_OUTPUT/${test_case}-`date -d today +%Y.%m.%d-%H.%M.%S`

mkdir -p $VORPAL_INPUT
mkdir -p $VORPAL_OUTPUT
mkdir -p $output_dir

echo "Test case:  $test_case"
echo "Input dir:  $input_dir"
echo "Output dir: $output_dir"

echo "qsub -q long@vorpalpbs.hpc.cc.spbu.ru -W group_list=vorpal -N vorpal -lnodes=$n:ppn=$p "
qsub -q long@vorpalpbs.hpc.cc.spbu.ru -W group_list=vorpal -N vorpal -lnodes=$n:ppn=$p <<< "$HOME/vorpal.sh $test_case $input_dir $output_dir $args" 
