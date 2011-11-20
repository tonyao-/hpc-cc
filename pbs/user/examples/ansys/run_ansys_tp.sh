#/bin/sh!
export ANSYSLMD_LICENSE_FILE="1055@v161.cc.spbu.ru"
export ANSYSLI_SERVERS="2325@v161.cc.spbu.ru"
cd $PWD
/usr/local/ansys_inc/v130/ansys/bin/ansys130 -b nolist -p aa_r -j ansys_demo  -i ansys_demo.inp -o ansys_demo.out

