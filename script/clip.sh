#!/bin/bash

input=$1
output=$2
adapter=$3

fastx_clipper -Q 33 -v -n -l 10 -a $adapter -i $input -o $output

