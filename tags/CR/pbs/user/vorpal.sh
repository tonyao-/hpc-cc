#!/bin/bash


export VORPAL_ROOT=/usr/local/vorpal/Vorpal-5.0.0-Linux-x86_64/Contents/engine
export VORPAL_BIN=$VORPAL_ROOT/bin
export VORPAL_LIB=$VORPAL_ROOT/lib
export VORPAL_SHARE=$VORPAL_ROOT/share

test_case=$1
shift
input_dir=$1
shift
output_dir=$1
shift
arguments=$*
nodes=`cat $PBS_NODEFILE | uniq`
cat $PBS_NODEFILE

tmp_dir=`mktemp -d`
#tmp_dir="/tmp/myvorpal"
#mkdir -p $tmp_dir

cd $tmp_dir
cp $input_dir/* $tmp_dir

export PYTHONHOME=$VORPAL_ROOT
export PYTHONPATH=$VORPAL_LIB/python2.6/site-packages
$VORPAL_BIN/python $VORPAL_BIN/txpp.py --import=$VORPAL_SHARE/macros --prefile=$test_case.pre --outfile=$test_case.in

for n in $nodes; do
	echo "Copying to node $n"
	ssh $n "mkdir -p $tmp_dir"
	scp $tmp_dir/* $n:$tmp_dir
done

N=`wc -l < $PBS_NODEFILE`
$VORPAL_BIN/mpiexec -np $N -machinefile $PBS_NODEFILE $VORPAL_BIN/vorpal -i $tmp_dir/$test_case.in $arguments

for n in $nodes; do
	scp $n:$tmp_dir/* $output_dir
	ssh $n "rm -rf $tmp_dir"
done
