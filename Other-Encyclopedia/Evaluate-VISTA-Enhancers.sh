#!/bin/bash

#Jill E. Moore - Jill.Elizabeth.Moore@gmail.com
#Weng Lab - UMass Medical School
#ENCODE Encyclopedia Version 4
#Updated May 2017

#./Evaluate-Enhancers.sh Hindbrain 10000 DNase H3K27ac

tissue=$1
min=$2
peakMethod=$3
signalMethod=$4


if [ $signalMethod == "DNase" ]
then
    width=150
else
    width=1000
fi


if [ $peakMethod == "DNase" ]
then
    awk -F "\t" '{printf "%s\t%.0f\t%.0f\t%s\n", $1,($3+$2)/2-'$width',\
    ($3+$2)/2+'$width',$4}' DNase-$tissue.bed | awk '{if ($2 < 0) print $1 "\t" 0 \
    "\t" $3 "\t" $4 ; else print $0}' > bed
else
    awk '{print $1 "\t" $2+$10-'$width' "\t" $2+$10+'$width' "\t" $4}' \
    $peakMethod"-"$tissue.bed > bed
fi

A=$(grep $tissue $signalMethod"-List.txt" | awk -F "\t" '{print $1}')
B=$(grep $tissue $signalMethod"-List.txt" | awk -F "\t" '{print $2}')

~/bin/bigWigAverageOverBed /data/projects/encode/data/$A/$B.bigWig bed \
    out.tab -bedOut=out.bed

awk '{print $1 "\t" $2+'$width'-150 "\t" $3-'width'+150 "\t" $4 "\t" $5}' \
    out.bed | sort -k5,5rg | head -n $min > bed
bedtools intersect -wo -a $tissue.bed -b bed > p

python pick.best.peak.py p 9 | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $9}' \
    >  $tissue-$peakMethod-$signalMethod-Results.txt
bedtools intersect -v -a $tissue.bed -b bed | awk '{print $1 "\t" $2 "\t" $3 \
    "\t" $4 "\t" 0 }' >> $tissue-$peakMethod-$signalMethod-Results.txt




