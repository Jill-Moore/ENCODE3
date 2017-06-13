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
files=/home/jm36w/Lab/Results/V4-hg19/Rampage-List.txt
width=50

mkdir -p /home/jm36w/Lab/Results/V4-hg19/rampage/$LSB_JOBID"-"$LSB_JOBINDEX
cd /home/jm36w/Lab/Results/V4-hg19/rampage/$LSB_JOBID"-"$LSB_JOBINDEX

experiment=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $1}' $files)
signal=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $2}' $files)
bigwig=/project/umw_zhiping_weng/0_metadata/encode/data/$experiment/$signal.bigWig


awk '{printf "%s\t%.0f\t%.0f\t%s\n", $1,$2-'$width',$3+'$width',$4}' $tss | \
    awk '{if ($2 < 0) print $1 "\t" 0 "\t" $3 "\t" $4 ; else print $0}' | \
    sort -u > tmp.bed

~/bin/bigWigAverageOverBed $bigwig tmp.bed out2

sort -k1,1 out2 | awk 'BEGIN{print "'$dsig'"}{print $4}' > $LSB_JOBINDEX".Results"

rm out2 tmp.bed
