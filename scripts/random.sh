#!/usr/bin/env bash
#
# pick random continuous sequences from intergenic region of genome
#

#USAGE: echo 5 30 | ./random.sh ../data/genome/plasmo_intergenic.fasta

FILE=$1; #input file
SIZE=100; #Max size of two reads (120 for plasmo)

#get two lines (as one) from intergenic file ( only one if happens to hit '>' line)
function rndline(){
awk \
      -v num=$(( $RANDOM % $(wc -l $FILE|cut -f1 -d ' ') +1)) \
      '(NR==num || NR==num+1){ 
      	if(/^>/ || /^$/){ num=num+1 } 
      	else {print} 
      }' $FILE |
      xargs |sed -e 's/ //g'
}

#pick random segment of this sequence. Recruse if too short (e.g. rndline hit '>')
function sequence(){
    LENGTH=$1;
    START=$(($RANDOM%($SIZE-$LENGTH) +1 ));
    seq=$(rndline | cut -c$START-$(($START+$LENGTH -1)));
    if [ $(echo $seq|wc -m) -lt $LENGTH ]; then
       seq=$(sequence $LENGTH);
    fi
    echo $seq;
}

#for each input line as _# occurances_ of _length_, generate random lines of genome
while read freq length; do
  for ((i=1; i<=$freq; i++)); do
     echo ">random-$length-$i"
     sequence $length
  done;
done
