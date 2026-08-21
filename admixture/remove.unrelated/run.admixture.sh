#### submit_job.sh START ####
#!/bin/bash
#$ -cwd
#$ -o ./joblog.$JOB_ID.txt                   #set the job log output file
#$ -j y                                      #set error = Merged with joblog
#$ -l h_rt=1:00:00,h_data=3G      #specify requested resources (h_rt gives time request in 'hrs:mins:secs' format) (h_data specifies requested RAM per task) (highp=TRUE means run it on Aguillon Lab owned nodes)
#$ -pe shared 10                              #specify number of CPUs requested

#load necessary modules
. /u/local/Modules/default/init/modules.sh
#load plink #(v1.90b6.24)
module load plink/1.90b624

#use plink to convert vcf directly to bed format:
plink --vcf unrelated.trimmed.vcf --double-id --allow-extra-chr --make-bed --out binary_fileset
#fix chromosome names
cut -f2- binary_fileset.bim  > temp
awk 'BEGIN{FS=OFS="\t"}{print value 1 OFS $0}' temp > binary_fileset.bim

#run admixture for a K of 1-10, using cross-validation, with 10 threads
for K in 1 2 3 4 5 6 7 8 9 10; 
do /u/project/aguillon/shared_bin/admixture_linux-1.3.0/admixture --cv -j10 binary_fileset.bed $K | tee log${K}.out;
done

#Which K iteration is optimal according to ADMIXTURE ?
grep -h CV log*.out > log.errors.txt

