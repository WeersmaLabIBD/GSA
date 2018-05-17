# Author: Michiel Voskuil 

# Date: 2018/05/09

```
# Make sure you have the following scripts/files available in your workdirectory (/groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/AllImputedsnps_maf001_parallel)

Scripts
create_phewas_rscripts.sh            <---- enter your work directory in here 
create_phewas_jobs.sh                <---- enter your work directory in here 
combined_phewas_manhatthanplot.r


Files
Binary plink files
List with multi-allelic sites [i.e. GSA_chr_1-22-merge.missnp]
Michiel_PSI_data_opgeschoond.dta
pheinfo.csv 
phemap.csv
PSI.imputation.key
```


0. Set variables
---------------------------------------------------
```
wd=[workingdirectory]
input=[prefix-to-plink-binary-file]
```

1. Prepare genotype files
---------------------------------------------------
```
module load plink
cd $wd

# Remove multi-allelic sites
plink --bfile $input --exclude GSA_chr_1-22-merge.missnp --out tmp01 --make-bed --allow-no-sex

# Cut into small chunks [here chunks of 10000 snps]
mkdir splits



split --lines=10000 tmp01.bim --numeric-suffixes -a 3 splits/chunk_

ls splits/* | while read line; 
    do plink --bfile tmp01 --extract <(awk '{print $2}' ${line}) --recode A --out ${line} --allow-no-sex;
done

mv splits/*.raw .
rm splits/*.nosex
rm splits/*.log
rm tmp01.*

# create jobs for phewas
bash create_phewas_jobs.sh
mv splits/chunk_*.sh .

# create phewas r scripts
bash create_phewas_rscripts.sh
mv splits/chunk_*.r .


awk '{print $2}' $input.bim > snplist

split -l 10000 snplist splits/chunk_ --numeric-suffixes -a 3

for i in {000..154}; do plink --bfile $input --extract chunk_"$i" --make-bed --out GSA_chunk_"$i"; done

for i in {000..154}; do plink --bfile GSA_chunk_"$i" --recode A --out GSA_chunk_"$i".A; done




for i in {1..22};
do plink --bfile $input --exclude GSA_chr_1-22-merge.missnp --recodeA --out chr_"$i".A;
done
```

```
# Optionally, you can subset only GWAS catalogue snps

# module load VCFtools
# vcftools --gzvcf /groups/umcg-weersma/tmp04/Michiel/GSA-redo/imputation/european/results/european_maf001/merged/european_maf001.vcf.gz --positions /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/curated_snplist --recode --stdout | bgzip -c > /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/european_maf001_gwascatalogue.vcf.gz
# tabix -p vcf european_maf001_gwascatalogue.vcf.gz

# Here 35047 snps left.

# Make plink files from imputed VCFs (use prob > 0.4)

# sbatch /groups/umcg-weersma/tmp04/Michiel/GSA-redo/scripts/imputedVCFtoPlinkS_gwascat.sh

# module load plink
# plink --bfile /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/plink/GSA --recodeA --out /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/GWAScatsnps/GSA.A
```




2. Prepare phenotype and run PheWas in R (here only for all maf >0.01 imputed variants)
---------------------------------------------------

```
# Create R scripts and jobs per chromosome

bash create_phewas_rscripts.sh
bash create_phewas_jobs.sh

# Submit jobs to cluster (chr 21 takes ~12 hours and uses about ~25GB memory) 
for i in {1..22}; do sbatch PheWas_chr_"$i".sh; done
```

3. Combine results in one results file
---------------------------------------------------
```

# Combine
head -1 phewasresults/PheWas_All_snps_chr_1.csv > phewasresults/PheWas_All_snps.csv; tail -n +2 -q phewasresults/PheWas_All_snps_chr_{1..22}.csv >> phewasresults/PheWas_All_snps.csv

# Remove NAs from PheWas_All_snps.csv, as there are many NA results for phenotypes with < 20 cases or monomorphic snps

awk 'BEGIN{FS=OFS=","} $4!="NA"{print $0}' phewasresults/PheWas_All_snps.csv > phewasresults/PheWas_All_snps_without_NA.csv
awk 'BEGIN{FS=OFS=","} $4=="NA"{print $0}' phewasresults/PheWas_All_snps.csv > phewasresults/PheWas_All_snps_NA.csv


# Make combined Manhattan plot
Rscript combined_phewas_manhatthanplot.r






```

4. Prune SNPs
---------------------------------------------------
```
# # This should actually be done before the association testing, so please move up once done. 

# Prune our dataset using with a 100kb window, 5 step, and 0.3 R2. (and exclude multi-allelic sites)
module load plink

plink --bfile /groups/umcg-weersma/tmp04/Michiel/GSA-redo/imputation/european/results/european_maf001/mergedplinkfiles/GSA_chr_1-22 --exclude   /groups/umcg-weersma/tmp04/Michiel/GSA-redo/imputation/european/results/european_maf001/mergedplinkfiles/GSA_chr_1-22-merge.missnp --out /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/pruned/GSA_chr_1-22-prune --indep-pairwise 500 5 0.3  

# 7737655 variants before pruning

plink --bfile /groups/umcg-weersma/tmp04/Michiel/GSA-redo/imputation/european/results/european_maf001/mergedplinkfiles/GSA_chr_1-22 --exclude   /groups/umcg-weersma/tmp04/Michiel/GSA-redo/imputation/european/results/european_maf001/mergedplinkfiles/GSA_chr_1-22-merge.missnp --extract /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/pruned/GSA_chr_1-22-prune.prune.in --make-bed --out /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/pruned/GSA_chr_1-22-pruned

# 1085628 variants after pruning 


 # Convert to phewas input genotype files
 plink --bfile GSA_chr_1-22-pruned --recodeA --out GSA_chr_1-22_pruned.A
