# SoVatSC

A pipeline to perform quality evaluation and identify somatic variants for single cell DNA sequencing. 

The pipeline is written in Perl and R.

## R packages required
1. Mixtools
2. MASS

## The pipeline consist of three parts:
1) Quality control of single cells data
2) Identification of threshold for filtering of low quality genotypes
3) Identification of somatic variants from single cell data

The pipeline takes in variant calls from GATK.

## Perform quality control of single cells data

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



