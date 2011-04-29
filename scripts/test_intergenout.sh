#!/usr/bin/env bash

awk 'END{print "\n"} {if(/^>/){printf "\n"substr($0,2)" "}else{printf $0} }' ../bridge/celg_intergenic.fasta | 
while read pos seq; do
	if [ -n "$seq" ]; then 
	   diff=$(echo  "$pos-1" | sed 's/^.*chr.*://' | bc  |tr -d '-'  )
	   wc=$(echo $seq |wc -m); 
	   if [ $wc -ne $diff ]; then
	       echo -ne "$pos\t"
	       echo -e "$diff\t$wc";
	   fi
	fi; 
done; 
