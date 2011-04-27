#annotations

#PLASMO
curl curl http://plasmodb.org/common/downloads/release-7.1/Pfalciparum/txt/PfalciparumGene_PlasmoDB-7.1.txt | 
grep "Genomic Location:"|
sed s/,//g | 
sort -t' ' -k3.7n > ../data/CDS/plasmoSorted.txt

#C El
wget ftp://ftp.wormbase.org/pub/wormbase/genomes/c_elegans/genome_feature_tables/GFF3/current.gff3.gz
gunzip current.gff3.gz
awk '($3~/gene/){print $1,$4, $5,$7}' current.gff3 |sort -k1,1d -k2n > ../data/CDS/celSorted.txt 
