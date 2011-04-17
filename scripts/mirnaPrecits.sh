#!/usr/bin/env bash

export PATH=$PATH:/afs/andrew.cmu.edu/usr/wforan1/project/bin/
BASE="/afs/andrew.cmu.edu/usr/wforan1/project/"

srnaloop -sf $BASE/data/genome/pf71.fasta -o $BASE/outputs/srnaloop-run1.txt -t 25
