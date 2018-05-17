#!/bin/bash
#check number of chunks you have created and enter here
for i in {000..154};
do
echo "#!/bin/bash" >> PheWas_chunk_"$i".sh
echo "#SBATCH --job-name=PheWAS_5c_chunk_"$i"" >> PheWas_chunk_"$i".sh
echo "#SBATCH --mem 10gb" >> PheWas_chunk_"$i".sh
echo "#SBATCH --time=23:59:00" >> PheWas_chunk_"$i".sh
echo "#SBATCH --output=PheWAS_5c_chunk_"$i".out" >> PheWas_chunk_"$i".sh
echo "#SBATCH --error=PheWAS_5c_chunk_"$i".err" >> PheWas_chunk_"$i".sh
echo "#SBATCH --nodes 1" >> PheWas_chunk_"$i".sh
echo "#SBATCH --cpus-per-task=2" >> PheWas_chunk_"$i".sh
echo "cd /groups/umcg-weersma/tmp04/Michiel/GSA-redo/phewas/PheWASanalysis/chunks" >> PheWas_chunk_"$i".sh
echo "module load R" >> PheWas_chunk_"$i".sh
echo "Rscript PheWas_chunk_"$i".r" >> PheWas_chunk_"$i".sh;
done
