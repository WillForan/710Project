#!/usr/bin/env bash
#
#make fa of probable UTRs (size away from gene defaults at 100)

if [ ! -n "$1" ];then
 echo "USEAGE: $0 annotation_file [utr_size]";
 echo -e "annotation_file should be chrom\tstart\tend\tstrand";
 echo -e "where chrom is like 1 or I";
 exit;
fi
annotefile=$1
#eg '../data/CDS/plasmoSorted_numonly.txt'

size=100;
if [ -n "$2" ];then
 size=$2
fi

awk -v size=$size '{print $1, $2-size, $2, $4; print $1, $3, $3+size, $4}'  |
while read c s e strand; do
  if [ "$strand" == "-" ]; then
    tmp=$s;
    s=$e;
    e=$tmp;
  fi
  seq="chr$c:$s-$e";
  echo ">$seq";
  ./seq.pl $seq;
done 

