# MFRT
MFRT - Multi-fraction replication timing pipeline
## Requirements
* FASTX-Toolkit (http://hannonlab.cshl.edu/fastx_toolkit/commandline.html)
* bowtie2 (http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
* samtools (http://samtools.sourceforge.net/)
* bedtools (http://bedtools.readthedocs.io/en/latest/)
## Usage
```shell
# Map reads to reference genome. My_dir should contain raw fastq data, with each fraction in an individual folder.
mapping.sh my_dir hg38_index
# Make bed file of 10k window size.
bedtools makewindows -g hg38.chrom.size -w 10000 > hg38.10k.bed
# Normalize reads.
normalize.sh my_dir
```
## In progress
Using early/late pipeline from DCIC for mapping/counting.
