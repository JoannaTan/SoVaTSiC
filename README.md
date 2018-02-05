# SoVaTSiC

A pipeline to perform quality evaluation and identify somatic variants for single cell DNA sequencing. 

The pipeline is written in Perl and R.

## R packages and software required
1. Mixtools (R package)
2. MASS (R package)
3. Samtools
4. GATK

For more information on how to run SoVatSC, please refer to https://github.com/JoannaTan/SoVatSC/wiki

To run SoVaTSiC

perl singlecellpipeline.pl --Config configfile.txt --Analysistype Analysis

There are three type of analysis that can be run:
1. CellQC (to look for low quality cells)
2. GenotypeQC (to look for thresholds across multiple variant quality parameters)
3. filtergenotypes (remove low quality genotypes and filter germline mutations)













 



