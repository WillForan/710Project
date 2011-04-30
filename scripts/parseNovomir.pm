#!/usr/bin/env perl
#package parseNovomir; #this would probably suffice as 
use warnings; use strict;
use Carp;

#output:
# array of hash refrences:
# chr, start, end, score(rfold energy), len (length)
# val, meanval, T,
# seq,fold
# pos (array of refrences to [start,end])

#input like:
#
##################################################
#>chr-10017-10102-23-60-85.0	is_MIRNA
#	VAL:	28.51	MeanVal:	226.053373	Thresholds t: 0.9	T: 4.37
#    FWD:    ccu-auauuagugaaaguaaggucugag-uuaguuaaguua
#            +++|++++++++++--++-++++++---|++--++++-+++
#            +++-++++++++++-|++|++++++----++--++++-+++
#    REV:    ggauuguaaucauua-ca-uccagaaugaaagugauugaau
#	
#                *********************	5:::25	4--24
#                  *********************	7:::27	6--26
#              *********************	3:::23	3--22
#             *********************	2:::22	2--21
#               *********************	4:::24	4--23
#                 *********************	6:::26	5--25
#	ccuauauuagugaaaguaaggucugaguuaguuaaguuaagaccuaaguuagugaaaguaagaccuacauuacuaauguuaggac
#	(((((((((((((..((.((((((...((..((((.(((.....))).))))..))....)))))))).)))))))))).)))..
#
##################################################


sub parseNovomir{
    #my $class = shift;
    croak "Requires filename and filename only" unless @_ == 1;
    my $novooutput = shift;
    my @mirs;
    open my $fh, $novooutput or croak "$novooutput won't open: $!\n";
    while(<$fh>) {
       if(/is_MIRNA$/){ 
            my %mir;
            #>chr-10017-10102-23-60-85.0	is_MIRNA
            ($mir{'chr'},$mir{'start'},
             $mir{'end'},$mir{'score'},
             $mir{'len'}              )=(split /[-\s]/)[0,1,2,3,4];

           $_=<$fh>; #VAL:	28.51	MeanVal:	226.053373	Thresholds t: 0.9	T: 4.37
            ($mir{'val'}, $mir{'meanval'}) = (split /\s/)[2,4];
           <$fh>; #FWD:...
           <$fh>; #+++...
           <$fh>; #++-...
           <$fh>; #REV:...
           <$fh>; #newline
           $_=<$fh>; # ***** 5::25   4--24
           while(m/\*\*\*\s(\d+):::(\d+)\s/){
             push(@{$mir{'pos'}},[$1, $2]);
             
            $_=<$fh>; #last will be seq; e.g. cccua....
           }
            chomp; s/\s//g;
            $mir{'seq'}= $_; #sequence from condition exiting while loop 

           $_=<$fh>; chomp;s/\s//g;
            $mir{'fold'}=$_; #folding
            push @mirs, \%mir;
            
       }
    }
    close $fh;

    #my $obj = { mirs=>@mirs };
    #bless $obj, $class;
    #return $obj;
    return @mirs;
}
1;
