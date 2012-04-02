#!/bin/bash
 
SPECIFIED_FILE="$1"
MOLPRO_DIR=/usr/local/molpro/molprop_2010_1_Linux_x86_64_i8/bin/
time $MOLPRO_DIR/molpro $SPECIFIED_FILE

