#!/usr/bin/env bash
curl 'http://plasmodb.org/common/downloads/release-7.1/Pfalciparum/fasta/data/PfalciparumAnnotatedCDS_PlasmoDB-7.1.fasta' |
 grep '^>'| sed -e 's/>psu|\(.*\?\)| o.*_\([0-9]\+.*\)(\([+-]\)) |.*/\3 \2 \1/'  > CDSregions.txt
