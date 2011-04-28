#!/usr/bin/perl
#
# script to get length distribution which then calls randomStuff.pl to get 
# a random set of sequences with the same distribution as the candidate sequences. 
#
# inputs: file containing unstuttered predictions (output) srnaloop or novomir
# outout: file containing random sequences with the same length distribution of the input file
#

use strict; use warnings; use File::stat; use Switch;

use POSIX;

print $ARGV[0], "\n";
my $outpath = "/afs/andrew.cmu.edu/usr24/jvendrie/Genomics2011/bridge/stats/"; 
if( @ARGV != 2 || ($ARGV[1] != 1 && $ARGV[1] != 2))
{
    print "USAGE: ./getLengthDist predictions_file, genome\n";
    print "for genome, 1 = p. falciparum, 2 = c. elegans \n";
    print "note that this script is directory dependent\n";
    print "if you are using plasmo, prolly want to do ./exe srna_unstuttered_in_bridge_dir 1\n";
    print "if you are using c elegans, want to do ./exe file_to_be_created 2\n";
    exit;
}

my $outfile = "";

if($ARGV[1] == 1)
{
	$outfile = $outpath . "p.f.random_seq.txt";
}
elsif($ARGV[1] == 2)
{
	$outfile = $outpath . "c.e.random_seq.txt";
}
else
{
	print "should not go here.\n";
}

my $filename = $ARGV[0];
my $len = 0;

my %map = (); #key = lentgh,value = number of occurrences
open (FILE, $filename);

#this loop gets the count from each line and stores in a hash to get
#a count distribution
while(<FILE>)
{
	chomp;
	$len  = (split / /)[3];
	#print $_,  "\n";
	#sleep(3);

	if( exists $map{$len})
	{
		$map{$len} = $map{$len} +1;
	}
	else
	{
		$map{$len} = 1;
	}
}

#this displays the distribution
#
#foreach my $key(sort keys %map)
#{
#	print "$key: $map{$key} \n";
#}

my $counter = 0;
foreach my $key(sort keys %map)
{
	for( my $i = 0; $i < $map{$key} ; $i++)
	{	
		$counter++;
		print "seq length is $key, genome is $ARGV[1], seqNum $counter\n";
		system("/usr/bin/perl ./randomStuff.pl $key $ARGV[1] >> $outfile");
		#sleep(3);
	}
}

