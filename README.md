# SoVatSC

A pipeline to perform quality evaluation and identify somatic variants for single cell DNA sequencing. 

The pipeline is written in Perl and R.

R packages required
1. Mixtools
2. MASS

The pipeline consist of three parts:
1) Quality control of single cells data
2) Identification of threshold for filtering of low quality genotypes
3) Identification of somatic variants from single cell data

The pipeline takes in variant calls from GATK.
To convert your VCFs to the required input file format, use GATK variantToTable function. 
