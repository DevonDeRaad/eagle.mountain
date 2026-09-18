#### submit_job.sh START ####
#!/bin/bash
#$ -cwd
#$ -o ./joblog.$JOB_ID.$TASK_ID.txt          #set the job log output file
#$ -j y                   #set error = Merged with joblog
#$ -l h_rt=10:00:00,h_data=5G   #specify requested resources (h_rt gives time request in 'hrs:mins:secs' format) (h_data specifies requested RAM per task) (highp=TRUE means run it on Aguillon Lab owned nodes)
#$ -pe shared 1              #specify number of CPUs requested
#  Job array indexes (1-25: by 1)
#$ -t 1-23:1

#load modules
. /u/local/Modules/default/init/modules.sh
#load programs
module load conda
conda activate pixy2 #version (2.3.2)
module load bcftools #(version: 1.11)

#base name so that the array gets one sample per job
basename_array=$( head -n${SGE_TASK_ID} basenames.txt | tail -n1 )

#write pop file for this sample
echo -e "${basename_array}\tpop1" > ${basename_array}_popfile.txt

#run pixy in 1Mb sliding windows
### use "--chromosomes 'X'" to restrict to just certain chromosomes in the vcf. Default is all chromosomes in vcf
pixy --stats pi \
--vcf /u/home/d/dderaad/project-aguillon/eagle.mountain.scrubjays/bwa.mem/vcf/${basename_array}.depth.filtered.vcf.gz \
--populations ${basename_array}_popfile.txt \
--window_size 1000000 \
--n_cores 1 \
--output_folder /u/home/d/dderaad/project-aguillon/eagle.mountain.scrubjays/main.text/pixy \
--output_prefix ${basename_array}
