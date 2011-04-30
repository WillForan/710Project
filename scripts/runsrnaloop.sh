#!/usr/bin/env bash
length=70
score=23

##run srnaloop and pretty-ify the output
#celgans
#srnaloop -t $score -sf ../data/genome/cel/celg_intergenic.fasta -o ../data/predict/celg_srna_s30.txt -l $length
#./printpretty_srnaloop.sh ../data/predict/celg_srna_s30.txt > ../data/predict/celg_srna_unstuttered.txt

#plasmo
srnaloop -t $score -sf ../data/genome/plasmo_intergenic.fasta -o ../data/predict/plasmo_srna_s30.txt -l $length
./printpretty_srnaloop.sh ../data/predict/plasmo_srna_s30.txt > ../data/predict/plasmo_srna_unstuttered.txt

#output frequencies
paste \
<(awk '{print length($5);print length($6);}' ../data/predict/plasmo_srna_unstuttered.txt |sort -n |uniq -c) \
<(awk '{print length($5);print length($6);}' ../data/predict/celg_srna_unstuttered.txt |sort -n |uniq -c) | tee -a ../data/srna_freqs.txt
