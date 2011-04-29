#!/usr/bin/env bash
#
#make fa of probable UTRs (size away from gene defaults at 100)


size=100;
if [ -n "$1" ];then
 size=$1
fi

awk -v size=$size '{print $1, $2-size, $2, $4; print $1, $3, $3+size, $4}' ../data/CDS/plasmoSorted_numonly.txt |
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

