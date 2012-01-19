#!/bin/sh

#. /usr/local/pgi/linux86-64/11.10/pgi.sh
#LM_LICENSE_FILE=27200@lm-ms55.hpc.cc.spbu.ru; export LM_LICENSE_FILE
. /usr/local/pgi/pgi.sh
cp /usr/local/pgi/linux86-64/11.10/bin/localrc.wind ~/localrc.`hostname`
if [ -n "$*" ]
then
	$*
else
	pgcc -V
	pgCC -V
	pgfortran -V
fi
rm -f ~/localrc.`hostname`

