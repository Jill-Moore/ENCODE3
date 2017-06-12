#Jill E. Moore - Jill.Elizabeth.Moore@gmail.com
#Weng Lab - UMass Medical School
#ENCODE Encyclopedia Version 4
#Updated May 2017

#This script is designed to run on UMass GHPCC (LSF Queue)
#Script for creating Jaccard Matrix for cRE Clustering Analysis

#BSUB -L /bin/bash
#BSUB -n 1
#BSUB -R rusage[mem=10000] # ask for memory
#BSUB -q short 
#BSUB -o "/home/jm36w/JobStats/%J.out"
#BSUB -e "/home/jm36w/JobStats/%J.error"
#BSUB -W 2:00
#BSUB -J "Process-Control[1-72]"

source ~/.bashrc

dset=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $1}' $files)
dsig=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $2}' $files)
dline=$(awk -F "\t" '{if (NR=='$LSB_JOBINDEX') print $0}' $files)

cd /home/jm36w/Lab/Results/V4-mm10/

file=h3k4me3-embryo
l=$(wc -l $file | awk '{print $1}')
dset=$(cat $file  | awk -F "\t" '{if (NR == '$LSB_JOBINDEX') print $1}')
dsig=$(cat $file  | awk -F "\t" '{if (NR == '$LSB_JOBINDEX') print $2}')
T=$(cat $file  | awk -F "\t" '{if (NR == '$LSB_JOBINDEX') print $3}')
awk 'FNR==NR {x[$4];next} ($1 in x)' /home/jm36w/Lab/Results/V4-mm10/mm10-cREs-Simple.bed /home/jm36w/Lab/Results/V4-mm10/signal-output/$dset"-"$dsig.txt > $LSB_JOBINDEX.1.sig

echo $T > col.$LSB_JOBINDEX

for k in $(seq $l)
do
hset=$(cat $file  | awk -F "\t" '{if (NR == '$k') print $1}')
hsig=$(cat $file  | awk -F "\t" '{if (NR == '$k') print $2}')
echo -e $T "\t" $hset
awk 'FNR==NR {x[$4];next} ($1 in x)' /home/jm36w/Lab/Results/V4-mm10/mm10-cREs-Simple.bed /home/jm36w/Lab/Results/V4-mm10/signal-output/$hset"-"$hsig.txt > $LSB_JOBINDEX.2.sig
python /home/jm36w/Projects/ENCODE/Encyclopedia/Version4/calculate.jaccard.py $LSB_JOBINDEX.1.sig $LSB_JOBINDEX.2.sig >> col.$LSB_JOBINDEX
done

