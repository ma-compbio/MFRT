# MFRT
MFRT - Multi-fraction replication timing pipeline
## Requirements
* FASTX-Toolkit (http://hannonlab.cshl.edu/fastx_toolkit/commandline.html)
* BWA (http://bio-bwa.sourceforge.net/)
* samtools (http://samtools.sourceforge.net/)
* bedtools (http://bedtools.readthedocs.io/en/latest/)
## Input files
* Raw fastq files (fastq.gz)
* Multi-fraction information
```
input_info.txt:
fraction_1.fastq.gz fraction_1 adapter_1-1 adapter_1-2
fraction_2.fastq.gz fraction_2 adapter_2-1 adapter_2-2
......
fraction_k.fastq.gz fraction_k adapter_k-1 adapter_k-2
```
* BWA index for reference genome
* Reference genome size


## Usage
```shell
multi-repliseq.sh $input_dir $input_info $output_dir $output_prefix $bwa_index $threads $window_size $genome_size
```

