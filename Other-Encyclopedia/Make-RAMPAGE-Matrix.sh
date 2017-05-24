#Jill E. Moore - Jill.Elizabeth.Moore@gmail.com
#Weng Lab - UMass Medical School
#ENCODE Encyclopedia Version 4
#Updated May 2017

#This script is designed to run on UMass GHPCC (LSF Queue)

#Script for making RAMPAGE matrix used in SCREEN

#BSUB -L /bin/bash
#BSUB -n 1
#BSUB -R rusage[mem=10000] # ask for memory
#BSUB -q short 
#BSUB -o "/home/jm36w/JobStats/%J.out"
#BSUB -e "/home/jm36w/JobStats/%J.error"
#BSUB -W 2:00
#BSUB -J "Process-Control[1-310]"

source ~/.bashrc

tss=~/Lab/Reference/Human/Gencode19/TSS.Filtered.bed
width=50

files=/home/jm36w/Lab/Results/V4-hg19/Rampage-List.txt

experiment=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $1}' $files)
dsig=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $2}' $files)
dline=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $0}' $files)

mkdir -p /home/jm36w/Lab/Results/V4-hg19/rampage/$LSB_JOBID"-"$LSB_JOBINDEX
cd /home/jm36w/Lab/Results/V4-hg19/rampage/$LSB_JOBID"-"$LSB_JOBINDEX

awk -F "\t" '{printf "%s\t%.0f\t%.0f\t%s\n", $1,$2-'$width',$3+'$width',$4}' $peaks | awk '{if ($2 < 0) print $1 "\t" 0 "\t" $3 "\t" $4 ; else print $0}' | sort -u > little

~/bin/bigWigAverageOverBed -bedOut=out2.bed /project/umw_zhiping_weng/0_metadata/encode/data/$experiment/$dsig.bigWig little out2

sort -k1,1 out2 | awk 'BEGIN{print "'$dsig'"}{print $4}' > $LSB_JOBINDEX".Results"
