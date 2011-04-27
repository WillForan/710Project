#!/usr/bin/env perl
use warnings; use strict;
my $PROJECTDIR='/afs/andrew.cmu.edu/usr/wforan1/project/';
use lib "/afs/andrew.cmu.edu/usr/wforan1/project/src/perl/";
#use Bio::Tools::Run::StandAloneBlast;
use Bio::Tools::Run::StandAloneBlastPlus;
use Bio::SearchIO; 
use Data::Dumper;

my $blast_obj= Bio::Tools::Run::StandAloneBlastPlus->new(-program  => 'blastn', -database => "$PROJECTDIR/data/blastdbs/pf7", -g=>'f', -q=>'-1');
my $seq_obj = Bio::Seq->new(-id  =>"testquery", -seq =>"TTTAAATATATTTTGAAGTATAGATTATATGTT");
my $report_obj = $blast_obj->blastn($seq_obj);
#my $result_obj = $report_obj->next_result;
#print $result_obj->num_hits,"\n";

while( my $result = $report_obj->next_result ) {     
    while( my  $hit = $result->next_hit ) {       
	while( my $hsp = $hit->next_hsp ) {           
	    #if ( my $hsp->percent_identity > 75 ) {             
		#print "Hit\t", $hit->name, "\n", "Length\t", $hsp->length('total'),  
		#      "\n", "Percent_id\t", $hsp->percent_identity, "\n";         
	    #}       
	    #print Dumper($hsp),"\n";
	    print $hsp->score, "\t", $hsp->percent_identity,"\t", $hsp->length('total'), "\n-\t",$hsp->target_string,"\n-\t",$hsp->hit_string,"\n";
	    last;
	}     
    }   
}
