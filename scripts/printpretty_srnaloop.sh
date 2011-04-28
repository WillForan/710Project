#!/usr/bin/env bash

if [ ! -n "$1" ]; then
 echo "$0 srnaloopoutput.txt"
 exit;
fi

perl -ne 'chomp; 
        BEGIN{$name; $pos; $len; $score;$mirna;$mis}
	if(m/Name: (.*)/){$name=$1;}
	elsif(m/Position: (.*) \(\d/){$pos=$1;} #$strand=$2;
	elsif(m/Length: (\d+)/){$len=$1}
	elsif(m/Score: (\d+)/){$score=$1}
	elsif(m/Sequence \(.*: ([UAGC-]+)[aucg]+/){$mirna=$1; $mirna=~tr/U-/T/d;}
	elsif(m/\s([UAGC-]+)/){$mis=$1; $mis=~tr/U-/T/d;
	  print "$name $pos $len $score $mirna $mis\n"}
	else{ }
	' $1 #|sort -k 1,1n -k 2,2n -k 6,6n 
