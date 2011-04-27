#!/usr/bin/env perl
use strict; use warnings;
#
# generate genome without genetic material
#eg ./generateInterGenic.pl > ../bridge/plasmo_intergenic.fasta
#
#
open my $genefile, '/afs/andrew.cmu.edu/usr/wforan1/project/data/CDS/plasmoSorted.txt' or die "Cannot read gene file: $!\n";

#id label 
my $id=0;
#start with + reads
my $sense='\(\+\)';
#start on chr1
my $gene_chr=1;

#need genome and genpos to be globalish
my $genome;
my $genpos;
my @nts;

#open a new chromosome
sub openchr{
    close($genome) if($genome);
    my $chr=shift;
    open $genome, "/afs/andrew.cmu.edu/usr/wforan1/project/data/genome/chr$chr.fa" or die "Cannot read chr$chr.fa: $!\n";
    scalar(<$genome>); #read first line (not part of seq)
    $genpos=1;
    $gene_chr=$chr;
}



openchr $gene_chr;

#for each line
while(<$genefile>){
 #line must be the right sense and have an assocated chrome
 next if(!m/$sense$/ || !m/Pf3D7_0+(\d+)/);
 my $chrom=$1;
 
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
 print "\n>$id;chr$chrom:$genpos-$start\n";

# #print all the nts up to the genomic region
 while($genpos<=$end ) {
   #read in nt if none are cached (possible inf. loop here if input not formated well)
   @nts=split //, <$genome> if($#nts < 0 && !eof($genome));

   my $nt = shift @nts;

   #print it if its before start
   print $nt if($genpos<$start);

   #print but don't count newlines
   next if $nt eq "\n";
   $genpos++;
 }
# $genpos=$end+1;


}
close $genome;
close $genefile;

