# Author: Michiel Voskuil 

# Date: 2018/05/09

```
# Make sure you have the following scripts/files available in your workdirectory (/groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/AllImputedsnps_maf001_parallel)

bash create_phewas_rscripts.sh
bash create_phewas_jobs.sh
combined_phewas_manhatthanplot.r
Michiel_PSI_data_opgeschoond.dta
pheinfo.csv 
phemap.csv
PSI.imputation.key
```


1. Prepare genotype files
---------------------------------------------------
```
# Prepare plink file for all snps with maf 0.01

cd /groups/umcg-weersma/tmp04/Michiel/GSA-redo/imputation/european/results/european_maf001/plinkfiles

# Remove multi-allelic sites and recode to Phewas input format

for i in {1..22}; 
do plink --bfile ../plinkfiles/GSA_chr_"$i" --exclude GSA_chr_1-22-merge.missnp --recodeA --out /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/AllImputedsnps_maf001_parallel/GSA_chr_"$i";
done
```
```
# Optionally, you can subset only GWAS catalogue snps

module load VCFtools
vcftools --gzvcf /groups/umcg-weersma/tmp04/Michiel/GSA-redo/imputation/european/results/european_maf001/merged/european_maf001.vcf.gz --positions /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/curated_snplist --recode --stdout | bgzip -c > /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/european_maf001_gwascatalogue.vcf.gz
tabix -p vcf european_maf001_gwascatalogue.vcf.gz

# Here 35047 snps over.

# Make plink files from imputed VCFs (use prob > 0.4)

sbatch /groups/umcg-weersma/tmp04/Michiel/GSA-redo/scripts/imputedVCFtoPlinkS_gwascat.sh

module load plink
plink --bfile /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/plink/GSA --recodeA --out /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/GWAScatsnps/GSA.A
```



2. Prepare phenotype and run PheWas in R (here only for all maf >0.01 imputed variants)
---------------------------------------------------

```
# Create R scripts and jobs per chromosome

bash create_phewas_rscripts.sh
bash create_phewas_jobs.sh

# Submit jobs to cluster (each chromosome will take approximately XX hours)
for i in {1..22}; do sbatch PheWas_chr_"$i".sh; done
```

3. Combine results in one results file
---------------------------------------------------
```

# Combine
head -1 phewasresults/PheWas_All_snps_chr_1.csv > phewasresults/PheWas_All_snps.csv tail -n +2 -q phewasresults/PheWas_All_snps_chr_{1..22}.csv >> phewasresults/PheWas_All_snps.csv

# Remove NAs from PheWas_All_snps.csv, as there are many NA results for phenotypes with < 20 cases or monomorphic snps

awk 'BEGIN{FS=OFS=","} $4!="NA"{print $0}' phewasresults/PheWas_All_snps.csv > phewasresults/PheWas_All_snps_without_NA.csv
awk 'BEGIN{FS=OFS=","} $4=="NA"{print $0}' phewasresults/PheWas_All_snps.csv > phewasresults/PheWas_All_snps_NA.csv


# Make combined Manhattan plot
Rscript combined_phewas_manhatthanplot.r






```


