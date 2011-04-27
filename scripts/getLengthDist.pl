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
if( @ARGV != 2 || ($ARGV[1] != 1 && $ARGV[1] != 2))
{
    print "USAGE: ./getLengthDist predictions_file, genome\n";
    print "for genome, 1 = p. falciparum, 2 = c. elegans \n";
    print "note that this script is directory dependent\n";
    exit;
}

my $outfile = "";

if($ARGV[1] == 1)
{
	$outfile = "p.f.random_seq.txt";
}
elsif($ARGV[1] == 2)
{
	$outfile = "c.e.random_seq.txt";
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


foreach my $key(sort keys %map)
{
	for( my $i = 0; $i < $map{$key} ; $i++)
	{
		print "seq length is $key, genome is $ARGV[1], outfile is $outfile\n";
		system("/usr/bin/perl ./randomStuff.pl $key $ARGV[1] >> $outfile");
		sleep(3);
	}
}


