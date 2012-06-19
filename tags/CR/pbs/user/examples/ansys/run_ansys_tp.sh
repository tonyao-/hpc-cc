#/bin/sh!
export ANSYSLMD_LICENSE_FILE="1055@v161.cc.spbu.ru"
export ANSYSLI_SERVERS="2325@v161.cc.spbu.ru"
export ANSYS130_DIR=/usr/local/ansys_inc/v130/ansys
cd $PWD
$ANSYS130_DIR/bin/ansys130 -b nolist -p aa_r -j ansys_demo  -i ansys_demo.inp -o ansys_demo.out

