#!/usr/bin/env bash

#
# take unstuttered srnaoutput and pass the rev complement of the miRNA to blast  
#


PROJECTDIR='/afs/andrew.cmu.edu/usr19/wforan1/project/';
SRNADATA=$PROJECTDIR/bridge/srna_unstuttered.txt
function posFromSrnaloopOutput(){
 #take 10;chr#:##-### pos_in_fasta 5/3 length  score
 #print chr#:###-### for both ends

 awk -v m=$1 -F'[ ;:-]' '{s=$3-$5;e=s+$7; print $2 ":" s "-" s+m "\t" $7; print $2 ":" e-m "-" e "\t" $7}' $SRNADATA
}
#

miRNASize=22
#blast for miRNA targets
posFromSrnaloopOutput $miRNASize | head |while read pos len; do
 $PROJECTDIR/scripts/pos2seq.pl $pos | tr ATCG TAGC|rev |
 blastn -db $PROJECTDIR/data/blastdbs/pf7 -dust no -word_size $(($len/3 -2)) |
 ../scripts/parseBlast.pl 22 $pos
done
