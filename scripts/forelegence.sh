#!/usr/bin/env bash

#test novomir with c. elgans matching miRNA in miRBase

BASE="/afs/andrew.cmu.edu/usr/wforan1/project/"
OUTFILE=${BASE}outputs/novomir-celgans-test.txt

function find_elgans(){
    cut -s -f 1,4,5,7   ${BASE}data/miRBase/cel/cel.gff 
}
function prepair_fasta(){
    left=$1;
    right=$2;
    i=0;
    while read c s e strand; do 
	i=$(($i+1));
	s=$(($s-$left)); e=$(($e+$left));
	if [ $strand == "-"  ]; then
	  tmp=$s; s=$e; e=$tmp;
	fi

	echo ">$i";
	${BASE}scripts/el2seq.pl -c chr$c -s $s -e $e; 
    done;
}
function to_output(){
   grep  is_MIRNA | awk 'BEGIN{c=0} (!/.0/){c=1+c} END{print NR " " c}' | tee -a $OUTFILE;
}


echo -e "\n$(date) - $i c. elgans miRNAs" >> $OUTFILE 

if [ "$1 x" != " x" ]; then 
    echo "with arguments: $@";
    tmpfile=mktemp;
    find_elgans | prepair_fasta $lr > $tmpfile 
    novomir $@ -f $tmpfile | to_output;
    exit;
fi

for lr in {"0 0","70 70","70 0","0 70"}; do
    echo left extra  right extra: $lr| tee -a $OUTFILE
    tmpfile=mktemp;
    find_elgans | prepair_fasta $lr > $tmpfile 
    novomir -f $tmpfile | to_output; 
done;

