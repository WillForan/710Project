#!/usr/bin/env perl
use strict; use warnings;
use Switch;
use Getopt::Std;
#
# generate genome without genetic material in two passes (+ and -)
# e.g.
#    for org in {plasmo,celg};   do  ./generateInterGenic.pl -o $org > ../bridge/${org}_intergenic.fasta;  done
# expects chr seperated fasta genome within a directgory
# and notation file like:
# 	chrom	start	end	strand
#e.g	I	100	300	+
#
# location of gene annotation file
my $annotationfile='/afs/andrew.cmu.edu/usr/wforan1/project/data/CDS/';#plasmoSorted_numonly.txt
# location of genome chromosome file
my $chromprefix='/afs/andrew.cmu.edu/usr/wforan1/project/data/genome/';#chr
#chrom to start with (1 for plasmo, I for cel)
my $default_chrom=1;

#what organism
my %org=('o'=>'');
getopts('o:',\%org);
switch ($org{'o'}) {
  case /plas/ { $annotationfile.='plasmoSorted_numonly.txt'; $chromprefix.="chr"; }
  case /elg/  { $annotationfile.='celSorted.txt';            $chromprefix.="cel/chr"; $default_chrom='I'}
  else { print STDERR "USAGE: $0 -o [plasmodium or celgance]\n(doing both will cause problems :) )\n";exit }
}

#id label 
my $id=0;

#need genome and genpos to be globalish for following functino to work as expected
my $genome;
my $genpos;
my $gene_chr;
my @nts;

#open a new chromosome, set vars
sub openchr{
    close($genome) if($genome);
    my $chr=shift;
    open $genome, "$chromprefix$chr.fa" or die "Cannot read chr$chr: $!\n";
    #open $genome, "tmptestseq" or die "Cannot read chr$chr.fa: $!\n";
    scalar(<$genome>); #read first line (not part of seq)
    $genpos=1;
    $gene_chr=$chr;
    print STDERR "$chr ";
}

#for each strand
for my $strand ('+','-'){
    print STDERR "$strand "; #for status update

    open my $annoteFH, $annotationfile  or die "Cannot read gene file: $!\n";
    $gene_chr=$default_chrom;
    openchr $gene_chr;
    my $intergen="";

    #for each line
    while(<$annoteFH>){ 
     #line must be the right sense and have an assocated chrome
     my ($chrom,$start, $end,$gene_strand) = split /\s/;
     next if($strand ne $gene_strand);
     #print $chrom,":", $start,"-",$end,"\n";
     
     #make sure were reading the right file;
     if($chrom ne $gene_chr){
	#print the rest of the genome as one id
	$id++;
	print "\n>$id;chr$gene_chr:$genpos-rest\n";
	print <$genome>; 

	#open the next chrm
	openchr $chrom;
     }


     #start new fa ID
     $id++;
     if($strand eq '-'){
	 print ">$id;chr$chrom:$start-$genpos\n";
     }
     else{ 
	 print ">$id;chr$chrom:$genpos-$start\n";
     }

    # #print all the nts up to the genomic region
     while($genpos<=$end) {
       #read in nt if none are cached (possible inf. loop here if input not formated well)
       @nts=split //, <$genome> if($#nts < 0 && !eof($genome));
       last if eof($genome);

       my $nt = shift @nts;

       next if !$nt;

       #print it if its before start
       #print $nt if($genpos<$start);
       $intergen.=$nt if $genpos < $start;
       #print but don't count newlines (or any other chacter not correct
       #$genpos++ if $nt =~ /[ATGCNnatgc]/; #what about N's and other weird things?
       $genpos++ unless $nt eq "\n";
       
     }#end of intergen region
     if($strand eq '-'){
       $intergen =~ tr/ATGCatgc/TACGtacg/;
       $intergen = reverse $intergen;
     }

     #dump the sequence, and reset
     print $intergen,"\n";
     $intergen="";
   }#end gene annotation file
   print STDERR "\n";
   close $annoteFH;
}#end for each strand
close $genome;

