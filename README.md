# SoVatSC

A pipeline to perform quality evaluation and identify somatic variants for single cell DNA sequencing. 

The pipeline is written in Perl and R.

## R packages and software required
1. Mixtools (R package)
2. MASS (R package)
3. Samtools
4. GATK

## The pipeline consist of three parts:
1) Quality control of single cells data
2) Identification of threshold for filtering of low quality genotypes
3) Identification of somatic variants from single cell data

## Running GATK to generate the input files required by the pipeline

The pipeline takes in variant calls from GATK.

After processing the bam files for each single cell, we identify variants using GATK haplotypecaller. 

**Step 1: Call variants individually for each single cell using haplotypecaller to get a gVCF per cell.**

java -jar GenomeAnalysisTK.jar -R ReferenceGenomeFile -T HaplotypeCaller -I Singlecell_1.bam -mbq 20 -mmq 40 -L targetinterval.bed --emitRefConfidence GVCF --dbsnp dbsnp_138.b37.vcf -o singlecell_1.g.vcf

**Step 2: Perform jointgenotyping using the gvcfs obtained from all cells**

java -jar GenomeAnalysisTK.jar -R ReferenceGenomeFile -T GenotypeGVCFs --variant singlecell_1.g.vcf --variant singlecell_2.g.vcf --variant singlecell_3.g.vcf --dbsnp dbsnp_138.b37.vcf -o ALL_singlecells_jointgenotype.vcf

**Step 3: Perform GATK variant recalibration**

Refer to https://gatkforums.broadinstitute.org/gatk/discussion/2805/howto-recalibrate-variant-quality-scores-run-vqsr
or https://software.broadinstitute.org/gatk/documentation/article.php?id=1259

For SNVs, the annotations used for recalibration training include:
  1. variant quality score by read depth (QD) 
  2. strand bias (FS)
  3. mapping quality rank sum score (MQRankSum) 
  4. read position rank sum score (ReadPosRankSum)
  5. mapping quality (MQ)
   
For INDELS, the annotations used for recalibration training include: 
  1. variant quality score by read depth (QD)
  2. strand bias (FS)
  3. mapping quality rank sum score (MQRankSum)
  4. read position rank sum score (ReadPosRankSum) 

To convert your VCFs to the required input file format, use GATK VariantsToTable function. 
We have tested the command below using GATK v3.5 and v3.7

java -jar GenomeAnalysisTK.jar -T VariantsToTable -R ReferenceGenomeFile -V input.vcf -F CHROM -F POS -F ID -F REF -F ALT -F QUAL -F AC -F FILTER -F VQSLOD -F EVENTLENGTH -F TRANSITION -F HET -F HOM-REF -F HOM-VAR -F NO-CALL -F TYPE -F NCALLED -F MQ -F GQ_MEAN -F GQ_STDDEV -F QD -F HWP -F NEGATIVE_TRAIN_SITE -F POSITIVE_TRAIN_SITE -GF GT -GF AD -GF DP -GF GQ -GF PL --allowMissingData -o output.table

## PART 1: To perform quality control of single cell data

Step 1. Generate the flagstat file. This file consist of the mapping statistics, percentage of genome covered information and read depth information which can be obtained from GATK DepthofCoverage Tool.

*To generate the flagstat file*

To get the mapping statistics, run **samtools flagstat**

samtools flagstat singlecell_1.bam >> singlecell_1.flagstat

To get the percentage of genome covered and read depth information, run **GATK DEPTHofCoverage**

java -jar GenomeAnalysisTK.jar -R ReferenceGenomeFile -T DepthOfCoverage -o singlecell_1_depthofcoveage.afterrecal -I singlecell_1.bam -L targetinterval.bed -mmq 20

For our experiments, we used reads with mapping quality >= 20.

To combine the flagstat information, read depth and the percentage of genome covered information, a perl script is provided.

Before you run the perl script, make sure you prepare a **tab-delimited** file containing 
SampleName(tab)path_to_flagstat_file(tab)path_to_sample_cumulative_coverage_proportions_file(tab)path_to_sample_summary_file

One line per cell.

Lastly, run the command below
perl combine_flagstat_information.pl --inputfile.txt --o outfile.txt

This will give you the flagstat file that will be taken in by the pipeline.

Step 2. Identify variants from BULK sequencing files using GATK haplotypecaller

This step will identify SNVs and INDELs from BULK sequencing and generate VCF files which will be used by the pipeline.

The Bulk VCF files will be used to determine
1) The heterozygous sites for ADO and FN calculation
2) The true positive and false positive sites for identification of threshold for filtering low quality genotypes.

To get the variants, run

java -jar GenomeAnalysisTK.jar -R ReferenceGenomeFile -T HaplotypeCaller -I bulk_normal.bam -L targetinterval.bed --dbsnp dbsnp_138.b37.vcf --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -o bulk_normal_variants.vcf

We follow the recommedations of GATK (https://gatkforums.broadinstitute.org/gatk/discussion/2803/howto-call-variants-with-haplotypecaller)

**Repeat the same for the bulk tumour files.**

For the filtering of variant sites, we used the hard filters recommended by GATK
(https://gatkforums.broadinstitute.org/gatk/discussion/2806/howto-apply-hard-filters-to-a-call-set).

In addition, we removed variants in the bulk tumour or normal if they have GQ (Genotype Quality) < 30 and DP (Read Depth) < 8.
This step is optional. We have tested using variants with and without removing variants with low GQ and DP, and the results were the same.

3. A **tab-delimited** file containing all the names of the cells, the type of cell, and information if it is a single cell or bulk.

4. A config file that contain information of where all the files are. An example config file (cellqc_config.txt) is given.
The information required include
- Path to the bulk vcf files. VCF from each bulk should be separated by a comma (,). 
- Path to the single cell file generated after running GATK VariantsToTable
- Path to the file containing the samplenames information
- Path to the flagstat file 
- Name of the output file
- Read depth to filter (We used sites that were covered by at least 5 reads for the calculation of ADO and FN in single cells)
- Genotype quality to filter 
- Variant allele frequency to filter 

5. To run the single cell QC pipeline, simply type
perl  singlecellpipeline.pl --Config cellqc_config.txt --Analysistype CellQC












 



