#!/bin/bash

dir=$1

for i in `ls $dir|grep Sample`
do
        echo $i
        intersectBed -c -a hg38.10k.bed -b $dir/$i/$i.hg38.bed > $i.hg38.10k.bed
done

paste *.hg38.10k.bed > Sample_all_R1.hg38.10k.bed

awk 'NR==FNR{
        for(i=4;i<=NF;i=i+1){
                a[i]=a[i]+$i
        }
}NR>FNR{
        printf $1"\t"$2"\t"$3
        for(i=4;i<=NF;i=i+1){
                printf "\t"$i*1000000/a[i]
        }
        print ""
}' Sample_all_R1.hg38.10k.bed Sample_all_R1.hg38.10k.bed > Sample_all_R1.hg38.10k.norm.bed

awk '{
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
}' Sample_all_R1.hg38.10k.norm.bed > Sample_all_R1.hg38.10k.ratio.bed
