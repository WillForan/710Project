#!/usr/bin/env bash

cut -f 1,4,5   ../data/miRBase/cel/cel.gff | while read c s e; do echo ./el2seq.pl -c chr$c -s $s -e $e; done;
