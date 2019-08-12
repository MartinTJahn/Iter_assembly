#!/bin/bash

########################
## assembly per library
########################

OUTDIR="DATA/" # set foo dir

for i in *_R1_maq15.bbduk.fastq # loop libraries
do
   SAMPLE=$(echo ${i} | sed "s/_R1_maq15.bbduk\.fastq//") # crop sample ID from filename
   input1=$SAMPLE"_R1_maq15.bbduk.fastq"
   input2=$SAMPLE"_R2_maq15.bbduk.fastq"
   OUTPUT=$OUTDIR${SAMPLE##*/}_mspades
   spades.py -1 $input1 -2 $input2 -o $OUTPUT --meta -m 370 -t 30
done

########################
## iterative assembly
########################

prop="0.05" # proportion sampled (50x 0.01%; 12x 0.05%; 12x 0.10%) ## set parameters here 
times="12"  # times sampled

for j in $(seq 1 $times) 
do
    i=$((1 + RANDOM % 1000))
	seqtk sample -s$i ../trimming/Allcat_R1_maq15.fastq $prop > ${prop}pick_${i}seed_1.fq & # random pick prop from concatenated sequence pool
	seqtk sample -s$i ../trimming/Allcat_R2_maq15.fastq $prop > ${prop}pick_${i}seed_2.fq & 
	wait
	spades.py -1 ${prop}pick_${i}seed_1.fq -2 ${prop}pick_${i}seed_2.fq -o ${prop}pick_${i}seed --meta -m 220 -t 30 # assemble
done
