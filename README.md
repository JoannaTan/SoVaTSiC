# SoVaTSiC

A framework to perform quality evaluation and identify somatic variants for single cell DNA sequencing. 

The framework consist codes written in Perl and R.

## R packages and software required
1. Mixtools (R package)
2. MASS (R package)
3. Samtools
4. GATK

## How to run
For more information on how to run SoVatSC, please refer to https://github.com/JoannaTan/SoVaTSiC/wiki

To run SoVaTSiC

perl singlecellpipeline.pl --Config configfile.txt --Analysistype Analysis

## Type of analysis available
There are three type of analysis that can be run:

1. CellQC 

The following is done when this function is chosen:
- Calculate ADO and FN rate to be used for identification of low quality cells
- Combine user input percentage of genome covered with the ADO and FN rate calculated to give a consolidated file containing all information

After obtaining the final output, we provide an R script that can help users to identify low quality cells.

Refer to https://github.com/JoannaTan/SoVaTSiC/wiki/3.-Cell-QC


2. GenotypeQC

The following is done when the GenotypeQC function is chosen:
- Remove variants sites within 10bp of each other
- Remove variant sites whereby variant is only seen in 1 cell
- Remove triallelic sites (sites with more than 1 alternative alleles)
- Identify the true positive and false positive set so that users can determine the thresholds across multiple variant quality parameters

After obtaining the true positive and false positive set, users can use the Rscript provided to plot the diagnostic plots to determine threshold.

Refer to https://github.com/JoannaTan/SoVaTSiC/wiki/4.-Genotype-QC for a step-by-step guide on how to perform this part.

3. filtergenotypes 

The following is done when this function is chosen:
- remove low quality genotypes based on user defined threshold
- remove germline mutations based on SoVaTSiC's germliner filters

Refer to https://github.com/JoannaTan/SoVaTSiC/wiki/5.-Identifying-Somatic-Variations for guide













 



