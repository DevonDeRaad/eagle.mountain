#### submit_job.sh START ####
#!/bin/bash
#$ -cwd
#$ -o ./joblog.$JOB_ID         #set the job log output file
#$ -j y                   #set error = Merged with joblog
#$ -l h_rt=24:00:00,h_data=5G   #specify requested resources (h_rt gives time request in 'hrs:mins:secs' format) (h_data specifies requested RAM per task) (highp=TRUE means run it on Aguillon Lab owned nodes)
#$ -pe shared 20              #specify number of CPUs requested


#load modules
. /u/local/Modules/default/init/modules.sh
#load programs
module load bcftools #(version: 1.11)
module load htslib

# run bcftools to merge the vcf files
bcftools merge --threads 20 -m id --output-type z vcf/*.depth.filtered.vcf.gz --output vcf/allsamps.depth.filtered.vcf.gz

#Filter using locally installed version of vcftools (v0.1.17)
#To retain a SNP, genotypes must be called in >= 90% of samples, it must be bi-allelic, and it must have a minor allele count >=3 
/u/project/aguillon/shared_bin/vcftools/src/cpp/vcftools --gzvcf vcf/allsamps.depth.filtered.vcf.gz --max-missing 0.9 --max-alleles 2 --mac 3 --recode --recode-INFO-all --stdout | bgzip > vcf/filtered.miss90.mac3.vcf.gz

#mac and linkage filter
/u/project/aguillon/shared_bin/vcftools/src/cpp/vcftools --gzvcf vcf/filtered.miss90.mac3.vcf.gz --thin 5000 --recode --recode-INFO-all --stdout | bgzip > vcf/filtered.miss90.mac3.thin5000.vcf.gz
