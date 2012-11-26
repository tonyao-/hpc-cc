#!/bin/sh

MPPCRYSTAL=/usr/local/crystal09/bin/Linux-ifort-11.1_emt64/v1_0_1/MPPcrystal
CASES=$HOME/crystal/inputs
mkdir -p $CASES

test_case=$1
queue=$2
np=$3
if [ -z "$test_case" ] || [ ! -f "$CASES/$test_case.d12" ] || [ -z "$queue" ] || [ -z "$np" ]; then
	echo "USAGE: ./$(basename $0) <test_case> <queue> <n> "
	echo "EXAMPLE: ./$(basename $0) tio2pr short 'nodes=2:ppn=4'"
	exit 1
fi
shift
shift
shift

OUTDIR=$HOME/crystal/$(date +%Y.%m.%d_%H.%M.%S)_${test_case}


echo "Test case: $test_case"
echo "Results:   $OUTDIR"
qsub -q $queue -l $np << EOF

WORKDIR=\$(mktemp -d)
cp $CASES/${test_case}* \$WORKDIR
cp \$WORKDIR/${test_case}.d12 \$WORKDIR/INPUT
if [ -f "\$WORKDIR/${test_case}.gui" ]; then
	cp \$WORKDIR/${test_case}.gui \$WORKDIR/fort.34
fi

NODES=\$(uniq < \$PBS_NODEFILE)
for n in \$NODES; do
	ssh \$n mkdir -p \$WORKDIR
	scp \$WORKDIR/* \$n:\$WORKDIR
done

cd \$WORKDIR
source $HOME/bin/intel.sh
mpirun -machinefile \$PBS_NODEFILE $MPPCRYSTAL >$test_case.out 2>&1 

rm -f \$WORKDIR/fort.*.pe*
cp -r \$WORKDIR $OUTDIR

for n in $NODES; do
	ssh $n rm -rf \$WORKDIR
done

EOF
