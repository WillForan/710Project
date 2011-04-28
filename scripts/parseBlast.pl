#!/usr/bin/env perl
use strict; use warnings;

die "Usage: $0 seq_length miRNA_pos\n" if(!$ARGV[1]);

my $LEN=shift;
my $POS=shift;
my $var=2; #set to 1 for exact length only
my $per=98;

my $chr=0;
my $start=0;
my $end=0;
my @cont_bits;

my $id=0; my $l=0; my $gap=0;

while(<>) {
    if(/^> psu\|Pf3D7_(\d+)/){
      $chr=sprintf('%d',$1);
    }
    elsif (/^ Ident/){
     ($l,$id)=(split/[ \/]/)[4,5];
     $id=~s/[(),%]//g;
    }
    elsif(/^Query/){
     $start=0;
     $end=0;
     @cont_bits=();
     my $align="";
     $_=<>;
     while(/(Query)|(Sbjct)|(\|+)/){
       if(/Sbjct  (\d+) .* (\d+)$/){
        #print $_;
	$start=$1 if $start==0;
        $end=$2;
       }
       elsif(/\|+/){
        s/^\s+//;
	$align.=$_;
       }
       else { #do nothing
       }
       $_=<>;
     }
      while($align=~/\|+/g){
	   push @cont_bits, length($&);
      }   
     print "$id, ",$LEN-$l,", chr$chr:$start-$end \t($POS)\n" if($l>$LEN-$var && $id>=$per && $cont_bits[0]>=$l/3 && $#cont_bits<3 );
    }
    else { 
	#slip line
    }
}

