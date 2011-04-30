#!/usr/bin/env bash

#
# take unstuttered srnaoutput and pass the rev complement of the miRNA to blast  
#


PROJECTDIR='/home/wforan1/pj/';
#SRNADATA=$PROJECTDIR/data/predict/plasmo_srna_unstuttered.txt
if [ -n $1 ]; then
 SRNADATA=$1;
else
 echo "USEAGE: $0 srnaloop_unstuttered"
 echo "output blast hits"
 exit;
fi
#1;chr1:1-11513 10270 110 33 GTTATGTCACTCATGATGTTAGTGATGTTGTTAGTAGTCATGTAAGTAGTCAT TAGTACAGACTGTACTGACGATTGTAATGATGATTGTACTGATTCTTGTA

function blastUTR(){
  seq=$1;
  name=$2;
  len=${#seq};
  echo $seq|  $PROJECTDIR/bin/blastn -db $PROJECTDIR/data/blastdbs/plasmoUTRs -dust no -word_size $(($len/3 -2)) |
 $PROJECTDIR/scripts/pB.pl -l $len -e $name  
}
function wholeSeq(){
  len=$1
  position=$(echo $2|sed -e 's/.*;//;'|awk -v len=$len -v pos=$3 -F'[:-]' '{print $1 ":" $2+pos"-" $2+pos+len}')
  $PROJECTDIR/scripts/seq.pl $position
}
function blastSeq(){
  echo $1 |  $PROJECTDIR/bin/blastn -db $PROJECTDIR/data/blastdbs/mirbase -dust no -gapextend 0 -word_size $(($len/3 -2)) |
 $PROJECTDIR/scripts/pB.pl -l $(($len-5)) -e $name  -p 90
}
function energy(){
   energy=$(echo $1 | RNAfold -noPS | tail -n1| sed 's/.*( *\(-[0-9]\+\.[0-9]\+\))/\1/')
   if [ ${#energy} -gt 8 ]; then
     echo 0; return;
   fi
   printf "%.0f\n" $energy
}

org=$(basename $1 _srna_unstuttered.txt);
if [ -e ../data/predict/${org}_utr ]; then
 echo remove file ../data/predict/${org}_utr then run
 exit
fi;
awk -F' ' '{print $1,$2,$3,$5,$6}' $SRNADATA |while read name number length seq1 seq2; do
 #echo -n '.'
 #blastUTR $seq1 ${name}-${number} >> ../data/predict/_utr
 #blastUTR $seq2 ${name}-${number} >> ../data/predict/_utr
 #blastMB $seq1$seq2 ${name}_${number} #> ../data/predict/_mirblast
 seq=$(wholeSeq $length ${name} ${number});
 energy=$(energy $seq);
 if [ $energy -lt -18 ]; then
    echo $energy $name;
    blastUTR $seq1 ${name}_${number} >> ../data/predict/${org}_utrblast
    blastUTR $seq2 ${name}_${number} >> ../data/predict/${org}_utrblast
    #blastSeq $seq 		     >> ../data/predict/${org}_mirblast

 fi
 #blastSeq $seq #> ../data/predict/_mirblast

done
