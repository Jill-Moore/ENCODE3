module load bedtools/2.25.0
module load python/2.7.5

d=$1
peakType=$2
dataDir=/project/umw_zhiping_weng/0_metadata/encode/data

if [[ $2 == "mm10" ]]
then
TSS=~/Lab/Reference/Mouse/GencodeM4/TSS.4K.bed
elif [[ $2 == "hg19" ]]
TSS=~/Lab/Reference/Human/Gencode19/TSS.4K.bed
fi

dset=$(grep $d Data-Files | awk -F "\t" '{print $5}')
dsig=$(grep $d Data-Files | awk -F "\t" '{print $7}')
dpeaks=$(grep $d Data-Files | awk -F "\t" '{print $6}')

hset=$(grep $d Data-Files | awk -F "\t" '{print $1}')
hsig=$(grep $d Data-Files | awk -F "\t" '{print $3}')
hpeaks=$(grep $d Data-Files | awk -F "\t" '{print $2}')

genes=$(grep $d Data-Files | awk -F "\t" '{print $8}')

if [[ peakType == "H3K4me3" ]]
then
    cp $dataDir/$hset/$hpeaks.bed.gz hpeaks.bed.gz
    gunzip hpeaks.bed.gz
    bedtools intersect -u -a hpeaks.bed -b $TSS | sort -rgk8,8 -rgk7,7 | \
        awk '{print $1 "\t" $2 "\t" $3 "\t" "Peak_"NR "\t" $5 "\t" $6 "\t" \
        $7 "\t" $8}' > T
elif [[ peakType == "DNase" ]]
then
    cp $dataDir/$dset/$dpeaks.bed.gz dpeaks.bed.gz
    gunzip dpeaks.bed.gz
    bedtools intersect -u -a dpeaks.bed -b $TSS | sort -rgk8,8 -rgk7,7 | \
        awk '{print $1 "\t" $2 "\t" $3 "\t" "Peak_"NR "\t" $5 "\t" $6 \
        "\t" $7 "\t" $8}' > T
fi

j=1500
awk -F "\t" '{printf "%s\t%.0f\t%.0f\t%s\n", $1,($3+$2)/2-'$j',($3+$2)/2+'$j',$4}' T \
    | awk '{if ($2 < 0) print $1 "\t" 0 "\t" $3 "\t" $4 ; else print $0}' | \
    sort -u > little
~/bin/bigWigAverageOverBed -bedOut=out3.bed $dataDir/$hset/$hsig.bigWig little out3 

j=150
awk -F "\t" '{printf "%s\t%.0f\t%.0f\t%s\n", $1,($3+$2)/2-'$j',($3+$2)/2+'$j',$4}' T \
    | awk '{if ($2 < 0) print $1 "\t" 0 "\t" $3 "\t" $4 ; else print $0}' | \
    sort -u > little
~/bin/bigWigAverageOverBed -bedOut=out2.bed $dataDir/$dset/$dsig.bigWig little out2

bedtools intersect -wo -a T -b $TSS > intersections
python tmp.py $genes.tsv intersections out2 out3 > test
sort -k2,2rg test | awk '{print $0 "\t" NR}' | sort -k3,3rg | \
    awk '{print $0 "\t" NR}' | sort -k4,4rg | awk 'BEGIN{a=0; r=1}{if ($4 == a) \
    print $0 "\t" r; else {print $0 "\t" NR; r=NR+1}; a=$4}' > $d.final.New
