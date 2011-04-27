#!/usr/bin/env bash

#useful stats about hairpin loops of c. elgans

fafile=elegans_hairpin.fa
if [ -n "$1" ]; then
 fafile=$1
fi

#paste together 
	#length frequencies   and
	#energy frequencies
paste \
<(awk  'BEGIN{count=0} {if($1 ~ /^>/){print count;count=0 } else { count=count+length($0)} }' $fafile| sort -n | uniq -c) \
<(perl -lane 'BEGIN{$seq=" ";} if(m/^>/){print $seq; $seq=""; next} chomp; $seq.=$_;' < $1 | while read seq; do
    echo $seq | RNAfold -noPS |
    perl -lne 'if(m/-\d+\.\d+/) {print sprintf("%.0f",$&)}'
    #perl -lane 'BEGIN{$score=0;} m/-\d+\.\d+/; $score=$&; print $score if(m/^[AUGC]/);' 
done | sort -nr | uniq -c)

