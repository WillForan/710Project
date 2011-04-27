#!/usr/bin/env perl
# take: gene file (-f) and short reads file (-g) BOTH SORTED
#
# is one gene intergenic?
#
use strict; use warnings;
use Getopt::Std;

my $PROJECTDIR='/afs/andrew.cmu.edu/usr19/wforan1/project/';
my %chrtonum=('I'=>1,'II'=>2,'III'=>3,'IV'=>4,'V'=>5,'X'=>10);
#two files and a window as options
my %opt=('g'=>"$PROJECTDIR/data/CDS/celSorted.txt", 'r'=>'chrI:100:200','w'=>0 );
getopts('g:r:w:',\%opt);

#intialize hash for reads in gene, and gene names
my %intergenic;
my %intragen;

#open files
open my $GF, $opt{'g'} or die "cannot open gene file: $!";

#make printing arrays pretty
$,="\t";

##initialize genes -- need 2
#   looks like:
#I 29732 37349 + 
my @oldgene=split(/\s/,<$GF>);
chomp($oldgene[$#oldgene]);

my @gene=split(/\s/,<$GF>);
chomp($gene[$#gene]);

#get chrm number
#my $gchrm=substr($gene[0],3);
my $gchrm=$chrtonum{$gene[0]};
#print "chrom is $gchrm", $gene[0],"\n";
#my $ogchrm=substr($oldgene[0],3);
my $ogchrm=$chrtonum{$oldgene[0]};
#print "old chrom is $ogchrm", $oldgene[0],"\n";


#start getting reads
while($opt{'r'}=~/chr(.+):(\d+)-(\d+)/g){ 
   my @read=($chrtonum{$1},$2,$3);
   my $rchrm=$read[0];
   

   #get another gene if reads are ahead
   #1----g----2  1++++r++++2
   while(!eof($GF) && 
   	( $rchrm>$gchrm || ( $rchrm==$gchrm && $read[1]>$gene[2]    ) )
        ) {   
       # print "done with gene @gene\n";

        #move gene to old gene
	#and get another possible alignment
        @oldgene=@gene;
   	@gene=split(/\s/,<$GF>);
	chomp($gene[$#gene]);
	#$gchrm=substr($gene[0],3);
	#$ogchrm=substr($oldgene[0],3);
	$gchrm=$chrtonum{$gene[0]};
	$ogchrm=$chrtonum{$oldgene[0]};
	
        print STDERR "chrm number error:\ng:\t", @gene,"\nr:\t", @read[0..2],"\nog:\t",@oldgene,"\n" if($ogchrm>$rchrm);
    }
   
   #read is in a gene

   # 1-----og-----2 1++++++r++++2 1--------g-------2 #most freq case
   #
   # 1+++++r++++++2 1----og-----2                    #could be initial case
   #
   #
   # 1-----g------2 1++++++r++++2		     #hits while loop above *until EOF*!
   #
      
   if( (  ( ($read[1] > $oldgene[2]  && $rchrm==$ogchrm) || $ogchrm<$rchrm  )&&        #old gene is behind and
          ( ($read[2] < $gene[1]     && $rchrm==$gchrm ) ||  $rchrm<$gchrm  )  ) ||    #new is ahead
          ( ($read[2] < $oldgene[1]  && $rchrm==$ogchrm) || $ogchrm>$rchrm  )    ||    #old is ahead  (at initialization)
          ( ($read[1] > $gene[2]     && $rchrm==$gchrm ) ||  $rchrm>$gchrm  )       ){ #new is behind (only after gene eof)
      
      #it's intergenic! print 
      print "0";
   }
   else {
     print "1";
  }
  print "\n";
}
close($GF);

