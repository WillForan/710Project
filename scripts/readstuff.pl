#!/usr/bin/perl
#
# Program to do the obvious part 2
#

print "Harro Prease. \n";		# Print a message

use strict; use warnings;
use POSIX;

my $sequencecounter = 0;
my $counter = 0;
my $basepath = "/afs/andrew.cmu.edu/usr19/wforan1/project/";
my $seqspath = $basepath . "data/c_elegans_seqs/";
my $novomirpath = $basepath . "bin/";
my $sequencesFile = $seqspath . "c_elegans_miRNA_in_DB.txt";

print $sequencesFile, "\n";

open(INFO, $sequencesFile) or die("can't open file $sequencesFile for reading\n");

my $prevline = "";
while (my $line = <INFO>)
{

   if ($line =~ /^(A|C|G|U)/) 
   { 

   	  $counter++;
#      my @data = split(/\|/, $line);
      my $nextline = <INFO>;
      if(substr($nextline, 0, 1) ne ">")
      {
      	my $newline = substr($line,0,-1) . substr($nextline,0,-1);
	    my $size = length($newline);	
    	print "sequence at line $counter = $newline, with length $size\n";
    	$sequencecounter++;
    	
    	my $outfile = $seqspath ."sequence_No_" . $sequencecounter . "_results" . ".txt"; #stores the sequence to use with novomir
		open (OUT, ">$outfile") or die("can't open file $outfile for writing\n");
		print OUT "$newline\n"; 
		close(OUT);
      }

  }
 
	$counter++;
}
close(INFO);
print "num seqs is $sequencecounter\n";

