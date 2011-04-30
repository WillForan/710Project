#!/usr/bin/env bash

#
# take unstuttered srnaoutput and pass the rev complement of the miRNA to blast  
#
#./blastForPredictions.sh ../data/predict/plasmo_srna_unstuttered.txt | tee ../data/predict/plasmo_srnaWithEnergy.txt
#./blastForPredictions.sh ../data/predict/celg_srna_unstuttered.txt | tee ../data/predict/celg_srnaWithEnergy.txt


PROJECTDIR='/home/wforan1/pj/';
#UTRDB=$PROJECTDIR/data/blastdbs/plasmoUTRs; 
UTRDB=$PROJECTDIR/data/blastdbs/celUTRs; 

#SRNADATA=$PROJECTDIR/data/predict/plasmo_srna_unstuttered.txt
if [ -n "$1" ]; then
 SRNADATA=$1;
else
 echo "USEAGE: $0 srnaloop_unstuttered"
 echo "writes to utrblast and mirblast files for seq where energy criteria is met"
 echo "tee to energy file to save energies"
 exit;
fi
#1;chr1:1-11513 10270 110 33 GTTATGTCACTCATGATGTTAGTGATGTTGTTAGTAGTCATGTAAGTAGTCAT TAGTACAGACTGTACTGACGATTGTAATGATGATTGTACTGATTCTTGTA

function blastUTR(){
  seq=$1;
  name=$2;
  len=${#seq};
  echo $seq|  $PROJECTDIR/bin/blastn -db $UTRDB -dust no -word_size $(($len/3 -2)) |
 $PROJECTDIR/scripts/pB.pl -l $(($len-$len/8)) -e $name  
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
if [ -e ../data/predict/${org}_utrblast ]; then
 echo remove file ../data/predict/${org}_utrblast then run
 exit
fi;
if [ -e ../data/predict/${org}_mirblast ]; then
 echo remove file ../data/predict/${org}_mirblast then run
 exit
fi;
cat $SRNADATA |while read name number length score seq1 seq2; do
 seq=$(wholeSeq $length ${name} ${number});
 energy=$(energy $seq);
 if [ $energy -lt -18 ]; then
    echo $energy $name $number $length $score;# >> ../data/predict/${org}_srnaloop_withenergy.txt; #pipe to tee instead
    blastUTR $seq1 ${name}_${number} >> ../data/predict/${org}_utrblast
    blastUTR $seq2 ${name}_${number} >> ../data/predict/${org}_utrblast
    blastSeq $seq 		     >> ../data/predict/${org}_mirblast

 fi

done
