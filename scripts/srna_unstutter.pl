#!/usr/bin/env perl
use strict; use warnings;

#fix shutttering 
# i.e.
#10;chr1:66050-71857 5131 5 75 30
#10;chr1:66050-71857 5136 5 74 30
#10;chr1:66050-71857 5141 5 75 30
#
# start with srnaloop -s 30 intergenic.
#e.g. ./srna_display_results.sh ../bridge/srnaloop_score30.txt | ./srna_unstutter.pl  | wc -l
#
my @line=('initialization',0,0,0,0);
my $end=0;
my $DIST=5;
while(<>){
  my @newline = split /\s/;
  chomp($newline[4]);

  if($line[0] ne $newline[0] || $end+$DIST<$newline[1]){
   print join(" ",@line),"\n" unless $line[0] eq 'initialization';
   @line=@newline; #update line b/c its a new region
  } 
  elsif($newline[4]>$line[4]){
    @line=@newline; #update line b/c this has a better score
  }
  else{
    #do nothing?
    #but update end; done for all
  }
  $end=$line[1];

}
