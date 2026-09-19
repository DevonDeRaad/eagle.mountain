#### submit_job.sh START ####
#!/bin/bash
#$ -cwd
#$ -o ./joblog.$JOB_ID.txt                   #set the job log output file
#$ -j y                                      #set error = Merged with joblog
#$ -l h_rt=24:00:00,h_data=5G      #specify requested resources (h_rt gives time request in 'hrs:mins:secs' format) (h_data specifies requested RAM per task) (highp=TRUE means run it on Aguillon Lab owned nodes)
#$ -pe shared 1                              #specify number of CPUs requested

#load necessary modules
. /u/local/Modules/default/init/modules.sh
#load programs
module load bcftools #(version: 1.11)



### Step 0: get a filtered vcf file that includes all of the necessary samples (both reference pops and the putative hybrids)

#Needs to be a biallelic vcf where genotypes are only 0/0, 0/1, and 1/1. This is required to accurately count reference and alternate alleles in step 2b.



### First run: 93535

### Step 1: define input files
#define the vcf to use
vcf=final.trimmed.snps.vcf.gz

#define samples to use as the parentals (pop0)
cat > pop0.txt << 'EOF'
Aph_californica_56723
Aph_californica_65019
Aph_californica_65020
Aph_californica_333971
Aph_californica_342053
Aph_californica_342054
Aph_californica_342072
Aph_californica_334039
Aph_californica_334041
Aph_californica_195411
Aph_californica_343436
Aph_californica_193641
Aph_californica_342022
EOF

#define samples to use as the parentals (pop1)
cat > pop1.txt << 'EOF'
Aph_woodhouseii_50478
Aph_woodhouseii_27904
Aph_woodhouseii_19203
Aph_woodhouseii_68851
Aph_woodhouseii_334080
Aph_woodhouseii_334081
Aph_woodhouseii_334096
EOF

#define hybrid samples to use for ancestry inference
cat > hybrids.txt << 'EOF'
Aph_californica_93535
EOF

#define hybrid samples with ploidy for ancestryHMM input
cat > sample_list.txt << 'EOF'
Aph_californica_93535	2
EOF



### Step 2: Generate the Ancestry_HMM Input File

#Based on the tutorial associated with the program (https://github.com/russcd/Ancestry_HMM/tree/master)
#The goal is a tab-delimited file with the following columns:
#1. Chromosome
#2. Position in basepairs
#3. Allele counts of allele A in reference panel 0
#4. Allele counts of allele a in reference panel 0
#5. Allele counts of allele A in reference panel 1
#6. Allele counts of allele a in reference panel 1
#7. Distance in Morgans between the previous marker and this position.
#8. Read counts of allele A in sample 1
#9. Read counts of allele a in sample 1
#10. Read counts of allele A in sample 2
#11. Read counts of allele a in sample 2
#(keep going 2 columns per sample)

### Step 2a: use bcftools to extract columns 1 and 2 for the input file
bcftools query -f '%CHROM\t%POS\n' ${vcf} > ancestryHMM.input.txt

### Step 2b: use bcftools and awk to calculate the reference allele count for the first reference population (column 3) and add that info to the text file 
#inputs for this step are the filtered vcf and a list of samples that correspond to each reference population.
bcftools view -S pop0.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/0/,"0",$i); print c}' > ref_counts.txt
# Add the counts as column 3
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2c: use bcftools and awk to calculate the ALT allele count for the first reference population (column 4) and add that info to the text file 
bcftools view -S pop0.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/1/,"1",$i); print c}' > ref_counts.txt
# Add the counts as column 4
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2d: use bcftools and awk to calculate the REF allele count for the second reference population (column 5) and add that info to the text file 
bcftools view -S pop1.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/0/,"0",$i); print c}' > ref_counts.txt
# Add the counts as column 5
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2e: use bcftools and awk to calculate the ALT allele count for the second reference population (column 6) and add that info to the text file 
bcftools view -S pop1.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/1/,"1",$i); print c}' > ref_counts.txt
# Add the counts as column 6
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2f: calculate distance in Morgans between SNPs (column 7)
# Simple uniform rate — multiply at a rate of 3.57 centimorgans per Mb (https://www.biorxiv.org/content/10.1101/2025.08.18.670172v1.full)
bcftools query -f '%CHROM\t%POS\n' ${vcf} | awk 'BEGIN{OFS="\t"} {cM = $2 / 1e6 * 3.57; print $1, $2, cM}' > ref_counts.txt
# Get the difference between previous and current row in centimorgans (expected input for column 7)
awk 'NR>1 {print $3-prev} {prev=$3}' ref_counts.txt > centimorgans.txt
#add in a 0 for the first row, which doesn't get a value from the previous code because there is no preceding row to subtract from:
{ echo 0; cat centimorgans.txt; } > centimorgans.tmp && mv centimorgans.tmp centimorgans.txt
# Add the values as column 7
paste ancestryHMM.input.txt centimorgans.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2g: add in allele depth counts for each putative hybrid sample
#extract allele depth for each sample
bcftools view -S hybrids.txt ${vcf} | bcftools query -f '%CHROM\t%POS[\t%AD]\n' > raw_AD.txt
#awk code to convert '.' into '0', which correctly implies zero supporting reads
awk 'BEGIN{OFS="\t"} {printf "%s\t%s", $1, $2
    for (i=3; i<=NF; i++) {field = $i
        # Handle lone "." — treat as missing, output 0 0
        if (field == ".") {printf "\t0\t0"}
        # Handle "ref,." or ".,alt" — dot means 0 for that allele
        else {
            n = split(field, a, ",")
            ref = (a[1] == "." ? 0 : a[1])
            alt = (a[2] == "." ? 0 : a[2])
            printf "\t%s\t%s", ref, alt
        }
    }
    printf "\n"
}' raw_AD.txt > cleaned_counts.txt
#remove the first two columns (redundant info on chromosome and position)
cut -f3- cleaned_counts.txt > cleaned_counts.tmp && mv cleaned_counts.tmp cleaned_counts.txt
#merge the allele counts into the input file (columns 8 - 8+2n, where n = # of hybrid samples)
paste ancestryHMM.input.txt cleaned_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2h: (optional) Restrict the input SNP dataset to only diagnostic alleles.
#Schumer lab has gotten very reliable results using the ancestryHMM program restricted to highly diagnostic (0.98 AF diff) loci: https://github.com/Schumerlab/ancestryinfer
#calculate allele frequency in population 0
awk '{print $3/($3+$4)}' ancestryHMM.input.txt > pop0freq.txt
#calculate allele frequency in population 1
awk '{print $5/($5+$6)}' ancestryHMM.input.txt > pop1freq.txt
#calculate allele frequency difference
paste pop1freq.txt pop0freq.txt | awk '{print ($1>$2 ? $1-$2 : $2-$1)}' > afdif.txt
#subset input file to only sites where the allele frequency difference > 0.9
awk 'NR==FNR {keep[FNR]=($1>0.9); next} keep[FNR]' afdif.txt ancestryHMM.input.txt > diagnostic.HMM.input.txt
#print number of input SNPs
cat ancestryHMM.input.txt | wc -l > numsnps
echo "number of input SNPs = $numsnps"
#print number of AIMs used:
cat diagnostic.HMM.input.txt | wc -l > numaims
echo "number of AIMs used = $numaims"

#recalculate distance in Morgans between SNPs (column 7) which has now changed because the dataframe has been subset
#subset the dataframe with morgans info to only the diagnostic SNPs
awk 'NR==FNR {keep[FNR]=($1>0.9); next} keep[FNR]' afdif.txt ref_counts.txt > diagnostic.refcounts.txt
# Get the difference between previous and current row in centimorgans (expected input for column 7)
awk 'NR>1 {print $3-prev} {prev=$3}' diagnostic.refcounts.txt > centimorgans.txt
#add in a 0 for the first row, which doesn't get a value from the previous code because there is no preceding row to subtract from:
{ echo 0; cat centimorgans.txt; } > centimorgans.tmp && mv centimorgans.tmp centimorgans.txt
# Add the values as column 7
awk 'BEGIN{FS=OFS="\t"} NR==FNR{a[FNR]=$1; next} {$7=a[FNR]; print}' centimorgans.txt diagnostic.HMM.input.txt > tmp && mv tmp diagnostic.HMM.input.txt



### Step 3: run ancestryHMM

#code used to install the program:
#module load conda
#conda create -n ancestryHMM
#conda activate ancestryHMM
#conda install -c conda-forge -c bioconda ancestry_hmm

#activate the program
module load conda
conda activate ancestryHMM
#run the program
ancestry_hmm -i diagnostic.HMM.input.txt -s sample_list.txt -a 2 0.6687 0.3313 -p 0 100000 0.6687 -p 1 -100 0.3313 -o cana.93535

#example details:
#  -i ancestryHMM.input.txt \      #formatted input file
#  -s sample_list.txt \            #for each putative hybrid, one sample name per line (first column) plus ploidy (second column) tab delimited
#  -a 2 0.8 0.2 \                  #2 ancestral pops, estimated ancestry contributions
#  -p 0 100000 0.8 \               #pop 0: initial pulse (ie, founded the pop 100K generations ago), 80% contribution to current ancestry
#  -p 1 -100 0.2 \                 #pop 1: program will estimate the time of the ancestry pulse (which replaced 20%) using an initial time estimate of 100 gens ago
#  -o testrun                      #name the output files





### Run 2: 94204

### Step 1: define input files
#define the vcf to use
vcf=final.trimmed.snps.vcf.gz

#define samples to use as the parentals (pop0)
cat > pop0.txt << 'EOF'
Aph_californica_56723
Aph_californica_65019
Aph_californica_65020
Aph_californica_333971
Aph_californica_342053
Aph_californica_342054
Aph_californica_342072
Aph_californica_334039
Aph_californica_334041
Aph_californica_195411
Aph_californica_343436
Aph_californica_193641
Aph_californica_342022
EOF

#define samples to use as the parentals (pop1)
cat > pop1.txt << 'EOF'
Aph_woodhouseii_50478
Aph_woodhouseii_27904
Aph_woodhouseii_19203
Aph_woodhouseii_68851
Aph_woodhouseii_334080
Aph_woodhouseii_334081
Aph_woodhouseii_334096
EOF

#define hybrid samples to use for ancestry inference
cat > hybrids.txt << 'EOF'
Aph_californica_94204
EOF

#define hybrid samples with ploidy for ancestryHMM input
cat > sample_list.txt << 'EOF'
Aph_californica_94204   2
EOF



### Step 2: Generate the Ancestry_HMM Input File

#Based on the tutorial associated with the program (https://github.com/russcd/Ancestry_HMM/tree/master)
#The goal is a tab-delimited file with the following columns:
#1. Chromosome
#2. Position in basepairs
#3. Allele counts of allele A in reference panel 0
#4. Allele counts of allele a in reference panel 0
#5. Allele counts of allele A in reference panel 1
#6. Allele counts of allele a in reference panel 1
#7. Distance in Morgans between the previous marker and this position.
#8. Read counts of allele A in sample 1
#9. Read counts of allele a in sample 1
#10. Read counts of allele A in sample 2
#11. Read counts of allele a in sample 2
#(keep going 2 columns per sample)

### Step 2a: use bcftools to extract columns 1 and 2 for the input file
bcftools query -f '%CHROM\t%POS\n' ${vcf} > ancestryHMM.input.txt

### Step 2b: use bcftools and awk to calculate the reference allele count for the first reference population (column 3) and add that info to the text file 
#inputs for this step are the filtered vcf and a list of samples that correspond to each reference population.
bcftools view -S pop0.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/0/,"0",$i); print c}' > ref_counts.txt
# Add the counts as column 3
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2c: use bcftools and awk to calculate the ALT allele count for the first reference population (column 4) and add that info to the text file 
bcftools view -S pop0.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/1/,"1",$i); print c}' > ref_counts.txt
# Add the counts as column 4
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2d: use bcftools and awk to calculate the REF allele count for the second reference population (column 5) and add that info to the text file 
bcftools view -S pop1.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/0/,"0",$i); print c}' > ref_counts.txt
# Add the counts as column 5
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2e: use bcftools and awk to calculate the ALT allele count for the second reference population (column 6) and add that info to the text file 
bcftools view -S pop1.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/1/,"1",$i); print c}' > ref_counts.txt
# Add the counts as column 6
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2f: calculate distance in Morgans between SNPs (column 7)
# Simple uniform rate — multiply at a rate of 3.57 centimorgans per Mb (https://www.biorxiv.org/content/10.1101/2025.08.18.670172v1.full)
bcftools query -f '%CHROM\t%POS\n' ${vcf} | awk 'BEGIN{OFS="\t"} {cM = $2 / 1e6 * 3.57; print $1, $2, cM}' > ref_counts.txt
# Get the difference between previous and current row in centimorgans (expected input for column 7)
awk 'NR>1 {print $3-prev} {prev=$3}' ref_counts.txt > centimorgans.txt
#add in a 0 for the first row, which doesn't get a value from the previous code because there is no preceding row to subtract from:
{ echo 0; cat centimorgans.txt; } > centimorgans.tmp && mv centimorgans.tmp centimorgans.txt
# Add the values as column 7
paste ancestryHMM.input.txt centimorgans.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2g: add in allele depth counts for each putative hybrid sample
#extract allele depth for each sample
bcftools view -S hybrids.txt ${vcf} | bcftools query -f '%CHROM\t%POS[\t%AD]\n' > raw_AD.txt
#awk code to convert '.' into '0', which correctly implies zero supporting reads
awk 'BEGIN{OFS="\t"} {printf "%s\t%s", $1, $2
    for (i=3; i<=NF; i++) {field = $i
        # Handle lone "." — treat as missing, output 0 0
        if (field == ".") {printf "\t0\t0"}
        # Handle "ref,." or ".,alt" — dot means 0 for that allele
        else {
            n = split(field, a, ",")
            ref = (a[1] == "." ? 0 : a[1])
            alt = (a[2] == "." ? 0 : a[2])
            printf "\t%s\t%s", ref, alt
        }
    }
    printf "\n"
}' raw_AD.txt > cleaned_counts.txt
#remove the first two columns (redundant info on chromosome and position)
cut -f3- cleaned_counts.txt > cleaned_counts.tmp && mv cleaned_counts.tmp cleaned_counts.txt
#merge the allele counts into the input file (columns 8 - 8+2n, where n = # of hybrid samples)
paste ancestryHMM.input.txt cleaned_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2h: (optional) Restrict the input SNP dataset to only diagnostic alleles.
#Schumer lab has gotten very reliable results using the ancestryHMM program restricted to highly diagnostic (0.98 AF diff) loci: https://github.com/Schumerlab/ancestryinfer
#calculate allele frequency in population 0
awk '{print $3/($3+$4)}' ancestryHMM.input.txt > pop0freq.txt
#calculate allele frequency in population 1
awk '{print $5/($5+$6)}' ancestryHMM.input.txt > pop1freq.txt
#calculate allele frequency difference
paste pop1freq.txt pop0freq.txt | awk '{print ($1>$2 ? $1-$2 : $2-$1)}' > afdif.txt
#subset input file to only sites where the allele frequency difference > 0.9
awk 'NR==FNR {keep[FNR]=($1>0.9); next} keep[FNR]' afdif.txt ancestryHMM.input.txt > diagnostic.HMM.input.txt
#print number of input SNPs
cat ancestryHMM.input.txt | wc -l > numsnps
echo "number of input SNPs = $numsnps"
#print number of AIMs used:
cat diagnostic.HMM.input.txt | wc -l > numaims
echo "number of AIMs used = $numaims"

#recalculate distance in Morgans between SNPs (column 7) which has now changed because the dataframe has been subset
#subset the dataframe with morgans info to only the diagnostic SNPs
awk 'NR==FNR {keep[FNR]=($1>0.9); next} keep[FNR]' afdif.txt ref_counts.txt > diagnostic.refcounts.txt
# Get the difference between previous and current row in centimorgans (expected input for column 7)
awk 'NR>1 {print $3-prev} {prev=$3}' diagnostic.refcounts.txt > centimorgans.txt
#add in a 0 for the first row, which doesn't get a value from the previous code because there is no preceding row to subtract from:
{ echo 0; cat centimorgans.txt; } > centimorgans.tmp && mv centimorgans.tmp centimorgans.txt
# Add the values as column 7
awk 'BEGIN{FS=OFS="\t"} NR==FNR{a[FNR]=$1; next} {$7=a[FNR]; print}' centimorgans.txt diagnostic.HMM.input.txt > tmp && mv tmp diagnostic.HMM.input.txt



### Step 3: run ancestryHMM

#code used to install the program:
#module load conda
#conda create -n ancestryHMM
#conda activate ancestryHMM
#conda install -c conda-forge -c bioconda ancestry_hmm

#activate the program
module load conda
conda activate ancestryHMM
#run the program
ancestry_hmm -i diagnostic.HMM.input.txt -s sample_list.txt -a 2 0.850906 0.149094 -p 0 100000 0.850906 -p 1 -100 0.149094 -o cana.94204

#example details:
#  -i ancestryHMM.input.txt \      #formatted input file
#  -s sample_list.txt \            #for each putative hybrid, one sample name per line (first column) plus ploidy (second column) tab delimited
#  -a 2 0.8 0.2 \                  #2 ancestral pops, estimated ancestry contributions
#  -p 0 100000 0.8 \               #pop 0: initial pulse (ie, founded the pop 100K generations ago), 80% contribution to current ancestry
#  -p 1 -100 0.2 \                 #pop 1: program will estimate the time of the ancestry pulse (which replaced 20%) using an initial time estimate of 100 gens ago
#  -o testrun                      #name the output files





### Run 3: 94205

### Step 1: define input files
#define the vcf to use
vcf=final.trimmed.snps.vcf.gz

#define samples to use as the parentals (pop0)
cat > pop0.txt << 'EOF'
Aph_californica_56723
Aph_californica_65019
Aph_californica_65020
Aph_californica_333971
Aph_californica_342053
Aph_californica_342054
Aph_californica_342072
Aph_californica_334039
Aph_californica_334041
Aph_californica_195411
Aph_californica_343436
Aph_californica_193641
Aph_californica_342022
EOF

#define samples to use as the parentals (pop1)
cat > pop1.txt << 'EOF'
Aph_woodhouseii_50478
Aph_woodhouseii_27904
Aph_woodhouseii_19203
Aph_woodhouseii_68851
Aph_woodhouseii_334080
Aph_woodhouseii_334081
Aph_woodhouseii_334096
EOF

#define hybrid samples to use for ancestry inference
cat > hybrids.txt << 'EOF'
Aph_californica_94205
EOF

#define hybrid samples with ploidy for ancestryHMM input
cat > sample_list.txt << 'EOF'
Aph_californica_94205   2
EOF



### Step 2: Generate the Ancestry_HMM Input File

#Based on the tutorial associated with the program (https://github.com/russcd/Ancestry_HMM/tree/master)
#The goal is a tab-delimited file with the following columns:
#1. Chromosome
#2. Position in basepairs
#3. Allele counts of allele A in reference panel 0
#4. Allele counts of allele a in reference panel 0
#5. Allele counts of allele A in reference panel 1
#6. Allele counts of allele a in reference panel 1
#7. Distance in Morgans between the previous marker and this position.
#8. Read counts of allele A in sample 1
#9. Read counts of allele a in sample 1
#10. Read counts of allele A in sample 2
#11. Read counts of allele a in sample 2
#(keep going 2 columns per sample)

### Step 2a: use bcftools to extract columns 1 and 2 for the input file
bcftools query -f '%CHROM\t%POS\n' ${vcf} > ancestryHMM.input.txt

### Step 2b: use bcftools and awk to calculate the reference allele count for the first reference population (column 3) and add that info to the text file 
#inputs for this step are the filtered vcf and a list of samples that correspond to each reference population.
bcftools view -S pop0.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/0/,"0",$i); print c}' > ref_counts.txt
# Add the counts as column 3
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2c: use bcftools and awk to calculate the ALT allele count for the first reference population (column 4) and add that info to the text file 
bcftools view -S pop0.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/1/,"1",$i); print c}' > ref_counts.txt
# Add the counts as column 4
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2d: use bcftools and awk to calculate the REF allele count for the second reference population (column 5) and add that info to the text file 
bcftools view -S pop1.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/0/,"0",$i); print c}' > ref_counts.txt
# Add the counts as column 5
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2e: use bcftools and awk to calculate the ALT allele count for the second reference population (column 6) and add that info to the text file 
bcftools view -S pop1.txt ${vcf} | bcftools query -f '[\t%GT]\n' |
awk '{c=0; for(i=1;i<=NF;i++) c+=gsub(/1/,"1",$i); print c}' > ref_counts.txt
# Add the counts as column 6
paste ancestryHMM.input.txt ref_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2f: calculate distance in Morgans between SNPs (column 7)
# Simple uniform rate — multiply at a rate of 3.57 centimorgans per Mb (https://www.biorxiv.org/content/10.1101/2025.08.18.670172v1.full)
bcftools query -f '%CHROM\t%POS\n' ${vcf} | awk 'BEGIN{OFS="\t"} {cM = $2 / 1e6 * 3.57; print $1, $2, cM}' > ref_counts.txt
# Get the difference between previous and current row in centimorgans (expected input for column 7)
awk 'NR>1 {print $3-prev} {prev=$3}' ref_counts.txt > centimorgans.txt
#add in a 0 for the first row, which doesn't get a value from the previous code because there is no preceding row to subtract from:
{ echo 0; cat centimorgans.txt; } > centimorgans.tmp && mv centimorgans.tmp centimorgans.txt
# Add the values as column 7
paste ancestryHMM.input.txt centimorgans.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2g: add in allele depth counts for each putative hybrid sample
#extract allele depth for each sample
bcftools view -S hybrids.txt ${vcf} | bcftools query -f '%CHROM\t%POS[\t%AD]\n' > raw_AD.txt
#awk code to convert '.' into '0', which correctly implies zero supporting reads
awk 'BEGIN{OFS="\t"} {printf "%s\t%s", $1, $2
    for (i=3; i<=NF; i++) {field = $i
        # Handle lone "." — treat as missing, output 0 0
        if (field == ".") {printf "\t0\t0"}
        # Handle "ref,." or ".,alt" — dot means 0 for that allele
        else {
            n = split(field, a, ",")
            ref = (a[1] == "." ? 0 : a[1])
            alt = (a[2] == "." ? 0 : a[2])
            printf "\t%s\t%s", ref, alt
        }
    }
    printf "\n"
}' raw_AD.txt > cleaned_counts.txt
#remove the first two columns (redundant info on chromosome and position)
cut -f3- cleaned_counts.txt > cleaned_counts.tmp && mv cleaned_counts.tmp cleaned_counts.txt
#merge the allele counts into the input file (columns 8 - 8+2n, where n = # of hybrid samples)
paste ancestryHMM.input.txt cleaned_counts.txt > ancestryHMM.input.tmp && mv ancestryHMM.input.tmp ancestryHMM.input.txt

### Step 2h: (optional) Restrict the input SNP dataset to only diagnostic alleles.
#Schumer lab has gotten very reliable results using the ancestryHMM program restricted to highly diagnostic (0.98 AF diff) loci: https://github.com/Schumerlab/ancestryinfer
#calculate allele frequency in population 0
awk '{print $3/($3+$4)}' ancestryHMM.input.txt > pop0freq.txt
#calculate allele frequency in population 1
awk '{print $5/($5+$6)}' ancestryHMM.input.txt > pop1freq.txt
#calculate allele frequency difference
paste pop1freq.txt pop0freq.txt | awk '{print ($1>$2 ? $1-$2 : $2-$1)}' > afdif.txt
#subset input file to only sites where the allele frequency difference > 0.9
awk 'NR==FNR {keep[FNR]=($1>0.9); next} keep[FNR]' afdif.txt ancestryHMM.input.txt > diagnostic.HMM.input.txt
#print number of input SNPs
cat ancestryHMM.input.txt | wc -l > numsnps
echo "number of input SNPs = $numsnps"
#print number of AIMs used:
cat diagnostic.HMM.input.txt | wc -l > numaims
echo "number of AIMs used = $numaims"

#recalculate distance in Morgans between SNPs (column 7) which has now changed because the dataframe has been subset
#subset the dataframe with morgans info to only the diagnostic SNPs
awk 'NR==FNR {keep[FNR]=($1>0.9); next} keep[FNR]' afdif.txt ref_counts.txt > diagnostic.refcounts.txt
# Get the difference between previous and current row in centimorgans (expected input for column 7)
awk 'NR>1 {print $3-prev} {prev=$3}' diagnostic.refcounts.txt > centimorgans.txt
#add in a 0 for the first row, which doesn't get a value from the previous code because there is no preceding row to subtract from:
{ echo 0; cat centimorgans.txt; } > centimorgans.tmp && mv centimorgans.tmp centimorgans.txt
# Add the values as column 7
awk 'BEGIN{FS=OFS="\t"} NR==FNR{a[FNR]=$1; next} {$7=a[FNR]; print}' centimorgans.txt diagnostic.HMM.input.txt > tmp && mv tmp diagnostic.HMM.input.txt



### Step 3: run ancestryHMM

#code used to install the program:
#module load conda
#conda create -n ancestryHMM
#conda activate ancestryHMM
#conda install -c conda-forge -c bioconda ancestry_hmm

#activate the program
module load conda
conda activate ancestryHMM
#run the program
ancestry_hmm -i diagnostic.HMM.input.txt -s sample_list.txt -a 2 0.835957 0.164043 -p 0 100000 0.835957 -p 1 -100 0.164043 -o cana.94205

#example details:
#  -i ancestryHMM.input.txt \      #formatted input file
#  -s sample_list.txt \            #for each putative hybrid, one sample name per line (first column) plus ploidy (second column) tab delimited
#  -a 2 0.8 0.2 \                  #2 ancestral pops, estimated ancestry contributions
#  -p 0 100000 0.8 \               #pop 0: initial pulse (ie, founded the pop 100K generations ago), 80% contribution to current ancestry
#  -p 1 -100 0.2 \                 #pop 1: program will estimate the time of the ancestry pulse (which replaced 20%) using an initial time estimate of 100 gens ago
#  -o testrun                      #name the output files















