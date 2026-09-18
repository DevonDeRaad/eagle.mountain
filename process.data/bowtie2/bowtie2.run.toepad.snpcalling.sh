#### submit_job.sh START ####
#!/bin/bash
#$ -cwd
#$ -o ./joblog.$JOB_ID.$TASK_ID.txt          #set the job log output file
#$ -j y                   #set error = Merged with joblog
#$ -l h_rt=24:00:00,h_data=5G   #specify requested resources (h_rt gives time request in 'hrs:mins:secs' format) (h_data specifies requested RAM per task) (highp=TRUE means run it on Aguillon Lab owned nodes)
#$ -pe shared 1             #specify number of CPUs requested
#  Job array indexes (1-200: by 1)
#$ -t 1-11:1

#load modules
. /u/local/Modules/default/init/modules.sh
#load programs
module load bcftools #(version: 1.11)
module load samtools #(Version: 1.15)
module load java/jdk-17.0.12
module load R
module load python
module load bowtie2
#find the python programs installed in my path
source ~/.bashrc

#make output directories
#mkdir cleaned_reads
#mkdir bam_files
#mkdir vcf
#mkdir stats

#set threads
threads=15

#index reference genome (this only needs to be done once and then it can be commented out)
#on August 12, 2026, I used the following code 'wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/041/296/385/GCF_041296385.2_UR_Acoe_1.0/GCF_041296385.2_UR_Acoe_1.0_genomic.fna.gz'
#to download this assembly: https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_041296385.2/ of a Florida Scrub-jay
#then renamed it to 'FLSJ.fna.gz' and ran: 'gunzip FLSJ.fna.gz'
#index for bwa
#/u/project/aguillon/shared_bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 index FLSJ.fna
#index for picard (v3.3.0)
#java -jar /u/project/aguillon/shared_bin/picard/build/libs/picard.jar CreateSequenceDictionary R=FLSJ.fna O=FLSJ.fna.dict
#index for samtools
#samtools faidx FLSJ.fna

# define the reference genome
refgenome=/u/home/d/dderaad/project-aguillon/eagle.mountain.scrubjays/FLSJ.fna

# isolate base name for this replicate
sample=$( head -n${SGE_TASK_ID} /u/home/d/dderaad/project-aguillon/eagle.mountain.scrubjays/toepad.basenames.txt | tail -n1 )

#run fastp
#/u/project/aguillon/shared_bin/fastp -i raw.fastq/concatenated.reads/${sample}_R1.fastq.gz \ #input read 1
#        -I raw.fastq/concatenated.reads/${sample}_R2.fastq.gz \ #input read 2
#        -o cleaned_reads/${sample}-READ1.fastq.gz \ #output cleaned reads
#        -O cleaned_reads/${sample}-READ2.fastq.gz \ #output cleaned reads
#        --unpaired1 cleaned_reads/${sample}-READ-singleton.fastq.gz \ #remove unpaired reads
#        --unpaired2 cleaned_reads/${sample}-READ-singleton.fastq.gz \ #remove unpaired reads
#        --detect_adapter_for_pe \ #remove adapters
#        --length_required 25 \ #remove trimmed reads below 25 base-pairs
#        -c \ #enable read-correction based on overlapping paired ends
#        -h cleaned_reads/${sample}.html #output report

#(the above code is commented out because it was run once in the directory above this, so that each mapping approach didn't require re-filtering the raw reads)
echo"
#run bowtie2 (v2.4.2) with default parameters.
#bowtie2 default mode implicitly includes the '--end-to-end' and '--sensitive' flags, which should result in more conservative mapping than bwa
bowtie2 --threads ${threads} -x /u/home/d/dderaad/project-aguillon/eagle.mountain.scrubjays/FLSJ \
-1 /u/home/d/dderaad/project-aguillon/eagle.mountain.scrubjays/cleaned_reads/${sample}-READ1.fastq.gz \
-2 /u/home/d/dderaad/project-aguillon/eagle.mountain.scrubjays/cleaned_reads/${sample}-READ2.fastq.gz | samtools sort -o bam_files/${sample}.bam

# add read groups to sorted bam file
java -jar /u/project/aguillon/shared_bin/picard/build/libs/picard.jar AddOrReplaceReadGroups I=bam_files/${sample}.bam O=bam_files/${sample}_rg.bam RGLB=1 RGPL=illumina RGPU=unit1 RGSM=${sample}

# remove the sorted bam file
rm bam_files/${sample}.bam

# remove duplicates from the bam file with read groups (creates final bam file)
java -jar /u/project/aguillon/shared_bin/picard/build/libs/picard.jar MarkDuplicates REMOVE_DUPLICATES=true M=bam_files/${sample}_markdups_metric_file.txt I=bam_files/${sample}_rg.bam O=bam_files/${sample}_final.bam

# remove the remaining intermediate bam file
rm bam_files/${sample}_rg.bam

# index the final bam file
samtools index bam_files/${sample}_final.bam

#quantify insert sizes for this sample using picard (v3.3.0)
java -jar /u/project/aguillon/shared_bin/picard/build/libs/picard.jar CollectInsertSizeMetrics \
 I=bam_files/${sample}_final.bam \
 O=stats/${sample}.insert_size_metrics.txt \
 H=stats/${sample}.insert_size_histogram.pdf \
 M=0.5

#filter to remove reads mapped with an insert size less than the length of a single read (50 bp) which are likely spurious
samtools view -h bam_files/${sample}_final.bam | \
awk 'BEGIN{OFS="\t"}
     /^@/ {print; next}
     { if ($9 < 0) tlen = -$9; else tlen = $9 }
     tlen >= 50 { print }' | \
samtools view -b -o bam_files/${sample}_final_filtered.bam

#remove remaining intermediate bam
rm bam_files/${sample}_final.bam

# index the final bam file
samtools index bam_files/${sample}_final_filtered.bam

#re-quantify insert sizes to ensure filtering worked
java -jar /u/project/aguillon/shared_bin/picard/build/libs/picard.jar CollectInsertSizeMetrics \
 I=bam_files/${sample}_final_filtered.bam \
 O=stats/${sample}.filtered_insert_size_metrics.txt \
 H=stats/${sample}.filtered_insert_size_histogram.pdf \
 M=0.5
"
##### Run mapDamage (toepad samples only)
#run mapdamage (v2.3.0a0)
mapDamage -i bam_files/${sample}_final_filtered.bam -r ${refgenome} --rescale

#replace the previous .bam file with the rescaled .bam file
rm bam_files/${sample}_final_filtered.bam
rm bam_files/${sample}_final.bam.bai
rm bam_files/${sample}_final_filtered.bam.bai
mv ${sample}_final_filtered.mapDamage/${sample}_final_filtered.rescaled.bam bam_files/${sample}_final_filtered.bam

# index the final bam file
samtools index bam_files/${sample}_final_filtered.bam
#####

###run bcftools to genotype
#-d 200 = do not consider reads beyond 200x depth covering a site to save memory space
#--min-MQ 10 = skip alignments with mapQ smaller than 10
bcftools mpileup -a FORMAT/DP,FORMAT/AD -Ou -d 200 --skip-indels --min-MQ 10 --threads ${threads} -f ${refgenome} bam_files/${sample}_final_filtered.bam | \
bcftools call -m --threads ${threads} --output-type z -o vcf/${sample}.allsites.vcf.gz

#tabix index
/u/project/aguillon/shared_bin/tabix-0.2.6/tabix vcf/${sample}.allsites.vcf.gz

# filter individual vcf files
#calculate average genome-wide depth for this sample and then determine 1/3 min cutoff and 3x max cutoff based on that
AVG_DP=$(samtools depth -a bam_files/${sample}_final_filtered.bam | awk '{sum+=$3; count++} END {print sum/count}')
echo $AVG_DP
HALF_DP=$(echo "$AVG_DP / 3" | bc)
UPPER_DP=$(echo "$AVG_DP * 3" | bc)

#filter to retain only sites with > 1/3 and < 3x average genome-wide depth, and QUAL > 19
bcftools view -i "QUAL>19 && FORMAT/DP>${HALF_DP} && FORMAT/DP<${UPPER_DP}" -Oz -o vcf/${sample}.depth.filtered.vcf.gz vcf/${sample}.allsites.vcf.gz

#tabix
/u/project/aguillon/shared_bin/tabix-0.2.6/tabix vcf/${sample}.depth.filtered.vcf.gz




#### export stats on this sample
#code from: https://sarahpenir.github.io/bioinformatics/awk/calculating-mapping-stats-from-a-bam-file-using-samtools-and-awk/

#get alignment stats
echo ${sample} > stats/${sample}.stats

#samtools calc mean depth of coverage at all sites in the reference genome (including sites with 0 coverage)
echo "avg. depth of coverage:" >> stats/${sample}.stats
samtools depth -a bam_files/${sample}_final_filtered.bam | awk '{c++;s+=$3}END{print s/c}' >> stats/${sample}.stats

#calculate breadth of coverage
echo "genome-wide breadth of coverage (proportion of sites with read count > 0):" >> stats/${sample}.stats
samtools depth -a bam_files/${sample}_final_filtered.bam | awk '{c++; if($3>0) total+=1}END{print (total/c)}' >> stats/${sample}.stats

#calculate mapping percentage
echo "mapping info for this sample:" >> stats/${sample}.stats
samtools flagstat bam_files/${sample}_final_filtered.bam >> stats/${sample}.stats
