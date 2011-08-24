#/bin/sh!
severname=pbs-tp.hpc.cc.spbu.ru
jobname=abinit.`date +%s`;
submitfile=file`date +%s`.sh;
MPICH2_PREFIX=/usr/local/mpich2-1.4.INT.20110813/
debug=0
input=$1
np=$2
logfile=$3
queue=$4
PWD=`pwd`;
for i in $@ " ";do
	if [ "$i" == "--help" -o "$i" == "-h" ]; then
		cat << EOF
abinit submit script
$]./submit-abinit.sh input.files N logfiles queue
default:
 N=1
logfiles - stdout (pbs output = $jobname.o.pbsjobnumber and $jobname.e.pbsjobnumber)
queue=longh
without input.files - error.
iput.files - list of input files in the current directory or with full path.
EOF
	exit 0;
	fi
done

for i in $@ " ";do
	if [ "$i" == "--debug" ]; then
		debug=1;
	fi
done


if [ ! -n "$queue" ];then
        queue=long;
else
        queue=${queue};
fi

case $queue in
        long|short|infi)
        qolor=green
        ;;
        test)
        qolor=red
        ;;
        virtshort)
        qolor=blue
        ;;
esac

NN=`pbsnodes -s $severname |awk -v qolor=$qolor '{if ($1 == "state") {state=$3} if ($1 == "properties") {properties=$3} if ($1 == "status") {if (properties == qolor) {print state}}}' | grep free |wc -l` 
if [ $NN -eq 0 ]; then
        echo "All nodes are full now, sorry. But your  job will be  queued on one node.";
        NN=1;
fi
export NP=8;# core number
ALLNP=`expr $NN  \* $NP`


if [ ! -f "$input" ]; then
	echo "error input files (it not exist)";
	exit 1;
fi

if [ -n "$np" ];then
        if [ "$np" -gt "$ALLNP" ]; then
                echo "Sorry, we have $ALLNP cores only, less $np";
                exit
        else
                mpiarg="$mpiarg -np $np";
                
        fi
else
        np=1;
fi


if [ $np -ge $NN ]; then
	t=`expr $np \/ $NN`;
        k=`expr $t \* $NN`;
        i=`expr $np - $k`;
        if [ $i -eq 0 ]; then
		count=$NN:ppn=$t;
        else
		count="`expr $NN - $i`:ppn=$t+$i:ppn=`expr $t + 1`";    
	fi
else
	count="${np}:ppn=1";
fi

cat << EOF > $submitfile
#/bin/sh!
. /usr/local/intel/mkl/bin/mklvars.sh intel64
. /usr/local/intel/bin/compilervars.sh intel64
cd $PWD;

EOF

if [ -n "$logfile" ]; then
	logfile=" > $logfile";
fi

cat << EOF >> $submitfile
$MPICH2_PREFIX/bin/mpirun -np $np  -machinefile  \$PBS_NODEFILE /usr/local/abinit-6.8.1/bin/abinit < $input  $logfile

EOF


cat $submitfile | qsub -N $jobname -l nodes=$count -q "$queue"@"$severname"



if [ $debug -eq "1" ]; then
        echo "cat $submitfile | qsub -N $jobname -l nodes=$count -q $queue"@"$severname"
else
        rm $submitfile;
fi





