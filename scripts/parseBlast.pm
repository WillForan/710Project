#!/usr/bin/env perl
use strict; use warnings;
use Carp;

sub blast{
    my %opt=%{$_[0]};
     
     croak "no database to blast" if(!exists($opt{'db'}));
     croak "no sequence to blast" if(!exists($opt{'seq'}));
     $opt{'p'}=-1 if(!exists($opt{'p'}));
     $opt{'l'}=-1 if(!exists($opt{'l'}));
     $opt{'dust'}="no" if(!exists($opt{'dust'}));
     $opt{'options'}="" if(!exists($opt{'options'}));

    open my $bhandle, 
       "echo $opt{'seq'} | blastn -db $opt{'db'} -dust $opt{'dust'} $opt{'options'} | " or
       croak "Could not open blast pipe: $!\n"; #open a pipe

    my @hits; #hits to return

    my %hit;
    while(<$bhandle>) {
	$hit{'start'}=0;
	#if(/^> $chromregex/){
	#  $chr=sprintf('%d',$1);
	#}
	if(/^>/){
	  chomp;
	  $hit{'name'}=$_;
	}
	elsif (/^ Ident/){
	 ($hit{'length'},$hit{'percent'})=(split/[ \/]/)[4,5];
	 $hit{'percent'}=~s/[(),%]//g;
	}
	elsif(/^Query[^=]/){
	 $hit{'start'}=0;
	 $hit{'end'}=0;
	 $hit{'align'}="";
	 $_=<$bhandle>;
	 while(/(Query)|(Sbjct)|(\|+)|(^$)/){
	   if(/Sbjct  (\d+) .* (\d+)$/){
	    $hit{'start'}=$1 if $hit{'start'}==0;
	    $hit{'end'}=$2;
	   }
	   elsif(/\|+/){
	    chomp;
	    s/^\s+//;
	    $hit{'align'}.=$_;
	   }
	   else { #do nothing
	   }
	   $_=<$bhandle>;
	 }
	 my %hit_tmp=%hit; #bad structure :(
	 push (@hits,\%hit_tmp) unless ($hit{'start'}=0 || $hit{'length'}<$opt{'l'} || $hit{'percent'}<$opt{'p'});
	}
	else { 
	    #slip line
	}
    }
    return @hits;
}
1;
