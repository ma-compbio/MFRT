#!/bin/bash

input_dir=$1
input_info=$2
output_dir=$3
output_prefix=$4
bwa_index=$5
threads=$6
window_size=$7
genome_size=$8

mkdir -p $output_dir

bedtools makewindows -g $genome_size -w $window_size |sort -k 1,1 -k2,2n > $output_dir/genome.${window_size}.bed

IFS=$'\n'
for line in `cat $input_info`
do
	echo $line
	file="$(cut -d' ' -f 1 <<<$line)"
	fraction="$(cut -d' ' -f 2 <<<$line)"
	adapter1="$(cut -d' ' -f 3 <<<$line)"
	adapter2="$(cut -d' ' -f 4 <<<$line)"

	gzip -d -c $input_dir/$file > $output_dir/${output_prefix}.${fraction}.fastq
	
fastx_clipper -Q 33 -v -n -l 10 -a $adapter1 -i $output_dir/${output_prefix}.${fraction}.fastq -o $output_dir/${output_prefix}.${fraction}.clip1.fastq
	fastx_clipper -Q 33 -v -n -l 10 -a $adapter2 -i $output_dir/${output_prefix}.${fraction}.clip1.fastq -o $output_dir/${output_prefix}.${fraction}.clip2.fastq

	bwa mem -t $threads $bwa_index $output_dir/${output_prefix}.${fraction}.clip2.fastq | samtools view -Shb - > $output_dir/${output_prefix}.${fraction}.bam

	samtools sort $output_dir/${output_prefix}.${fraction}.bam -o $output_dir/${output_prefix}.${fraction}.sort.bam
	
	samtools rmdup $output_dir/${output_prefix}.${fraction}.sort.bam $output_dir/${output_prefix}.${fraction}.dedup.bam

	bamToBed -i $output_dir/${output_prefix}.${fraction}.dedup.bam > $output_dir/${output_prefix}.${fraction}.bed

	intersectBed -c -a $output_dir/genome.${window_size}.bed -b $output_dir/${output_prefix}.${fraction}.bed > $output_dir/${output_prefix}.${fraction}.coverage.bed

	rm -f $output_dir/${output_prefix}.${fraction}.fastq $output_dir/${output_prefix}.${fraction}.clip1.fastq $output_dir/${output_prefix}.${fraction}.clip2.fastq $output_dir/${output_prefix}.${fraction}.bam $output_dir/${output_prefix}.${fraction}.sort.bam $output_dir/${output_prefix}.${fraction}.bed 

done



