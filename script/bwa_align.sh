#!/bin/bash

input=$1
index=$2
output=$3
threads=$4

bwa mem -t $threads $index $input | samtools view -Shb - > $output


