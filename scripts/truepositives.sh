#!/usr/bin/env bash

for len in {70,90,110}; do 
	for thres in {23,30}; do 
	    #srnaloop -t $thres -l $len -sf ../data/miRBase/elegans_hairpin.fa -o ../outputs/srnaloop/celg_srnaloop_truepositive_$len.txt 1>/dev/null
	    #./printpretty_srnaloop.sh ../outputs/srnaloop/celg_srnaloop_truepositive_$len.txt > ../outputs/srnaloop/celg_srnaloop_tp_unstut_${len}_$thres.txt;
	    #rm ../outputs/srnaloop/celg_srnaloop_truepositive_$len.txt;
	    echo -ne "l: $len, t:$thres\ttotal: ";
	    wc -l ../outputs/srnaloop/celg_srnaloop_tp_unstut_${len}_$thres.txt | cut -f1 -d' '
	    awk 'BEGIN{score=0;len=0} {score=score+$4; len=len+$3} END{print "    avg score: " score/NR " len: " len/NR}' ../outputs/srnaloop/celg_srnaloop_tp_unstut_${len}_$thres.txt
	    echo -e "    uniqness";
	    cut -f1 -d' ' ../outputs/srnaloop/celg_srnaloop_tp_unstut_${len}_$thres.txt  | sort | uniq -c |cut -f7 -d' '|sort  |uniq -c
	done |tee -a ../outputs/srnaloop/celg_params.txt;
done

#novomir ../data/miRBase/elegans_hairpin.fa
