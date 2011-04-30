#!/usr/bin/env perl
use strict; use warnings;
require '/home/wforan1/pj/scripts/parseNovomir.pm';

my @mirs=parseNovomir('/home/wforan1/pj/data/predict/plasmo_novoout.txt');
for my $ref (@mirs){
 print sprintf "%.1f\n", $ref->{'meanval'};
}

exit;
