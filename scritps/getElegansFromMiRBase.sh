awk 'BEGIN{el=0} { if(/^>/){ if(/elegans/){el=1} else{el=0} } if(el){print}  }' hairpin.fa  > elegans_hairpin.fa
