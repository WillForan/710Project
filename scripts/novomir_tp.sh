#!/usr/bin/env bash

for thres in {.5,.9,2}; do 
    for energy in {.1,.5,1}; do 
	    for len in {30,50,70,90}; do 
	        name=../outputs/srnaloop/celg_novo_truepositive_${len}_${energy}_${thres}.txt
		#novomir -t $thres -e $energy -m $len -f ../data/miRBase/elegans_hairpin.fa > $name
		echo -ne "t: $thres e: $energy, t:$len\n   total: ";
		grep is_MIRNA $name | wc -l 

		echo  "   uniquiness:"
		awk -F '-' '(/is_MIRNA/){print $3}' $name | uniq -c | sort -nr | cut -f7 -d' '| uniq -c;
		#awk 'BEGIN{score=0;len=0} {score=score+$4; len=len+$3} END{print "    avg score: " score/NR " len: " len/NR}' ../outputs/srnaloop/celg_srnaloop_tp_unstut_${len}_$thres.txt
		#echo -e "    uniqness";
		#cut -f1 -d' ' $name | sort | uniq -c |cut -f7 -d' '|sort  |uniq -c
	    done |tee -a ../outputs/novo/novo_params.txt;
    done
done
echo
