# SoVatSC

A pipeline to perform quality evaluation and identify somatic variants for single cell DNA sequencing. 

The pipeline is written in Perl and R.

##R packages required
1. Mixtools
2. MASS

##The pipeline consist of three parts:
1) Quality control of single cells data
2) Identification of threshold for filtering of low quality genotypes
3) Identification of somatic variants from single cell data

The pipeline takes in variant calls from GATK.

###STEP 1: Perform quality control of single cells data










To convert your VCFs to the required input file format, use GATK VariantsToTable function. 
We have tested the below command using GATK v3.5 and v3.7

java -jar GenomeAnalysisTK.jar -T VariantsToTable -R ReferenceGenomeFile -V input.vcf -F CHROM -F POS -F ID -F REF -F ALT -F QUAL -F AC -F FILTER -F VQSLOD -F EVENTLENGTH -F TRANSITION -F HET -F HOM-REF -F HOM-VAR -F NO-CALL -F TYPE -F NCALLED -F MQ -F GQ_MEAN -F GQ_STDDEV -F QD -F HWP -F NEGATIVE_TRAIN_SITE -F POSITIVE_TRAIN_SITE -GF GT -GF AD -GF DP -GF GQ -GF PL --allowMissingData -o output.table



