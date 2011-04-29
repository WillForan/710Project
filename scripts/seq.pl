#!/usr/bin/env perl
use strict; use warnings;

use POSIX;
use Switch;
#use Data::Dumper;

sub USAGE(){
    print "USAGE: $0 chr1:100-400 OR $0 -c chr1 -s 100 -e 400 -o plasmo\n";
    print "Will try to guess organs by chr#/X, -o takes 'elg' or 'plasmo'\n";
    print "-n will include newlines, -C will make all caps\n";
    exit;
}
#where the bychrom fasta files are
my $BASE; #='/afs/andrew.cmu.edu/usr/wforan1/project/data/genome/';

my $rev=0;

#get what to do
use Getopt::Std;
my %opt=();
getopts('c:s:e:o:Cn',\%opt);
my ($chrm, $start,$end);
if(defined($opt{'c'}) && defined($opt{'s'}) && defined($opt{'e'}) ) {
    $chrm=$opt{'c'}; $start=$opt{'s'}; $end=$opt{'e'};
}
elsif($#ARGV[0] && ($ARGV[0]=~m/(.*):(.*)-(.*)/) ) {
     $chrm=$1;  $start=$2;  $end=$3;
     $chrm=~s/chr/chr/i;
}
else { USAGE(); }

#set organism option based on chrm type
if(!defined($opt{'o'})){
  switch($chrm){
      case /chr\d/ { $opt{'o'}='plasmo'; }
      case /chr[IXVM]/ { $opt{'o'}='celg';  }
      else { $opt{'o'}='unknown';  }
  }
}

#set base file based on organims
switch($opt{'o'}){
      case /plasmo/ {  $BASE='/afs/andrew.cmu.edu/usr/wforan1/project/data/genome/'; }
      case /elg/ {  $BASE='/afs/andrew.cmu.edu/usr/wforan1/project/data/genome/cel/'; }
      else { USAGE(); }
}

#if is reverse
if($start>$end){
    my $tmp=$start;
    $start=$end;
    $end=$tmp;
    $rev=1;
}


open my $cFILE, "$BASE$chrm.fa" or die "Cannot open $chrm.fa file: $!\n";

my $offset=length(<$cFILE>);    #all files should start with some >chr1 notation that should be removed from count

my $linesize=length(<$cFILE>)-1; #all next lines should be the same length + newline (e.g. 60+1 or 50+1)


#extra byte(newline) ever 50 chars + start  + $offset - starts at 1 not 0
my $pos=floor($start/$linesize) + $start + $offset - 1;

#difference in positions
my $diff=$end-$start;

#extra byte every 50 + actual diff
my $len=floor($diff/$linesize)+$diff;

#add one if there is an extra newline to overcome (ie. compansate for not starting at beg. of line)
$len+=1 if ($end%$linesize<$start%$linesize);

#get the file to the start
seek($cFILE,$pos,SEEK_SET);

#read the length
read($cFILE,my $seq, $len+1,0);
#done with file
close($cFILE);

#make presenentable
$seq=uc($seq) if defined($opt{'C'}); #case of nt has some information, default to showing it
$seq=~s/\n//g unless defined($opt{'n'}); #include newlines if asked

#tr and rev if is antisense
if($rev) {
    $seq=~tr/ATGC/TACG/;
    $seq=reverse $seq;
}

print $seq,"\n";
