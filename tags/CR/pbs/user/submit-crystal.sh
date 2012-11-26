#/bin/sh!
INPUT=$1
INPUTS=${HOME}/crystal/inputs
#OUTPUT=$2
DATE=$(date -d today +%Y%m%d-%H%M%S)
PRJNAME=$(basename $INPUT)
PRJDIR=${HOME}/crystal/${PRJNAME}.$DATE
source ~/.openmpi-1.4.3
source /usr/local/crystal09/utils09/cry2k9.bashrc

mkdir -p $PRJDIR
cp $INPUTS/${INPUT}* $PRJDIR
cd $PRJDIR

cat $PBS_NODEFILE > machines.LINUX
cat machines.LINUX |uniq > nodes.par
N=$(wc -l < machines.LINUX)
time /usr/local/crystal09/utils09/runmpi109forpbs $N $PRJNAME
