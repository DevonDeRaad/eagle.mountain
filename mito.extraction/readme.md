### Mitochondrial genome extraction pipeline
This directory contains the code used to extract mitochondrial genomes, call haploid genotypes, align the resulting sequences, and construct a mtDNA haplotype network. Built into this pipeline are summary statistics including depth of sequencing coverage and variant allele frequency at each site in the mtDNA genome for each sample. 
- Each file with the suffix 'dp4_sums.txt' contains the depth of coverage at each site on the mtDNA scaffold, for a single sample. Making a histogram of these values will help you determine whether you got enough mtDNA reads to call genotypes for each sample
- Each file with the suffix 'VAF.txt' contains the variant allele frequency (VAF) at each site in the mtDNA genome for a single sample. Making a histogram of these values will help you identify potential cases of contamination
- Each file with the suffix 'mito.fa' contains the called mtDNA genome haplotype for a single individual.
- The file 'mito.alignment.fa' is an unaligned FASTA file containing the entire called mtDNA haplotype for each individual.
- A walkthrough of the entire pipeline with resulting visualizations can be found at: https://devonderaad.github.io/eagle.mountain/mito.extraction/perform.mito.extraction.html
