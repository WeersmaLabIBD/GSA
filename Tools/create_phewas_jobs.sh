#!/bin/bash

for i in {1..22};
do
echo "#!/bin/bash" >> PheWas_chr_"$i".sh
echo "#SBATCH --job-name=PheWAS_5c_chr_"$i"" >> PheWas_chr_"$i".sh
echo "#SBATCH --mem 30gb" >> PheWas_chr_"$i".sh
echo "#SBATCH --time=2-23:00:00" >> PheWas_chr_"$i".sh
echo "#SBATCH --output=PheWAS_5c_chr_"$i".out" >> PheWas_chr_"$i".sh
echo "#SBATCH --error=PheWAS_5c_chr_"$i".err" >> PheWas_chr_"$i".sh
echo "#SBATCH --nodes 1" >> PheWas_chr_"$i".sh
echo "#SBATCH --cpus-per-task=5" >> PheWas_chr_"$i".sh
echo "cd /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/AllImputedsnps_maf001_parallel" >> PheWas_chr_"$i".sh
echo "module load R" >> PheWas_chr_"$i".sh
echo "Rscript PheWas_chr_"$i".r" >> PheWas_chr_"$i".sh;
done
