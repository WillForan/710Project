#!/usr/bin/env bash

#
# take unstuttered srnaoutput and pass the rev complement of the miRNA to blast  
#


PROJECTDIR='/home/wforan1/pj/';
SRNADATA=$PROJECTDIR/data/predict/plasmo_srna_unstuttered.txt
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
function blastMB(){
  seq=$1;
  name=$2;
  len=${#seq};
  echo $seq|  $PROJECTDIR/bin/blastn -db $PROJECTDIR/data/blastdbs/mirbase -dust no -word_size $(($len/3 -2)) |
 $PROJECTDIR/scripts/pB.pl -l $(($len-$len/8)) -e $name  -p 90
}
awk -F' ' '{print $1,$2,$5,$6}' $SRNADATA |while read name number seq1 seq2; do
 #echo -n '.'
 #blastUTR $seq1 ${name}-${number} >> ../data/predict/_utr
 #blastUTR $seq2 ${name}-${number} >> ../data/predict/_utr
 blastMB $seq1$seq2 ${name}_${number} #> ../data/predict/_mirblast
done
echo 
