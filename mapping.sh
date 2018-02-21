#!/bin/bash

dir1=$1
hg38_index=$2

for i in `ls $dir1`
do
        echo $i
        mkdir -p $i
        rm -f $i/*.fastq
        #gzip -d -c $dir1/$i/*.fastq.gz > $i/all.fastq
        #gzip -d -c $dir2/$i/*.fastq.gz >> $i/all.fastq

        for j in `ls $dir1/$i|grep fastq.gz`
        do
                echo $j
                gzip -d -c $dir1/$i/$j >> $i/all.fastq
        done
        for j in `ls $dir2/$i|grep fastq.gz`
        do
                echo $j
                gzip -d -c $dir2/$i/$j >> $i/all.fastq
        done

        echo "Finished unzip."

        name=`ls $dir1/$i|grep fastq.gz|head -1`
        #echo $name
        adapter1=${name%-*}
        adapter1=${adapter1##*_}
        adapter2=${name#*-}
        adapter2=${adapter2%%_*}
        echo $adapter1 $adapter2

        fastx_clipper -Q 33 -v -n -l 10 -a $adapter1 -i $i/all.fastq -o $i/all.tmp.fastq
        fastx_clipper -Q 33 -v -n -l 10 -a $adapter2 -i $i/all.tmp.fastq -o $i/all.clipped.fastq

        bowtie2 -x $hg38_index $i/all.clipped.fastq -p 40 -S $i/$i.hg38.sam

        rm -f $i/*.fastq

        samtools view -Sb $i/$i.hg38.sam > $i/$i.hg38.bam

        bamToBed -i $i/$i.hg38.bam > $i/$i.hg38.bed

        sortBed -i $i/$i.hg38.bed > $i/tmp
        mv $i/tmp $i/$i.hg38.bed

done
