#!/usr/bin/env bash


PROJECTDIR="/afs/andrew.cmu.edu/usr/wforan1/project/";
SCORE=-20;

function rnalfold_chrom(){
    #expects to be a pipe from sequence list
    #first arg must be chr.:###-#### -- there is no check for sanity here
    #second arg must be sense (1 or not 1)   --  "
    #second argument can be maximum energy
    #final output like: 
    #1776    chr1:14174-14280        -30.40  106
    #pos     place in genome	      energy length

    if [ ! -n "$2" ];then
       echo "BAD INPUTS TO rnalfold_chrom";
       return;
    fi

    pos=$1;
    strand=$2;

    maxs=-20;
    if [ -n "$3" ];then
     maxs=$3;
    fi

    echo -n folding $pos with max G $maxs ... 1>&2

    #run RNALfold and pare the results as
     RNALfold -noPS -L 110 |
    perl -slane 'BEGIN{ $score=0; 
    			$orgpos=~m/(chr.+):(\d+)-(\d+)/;
			$chrm=$1; $start=$2; $end=$3;
			$ns=0; $ne=0;
		     }
	    m/ ?-\d+\.\d+/;	#find score
	    $score=$&; 
	    m/[.()]+/;	#find strucutre (for length)
	    $length=length($&); 
	    m/\d+$/;	#find where in seq this matches
	    $pos=$&;
	    #get name (by strand info)
	    if($strand==1){ $ns=$start+$pos; $ne=$start+$pos+$length;}
	    else	  { $ns=$end-$pos; $ne=$end-$pos-$length;    } 
	    #print it
	    print join("\t",
		      $chrm.":".$ns."-".$ne, $score,$length, $pos)
	     if($score<$maxs && $length>61);' -- -maxs=$maxs -orgpos=$pos -strand=$strand
    echo " done" 1>&2
} 

function parse_folds(){
      sort -t: -k 2n | $PROJECTDIR/scripts/rnalfold_unstutter.pl |
      while read name score length pos; do
        #echo ">$name-$score-$length$2" 1>&2
        echo -n ". " 1>&2 #indicate we used something to status output
        echo ">$name-$score-$length$2"
        echo ${seq:$pos:$length} 
      done >> $1
      echo "" 1>&2 #new line for status output
      # print a fasfa ID and then the sequence corresponding to it
      # save to first argument, second argument can be used to add notation
}
function by_fa(){
    fa=$1;
    save=$2;
    echo "$(basename $fa) -> $(basename $save)"
    #create/clear the save file
    echo -n > $save;
    #get each fasta sequence on one line: name AATTTAGCGCGA..
    #head $fa -n400|awk 'END{print "\n"} {if(/^>/){printf "\n"substr($0,2)" "}else{printf $0} }' $fa |
    awk 'END{print "\n"} {if(/^>/){printf "\n"substr($0,2)" "}else{printf $0} }' $fa |
    while read pos seq; do 
        if [ -n "$pos" ] && [ -n "$seq" ]; then
	    echo -ne "integen Seq len: "; echo $seq |wc -m
	    echo $seq | rnalfold_chrom $pos "1" $SCORE | parse_folds $save
	    echo $seq |tr ATCG TAGC | rev | rnalfold_chrom $pos "-1" $SCORE | parse_folds $save
	fi

    done;
}

#by_fa $PROJECTDIR/bridge/plasmo_intergenic.fasta $PROJECTDIR/bridge/plasmo_rnalfold$SCORE.fasta
by_fa $PROJECTDIR/bridge/celg_intergenic.fasta $PROJECTDIR/bridge/celg_rnalfold$SCORE.fasta
