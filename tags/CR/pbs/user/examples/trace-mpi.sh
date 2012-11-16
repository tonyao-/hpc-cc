#!/bin/bash

n=`wc -l < $PBS_NODEFILE`
echo $LD_LIBRARY_PATH | tr : '\n'

export VT_LOGFILE_FORMAT=STF
export VT_PCTRACE=5
export VT_LOGFILE_PREFIX=`mktemp -d`
export VT_PROCESS="0:N ON"

print_usage()
{
	echo "USAGE: trace-mpi.sh  <app-command-line>"
}

output_dir=`pwd`/trace-mpi-`date +%Y.%m.%d-%H.%M.%S`
app=$*
while [ -n "$1" ]
do
	shift
done

if [ -z "$app" ]; then
	echo "Error: specify application."
	print_usage
	exit 1
fi

rm -rf $VT_LOGFILE_PREFIX
mkdir -p $VT_LOGFILE_PREFIX

source ~/examples/intel-cluster-studio.sh
mpirun -n $n -machinefile $PBS_NODEFILE itcpin --verbose 3 --insert libVT --run -- $app
#mpirun -n $n -machinefile $PBS_NODEFILE itcpin --verbose 3 --profile --config ~/papi.itcpin --run -- $app
mkdir -p $output_dir
cp -r $VT_LOGFILE_PREFIX/* $output_dir
rm -rf $VT_LOGFILE_PREFIX
echo "Trace directory: $output_dir"
