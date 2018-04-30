#!/bin/bash

input_dir=$1
input_info=$2
output_dir=$3
output_prefix=$4
#bwa_index=$5
#threads=$6
#window_size=$7
genome_size=$5

echo "chr	start	end" > ${output_dir}/${output_prefix}.merge.tmp
cat ${input_dir}/genome.10000.bed >> ${output_dir}/${output_prefix}.merge.tmp

IFS=$'\n' 
for line in `cat $input_info`
do
	echo $line
	file="$(cut -d' ' -f 1 <<<$line)"
	fraction="$(cut -d' ' -f 2 <<<$line)"
	adapter1="$(cut -d' ' -f 3 <<<$line)"
	adapter2="$(cut -d' ' -f 4 <<<$line)"

	#file=`ls $input_dir|grep $fraction|grep coverage.bed`
	file=`ls $input_dir/*.${fraction}.coverage.bed`
	echo $file
	echo $fraction > ${output_dir}/${output_prefix}.${fraction}.tmp

	awk 'NR==FNR{
		total=total+$4
	}NR>FNR{
		print $4*1000000/total
	}' $file $file >> ${output_dir}/${output_prefix}.${fraction}.tmp

	paste ${output_dir}/${output_prefix}.merge.tmp ${output_dir}/${output_prefix}.${fraction}.tmp > ${output_dir}/${output_prefix}.swap.tmp
	mv ${output_dir}/${output_prefix}.swap.tmp ${output_dir}/${output_prefix}.merge.tmp

done

awk 'NR==1{
		for(i=1;i<=NF;i=i+1){
			if(i!=4){
				printf $i"\t"
			}
		}
		print
	}
	NR>1{
	t=0
	for(i=5;i<=NF;i=i+1){
		t=t+$i
	}
	if(t>0){
		printf $1"\t"$2"\t"$3
		for(i=5;i<=NF;i=i+1){
			printf "\t"$i/t
		}
		print ""
	}
}' ${output_dir}/${output_prefix}.merge.tmp |sort -k1,1 -k2,2n > ${output_dir}/${output_prefix}.ratio.bed

rm -rf ${output_dir}/${output_prefix}.*.tmp

awk -v output_dir=${output_dir} '
	NR==1{
		for(i=1;i<=NF;i=i+1){
			a[i]=$i
		}
	}
	NR>1{
		for (i=4;i<=NF;i=i+1){
			print $1"\t"$2"\t"$3"\t"$i >> output_dir"/"a[i]".ratio.tmp"
	}
}' ${output_dir}/${output_prefix}.ratio.bed

for i in `ls ${output_dir}|grep .ratio.tmp`
do
	fraction=${i%.ratio.tmp}
	echo $fraction

	bedGraphToBigWig ${output_dir}/$i $genome_size ${output_dir}/${output_prefix}.${fraction}.ratio.bw

done

rm -rf ${output_dir}/*.tmp















