#!/usr/bin/env perl
use strict; use warnings;

#fix shutttering 
# i.e.
#1500	chrI:100617-100705	-21.10	88
#1530	chrI:100619-100702	-20.20	83
#
#
#
my @line=('init');
my $left_end=0;
my $right_end=0;
my $DIST=10;
while(<>){
  chomp;
  my @newline = split /[-:\s]/;
  $newline[0]=~s/chr//;

  if($line[0] ne $newline[0] || 
  	($left_end+$DIST<$newline[1] && $right_end+$DIST<$newline[2])    
    ){
   #print join(" ",@line),"\n" unless $line[0] eq 'init';
   print "chr$line[0]:$line[1]-$line[2]",join("\t",@line[3..$#line]),"\n" unless $line[0] eq 'init';
   #print $oldline, "\n" unless $line[0] eq 'init';
   @line=@newline; #update line b/c its a new region
  } 
  elsif($newline[4]>$line[4] || 			  #better score (now positive)
      ($newline[4]==$line[4] && $newline[5]>$newline[5])  #same score, better length
  ){
    @line=@newline; #update line b/c this has a better score
  }
  else{
    #do nothing?
    #but update end; done for all
  }
  $left_end=$line[1];
  $right_end=$line[2];

}
