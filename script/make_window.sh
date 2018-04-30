#!/bin/bash

genome_size=$1
window_size=$2
output=$3

bedtools makewindows -g $genome_size -w $window_size |sort -k 1,1 -k2,2n > $output

