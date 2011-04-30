#!/usr/bin/env perl
use strict; use warnings;

sub USEAGE() {
    print "Usage: blastoutput | $0 \n";
    print "optional: -p min_percentID -l min_length\n";
    exit;
}

use Getopt::Std;
my %opt=('p'=>-1,'l'=>-1);
getopts('p:l:e:',\%opt);

my $seq;
my $start=0;
my $end=0;

my $id=0; my $l=0; my $gap=0;

my $extra=exists($opt{'e'})?$opt{'e'}."\t":"";

while(<>) {
    #if(/^> $chromregex/){
    #  $chr=sprintf('%d',$1);
    #}
    if(/^>/){
      chomp;
      $seq=$_;
    }
    elsif (/^ Ident/){
     ($l,$id)=(split/[ \/]/)[4,5];
     $id=~s/[(),%]//g;
    }
    elsif(/^Query[^=]/){
     $start=0;
     $end=0;
     my $align="";
     $_=<>;
     while(/(Query)|(Sbjct)|(\|+)|(^$)/){
       if(/Sbjct  (\d+) .* (\d+)$/){
	$start=$1 if $start==0;
        $end=$2;
       }
       elsif(/\|+/){
        chomp;
        s/^\s+//;
	$align.=$_;
       }
       else { #do nothing
       }
       $_=<>;
     }
      #while($align=~/\|+/g){
      #	   push @cont_bits, length($&);
      #}   
     #print "$id, ",$LEN-$l,", chr$chr:$start-$end \t($EXTRA)\n" if($l>$LEN-$var && $id>=$per && $cont_bits[0]>=$l/3 && $#cont_bits<3 );

     print $extra,
     	  join("\t",$seq, $id,$start, $end,$l,$align),"\n" 
       unless ($l<$opt{'l'} || $id<$opt{'p'});
    }
    else { 
	#slip line
    }
}

