#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;
require '/home/wforan1/pj/scripts/parseBlast.pm';

my $PROJECTDIR="/home/wforan1/pj";
my %plasmoOpts=('db'=>"$PROJECTDIR/data/blastdbs/mirbase", 'seq'=>'UACACUGUGGAUCCGGUGAGGUAGUAGGUUGUAUAGUUUGGAAUAUUACCACCGGUGAAC');
my @hits=blast(\%plasmoOpts);

for my $ref (@hits){
  print Dumper($ref), "\n";
}

