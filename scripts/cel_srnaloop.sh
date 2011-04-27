#!/usr/bin/env bash
OUTDIR="/afs/andrew.cmu.edu/course/10/810-s11/Submit/wforan1/Project/outputs/"
DATAD="/afs/andrew.cmu.edu/usr19/wforan1/project/data/genome/cel/"
GFF="/afs/andrew.cmu.edu/usr19/wforan1/project/data/miRBase/cel/cel.gff"
#
# TODO: 
#	*what relation to pos and length have?
#	*run results against mircheck or novomir
#	*chop up files
#
for c in {I,II,III,IV,V,X,M}; do
        out=${OUTDIR}chr$c.mirna
	if [  -e $out ]; then  
	        echo -ne "chr$c:\t"
		grep Position $out | cut -d' ' -f 3 | while read pos; do
			awk -v p=$pos -v c=$c '(c eq $1 &&  p>=$4-20 && p<=$5+20){print}' $GFF;
		done| wc -l
	else
	    ( srnaloop -t 20 -sf ${DATAD}chr$c.fa -o $out )&
	fi

done
