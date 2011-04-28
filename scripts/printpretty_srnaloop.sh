#!/usr/bin/env bash

PROJECTDIR='/afs/andrew.cmu.edu/usr19/wforan1/project/';

if [ ! -n "$1" ]; then
 echo "$0 srnaloopoutput.txt"
 exit;
fi

function blastit(){
    seq=$1;
    id=$2;
    echo $seq tr ATCG TAGC|rev |
     blastn -db $PROJECTDIR/data/blastdbs/plasmoUTRs -dust no -word_size $(($len/3 -2)) |
     $PROJECTDIR/scripts/parseBlast.pl ${#seq} $id
}
#parse srnaloop out to: id pos length score seq1 seq2
# then unstutter (remove matches within 15 of the next match)
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
	' $1 |sort -k 1,1n -k 2,2n -k 6,6n  |  #10;chr1:66050-71857 5131 75 30 TATA... ATGTA...
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
  $end=$line[1];' | #blast these for targets
while read id pos len score mirna mirstar; do
 blastit $mirna "$id-$pos"
 blastit $mirstar "$id-*$pos"
done
