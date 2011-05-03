set log xy
set title ""
set xlabel "Number of hits per canidate"
set ylabel "Frequency "
set term png
set output "blastingUTRs.png"
plot 'pnr.txt' title "Plasmodium - random novomir lengths", 'pnu.txt' title "Plasmodum - novomir" , 'psr.txt' title "Plasmodium - random srnaloop length" , 'psu.txt' title "Plasmodium - srnalooop", 'csr.txt' title "C. elegans - random srnaloop length" , 'csu.txt' title "C. elgans - srnaloop"
