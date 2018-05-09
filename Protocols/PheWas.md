# Author: Michiel Voskuil 

# Date: 2018/05/09

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









All scripts are available in the Github GSA/Tools directory.

```
# Set run directory in which input file is stored
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]

mkdir $RUNDIR/scripts
```

Make sure the following scripts are in **$RUNDIR/scripts**
```
 GS_to_OptiCall.sh
 OptiCall_to_plink.py
 HRC-1000G-check-bim.pl
 create_opticall_jobs.sh
 create_HRC_jobs.sh
 create_cut_jobs.sh
 create_IC_jobs.sh
 vcfparse.pl
 IC.pl
```


1. Convert GS final_report to optiCall input files
-------------------------------------------------------------------------
