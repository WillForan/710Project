#!/usr/bin/env bash


PROJECTDIR="/afs/andrew.cmu.edu/usr/wforan1/project/";

function rnalfold_chrom(){
    chrom=$PROJECTDIR/data/genome/cel/chrI.fa;
    if [ -n "$1" ];then
     chrom=$1;
    fi

    maxs=-20;
    if [ -n "$2" ];then
     maxs=$2;
    fi

    echo folding $chrom with max G $maxs 1>&2

    #gulp -- remove first line, combine everythign else as one continuous stream
    sed 1d $chrom | xargs|sed 's/ //g'| RNALfold -noPS -L 110 |
    perl -slane 'BEGIN{ $score=0; $chr=~m/(chr.+)\.fa/; $chrm=$1;} 
	    m/ ?-\d+\.\d+/;	#find score
	    $score=$&; 
	    m/[.()]+/;	#find strucutre (for length)
	    $length=length($&); 
	    m/\d+$/;	#find where in seq this matches
	    $pos=$&;
	    #print it
	    print $chrm,":",$pos,"-",$pos+$length,"\t",$score,"\t",$length if($score<$maxs && $length>61);' -- -maxs=$maxs -chr=$chrom
	    #print $chrm,":",$pos,"-",$pos+$length                           if($score<$maxs && $length>61);' -- -maxs=$maxs -chr=$chrom
    #perl -slane 'BEGIN{ $score=0} m/ ?-\d+\.\d+/; $score=$&; m/[.()]+/; $length=length($&); print $length, "\t", $_ if($score<$maxs && $length>70);' -- -maxs=$maxs
    #perl -slane 'BEGIN{ $score=0} m/ ?-\d+\.\d+/; $score=$&; print $score,"\t",$_ if(m/^[AUGC]/ && $score<$maxs);' -- -maxs=$maxs

    echo finished folding 1>&2
}
#for c in {I,II,III,IV,V,X,M}; do
#for c in I; do
for c in {II,III,IV,V,X,M}; do
    echo chr$c 1>&2
    rnalfold_chrom $PROJECTDIR/data/genome/cel/chr$c.fa | 
      sort -t: -k 2n| $PROJECTDIR/scripts/rnalfold_unstutter.pl | 
      while read pos score length; do
        if [ "$($PROJECTDIR/scripts/isInGene.pl -r $pos)" == "1" ]; then 
           echo "skipping $pos" 1>&2; 
           continue;
        fi; #skip genomic parts
        echo ">$pos-$score-$length"
        $PROJECTDIR/scripts/el2seq.pl $pos
    done > $PROJECTDIR/bridge/cel_chr${c}_for_novomir.fa

done;
