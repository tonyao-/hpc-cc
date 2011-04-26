#/bin/sh!
INPUT=$1
OUTPUT=$2
TMPDIR=`mktemp -d`
g03root=/usr/local
GAUSS_SCRDIR=$TMPDIR
export g03root GAUSS_SCRDIR
. /usr/local/g03/bsd/g03.profile

cd $TMPDIR
FILENAME=`basename $INPUT`
OUTFILE=`echo $FILENAME | sed s#\.com#\.log#`
cp $INPUT $FILENAME
time g03 $FILENAME

if [ -f $OUTFILE ]; then
        #mv $OUTFILE /home/viz/;
        mv $OUTFILE $OUTPUT;
else
        echo "No outputfile";
fi


