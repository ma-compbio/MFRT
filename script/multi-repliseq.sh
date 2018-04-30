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

# Prepare bed file of given window size 
make_window.sh $genome_size $window_size $output_dir/genome.${window_size}.bed

IFS=$'\n'
for line in `cat $input_info`
do
	echo $line
	file="$(cut -d' ' -f 1 <<<$line)"
	fraction="$(cut -d' ' -f 2 <<<$line)"
	adapter1="$(cut -d' ' -f 3 <<<$line)"
	adapter2="$(cut -d' ' -f 4 <<<$line)"

	# Unzip fastq file
	gzip -d -c $input_dir/$file > $output_dir/${output_prefix}.${fraction}.fastq
	
	# Remove adapter
	clip.sh $output_dir/${output_prefix}.${fraction}.fastq $output_dir/${output_prefix}.${fraction}.clip1.fastq $adapter1
	clip.sh $output_dir/${output_prefix}.${fraction}.clip1.fastq $output_dir/${output_prefix}.${fraction}.clip2.fastq $adapter2

	# Alignment
	bwa_align.sh $output_dir/${output_prefix}.${fraction}.clip2.fastq $bwa_index $output_dir/${output_prefix}.${fraction}.bam $threads

	# Sort bam file
	samtools sort $output_dir/${output_prefix}.${fraction}.bam -o $output_dir/${output_prefix}.${fraction}.sort.bam
	
	# Remove duplicates
	samtools rmdup $output_dir/${output_prefix}.${fraction}.sort.bam $output_dir/${output_prefix}.${fraction}.dedup.bam

	# bamToBed
	bamToBed -i $output_dir/${output_prefix}.${fraction}.dedup.bam > $output_dir/${output_prefix}.${fraction}.bed

	# Calculate coverage
	intersectBed -c -a $output_dir/genome.${window_size}.bed -b $output_dir/${output_prefix}.${fraction}.bed > $output_dir/${output_prefix}.${fraction}.coverage.bed


	rm -f $output_dir/${output_prefix}.${fraction}.fastq $output_dir/${output_prefix}.${fraction}.clip1.fastq $output_dir/${output_prefix}.${fraction}.clip2.fastq $output_dir/${output_prefix}.${fraction}.bam $output_dir/${output_prefix}.${fraction}.sort.bam $output_dir/${output_prefix}.${fraction}.bed 

done



