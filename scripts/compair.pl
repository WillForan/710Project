#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;
require '/home/wforan1/pj/scripts/parseBlast.pm';
require '/home/wforan1/pj/scripts/parseNovomir.pm';
require '/home/wforan1/pj/scripts/seq.pm';


#
#
# read novomir output, blast mirbase
# TODO: blast utrs (take max dist of @pos)
#
#


my %blastOpts;
my $PROJECTDIR="/home/wforan1/pj";


my %orgs;
sub countorg(){ #via parseBlast.pm

    #set length minimum
    $blastOpts{'l'}  = $blastOpts{'lenfrac'} * length($blastOpts{'seq'});

    my @hits=blast(\%blastOpts);

    for my $hit (@hits){
	my $name= join (' ', (split /\s/, $hit->{'name'})[3,4] );
	#print join("\t", $name, $hit->{'percent'}, $hit->{'align'}), "\n";
	$orgs{$name}+=1;
	#print STDERR "(hit $name)\n";
	#print Dumper($hit),"\n";
    }
}

sub blastUTRs(){ #via parseBlast.pm

    #set length minimum
    $blastOpts{'l'}  = $blastOpts{'lenfrac'} * length($blastOpts{'seq'});

    my @hits=blast(\%blastOpts);

    for my $hit (@hits){
	my $name= join (' ', (split /\s/, $hit->{'name'})[3,4] );
	#print join("\t", $name, $hit->{'percent'}, $hit->{'align'}), "\n";
	$orgs{$name}+=1;
	#print STDERR "(hit $name)\n";
	#print Dumper($hit),"\n";
    }
}
sub novomirbase{ #via parseNovomir.pm via novomir via foldfornovomir.sh
    %orgs=();
    my $novofile=shift; #'/home/wforan1/pj/data/predict/plasmo_novoout.txt';

    my @mirs=parseNovomir($novofile);
    for my $mir (@mirs){
	#print STDERR ". ";

	$blastOpts{'seq'}= $mir->{'seq'};
	countorg;

    }
    #print "\tnovomir results to mirbase:\n";
    print  "\t\t$_: $orgs{$_}\n" for keys %orgs;
}

sub randomirbase{ #via random.sh
    my $randfile=shift;
    %orgs=();
    open my $fh, $randfile or die "cannot open $randfile: $!\n";
    while(<$fh>){
	next if(/^>/); #this is not the sequence you are looking for
	chomp;
	$blastOpts{'seq'}= $_;
	countorg;
    }
    close($fh);
    #print "\twith random length to mirbase:\n";
    print  "\t\t$_: $orgs{$_}\n" for keys %orgs;
}
sub srnaloopmirbase{
    my $srnaloopout=shift;
    %orgs=();
    open my $fh, $srnaloopout or die "cannot open $srnaloopout: $!\n";
    while(<$fh>){
        #3;chr1:19516-27333 2039 69 24 AGACCTATATTAGTGAATGTAAGGTCTAAGTT TCTGGAATGTAAGTGATTATATCCAGAATTCAG
	chomp;
	my $r={c=>'',s=>'',e=>''};
	($r->{'c'}, my $s, my $e, my $pos, my $len)=(split /[ ;:-]/)[1,2,3,4,5];
	
	#get actual genomic position
	#likely error in reporting 'rest'
	if ($s<$e || $e eq 'rest') { $r->{'s'} =  $s + $pos;   $r->{'e'} =  $r->{'s'} + $len }
	else       { $r->{'s'} =  $s - $pos;   $r->{'e'} =  $r->{'s'} - $len }

	$blastOpts{'seq'}= getseqfrom($r);
	
	countorg;
    }
    close($fh);
    #print "\tsrnaloop to mirbase:\n";
    print  "\t\t$_: $orgs{$_}\n" for keys %orgs;
}


#$blastOpts{'db'} = "$PROJECTDIR/data/blastdbs/mirbase";
#$blastOpts{'p'}  = 90;
#$blastOpts{'lenfrac'}=2/3;
#print  localtime, "\tmin ID 90%, min length 2/3 of seq","\n";
#print "Plasmodium to miRBase:\n";
#print "\tNovomir\n";
#novomirbase("$PROJECTDIR/data/predict/plasmo_novoout.txt");
#print "\tRandom (novomir length):\n";
#randomirbase("$PROJECTDIR/data/predict/plasmo_novo_random.fa");
#print "\tsrnaloop\n";
#srnaloopmirbase("$PROJECTDIR/data/predict/plasmo_srna_unstuttered.txt");
#print "\tRandom (srnaloop length):\n";
#randomirbase("$PROJECTDIR/data/genome/plasmo_srnaloop_random.fa");
##randomirbase("$PROJECTDIR/data/predict/plasmo_celg_random.fa");
#print "C. Elgans to miRBase:\n";
#print "\tNovomir\n";
##novomirbase("$PROJECTDIR/data/predict/plasmo_novoout.txt");
#print "\t\tno data\n";
#print "\tRandom (novomir length):\n";
#print "\t\tno data\n";
##randomirbase("$PROJECTDIR/data/predict/celg_ .fa");
#print "\tsrnaloop\n";
#srnaloopmirbase("$PROJECTDIR/data/predict/celg_srna_unstuttered.txt");
#print "\tRandom (srnaloop length):\n";
#randomirbase("$PROJECTDIR/data/genome/cel/celg_srnaloop_random.fa");
$blastOpts{'db'} = "$PROJECTDIR/data/blastdbs/mirbase";
$blastOpts{'p'}  = 90;
$blastOpts{'lenfrac'}=2/3;


exit;
