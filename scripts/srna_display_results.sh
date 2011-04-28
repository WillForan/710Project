#!/usr/bin/env bash

if [ ! -n "$1" ]; then
 echo "$0 srnaloopoutput.txt"
 exit;
fi

perl -ne 'chomp; 
	if(m/Name: (.*)/){print $1," ";}
	elsif(m/Position: (.*) \((\d)/){print "$1 $2 "}
	elsif(m/Length: (\d+)/){print $1," "}
	elsif(m/Strand: (\d+)/){print $1," "}
	elsif(m/Score: (\d+)/){print $1,"\n"}
	' $1 |sort -k 1,1n -k 2,2n -k 5,5n 
