#!/usr/bin/env perl
use strict; use warnings;

sub USEAGE() {
    print "Usage: $0 -l length\n";
    print "optional: -e extra_print[''] -v length_varienc[2] -p percentID[98] -c chromregex[Pf3D7_(\\d+)]\n";
    exit
}

use Getopt::Std;
my %opt=('v'=>2,'p'=>98,e=>'',c=>'psu\|Pf3D7_(\d+)');
getopts('v:p:l:e:c:',\%opt);

USEAGE() if(!defined($opt{'l'}));

my $LEN=$opt{'l'};
my $EXTRA=$opt{'e'};

my $var=$opt{'v'}; #set to 1 for exact length only
my $per=$opt{'p'};
my $chromregex=$opt{'c'};

my $chr=1;
my $seq;
my $start=0;
my $end=0;
my @cont_bits;

my $id=0; my $l=0; my $gap=0;

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
     @cont_bits=();
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
     print join("\t",$seq, $id,$start, $end,$l,$align),"\n" unless $chr==0;
    }
    else { 
	#slip line
    }
}

