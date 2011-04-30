#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;
require '/home/wforan1/pj/scripts/parseBlast.pm';
require '/home/wforan1/pj/scripts/parseNovomir.pm';

my %blastOpts;
my $novofile='/home/wforan1/pj/data/predict/plasmo_novoout.txt';
my $PROJECTDIR="/home/wforan1/pj";


$blastOpts{'db'} = "$PROJECTDIR/data/blastdbs/mirbase";
$blastOpts{'p'}  = 90;

my @mirs=parseNovomir($novofile);

for my $mir (@mirs){
    #print STDERR ". ";

    $blastOpts{'seq'}= $mir->{'seq'};
    #$blastOpts{'l'}  = length($mir->{'seq'})-length($mir->{'seq'})/2;
    
    my @hits=blast(\%blastOpts);

    for my $hit (@hits){
        my $name= join (' ', (split /\s/, $hit->{'name'})[3,4] );
	print join("\t", $name, $hit->{'percent'}, $hit->{'align'}), "\n";
	#print Dumper($hit),"\n";
    }
}



exit;
