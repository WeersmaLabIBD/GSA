#!/bin/bash

#set your working directory here:
wd=/groups/umcg-weersma/tmp03/Michiel/phewas/chunks
cd $wd/splits
ls * | while read line;
    do

echo "#!/bin/bash" >> ${line}.sh
echo "#SBATCH --job-name=${line}" >> ${line}.sh
echo "#SBATCH --mem 10gb" >> ${line}.sh
echo "#SBATCH --time=23:59:00" >> ${line}.sh
echo "#SBATCH --output=${line}.out" >> ${line}.sh
echo "#SBATCH --error=${line}.err" >> ${line}.sh
echo "#SBATCH --nodes 1" >> ${line}.sh
echo "#SBATCH --cpus-per-task=2" >> ${line}.sh
echo "cd $wd" >> ${line}.sh
echo "module load R" >> ${line}.sh
echo "Rscript ${line}.r" >> ${line}.sh

done
