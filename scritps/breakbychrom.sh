 #!/usr/bin/env bash

# create chr#.fa
#USEAGE
# $0 < pf7.fasta
#
#

DATADIR="/afs/andrew.cmu.edu/usr/wforan1/project/data/genome/"

#echo "will remove all chr*fa files without interupt right now"; 
#read;

rm $DATADIR/chr*fa;

chr=0;
while read line; do  
 	if [ "$(echo $line|sed -e 's/^>.*//') x" = " x" ]; then 
		chr=$(($chr+1)); 
	fi;
	echo $line  >> $DATADIR/chr$chr.fa;
done 
