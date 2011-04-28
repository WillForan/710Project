#!/usr/bin/perl
#
# Program to do the obvious part 2
#



use strict; use warnings; use File::stat; use Switch;

use POSIX;

#print $ARGV[0], ", ", $ARGV[1], "\n";
if( @ARGV != 2 || ($ARGV[1] != 1 && $ARGV[1] != 2)) 
{
    print "USAGE: length, genome. for genome, 1 = p. falciparum, 2 = c_elegans\n";
    print "note that this script is directory dependent\n";
    exit;
}

my $path = "";
my $filename = "";
my $range  = 0;
my $random_number = 0;
my $numCharsPerLine = 0;
my $isIntergenic = 0;
my $intergenicFile = "";
my $chromNumber = 0;

#for (my $i = 0; $i < 10;$i++)
#{
#	$range = 14;
#
#	$random_number = int(rand($range));
#	$random_number = $random_number +1;
#
#	print $random_number . "\n";
#
#}

#getting random chromosome
#if we are looking at p facilparum
if($ARGV[1] == 1)
{
	$numCharsPerLine = 60;
	$path = "/afs/andrew.cmu.edu/usr19/wforan1/project/data/genome/";
	$range = 14;
	$random_number = int(rand($range));
	$random_number = $random_number +1;#otherwise we get between 0 and 13 and not 1 and 14
	$chromNumber = $random_number . " ";#saving this variable for later use
	$filename = $path. "chr" . $random_number . ".fa";
	
	$intergenicFile = "/afs/andrew.cmu.edu/usr19/wforan1/project/data/CDS/plasmoSorted_numonly.txt";

	#print $filename . "\n";

}
elsif($ARGV[1] == 2)
{
#if we are looking at c_elegans
	$numCharsPerLine = 50;
	$path = "/afs/andrew.cmu.edu/usr19/wforan1/project/data/genome/cel/";
	$range = 7;
	$random_number = int(rand($range));
	$random_number = $random_number +1;
	my $filenum = "";
	
	switch ($random_number) 
	{
		case 1	{$filenum = "I"}
		case 2	{$filenum = "II"}
		case 3	{$filenum = "III"}
		case 4	{$filenum = "IV"}
		case 5	{$filenum = "V"}
		case 6	{$filenum = "M"}
		case 7	{$filenum = "X"}
	}
	
		
	$chromNumber = $filenum . " ";#saving this variable for later use
	$filename = $path. "chr" . $filenum . ".fa";
	$intergenicFile =  "/afs/andrew.cmu.edu/usr19/wforan1/project/data/CDS/celSorted.txt"; 	

	#print $filename . "\n";

}
else
{
	print "Should never get here\n";
}

my $seqlen = $ARGV[0];


#open(FILEIN, $filename) or die("can't open file $filename for reading\n");

#From pos2seq.pl
open my $cFILE, $filename or die "Cannot open  $filename for reading\n";

my $filesize = stat($filename)->size;
#print "Size: $filesize\n";
my $counter = 0;
#for getting only intergenic regions
while ($isIntergenic ==0)
{
	$counter++;
	$range = $filesize - $seqlen;
	$random_number = int(rand($range));
	$random_number = $random_number +1;#otherwise we get between 0 and 13 and not 1 and 14

	my @regions = split /\n/, `grep '^$chromNumber' $intergenicFile`;
	foreach my $i(@regions)
	{
		#print $i . "\n";
		my @cols = split /\s/, $i;
		#print $cols[1] . "\n";
		#sleep(3);

		#if current region start and end are less than the start number, 
		#go to the next region start.
		if($cols[1] < $random_number && $cols[2] < $random_number)
		{
			$isIntergenic = 0;
			next;
		}
		#if the start number is between the current region start and end, that means the start
		#number points to part of a gene. Break out of foreach loop and choose a new start number
		elsif($cols[1] < $random_number && $cols[2] > $random_number)
		{
			$isIntergenic = 0;
			last;
		}
		#if the start is less than the current region start and we get to this part of the loop then we are 
		#in an intergenic region
		elsif($cols[1] > $random_number)
		{
			$isIntergenic = 1;
			last;
		}
	}
	#$isIntergenic = 1;
	#sleep(3);
}

#print $counter . "\n";

#my $start = 10;
my $start = $random_number;
my $end = $start + $seqlen-1;

my $offset=length(<$cFILE>);
#print "offset: $offset\n";

#extra byte(newline) ever 50 chars + start  + $offset - starts at 1 not 0
my $pos=floor($start/$numCharsPerLine) + $start + $offset - 1;

#difference in positions
my $diff=$end-$start;

#extra byte every 50 + actual diff
my $len=floor($diff/$numCharsPerLine)+$diff;

#add one if there is an extra newline to overcome (ie. compansate for not starting at beg. of line)
$len+=1 if ($end%$numCharsPerLine<$start%$numCharsPerLine);

#get the file to the start
seek($cFILE,$pos,SEEK_SET);

#read the length
read($cFILE,my $seq, $len+1,0);

#done with file
close($cFILE);

#make presenentable
$seq=uc($seq);
$seq=~s/\n//g;

print $seq,"\n";



#close(FILEIN);



