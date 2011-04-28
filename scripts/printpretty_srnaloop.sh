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
	' $1 |sort -k 1,1n -k 2,2n -k 6,6n  | 
perl -ne '
INIT{ @line=("initialization",0,0,0,0); $end=0;  $dist=15;}
  my @newline = split /\s/;

  if($line[0] ne $newline[0] || $end+$dist<$newline[1]){
   print join(" ",@line),"\n" unless $line[0] eq "initialization";
   @line=@newline; #update line b/c its a new region
  } 
  elsif($newline[2]>$line[2]){
    @line=@newline; #update line b/c this has a better score
  }
  else{
    #do nothing?
    #but update end; done for all
  }
  $end=$line[1];
'
