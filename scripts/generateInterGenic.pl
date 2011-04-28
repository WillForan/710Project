#!/usr/bin/env perl
use strict; use warnings;
#
# generate genome without genetic material
#eg ./generateInterGenic.pl > ../bridge/plasmo_intergenic.fasta
#
#
my $annotationfile='/afs/andrew.cmu.edu/usr/wforan1/project/data/CDS/plasmoSorted.txt';
my $chromprefix='/afs/andrew.cmu.edu/usr/wforan1/project/data/genome/chr';
#id label 
my $id=0;
#start with + reads
#my $sense='\(\+\)';
#start on chr1
my $gene_chr;

#need genome and genpos to be globalish
my $genome;
my $genpos;
my @nts;

#open a new chromosome
sub openchr{
    close($genome) if($genome);
    my $chr=shift;
    open $genome, "$chromprefix$chr.fa" or die "Cannot read chr$chr: $!\n";
    #open $genome, "tmptestseq" or die "Cannot read chr$chr.fa: $!\n";
    scalar(<$genome>); #read first line (not part of seq)
    $genpos=1;
    $gene_chr=$chr;
}


for my $strand ('\(\+\)','\(\-\)'){

    open my $annoteFH, $annotationfile  or die "Cannot read gene file: $!\n";
    $gene_chr=1;
    openchr $gene_chr;
    my $intergen="";

    #for each line
    while(<$annoteFH>){ 
     #line must be the right sense and have an assocated chrome
     next if(!m/$strand$/ || !m/Pf3D7_(\d+)/);
     my $chrom=$1;
     $chrom=~s/0//;
     
     #make sure were reading the right file;
     if($chrom!=$gene_chr){
	#print the rest of the genome as one id
	$id++;
	print "\n>$id;chr$gene_chr:$genpos-rest\n";
	print <$genome>; 

	#open the next chrm
	openchr $chrom 
     }

     my ($start, $end) = (split /[ :-]/)[5,8];
     #print $chrom,":", $start,"-",$end,"\n";

     #start new fa ID
     $id++;
     if($strand eq '\(\-\)'){
	 print ">$id;chr$chrom:$start-$genpos\n";
     }
     else{ 
	 print ">$id;chr$chrom:$genpos-$start\n";
     }

    # #print all the nts up to the genomic region
     while($genpos<=$end ) {
       #read in nt if none are cached (possible inf. loop here if input not formated well)
       @nts=split //, <$genome> if($#nts < 0 && !eof($genome));
       last if eof($genome);

       my $nt = shift @nts;

       #print it if its before start
       #print $nt if($genpos<$start);
       $intergen.=$nt;

       #print but don't count newlines (or any other chacter not correct
       $genpos++ if $nt =~ /[ATGC]/;
       
     }#end of intergen region
     if($strand eq '\(\-\)'){
       $intergen =~ tr/ATGC/TACG/;
       $intergen = reverse $intergen;
     }
     print $intergen,"\n";
     $intergen="";
   }#end gene annotation file
   close $annoteFH;
}#end for each strand
close $genome;

