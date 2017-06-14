#Jill E. Moore - Jill.Elizabeth.Moore@gmail.com
#Weng Lab - UMass Medical School
#ENCODE Encyclopedia Version 4
#Updated June 2017

# To run:
# ./calcuate-max-zscore.py Data-List.txt signalDir

import sys

def Compare_Zscore(signalOutput, rdhsDict):
    signalOutput=open(signalOutput)
    for line in signalOutput:
        line=line.rstrip().split("\t")
        if line[0] not in rdhsDict:
            rdhsDict[line[0]]=float(line[1])
        elif float(line[1]) > rdhsDict[line[0]]:
            rdhsDict[line[0]]=float(line[1])
    signalOutput.close()
    return rdhsDict

signalFiles=open(sys.argv[1])
signalDir=sys.argv[2]
rdhsDict={}

for line in signalFiles:
    line=line.rstrip().split("\t")
    signalOutput=signalDir+"/"+line[0]+"-"+line[1]+".txt"
    print signalOutput
    rdhsDict=Compare_Zscore(signalOutput, rdhsDict)

for rdhs in rdhsDict:
    print rdhs+"\t"+str(rdhsDict[rdhs])

signalFiles.close()
