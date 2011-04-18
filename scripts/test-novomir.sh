#!/usr/bin/env bash

#test novomir with c. elgans matching miRNA in miRBase
#without arguments, tries to add lengths to start, end, and both
#with arguments, passes to novomir and prints output to stats file
#e.g
#for i in {0..9}; do ./forelegence.sh -e .$i; done;

BASE="/afs/andrew.cmu.edu/usr/wforan1/project/"
OUTFILE=${BASE}outputs/novomir-celgans-test.txt
ELFILE=${BASE}outputs/hairpin_cel_info.fa
RANDFILE=${BASE}outputs/random_sequences.fa

function find_elgans(){
    
    if [ ! -e $ELFILE ]; then
	cut -s -f 1,4,5,7   ${BASE}data/miRBase/cel/cel.gff > $ELFILE
    fi
    cat $ELFILE
}
function random_seq(){
    if [ ! -e $RANDFILE ]; then
       echo "generating random file";
       CHROM=(I II III IV V X M);
       for i in {1..175}; do
          echo -n ".";
          c=${CHROM[$(($RANDOM%7))]};
          chrm=${BASE}data/genome/cel/chr$c.fa #random chromosome
          chrmwc=$(( $(wc -l $chrm | cut -f 1 -d ' ') -1));
          echo ">$i" >> $RANDFILE;
          #sed -n $((2+$RANDOM%$chrmwc))p $chrm >> $RANDFILE #random line
          sed -n $((2+$RANDOM%$chrmwc))p $chrm >>  $RANDFILE #random line
          #hairpins: smallest 54, longest 117, avg 90 --  cut -s -f 4,5 cel.gff |awk '{print $2-$1}'|sort -n| uniq -c
          s=$((1+$RANDOM%($chrmwc*50)));
          ${BASE}scripts/el2seq.pl -c chr$c -s $(($s)) -e $(($s+55+$RANDOM%60)) >> $RANDFILE;

       done
    fi
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
   grep  is_MIRNA | awk 'BEGIN{c=0} (!/.0/){c=1+c} END{print NR " " c " " NR-c " " (NR-c)/175}' | tee -a $OUTFILE;
}


echo -e "\n$(date)" >> $OUTFILE 

if [ "$1 x" != " x" ]; then 

    random_seq
    echo "with arguments: $@" | tee -a $OUTFILE;
    tmpfile=$(mktemp);
    find_elgans | prepair_fasta 0 0 > $tmpfile 
    echo -en "miRBase:\t" | tee -a $OUTFILE;
    novomir $@ -f $tmpfile | to_output;
    echo -en "random:\t" | tee -a $OUTFILE;
    novomir $@ -f $RANDFILE | to_output;

    exit;
fi

for lr in {"0 0","70 70","70 0","0 70"}; do
    echo left extra  right extra: $lr| tee -a $OUTFILE
    tmpfile=$(mktemp);
    find_elgans | prepair_fasta $lr > $tmpfile 
    novomir -f $tmpfile | to_output; 
done;

